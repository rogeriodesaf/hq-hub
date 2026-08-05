#!/usr/bin/env python3
"""Ponte local entre o HQ-HUB e o coletor interativo do Guia dos Quadrinhos.

O servidor escuta exclusivamente em 127.0.0.1. O navegador do HQ-HUB cria uma
coleta, acompanha o processo e recebe o JSON gerado pelo coletor que abre o
Chrome visível para a verificação humana.
"""

import argparse
import json
import os
import re
import secrets
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import webbrowser
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


VERSAO = "1.0.0"
TAMANHO_MAXIMO_REQUISICAO = 64 * 1024
ORIGENS_PERMITIDAS = {
    "https://hqhub-frontend.onrender.com",
    "http://localhost:4200",
    "http://127.0.0.1:4200",
}
COLETOR = Path(__file__).with_name("robo_importador_navegador_interativo.py")

trava = threading.Lock()
coletas = {}


def agora_iso():
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def origem_permitida(origem):
    if not origem:
        return True
    if origem in ORIGENS_PERMITIDAS:
        return True
    try:
        url = urlparse(origem)
        return url.scheme == "http" and url.hostname in {"localhost", "127.0.0.1"}
    except ValueError:
        return False


def validar_entrada(dados):
    url = str(dados.get("urlGuia") or "").strip()
    titulo = str(dados.get("tituloSerie") or "").strip()
    editora = str(dados.get("editora") or "").strip()
    try:
        endereco = urlparse(url)
    except ValueError as erro:
        raise ValueError("A URL do Guia é inválida.") from erro
    host = (endereco.hostname or "").lower()
    if endereco.scheme not in {"http", "https"} or not (
        host == "guiadosquadrinhos.com" or host.endswith(".guiadosquadrinhos.com")
    ) or "/edicao/" not in endereco.path.lower():
        raise ValueError("Informe uma URL /edicao/ válida do Guia dos Quadrinhos.")
    if not titulo:
        raise ValueError("Informe o título da série.")
    if not editora:
        raise ValueError("Informe a editora.")

    def inteiro(nome, padrao, minimo, maximo):
        valor = dados.get(nome)
        if valor in (None, ""):
            return padrao
        try:
            numero = int(valor)
        except (TypeError, ValueError) as erro:
            raise ValueError(f"O campo {nome} deve ser um número inteiro.") from erro
        if numero < minimo or numero > maximo:
            raise ValueError(f"O campo {nome} deve ficar entre {minimo} e {maximo}.")
        return numero

    return {
        "urlGuia": url,
        "tituloSerie": titulo,
        "fase": str(dados.get("fase") or "").strip(),
        "editora": editora,
        "volume": inteiro("volume", 1, 1, 999),
        "quantidade": inteiro("quantidade", None, 1, 200),
    }


def resumo_coleta(coleta, incluir_resultado=True):
    campos = {
        "id": coleta["id"],
        "status": coleta["status"],
        "mensagem": coleta["mensagem"],
        "paginasProcessadas": coleta["paginasProcessadas"],
        "totalPaginas": coleta["totalPaginas"],
        "avisos": list(coleta["avisos"]),
        "logs": list(coleta["logs"][-30:]),
        "criadaEm": coleta["criadaEm"],
        "atualizadaEm": coleta["atualizadaEm"],
        "resultado": coleta.get("resultado") if incluir_resultado else None,
    }
    return campos


def atualizar_por_log(coleta, linha):
    linha = linha.strip()
    if not linha:
        return
    with trava:
        coleta["logs"].append(linha)
        coleta["logs"] = coleta["logs"][-100:]
        coleta["atualizadaEm"] = agora_iso()
        encontrado = re.search(r"Processando\s+(\d+)/(\d+)", linha, re.IGNORECASE)
        if encontrado:
            coleta["paginasProcessadas"] = max(0, int(encontrado.group(1)) - 1)
            coleta["totalPaginas"] = int(encontrado.group(2))
            coleta["mensagem"] = f"Coletando edição {encontrado.group(1)} de {encontrado.group(2)} no Chrome..."
        elif "Aguardando a página do Guia" in linha:
            coleta["mensagem"] = "Aguardando você concluir a verificação 'Não sou um robô' no Chrome..."
        elif "Pausa automática entre lotes:" in linha:
            coleta["mensagem"] = linha
        elif "Arquivo gerado:" in linha:
            coleta["mensagem"] = "JSON gerado. Preparando a devolução ao HQ-HUB..."


