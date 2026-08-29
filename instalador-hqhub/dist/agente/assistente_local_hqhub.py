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


VERSAO = "1.3.0"
MAXIMO_ROBOS_TELEGRAM = 2
TAMANHO_MAXIMO_REQUISICAO = 64 * 1024
ORIGENS_PERMITIDAS = {
    "https://hqhub-frontend.onrender.com",
    "http://localhost:4200",
    "http://127.0.0.1:4200",
}
COLETOR = Path(__file__).with_name("robo_importador_navegador_interativo.py")
COLETOR_CAPAS_AUTOMATICAS = Path(__file__).with_name("robo_enriquecer_capas_multiplas_fontes.py")
COLETOR_CAPAS_TELEGRAM = Path(__file__).with_name("robo_enriquecer_capa_telegram.py")
COLETOR_CAPAS_PANINI = Path(__file__).with_name("robo_atualizar_capas_panini_catalogo.py")

trava = threading.Lock()
coletas = {}
coletas_capas_telegram = {}


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
    rota_edicao = endereco.path.lower()
    if endereco.scheme not in {"http", "https"} or not (
        host == "guiadosquadrinhos.com" or host.endswith(".guiadosquadrinhos.com")
    ) or not any(
        trecho in rota_edicao for trecho in ("/edicao/", "/edicao-estrangeira/")
    ):
        raise ValueError(
            "Informe uma URL /edicao/ ou /edicao-estrangeira/ válida do Guia dos Quadrinhos."
        )
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


def validar_entrada_capas_telegram(dados):
    def inteiro(nome, padrao, minimo, maximo):
        valor = dados.get(nome)
        if valor in (None, ""):
            return padrao
        try:
            numero = int(valor)
        except (TypeError, ValueError) as erro:
            raise ValueError(f"O campo {nome} deve ser um numero inteiro.") from erro
        if numero < minimo or numero > maximo:
            raise ValueError(f"O campo {nome} deve ficar entre {minimo} e {maximo}.")
        return numero

    serie_id = inteiro("serieId", None, 1, 2_147_483_647)
    inicial = inteiro("numeroInicial", 1, 1, 9999)
    final = inteiro("numeroFinal", None, inicial, 9999)
    consulta = str(dados.get("consulta") or "").strip()
    nome_inicia_numero = bool(dados.get("nomeIniciaNumero"))
    grupo = str(dados.get("grupo") or "@zagorbr").strip()
    origem = str(dados.get("origem") or "telegram").strip().lower()
    url_panini = str(dados.get("urlPaniniInicial") or "").strip()
    token = str(dados.get("tokenHqhub") or "").strip()
    backend = str(dados.get("backendUrl") or "https://hqhub-backend.onrender.com").strip()
    if origem == "panini":
        endereco_panini = urlparse(url_panini)
        if endereco_panini.scheme != "https" or (endereco_panini.hostname or "").lower() not in {
            "panini.com.br", "www.panini.com.br"
        } or not re.search(r"-\d+/?$", endereco_panini.path):
            raise ValueError("Informe uma URL da Panini terminada pelo numero da primeira edicao.")
    else:
        if not consulta and not nome_inicia_numero:
            raise ValueError("Informe o prefixo dos arquivos no Telegram.")
        if not re.fullmatch(r"@[A-Za-z0-9_]{5,}", grupo):
            raise ValueError("Informe um grupo publico no formato @nome_do_grupo.")
    if not token:
        raise ValueError("A sessao do HQ-HUB nao esta disponivel.")
    host = (urlparse(backend).hostname or "").lower()
    if host not in {"hqhub-backend.onrender.com", "localhost", "127.0.0.1"}:
        raise ValueError("Backend HQ-HUB nao autorizado pelo assistente local.")
    return {
        "serieId": serie_id,
        "numeroInicial": inicial,
        "numeroFinal": final,
        "consulta": consulta,
        "nomeIniciaNumero": nome_inicia_numero,
        "grupo": grupo,
        "tokenHqhub": token,
        "backendUrl": backend,
        "origem": origem,
        "urlPaniniInicial": url_panini,
        "removerForaIntervalo": bool(dados.get("removerForaIntervalo")),
    }


