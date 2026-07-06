#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from time import sleep

from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright


def carregar_urls(caminho):
    linhas = Path(caminho).read_text(encoding="utf-8").splitlines()
    urls = []
    for linha in linhas:
        valor = linha.strip()
        if not valor or valor.startswith("#"):
            continue
        if valor.lower() == "null":
            urls.append(None)
        else:
            urls.append(valor)
    return urls


def extrair_capa(page):
    # 1) landingImage data-old-hires
    old_hires = page.locator("#landingImage").get_attribute("data-old-hires")
    if old_hires and old_hires.strip():
        return old_hires.strip()

    # 2) landingImage data-a-dynamic-image
    dynamic = page.locator("#landingImage").get_attribute("data-a-dynamic-image")
    if dynamic:
        try:
            imagens = json.loads(dynamic)
            if isinstance(imagens, dict) and imagens:
                melhor_url = None
                melhor_area = -1
                for url, dimensoes in imagens.items():
                    if not isinstance(dimensoes, list) or len(dimensoes) < 2:
                        continue
                    largura = dimensoes[0] or 0
                    altura = dimensoes[1] or 0
                    area = largura * altura
                    if area > melhor_area:
                        melhor_area = area
                        melhor_url = url
                if melhor_url:
                    return melhor_url
        except Exception:
            pass

    # 3) src do landingImage
    src = page.locator("#landingImage").get_attribute("src")
    if src and src.strip():
        return src.strip()

    # 4) fallback og:image
    og = page.locator("meta[property='og:image']").get_attribute("content")
    if og and og.strip():
        return og.strip()

    return None


def extrair_titulo(page):
    titulo = page.locator("#productTitle")
    if titulo.count() == 0:
        return None
    texto = titulo.first.inner_text().strip()
    return " ".join(texto.split()) if texto else None


def salvar_resultados(saida_urls, saida_relatorio, resultados):
    linhas = [item.get("urlCapa") or "null" for item in resultados]

    caminho_urls = Path(saida_urls)
    caminho_urls.parent.mkdir(parents=True, exist_ok=True)
    caminho_urls.write_text("\n".join(linhas) + "\n", encoding="utf-8")

    caminho_relatorio = Path(saida_relatorio)
    caminho_relatorio.parent.mkdir(parents=True, exist_ok=True)
    caminho_relatorio.write_text(
        json.dumps(resultados, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def executar(args):
    urls = carregar_urls(args.entrada_urls)
    resultados = []

    with sync_playwright() as p:
        browser = None
        ultimo_erro = None

        opcoes = []
        if args.executable_path:
            opcoes.append({"headless": not args.headed, "executable_path": args.executable_path})
        if args.channel:
            opcoes.append({"headless": not args.headed, "channel": args.channel})
        opcoes.append({"headless": not args.headed})

        for opcao in opcoes:
            try:
                browser = p.chromium.launch(**opcao)
                break
            except Exception as erro:
                ultimo_erro = erro

        if browser is None:
            raise RuntimeError(f"Falha ao iniciar navegador Playwright: {ultimo_erro}")

        context = browser.new_context(locale="pt-BR")
        page = context.new_page()

        for indice, url in enumerate(urls, start=1):
            item = {
                "indice": indice,
                "urlProduto": url if url else "null",
                "productTitle": None,
                "urlCapa": None,
                "erro": None,
            }
            print(f"Processando {indice}/{len(urls)}: {item['urlProduto']}")

            if not url:
                item["erro"] = "URL de produto ausente."
                resultados.append(item)
                continue

            try:
                page.goto(url, wait_until="domcontentloaded", timeout=args.timeout_ms)
                page.wait_for_timeout(1200)
                item["productTitle"] = extrair_titulo(page)
                item["urlCapa"] = extrair_capa(page)
                if not item["urlCapa"]:
                    item["erro"] = "Capa não encontrada no HTML renderizado."
            except PlaywrightTimeoutError:
                item["erro"] = "Timeout ao abrir página de produto."
            except Exception as erro:
                item["erro"] = str(erro)

            resultados.append(item)
            if args.intervalo_segundos > 0 and indice < len(urls):
                sleep(args.intervalo_segundos)

        context.close()
        browser.close()

    salvar_resultados(args.saida_urls, args.saida_relatorio, resultados)

    total_ok = sum(1 for r in resultados if r.get("urlCapa"))
    total_erro = len(resultados) - total_ok
    print(f"Total de URLs processadas: {len(resultados)}")
    print(f"Capas encontradas: {total_ok}")
    print(f"Sem capa/erro: {total_erro}")
    print(f"Arquivo TXT gerado: {args.saida_urls}")
    print(f"Relatório JSON gerado: {args.saida_relatorio}")


def main():
    parser = argparse.ArgumentParser(
        description="Extrai productTitle e capa da Amazon com navegador real (Playwright).",
    )
    parser.add_argument("--entrada-urls", required=True)
    parser.add_argument("--saida-urls", required=True)
    parser.add_argument("--saida-relatorio", required=True)
    parser.add_argument("--intervalo-segundos", type=float, default=1.0)
    parser.add_argument("--timeout-ms", type=int, default=45000)
    parser.add_argument("--headed", action="store_true", help="Abre navegador visível.")
    parser.add_argument("--channel", default="msedge", help="Canal do navegador do sistema (ex.: msedge, chrome).")
    parser.add_argument("--executable-path", default=None, help="Caminho absoluto do executável do navegador.")
    args = parser.parse_args()
    executar(args)


if __name__ == "__main__":
    main()