def executar_coleta(coleta, entrada):
    pasta = Path(tempfile.mkdtemp(prefix="hqhub-assistente-local-"))
    saida = pasta / "resultado.json"
    comando = [
        sys.executable,
        "-u",
        str(COLETOR),
        "--url",
        entrada["urlGuia"],
        "--saida",
        str(saida),
        "--titulo-serie",
        entrada["tituloSerie"],
        "--editora",
        entrada["editora"],
        "--volume",
        str(entrada["volume"]),
        "--tempo-verificacao",
        "600",
    ]
    if entrada["fase"]:
        comando.extend(["--fase", entrada["fase"]])
    if entrada["quantidade"]:
        comando.extend(["--maximo-edicoes", str(entrada["quantidade"])])

    try:
        with trava:
            coleta["status"] = "COLETANDO"
            coleta["mensagem"] = "Abrindo o Chrome para a verificação do Guia..."
            coleta["atualizadaEm"] = agora_iso()

        opcoes = {
            "stdout": subprocess.PIPE,
            "stderr": subprocess.STDOUT,
            "text": True,
            "encoding": "utf-8",
            "errors": "replace",
            "bufsize": 1,
        }
        if os.name == "nt":
            opcoes["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
        else:
            opcoes["start_new_session"] = True
        processo = subprocess.Popen(comando, **opcoes)
        with trava:
            coleta["processo"] = processo

        for linha in processo.stdout or []:
            atualizar_por_log(coleta, linha)
        codigo = processo.wait()

        with trava:
            cancelada = coleta["status"] == "CANCELADA"
        if cancelada:
            return
        if codigo != 0:
            raise RuntimeError(
                coleta["logs"][-1] if coleta["logs"] else f"O coletor encerrou com o código {codigo}."
            )
        if not saida.exists():
            raise RuntimeError("O coletor terminou sem gerar o arquivo JSON.")
        resultado = json.loads(saida.read_text(encoding="utf-8"))
        with trava:
            coleta["resultado"] = resultado
            coleta["paginasProcessadas"] = int(resultado.get("totalEdicoes") or 0)
            coleta["totalPaginas"] = max(coleta["totalPaginas"], coleta["paginasProcessadas"])
            coleta["avisos"] = list(resultado.get("avisos") or [])
            coleta["status"] = "CONCLUIDA"
            coleta["mensagem"] = "JSON recebido do Chrome e pronto para revisão no HQ-HUB."
            coleta["atualizadaEm"] = agora_iso()
    except Exception as erro:
        with trava:
            if coleta["status"] != "CANCELADA":
                coleta["status"] = "ERRO"
                coleta["mensagem"] = str(erro)
                coleta["atualizadaEm"] = agora_iso()
    finally:
        with trava:
            coleta["processo"] = None
        shutil.rmtree(pasta, ignore_errors=True)


def encerrar_processo(processo):
    if not processo or processo.poll() is not None:
        return
    if os.name == "nt":
        subprocess.run(
            ["taskkill", "/PID", str(processo.pid), "/T", "/F"],
            capture_output=True,
            check=False,
        )
    else:
        os.killpg(os.getpgid(processo.pid), signal.SIGTERM)


class RequisicaoAssistente(BaseHTTPRequestHandler):
    server_version = f"HQHUBAssistente/{VERSAO}"

    def log_message(self, formato, *args):
        print(f"[{self.log_date_time_string()}] {formato % args}")

    def cabecalhos_cors(self):
        origem = self.headers.get("Origin")
        if origem and origem_permitida(origem):
            self.send_header("Access-Control-Allow-Origin", origem)
            self.send_header("Vary", "Origin")
        self.send_header("Access-Control-Allow-Private-Network", "true")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
        self.send_header("Cache-Control", "no-store")

    def responder(self, status, corpo):
        conteudo = json.dumps(corpo, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.cabecalhos_cors()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(conteudo)))
        self.end_headers()
        self.wfile.write(conteudo)

    def autorizar_origem(self):
        if origem_permitida(self.headers.get("Origin")):
            return True
        self.responder(403, {"mensagem": "Origem não autorizada a usar o assistente local."})
        return False

    def do_OPTIONS(self):
        if not self.autorizar_origem():
            return
        self.send_response(204)
        self.cabecalhos_cors()
        self.end_headers()

    def do_GET(self):
        if not self.autorizar_origem():
            return
        if self.path.rstrip("/") == "/health":
            self.responder(200, {"online": True, "versao": VERSAO})
            return
        encontrado = re.fullmatch(r"/coletas/([a-f0-9]+)", self.path)
        if encontrado:
            with trava:
                coleta = coletas.get(encontrado.group(1))
                corpo = resumo_coleta(coleta) if coleta else None
            if not corpo:
                self.responder(404, {"mensagem": "Coleta local não encontrada."})
            else:
                self.responder(200, corpo)
            return
        self.responder(404, {"mensagem": "Rota local não encontrada."})

    def do_POST(self):
        if not self.autorizar_origem():
            return
        if self.path.rstrip("/") != "/coletas":
            self.responder(404, {"mensagem": "Rota local não encontrada."})
            return
        try:
            tamanho = int(self.headers.get("Content-Length") or 0)
            if tamanho <= 0 or tamanho > TAMANHO_MAXIMO_REQUISICAO:
                raise ValueError("A requisição local está vazia ou é grande demais.")
            entrada = validar_entrada(json.loads(self.rfile.read(tamanho).decode("utf-8")))
            with trava:
                ativa = next(
                    (item for item in coletas.values() if item["status"] in {"INICIANDO", "COLETANDO"}),
                    None,
                )
                if ativa:
                    self.responder(409, {
                        "mensagem": "Já existe uma coleta local em andamento.",
                        "coleta": resumo_coleta(ativa, incluir_resultado=False),
                    })
                    return
                identificador = secrets.token_hex(12)
                coleta = {
                    "id": identificador,
                    "status": "INICIANDO",
                    "mensagem": "Preparando o Chrome...",
                    "paginasProcessadas": 0,
                    "totalPaginas": entrada["quantidade"] or 0,
                    "avisos": [],
                    "logs": [],
                    "resultado": None,
                    "processo": None,
                    "criadaEm": agora_iso(),
                    "atualizadaEm": agora_iso(),
                }
                coletas[identificador] = coleta
            threading.Thread(target=executar_coleta, args=(coleta, entrada), daemon=True).start()
            self.responder(202, resumo_coleta(coleta, incluir_resultado=False))
        except (ValueError, json.JSONDecodeError) as erro:
            self.responder(400, {"mensagem": str(erro)})
        except Exception as erro:
            self.responder(500, {"mensagem": f"Falha ao iniciar a coleta local: {erro}"})

    def do_DELETE(self):
        if not self.autorizar_origem():
            return
        encontrado = re.fullmatch(r"/coletas/([a-f0-9]+)", self.path)
        if not encontrado:
            self.responder(404, {"mensagem": "Rota local não encontrada."})
            return
        with trava:
            coleta = coletas.get(encontrado.group(1))
            if not coleta:
                self.responder(404, {"mensagem": "Coleta local não encontrada."})
                return
            coleta["status"] = "CANCELADA"
            coleta["mensagem"] = "Coleta local cancelada pelo usuário."
            coleta["atualizadaEm"] = agora_iso()
            processo = coleta.get("processo")
        encerrar_processo(processo)
        with trava:
            corpo = resumo_coleta(coleta, incluir_resultado=False)
        self.responder(200, corpo)


