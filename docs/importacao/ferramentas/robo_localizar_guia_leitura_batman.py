#!/usr/bin/env python3
"""Localiza no Guia dos Quadrinhos as obras da ordem de leitura do Batman."""

import argparse
import json
import re
import socket
import subprocess
import time
from pathlib import Path
from urllib.parse import parse_qs, quote, urlparse

from playwright.sync_api import sync_playwright


def porta_livre():
    with socket.socket() as servidor:
        servidor.bind(("127.0.0.1", 0))
        return servidor.getsockname()[1]


def itens_do_sql(caminho):
    texto = Path(caminho).read_text(encoding="utf-8")
    padrao = re.compile(
        r"^\s*\((\d+),\s*(\d+),\s*'((?:''|[^'])*)',\s*(NULL|'((?:''|[^'])*)')",
        re.MULTILINE,
    )
    return [
        {
            "ordem": int(item.group(1)),
            "subordem": int(item.group(2)),
            "titulo": item.group(3).replace("''", "'"),
            "detalhe": None if item.group(4) == "NULL" else item.group(5).replace("''", "'"),
        }
        for item in padrao.finditer(texto)
    ]


def url_real(href, tipos=("edicao", "titulo", "capas")):
    if not href:
        return None
    analisada = urlparse(href)
    if analisada.netloc.lower().endswith("google.com") and analisada.path == "/url":
        parametros = parse_qs(analisada.query)
        href = (parametros.get("q") or parametros.get("url") or [href])[0]
    analisada = urlparse(href)
    if analisada.netloc.lower() not in {"guiadosquadrinhos.com", "www.guiadosquadrinhos.com"}:
        return None
    partes = [parte for parte in analisada.path.lower().split("/") if parte]
    if not partes or partes[0] not in tipos:
        return None
    return f"https://www.guiadosquadrinhos.com{analisada.path}".rstrip("/")


def coletar_links(pagina, tipos=("edicao", "titulo", "capas")):
    encontrados = []
    for href in pagina.locator("a").evaluate_all("els => els.map(e => e.href)"):
        normalizada = url_real(href, tipos)
        if normalizada and normalizada not in encontrados:
            encontrados.append(normalizada)
    return encontrados


def localizar_edicoes(pagina, consulta, tentativas=4):
    busca = f"https://www.guiadosquadrinhos.com/titulos/{quote(consulta)}"
    for tentativa in range(1, tentativas + 1):
        pagina.goto(busca, wait_until="domcontentloaded", timeout=45000)
        esperar_verificacao(pagina)
        pagina.wait_for_timeout(1200)
        links = coletar_links(pagina)
        if links:
            break
        print(f"REPETINDO busca vazia ({tentativa}/{tentativas}): {consulta}", flush=True)
        pagina.wait_for_timeout(5000 * tentativa)
    else:
        return []

    edicoes = [link for link in links if "/edicao/" in link]
    paginas_intermediarias = [link for link in links if "/titulo/" in link or "/capas/" in link]
    for intermediaria in paginas_intermediarias[:8]:
        pagina.goto(intermediaria, wait_until="domcontentloaded", timeout=45000)
        esperar_verificacao(pagina)
        pagina.wait_for_timeout(800)
        for edicao in coletar_links(pagina, ("edicao",)):
            if edicao not in edicoes:
                edicoes.append(edicao)
    return edicoes


def salvar(saida, itens, resultados):
    payload = {
        "totalPosicoes": len(itens),
        "totalTitulosUnicos": len(resultados),
        "resultados": list(resultados.values()),
    }
    Path(saida).parent.mkdir(parents=True, exist_ok=True)
    Path(saida).write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def esperar_verificacao(pagina, timeout=300):
    limite = time.time() + timeout
    avisou = False
    while time.time() < limite:
        bloqueada = "momento" in pagina.title().lower() or pagina.locator("input[name='cf-turnstile-response']").count() > 0
        if not bloqueada:
            return
        if not avisou:
            print("VERIFICACAO: conclua o desafio na janela do Chrome.", flush=True)
            avisou = True
        pagina.wait_for_timeout(1000)
    raise TimeoutError("A verificacao do Guia nao foi concluida em 300 segundos.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--entrada", required=True)
    parser.add_argument("--saida", required=True)
    parser.add_argument("--perfil", required=True)
    parser.add_argument("--chrome", required=True)
    parser.add_argument("--intervalo", type=float, default=1.0)
    parser.add_argument("--diagnosticar-busca", action="store_true")
    args = parser.parse_args()

    itens = itens_do_sql(args.entrada)
    unicos = {}
    for item in itens:
        chave = f"{item['titulo']}|{item['detalhe'] or ''}"
        unicos.setdefault(chave, {**item, "posicoes": [], "candidatos": []})["posicoes"].append(
            {"ordem": item["ordem"], "subordem": item["subordem"]}
        )

    saida = Path(args.saida)
    existentes = {}
    if saida.exists():
        anteriores = json.loads(saida.read_text(encoding="utf-8"))
        existentes = {
            f"{item['titulo']}|{item.get('detalhe') or ''}": item
            for item in anteriores.get("resultados", [])
        }
    for chave, anterior in existentes.items():
        if chave in unicos and anterior.get("candidatos"):
            unicos[chave]["candidatos"] = anterior["candidatos"]

    porta = porta_livre()
    processo = subprocess.Popen([
        args.chrome,
        f"--remote-debugging-port={porta}",
        f"--user-data-dir={Path(args.perfil).resolve()}",
        "--no-first-run",
        "--no-default-browser-check",
        "--new-window",
        "about:blank",
    ])
    try:
        with sync_playwright() as playwright:
            navegador = None
            for _ in range(60):
                try:
                    navegador = playwright.chromium.connect_over_cdp(f"http://127.0.0.1:{porta}")
                    break
                except Exception:
                    time.sleep(0.5)
            if navegador is None:
                raise RuntimeError("Chrome nao respondeu na porta de depuracao.")
            pagina = navegador.contexts[0].pages[0]
            if args.diagnosticar_busca:
                pagina.goto("https://www.guiadosquadrinhos.com/", wait_until="domcontentloaded", timeout=45000)
                limite = time.time() + 300
                while time.time() < limite and ("momento" in pagina.title().lower() or not pagina.locator("form").count()):
                    pagina.wait_for_timeout(1000)
                print("TITULO:", pagina.title())
                print("FORMS:", pagina.locator("form").evaluate_all(
                    "els => els.map(e => ({action:e.action, method:e.method, html:e.outerHTML.slice(0,1000)}))"
                ))
                print("INPUTS:", pagina.locator("input").evaluate_all(
                    "els => els.map(e => ({name:e.name,id:e.id,type:e.type,placeholder:e.placeholder}))"
                ))
                navegador.close()
                return
            pendentes = [item for item in unicos.values() if not item["candidatos"]]
            for indice, item in enumerate(pendentes, 1):
                consulta = f'{item["titulo"]} {item.get("detalhe") or ""}'.strip()
                candidatos = localizar_edicoes(pagina, consulta)
                item["candidatos"] = candidatos[:10]
                print(f"{indice}/{len(pendentes)} {item['titulo']}: {len(item['candidatos'])}", flush=True)
                salvar(args.saida, itens, unicos)
                time.sleep(args.intervalo)
            navegador.close()
    finally:
        if processo.poll() is None:
            processo.terminate()
            processo.wait(timeout=10)

    salvar(args.saida, itens, unicos)


if __name__ == "__main__":
    main()