def resumo_capas_telegram(coleta):
    return {
        "id": coleta["id"],
        "robo": coleta["robo"],
        "origem": coleta.get("origem", "telegram"),
        "status": coleta["status"],
        "mensagem": coleta["mensagem"],
        "edicoesProcessadas": coleta["edicoesProcessadas"],
        "totalEdicoes": coleta["totalEdicoes"],
        "sucessos": coleta["sucessos"],
        "falhas": coleta["falhas"],
        "avisos": list(coleta["avisos"]),
        "logs": list(coleta["logs"][-50:]),
        "criadaEm": coleta["criadaEm"],
        "atualizadaEm": coleta["atualizadaEm"],
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
        # Enriquece o resultado antes de devolvê-lo ao HQ-HUB. O arquivo é
        # temporário e continua sendo removido ao final desta função.
        saida_com_capas = pasta / "resultado-com-capas.json"
        with trava:
            coleta["mensagem"] = "JSON gerado. Procurando capas em fontes públicas..."
            coleta["logs"].append("Iniciando busca automática de capas em Panini, Rika, Comix e Amazon.")
        enriquecimento = subprocess.Popen(
            [sys.executable, "-u", str(COLETOR_CAPAS_AUTOMATICAS),
             "--entrada", str(saida), "--saida", str(saida_com_capas)],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, encoding="utf-8", errors="replace", bufsize=1,
        )
        for linha in enriquecimento.stdout or []:
            linha = linha.rstrip()
            if linha:
                atualizar_por_log(coleta, linha)
        enriquecimento.wait(timeout=900)
        if enriquecimento.returncode == 0 and saida_com_capas.exists():
            resultado = json.loads(saida_com_capas.read_text(encoding="utf-8"))
            with trava:
                coleta["logs"].append("Busca automática de capas concluída.")
        else:
            resultado = json.loads(saida.read_text(encoding="utf-8"))
            with trava:
                coleta["logs"].append("Busca automática de capas falhou; JSON original preservado.")
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


def atualizar_por_log_telegram(coleta, linha):
    linha = linha.strip()
    if not linha:
        return
    with trava:
        coleta["logs"].append(linha)
        coleta["logs"] = coleta["logs"][-150:]
        coleta["atualizadaEm"] = agora_iso()
        edicao = re.search(r"=== Edicao\s+(\d+)/(\d+):\s+numero\s+([^ ]+)", linha)
        preparacao = re.search(r"(\d+) edicao\(oes\) para processar", linha)
        if preparacao:
            coleta["totalEdicoes"] = int(preparacao.group(1))
        if edicao:
            coleta["totalEdicoes"] = int(edicao.group(2))
            coleta["mensagem"] = f"Processando edicao {edicao.group(1)} de {edicao.group(2)} (numero {edicao.group(3)})."
        elif linha.startswith("[OK]"):
            coleta["sucessos"] += 1
            coleta["edicoesProcessadas"] += 1
        elif linha.startswith("[FALHA]"):
            coleta["falhas"] += 1
            coleta["edicoesProcessadas"] += 1
            coleta["avisos"].append(linha.removeprefix("[FALHA]").strip())


def executar_capas_telegram(coleta, entrada):
    if entrada.get("origem") == "panini":
        comando = [
            sys.executable, "-u", str(COLETOR_CAPAS_PANINI),
            "--serie-id", str(entrada["serieId"]),
            "--url-inicial", entrada["urlPaniniInicial"],
            "--numero-inicial", str(entrada["numeroInicial"]),
            "--numero-final", str(entrada["numeroFinal"]),
            "--backend-url", entrada["backendUrl"],
        ]
        if entrada.get("removerForaIntervalo"):
            comando.append("--remover-fora-intervalo")
    else:
        comando = [
            sys.executable, "-u", str(COLETOR_CAPAS_TELEGRAM),
            "--consulta", entrada["consulta"],
            "--serie-id", str(entrada["serieId"]),
            "--numero-inicial", str(entrada["numeroInicial"]),
            "--grupo", entrada["grupo"],
            "--backend-url", entrada["backendUrl"],
            "--sessao", str(Path.home() / ".telegram" / ("hqhub" if coleta["robo"] == 1 else "hqhub-worker-2")),
        ]
    if entrada.get("origem") != "panini" and entrada["nomeIniciaNumero"]:
        comando.extend(["--nome-inicia-numero", "--digitos-numero", "3"])
    if entrada.get("origem") != "panini" and entrada["numeroFinal"] is not None:
        comando.extend(["--numero-final", str(entrada["numeroFinal"])])
    ambiente = os.environ.copy()
    ambiente["HQHUB_API_TOKEN"] = entrada["tokenHqhub"]
    try:
        with trava:
            coleta["status"] = "COLETANDO"
            coleta["mensagem"] = "Consultando a Panini..." if entrada.get("origem") == "panini" else "Conectando ao Telegram..."
            coleta["atualizadaEm"] = agora_iso()
        opcoes = {
            "stdout": subprocess.PIPE, "stderr": subprocess.STDOUT,
            "text": True, "encoding": "utf-8", "errors": "replace",
            "bufsize": 1, "env": ambiente,
        }
        if os.name == "nt":
            opcoes["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
        else:
            opcoes["start_new_session"] = True
        processo = subprocess.Popen(comando, **opcoes)
        with trava:
            coleta["processo"] = processo
        for linha in processo.stdout or []:
            atualizar_por_log_telegram(coleta, linha)
        codigo = processo.wait()
        with trava:
            if coleta["status"] == "CANCELADA":
                return
            if codigo != 0:
                raise RuntimeError(coleta["logs"][-1] if coleta["logs"] else f"O robo encerrou com codigo {codigo}.")
            coleta["status"] = "CONCLUIDA"
            coleta["mensagem"] = f"Capas concluidas: {coleta['sucessos']} sucesso(s) e {coleta['falhas']} falha(s)."
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
        encontrado = re.fullmatch(r"/capas-telegram/([a-f0-9]+)", self.path)
        if encontrado:
            with trava:
                coleta = coletas_capas_telegram.get(encontrado.group(1))
                corpo = resumo_capas_telegram(coleta) if coleta else None
            if not corpo:
                self.responder(404, {"mensagem": "Tarefa de capas nao encontrada."})
            else:
                self.responder(200, corpo)
            return
        self.responder(404, {"mensagem": "Rota local não encontrada."})

    def do_POST(self):
        if not self.autorizar_origem():
            return
        rota = self.path.rstrip("/")
        if rota not in {"/coletas", "/capas-telegram"}:
            self.responder(404, {"mensagem": "Rota local não encontrada."})
            return
        try:
            tamanho = int(self.headers.get("Content-Length") or 0)
            if tamanho <= 0 or tamanho > TAMANHO_MAXIMO_REQUISICAO:
                raise ValueError("A requisição local está vazia ou é grande demais.")
            dados = json.loads(self.rfile.read(tamanho).decode("utf-8"))
            entrada = validar_entrada(dados) if rota == "/coletas" else validar_entrada_capas_telegram(dados)
            with trava:
                coletas_guia_ativas = [
                    item for item in coletas.values() if item["status"] in {"INICIANDO", "COLETANDO"}
                ]
                capas_ativas = [
                    item for item in coletas_capas_telegram.values()
                    if item["status"] in {"INICIANDO", "COLETANDO"}
                ]
                if rota == "/coletas" and (coletas_guia_ativas or capas_ativas):
                    self.responder(409, {"mensagem": "Existe um trabalho local em andamento. Aguarde ou interrompa-o."})
                    return
                if rota == "/capas-telegram":
                    if coletas_guia_ativas:
                        self.responder(409, {"mensagem": "A coleta do Guia está usando o assistente. Aguarde ou interrompa-a."})
                        return
                    if len(capas_ativas) >= MAXIMO_ROBOS_TELEGRAM:
                        self.responder(409, {"mensagem": "Os dois robôs de capas já estão trabalhando."})
                        return
                    novo_final = entrada["numeroFinal"] if entrada["numeroFinal"] is not None else 9999
                    sobreposta = next((
                        item for item in capas_ativas
                        if item["serieId"] == entrada["serieId"]
                        and entrada["numeroInicial"] <= item["numeroFinalComparacao"]
                        and novo_final >= item["numeroInicial"]
                    ), None)
                    if sobreposta:
                        self.responder(409, {
                            "mensagem": (
                                f"O intervalo informado coincide com o Robô {sobreposta['robo']} "
                                f"({sobreposta['numeroInicial']}–{sobreposta['numeroFinalComparacao']})."
                            )
                        })
                        return
                    robos_ocupados = {item["robo"] for item in capas_ativas}
                    robo = next(numero for numero in range(1, MAXIMO_ROBOS_TELEGRAM + 1) if numero not in robos_ocupados)
                identificador = secrets.token_hex(12)
                coleta = {
                    "id": identificador,
                    "status": "INICIANDO",
                    "mensagem": "Preparando o Chrome...",
                    "paginasProcessadas": 0,
                    "totalPaginas": (entrada.get("quantidade") or 0),
                    "avisos": [],
                    "logs": [],
                    "resultado": None,
                    "processo": None,
                    "criadaEm": agora_iso(),
                    "atualizadaEm": agora_iso(),
                }
                if rota == "/capas-telegram":
                    coleta.update({
                        "robo": robo,
                        "origem": entrada.get("origem", "telegram"),
                        "serieId": entrada["serieId"],
                        "numeroInicial": entrada["numeroInicial"],
                        "numeroFinalComparacao": entrada["numeroFinal"] if entrada["numeroFinal"] is not None else 9999,
                        "edicoesProcessadas": 0,
                        "totalEdicoes": 0,
                        "sucessos": 0,
                        "falhas": 0,
                    })
                    coletas_capas_telegram[identificador] = coleta
                    alvo = executar_capas_telegram
                    resumo = resumo_capas_telegram
                else:
                    coletas[identificador] = coleta
                    alvo = executar_coleta
                    resumo = lambda item: resumo_coleta(item, incluir_resultado=False)
            threading.Thread(target=alvo, args=(coleta, entrada), daemon=True).start()
            self.responder(202, resumo(coleta))
        except (ValueError, json.JSONDecodeError) as erro:
            self.responder(400, {"mensagem": str(erro)})
        except Exception as erro:
            self.responder(500, {"mensagem": f"Falha ao iniciar a coleta local: {erro}"})

    def do_DELETE(self):
        if not self.autorizar_origem():
            return
        encontrado = re.fullmatch(r"/(coletas|capas-telegram)/([a-f0-9]+)", self.path)
        if not encontrado:
            self.responder(404, {"mensagem": "Rota local não encontrada."})
            return
        with trava:
            colecao = coletas if encontrado.group(1) == "coletas" else coletas_capas_telegram
            coleta = colecao.get(encontrado.group(2))
            if not coleta:
                self.responder(404, {"mensagem": "Coleta local não encontrada."})
                return
            coleta["status"] = "CANCELADA"
            coleta["mensagem"] = "Coleta local cancelada pelo usuário."
            coleta["atualizadaEm"] = agora_iso()
            processo = coleta.get("processo")
        encerrar_processo(processo)
        with trava:
            corpo = (resumo_coleta(coleta, incluir_resultado=False)
                     if encontrado.group(1) == "coletas" else resumo_capas_telegram(coleta))
        self.responder(200, corpo)


def main():
    parser = argparse.ArgumentParser(description="Assistente local do HQ-HUB para o Guia dos Quadrinhos.")
    parser.add_argument("--porta", type=int, default=8765)
    parser.add_argument("--abrir-hqhub", action="store_true")
    args = parser.parse_args()
    if not COLETOR.exists():
        parser.error(f"Coletor interativo não encontrado: {COLETOR}")
    if not COLETOR_CAPAS_TELEGRAM.exists():
        parser.error(f"Coletor de capas do Telegram não encontrado: {COLETOR_CAPAS_TELEGRAM}")
    if not COLETOR_CAPAS_PANINI.exists():
        parser.error(f"Coletor de capas da Panini nao encontrado: {COLETOR_CAPAS_PANINI}")
    if args.porta < 1024 or args.porta > 65535:
        parser.error("--porta deve ficar entre 1024 e 65535.")

    pasta_sessoes = Path.home() / ".telegram"
    sessao_principal = pasta_sessoes / "hqhub.session"
    sessao_segundo_robo = pasta_sessoes / "hqhub-worker-2.session"
    if sessao_principal.exists() and not sessao_segundo_robo.exists():
        pasta_sessoes.mkdir(parents=True, exist_ok=True)
        shutil.copy2(sessao_principal, sessao_segundo_robo)
        print("Sessão autorizada do Telegram preparada para o Robô 2.")

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
            processos.extend(item.get("processo") for item in coletas_capas_telegram.values())
        for processo in processos:
            encerrar_processo(processo)
        servidor.server_close()


if __name__ == "__main__":
    main()