def main():
    parser = argparse.ArgumentParser(description="Assistente local do HQ-HUB para o Guia dos Quadrinhos.")
    parser.add_argument("--porta", type=int, default=8765)
    parser.add_argument("--abrir-hqhub", action="store_true")
    args = parser.parse_args()
    if not COLETOR.exists():
        parser.error(f"Coletor interativo não encontrado: {COLETOR}")
    if args.porta < 1024 or args.porta > 65535:
        parser.error("--porta deve ficar entre 1024 e 65535.")

    servidor = ThreadingHTTPServer(("127.0.0.1", args.porta), RequisicaoAssistente)
    print("=" * 68)
    print(f"Assistente local do HQ-HUB {VERSAO}")
    print(f"Escutando somente neste computador: http://127.0.0.1:{args.porta}")
    print("Mantenha esta janela aberta durante a coleta. Pressione Ctrl+C para sair.")
    print("=" * 68)
    if args.abrir_hqhub:
        threading.Timer(
            1.0,
            lambda: webbrowser.open("https://hqhub-frontend.onrender.com/importacao?assistenteLocal=1"),
        ).start()
    try:
        servidor.serve_forever()
    except KeyboardInterrupt:
        print("\nEncerrando o assistente local...")
    finally:
        with trava:
            processos = [item.get("processo") for item in coletas.values()]
        for processo in processos:
            encerrar_processo(processo)
        servidor.server_close()


if __name__ == "__main__":
    main()
