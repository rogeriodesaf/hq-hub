#!/usr/bin/env python3
"""Importa uma galeria do Guia usando uma sessão visível do Chrome.

Este modo existe para páginas protegidas por uma verificação interativa. O
usuário conclui a verificação no Chrome e o robô reutiliza a mesma sessão para
ler as páginas da galeria.
"""

import argparse
import hashlib
import importlib.util
import json
import os
import random
import re
import shutil
import socket
import subprocess
import tempfile
import time
import uuid
from datetime import datetime
from html import unescape
from pathlib import Path
from time import monotonic, sleep
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen

from playwright.sync_api import sync_playwright


TAMANHO_MAXIMO_CAPA = 15 * 1024 * 1024


def carregar_importador():
    caminho = Path(__file__).with_name("robo_importador_texto.py")
    spec = importlib.util.spec_from_file_location("robo_importador_texto", caminho)
    modulo = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(modulo)
    return modulo


def encontrar_chrome():
    candidatos = [
        Path.home() / "AppData/Local/Google/Chrome/Application/chrome.exe",
        Path("C:/Program Files/Google/Chrome/Application/chrome.exe"),
        Path("C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"),
    ]
    for caminho in candidatos:
        if caminho.exists():
            return caminho
    encontrado = shutil.which("chrome") or shutil.which("chrome.exe")
    if encontrado:
        return Path(encontrado)
    raise FileNotFoundError("Google Chrome não encontrado.")


def obter_porta_livre():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as servidor:
        servidor.bind(("127.0.0.1", 0))
        return servidor.getsockname()[1]


def conectar_chrome(playwright, porta, timeout_segundos=30):
    limite = monotonic() + timeout_segundos
    ultimo_erro = None
    while monotonic() < limite:
        try:
            return playwright.chromium.connect_over_cdp(f"http://127.0.0.1:{porta}")
        except Exception as erro:
            ultimo_erro = erro
            sleep(0.5)
    raise RuntimeError(f"Não foi possível conectar ao Chrome: {ultimo_erro}")


def configuracao_cloudinary():
    nomes = {
        "cloud_name": "CLOUDINARY_CLOUD_NAME",
        "api_key": "CLOUDINARY_API_KEY",
        "api_secret": "CLOUDINARY_API_SECRET",
    }
    valores = {chave: os.environ.get(nome, "").strip() for chave, nome in nomes.items()}
    ausentes = [nome for chave, nome in nomes.items() if not valores[chave]]
    if ausentes:
        raise ValueError(
            "Configure as variáveis do Cloudinary antes de usar "
            f"--armazenar-capas-cloudinary: {', '.join(ausentes)}"
        )
    return valores


def detectar_tipo_imagem(conteudo, tipo_informado=None):
    assinaturas = (
        (b"\xff\xd8\xff", "image/jpeg", ".jpg"),
        (b"\x89PNG\r\n\x1a\n", "image/png", ".png"),
        (b"GIF87a", "image/gif", ".gif"),
        (b"GIF89a", "image/gif", ".gif"),
    )
    for assinatura, tipo, extensao in assinaturas:
        if conteudo.startswith(assinatura):
            return tipo, extensao
    if len(conteudo) >= 12 and conteudo.startswith(b"RIFF") and conteudo[8:12] == b"WEBP":
        return "image/webp", ".webp"

    tipo = (tipo_informado or "").split(";", 1)[0].strip().lower()
    detalhe = f" (Content-Type: {tipo})" if tipo else ""
    raise ValueError(f"O conteúdo retornado pelo Guia não é uma imagem reconhecida{detalhe}.")


def extrair_url_capa_guia(importador, html, url_pagina):
    texto = importador.html_para_texto(html)
    candidatas = [
        unescape(url)
        for url in re.findall(r"https?://[^\s)]+", texto)
        if "guiadosquadrinhos.com/edicao/showimage.aspx" in url.lower()
    ]
    id_edicao = re.search(r"/(\d+)/?$", url_pagina)
    if id_edicao:
        candidatas_da_edicao = [
            url
            for url in candidatas
            if re.search(rf"[?&](?:amp;)?id={id_edicao.group(1)}(?:&|$)", url)
        ]
        if candidatas_da_edicao:
            candidatas = candidatas_da_edicao

    url = candidatas[-1] if candidatas else importador.extrair_url_capa(texto)
    if not url:
        return None
    return importador.normalizar_url_guia(urljoin(url_pagina, unescape(url)))


