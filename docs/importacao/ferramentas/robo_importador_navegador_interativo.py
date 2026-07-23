#!/usr/bin/env python3
"""Importa uma galeria do Guia usando uma sessão visível do Chrome.

Este modo existe para páginas protegidas por uma verificação interativa. O
usuário conclui a verificação no Chrome e o robô reutiliza a mesma sessão para
ler as páginas da galeria.
"""

import argparse
import importlib.util
import re
import shutil
import socket
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path
from time import monotonic, sleep

from playwright.sync_api import sync_playwright


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


def esperar_pagina_liberada(pagina, timeout_segundos):
    print("Aguardando a página do Guia. Conclua a verificação na janela do Chrome, se ela aparecer.")
    limite = monotonic() + timeout_segundos
    while monotonic() < limite:
        try:
            html = pagina.content()
            if re.search(r"/edicao/", html, re.IGNORECASE) and (
                "Publicado em:" in html or "Galeria de capas" in html
            ):
                return html
        except Exception:
            pass
        sleep(1)
    raise TimeoutError(
        f"A página não foi liberada em {timeout_segundos} segundos. "
        "Execute novamente e conclua a verificação no Chrome."
    )


def coletar_paginas(pagina, url_inicial, importador, timeout_verificacao, intervalo, maximo_edicoes):
    pagina.goto(url_inicial, wait_until="domcontentloaded", timeout=60_000)
    html_inicial = esperar_pagina_liberada(pagina, timeout_verificacao)
    urls = importador.extrair_links_galeria(html_inicial, url_inicial)
    urls = importador.limitar_urls_a_partir_da_inicial(urls, url_inicial, maximo_edicoes)

    textos = []
    urls_processadas = []
    avisos = []
    for indice, url in enumerate(urls):
        print(f"Processando {indice + 1}/{len(urls)}: {url}")
        try:
            if url == url_inicial:
                html = html_inicial
            else:
                pagina.goto(url, wait_until="domcontentloaded", timeout=60_000)
                html = esperar_pagina_liberada(pagina, timeout_verificacao)
            textos.append(importador.html_para_texto(html))
            urls_processadas.append(url)
        except Exception as erro:
            avisos.append(f"Não foi possível processar {url}: {erro}")
        if indice < len(urls) - 1 and intervalo > 0:
            sleep(intervalo)

    return "\n\n".join(textos), urls_processadas, avisos


def montar_resultado(importador, texto, urls_processadas, avisos, args):
    blocos = importador.separar_blocos_edicoes(texto.splitlines())
    edicoes = []

    for bloco in blocos:
        edicao = importador.extrair_edicao(bloco, args.titulo_serie, args.editora)
        if not edicao["numero"]:
            avisos.append(f"Bloco ignorado sem número: {bloco[0][:80]}")
            continue
        if not edicao["historias"] and len(bloco) <= 3:
            avisos.append(f"Edição {edicao['numero']} parece incompleta e precisa de revisão.")
        edicao.pop("_tituloSerieDetectado", None)
        edicoes.append(edicao)

    return {
        "origem": {
            "arquivoEntrada": None,
            "url": args.url,
            "urlsProcessadas": urls_processadas,
            "geradoEm": datetime.now().replace(microsecond=0).isoformat(),
            "gerador": Path(__file__).name,
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
        "--tempo-verificacao",
        type=int,
        default=180,
        help="Tempo máximo para concluir a verificação no Chrome.",
    )
    args = parser.parse_args()

    if "/edicao/" not in args.url:
        parser.error("--url deve apontar para uma página /edicao/.")

    importador = carregar_importador()
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
            texto, urls_processadas, avisos = coletar_paginas(
                pagina,
                args.url,
                importador,
                args.tempo_verificacao,
                args.intervalo_segundos,
                args.maximo_edicoes,
            )
            resultado = montar_resultado(importador, texto, urls_processadas, avisos, args)
            saida = Path(args.saida)
            saida.parent.mkdir(parents=True, exist_ok=True)
            importador.salvar_json_utf8(saida, resultado)
            navegador.close()

        print(f"Arquivo gerado: {saida}")
        print(f"Edições: {resultado['totalEdicoes']}")
        print(f"Histórias: {resultado['totalHistorias']}")
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