def baixar_capa_sessao(contexto, url_capa, url_pagina):
    resposta = contexto.request.get(
        url_capa,
        headers={"Referer": url_pagina},
        timeout=60_000,
        fail_on_status_code=False,
    )
    if not resposta.ok:
        raise RuntimeError(f"download da capa retornou HTTP {resposta.status}")

    conteudo = resposta.body()
    if not conteudo:
        raise ValueError("A capa retornada está vazia.")
    if len(conteudo) > TAMANHO_MAXIMO_CAPA:
        raise ValueError(
            f"A capa excede o limite de {TAMANHO_MAXIMO_CAPA // (1024 * 1024)} MB."
        )

    tipo, extensao = detectar_tipo_imagem(conteudo, resposta.headers.get("content-type"))
    return conteudo, tipo, extensao


def montar_multipart(campos, nome_arquivo, tipo_mime, conteudo):
    limite = f"----hqhub{uuid.uuid4().hex}"
    partes = []
    for nome, valor in campos.items():
        partes.extend(
            [
                f"--{limite}\r\n".encode(),
                f'Content-Disposition: form-data; name="{nome}"\r\n\r\n'.encode(),
                str(valor).encode(),
                b"\r\n",
            ]
        )
    partes.extend(
        [
            f"--{limite}\r\n".encode(),
            (
                'Content-Disposition: form-data; name="file"; '
                f'filename="{nome_arquivo}"\r\n'
            ).encode(),
            f"Content-Type: {tipo_mime}\r\n\r\n".encode(),
            conteudo,
            b"\r\n",
            f"--{limite}--\r\n".encode(),
        ]
    )
    return b"".join(partes), limite


def enviar_capa_cloudinary(conteudo, tipo_mime, extensao, public_id, config):
    timestamp = int(time.time())
    parametros_assinados = {
        "overwrite": "true",
        "public_id": public_id,
        "timestamp": str(timestamp),
    }
    texto_assinatura = urlencode(sorted(parametros_assinados.items()), safe="/")
    assinatura = hashlib.sha1(
        f"{texto_assinatura}{config['api_secret']}".encode()
    ).hexdigest()
    campos = {
        **parametros_assinados,
        "api_key": config["api_key"],
        "signature": assinatura,
    }
    corpo, limite = montar_multipart(
        campos,
        f"capa{extensao}",
        tipo_mime,
        conteudo,
    )
    requisicao = Request(
        f"https://api.cloudinary.com/v1_1/{config['cloud_name']}/image/upload",
        data=corpo,
        headers={"Content-Type": f"multipart/form-data; boundary={limite}"},
        method="POST",
    )
    with urlopen(requisicao, timeout=90) as resposta:
        resultado = json.loads(resposta.read().decode("utf-8"))

    url = resultado.get("secure_url")
    if not url:
        raise RuntimeError("O Cloudinary não retornou secure_url para a capa.")
    return url


def public_id_capa(importador, url_pagina):
    codigo = importador.extrair_codigo_colecao(url_pagina) or "sem-colecao"
    id_guia = re.search(r"/(\d+)/?$", url_pagina)
    identificador = id_guia.group(1) if id_guia else hashlib.sha1(
        url_pagina.encode()
    ).hexdigest()[:12]
    return f"hqhub/capas/{codigo.lower()}/{identificador}"


def esperar_pagina_liberada(pagina, timeout_segundos):
    print("Aguardando a página do Guia. Conclua a verificação na janela do Chrome, se ela aparecer.")
    limite = monotonic() + timeout_segundos
    while monotonic() < limite:
        try:
            html = pagina.content()
            if (
                "HTTP Error 403.0 - Forbidden" in html
                or "You do not have permission to view this directory or page" in html
            ):
                raise PermissionError("O Guia retornou HTTP 403.")
            if re.search(r"/edicao(?:-estrangeira)?/", html, re.IGNORECASE) and (
                "Publicado em:" in html or "Galeria de capas" in html
            ):
                return html
        except PermissionError:
            raise
        except Exception:
            pass
        sleep(1)
    raise TimeoutError(
        f"A página não foi liberada em {timeout_segundos} segundos. "
        "Execute novamente e conclua a verificação no Chrome."
    )


def abrir_edicao(pagina, url, timeout_verificacao, forcar_recarga=False):
    pagina.goto(url, wait_until="domcontentloaded", timeout=60_000)
    if forcar_recarga:
        print("Recarregando a sessão do Guia após o lote de edições.")
        pagina.reload(wait_until="domcontentloaded", timeout=60_000)

    try:
        return esperar_pagina_liberada(pagina, timeout_verificacao)
    except PermissionError:
        print("O Guia retornou 403. Recarregando a página uma vez antes de interromper.")
        pagina.wait_for_timeout(2_000)
        pagina.reload(wait_until="domcontentloaded", timeout=60_000)
        return esperar_pagina_liberada(pagina, timeout_verificacao)


def esperar_galeria_carregada(pagina, url_inicial, importador, timeout_segundos):
    """Espera os links dinâmicos da galeria estabilizarem no DOM."""
    limite = monotonic() + timeout_segundos
    melhor_html = pagina.content()
    melhores_urls = importador.extrair_links_galeria(melhor_html, url_inicial)
    repeticoes_estaveis = 0

    while monotonic() < limite:
        pagina.wait_for_timeout(1_000)
        html = pagina.content()
        urls = importador.extrair_links_galeria(html, url_inicial)

        if len(urls) > len(melhores_urls):
            melhor_html = html
            melhores_urls = urls
            repeticoes_estaveis = 0
        elif urls == melhores_urls:
            repeticoes_estaveis += 1

        if len(melhores_urls) > 1 and repeticoes_estaveis >= 2:
            break

    return melhor_html, melhores_urls


def coletar_paginas(
    pagina,
    url_inicial,
    importador,
    cloudinary,
    timeout_verificacao,
    timeout_galeria,
    intervalo,
    maximo_edicoes,
    recarregar_a_cada,
    pausa_minutos_minima,
    pausa_minutos_maxima,
):
    abrir_edicao(pagina, url_inicial, timeout_verificacao)
    html_inicial, urls = esperar_galeria_carregada(
        pagina,
        url_inicial,
        importador,
        timeout_galeria,
    )
    total_encontrado = len(urls)
    urls = importador.limitar_urls_a_partir_da_inicial(urls, url_inicial, maximo_edicoes)
    print(f"Edições encontradas na galeria: {total_encontrado}")
    if len(urls) != total_encontrado:
        print(f"Edições selecionadas pelo limite: {len(urls)}")

    textos = []
    urls_processadas = []
    capas_processadas = [] if cloudinary else None
    avisos = []
    for indice, url in enumerate(urls):
        inicio_novo_lote = bool(
            recarregar_a_cada
            and indice > 0
            and indice % recarregar_a_cada == 0
        )
        if inicio_novo_lote:
            pausa_minutos = random.uniform(pausa_minutos_minima, pausa_minutos_maxima)
            if pausa_minutos > 0:
                print(
                    "Pausa automática entre lotes: "
                    f"{pausa_minutos:.2f} minuto(s). "
                    f"A edição {indice + 1} será aberta automaticamente; não informe outra URL."
                )
                sleep(pausa_minutos * 60)
        print(f"Processando {indice + 1}/{len(urls)}: {url}")
        try:
            if url == url_inicial:
                html = html_inicial
            else:
                html = abrir_edicao(
                    pagina,
                    url,
                    timeout_verificacao,
                    forcar_recarga=inicio_novo_lote,
                )
            texto_pagina = importador.html_para_texto(html)
            url_cloudinary = None
            if cloudinary:
                url_capa = extrair_url_capa_guia(importador, html, url)
                if not url_capa:
                    avisos.append(f"Capa não encontrada na edição: {url}")
                else:
                    try:
                        conteudo, tipo_mime, extensao = baixar_capa_sessao(
                            pagina.context,
                            url_capa,
                            url,
                        )
                        url_cloudinary = enviar_capa_cloudinary(
                            conteudo,
                            tipo_mime,
                            extensao,
                            public_id_capa(importador, url),
                            cloudinary,
                        )
                        print(f"Capa armazenada: {url_cloudinary}")
                    except Exception as erro:
                        avisos.append(f"Não foi possível armazenar a capa de {url}: {erro}")
            textos.append(texto_pagina)
            urls_processadas.append(url)
            if capas_processadas is not None:
                capas_processadas.append(url_cloudinary)
        except PermissionError as erro:
            avisos.append(
                f"Importação interrompida em {url}: {erro} "
                "Aguarde antes de continuar a partir desta edição."
            )
            break
        except Exception as erro:
            avisos.append(f"Não foi possível processar {url}: {erro}")
        if indice < len(urls) - 1 and intervalo > 0:
            sleep(intervalo)

    return "\n\n".join(textos), urls_processadas, capas_processadas, avisos


def montar_resultado(importador, texto, urls_processadas, capas_processadas, avisos, args):
    blocos = importador.separar_blocos_edicoes(texto.splitlines(), args.titulo_serie)
    edicoes = []

    if not blocos:
        avisos.append(
            "Nenhuma edição foi identificada no conteúdo recebido. "
            "A página pode estar incompleta ou o formato do site pode ter mudado."
        )

    for bloco in blocos:
        edicao = importador.extrair_edicao(bloco, args.titulo_serie, args.editora)
        if not edicao["numero"]:
            avisos.append(f"Bloco ignorado sem número: {bloco[0][:80]}")
            continue
        if not edicao["historias"] and len(bloco) <= 3:
            avisos.append(f"Edição {edicao['numero']} parece incompleta e precisa de revisão.")
        if capas_processadas is not None:
            indice_capa = len(edicoes)
            edicao["urlCapa"] = (
                capas_processadas[indice_capa]
                if indice_capa < len(capas_processadas)
                else None
            )
        edicao.pop("_tituloSerieDetectado", None)
        edicoes.append(edicao)

    return {
        "origem": {
            "arquivoEntrada": None,
            "url": args.url,
            "urlsProcessadas": urls_processadas,
            "geradoEm": datetime.now().replace(microsecond=0).isoformat(),
            "gerador": Path(__file__).name,
            "capasArmazenadasCloudinary": (
                sum(1 for url in capas_processadas if url)
                if capas_processadas is not None
                else None
            ),
        },
        "serieBrasileira": {
            "titulo": args.titulo_serie,
            "fase": args.fase,
            "editora": args.editora,
            "volume": args.volume,
        },
        "totalEdicoes": len(edicoes),
        "totalHistorias": sum(len(edicao["historias"]) for edicao in edicoes),
        "avisos": avisos,
        "edicoes": edicoes,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Importa páginas do Guia com o Chrome visível, permitindo concluir a verificação interativa."
    )
    parser.add_argument("--url", required=True, help="URL inicial /edicao/ do Guia dos Quadrinhos.")
    parser.add_argument("--saida", required=True, help="Arquivo JSON que será gerado.")
    parser.add_argument("--titulo-serie", required=True, help="Título da série brasileira.")
    parser.add_argument("--fase", default=None, help="Fase textual da série.")
    parser.add_argument("--editora", default="Panini", help="Editora brasileira.")
    parser.add_argument("--volume", type=int, default=1, help="Volume interno da série.")
    parser.add_argument("--maximo-edicoes", type=int, default=None, help="Limite opcional de edições.")
    parser.add_argument("--intervalo-segundos", type=float, default=1.0, help="Pausa entre páginas.")
    parser.add_argument(
        "--recarregar-a-cada",
        type=int,
        default=10,
        help="Recarrega a sessão do Guia a cada N edições; use 0 para desativar.",
    )
    parser.add_argument(
        "--pausa-minutos-minima",
        type=float,
        default=2.0,
        help="Pausa mínima automática entre lotes (padrão: 2 minutos).",
    )
    parser.add_argument(
        "--pausa-minutos-maxima",
        type=float,
        default=3.0,
        help="Pausa máxima automática entre lotes (padrão: 3 minutos).",
    )
    parser.add_argument(
        "--tempo-verificacao",
        type=int,
        default=180,
        help="Tempo máximo para concluir a verificação no Chrome.",
    )
    parser.add_argument(
        "--tempo-galeria",
        type=int,
        default=15,
        help="Tempo máximo para a galeria dinâmica carregar as edições.",
    )
    parser.add_argument(
        "--armazenar-capas-cloudinary",
        action="store_true",
        help=(
            "Baixa cada capa pela sessão liberada do Chrome, envia ao Cloudinary "
            "e grava a secure_url em edicoes[].urlCapa."
        ),
    )
    args = parser.parse_args()

    importador = carregar_importador()
    args.url = importador.normalizar_url_guia(args.url)
    if not re.search(r"/edicao(?:-estrangeira)?/", args.url, re.IGNORECASE):
        parser.error(
            "--url deve apontar para uma página /edicao/ ou /edicao-estrangeira/."
        )
    if args.recarregar_a_cada < 0:
        parser.error("--recarregar-a-cada deve ser zero ou um número positivo.")
    if args.pausa_minutos_minima < 0 or args.pausa_minutos_maxima < 0:
        parser.error("As pausas entre lotes não podem ser negativas.")
    if args.pausa_minutos_maxima < args.pausa_minutos_minima:
        parser.error("--pausa-minutos-maxima deve ser maior ou igual à pausa mínima.")

    try:
        cloudinary = (
            configuracao_cloudinary()
            if args.armazenar_capas_cloudinary
            else None
        )
    except ValueError as erro:
        parser.error(str(erro))
    chrome = encontrar_chrome()
    porta = obter_porta_livre()
    perfil = Path(tempfile.mkdtemp(prefix="hqhub-guia-chrome-"))
    processo = None

    try:
        processo = subprocess.Popen(
            [
                str(chrome),
                f"--remote-debugging-port={porta}",
                f"--user-data-dir={perfil}",
                "--no-first-run",
                "--no-default-browser-check",
                "--new-window",
                args.url,
            ]
        )
        with sync_playwright() as playwright:
            navegador = conectar_chrome(playwright, porta)
            contexto = navegador.contexts[0]
            pagina = contexto.pages[0] if contexto.pages else contexto.new_page()
            texto, urls_processadas, capas_processadas, avisos = coletar_paginas(
                pagina,
                args.url,
                importador,
                cloudinary,
                args.tempo_verificacao,
                args.tempo_galeria,
                args.intervalo_segundos,
                args.maximo_edicoes,
                args.recarregar_a_cada,
                args.pausa_minutos_minima,
                args.pausa_minutos_maxima,
            )
            resultado = montar_resultado(
                importador,
                texto,
                urls_processadas,
                capas_processadas,
                avisos,
                args,
            )
            saida = Path(args.saida)
            saida.parent.mkdir(parents=True, exist_ok=True)
            importador.salvar_json_utf8(saida, resultado)
            navegador.close()

        print(f"Arquivo gerado: {saida}")
        print(f"Edições: {resultado['totalEdicoes']}")
        print(f"Histórias: {resultado['totalHistorias']}")
        if capas_processadas is not None:
            print(
                "Capas armazenadas no Cloudinary: "
                f"{resultado['origem']['capasArmazenadasCloudinary']}/{resultado['totalEdicoes']}"
            )
        if resultado["avisos"]:
            print("Avisos:")
            for aviso in resultado["avisos"]:
                print(f"- {aviso}")
    finally:
        if processo and processo.poll() is None:
            processo.terminate()
            try:
                processo.wait(timeout=5)
            except subprocess.TimeoutExpired:
                processo.kill()
        pasta_temporaria = Path(tempfile.gettempdir()).resolve()
        perfil_resolvido = perfil.resolve()
        if perfil_resolvido.parent == pasta_temporaria and perfil_resolvido.name.startswith("hqhub-guia-chrome-"):
            shutil.rmtree(perfil_resolvido, ignore_errors=True)


if __name__ == "__main__":
    main()
