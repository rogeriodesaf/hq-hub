#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path
from time import sleep
from urllib.parse import quote_plus

from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright


def extrair_edicoes_de_arquivo(caminho_json):
    dados = json.loads(Path(caminho_json).read_text(encoding="utf-8"))
    serie = (dados.get("serieBrasileira") or {}).get("titulo") or ""
    volume = (dados.get("serieBrasileira") or {}).get("volume")

    resultados = []
    for item in dados.get("edicoes", []):
        numero = str(item.get("numero") or "").strip()
        if not numero:
            continue
        resultados.append(
            {
                "numero": numero,
                "serie": serie,
                "volume": volume,
            }
        )
    return resultados


def montar_query(serie, volume, numero):
    partes = [serie.strip(), "vol", str(volume or 1), str(numero), "panini"]
    return " ".join(p for p in partes if p)


def normalizar_url_produto(url):
    if not url:
        return None

    match = re.search(r"/dp/([A-Z0-9]{10})", url, flags=re.IGNORECASE)
    if match:
        asin = match.group(1).upper()
        return f"https://www.amazon.com.br/dp/{asin}"

    return None


def contem_numero_edicao(titulo, numero):
    if not titulo:
        return False
    numero_int = int(re.sub(r"\D", "", str(numero)))
    if numero_int <= 0:
        return False

    padroes = [
        rf"\bvol\.?\s*{numero_int}\b",
        rf"\bv\.?\s*{numero_int}\b",
        rf"\bvolume\s*{numero_int}\b",
        rf"\bn[ºo°]?\s*{numero_int}\b",
        rf"\b{numero_int}/57\b",
    ]

    texto = " ".join(titulo.lower().split())
    return any(re.search(p, texto, flags=re.IGNORECASE) for p in padroes)


def extrair_titulo_produto(page):
    titulo = page.locator("#productTitle")
    if titulo.count() == 0:
        return None
    texto = titulo.first.inner_text().strip()
    return " ".join(texto.split()) if texto else None


def descobrir_primeiro_produto(page_busca, page_detalhe, numero_edicao, timeout_ms, max_validacoes=6):
    # Primeiro tenta os resultados estruturados da busca com filtro por número da edição.
    links = page_busca.locator("[data-component-type='s-search-result'] h2 a")
    qtd = links.count()
    candidatos = []
    vistos = set()

    for i in range(min(qtd, 20)):
        link = links.nth(i)
        href = link.get_attribute("href")
        url = normalizar_url_produto(href)
        if not url or url in vistos:
            continue
        vistos.add(url)

        titulo_busca = (link.inner_text() or "").strip()
        candidatos.append((url, titulo_busca))

    for url, titulo_busca in candidatos:
        if contem_numero_edicao(titulo_busca, numero_edicao):
            return url, titulo_busca

    # Valida alguns candidatos abrindo a página do produto.
    for url, _ in candidatos[:max_validacoes]:
        try:
            page_detalhe.goto(url, wait_until="domcontentloaded", timeout=timeout_ms)
            page_detalhe.wait_for_timeout(900)
            titulo_produto = extrair_titulo_produto(page_detalhe)
            if contem_numero_edicao(titulo_produto, numero_edicao):
                return url, titulo_produto
        except Exception:
            continue

    # Fallback por regex no HTML da busca.
    html = page_busca.content()
    match = re.search(r"/dp/([A-Z0-9]{10})", html, flags=re.IGNORECASE)
    if match:
        asin = match.group(1).upper()
        return f"https://www.amazon.com.br/dp/{asin}", None

    return None, None


def salvar_saidas(saida_urls, saida_relatorio, resultados):
    linhas = [item.get("urlProduto") or "null" for item in resultados]

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
    edicoes = []
    for caminho in args.entradas_json:
        edicoes.extend(extrair_edicoes_de_arquivo(caminho))

    unicas = {}
    for e in edicoes:
        chave = e["numero"]
        if chave not in unicas:
            unicas[chave] = e
    ordenadas = sorted(unicas.values(), key=lambda x: int(re.sub(r"\D", "", x["numero"])))

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
        page_detalhe = context.new_page()

        for indice, ed in enumerate(ordenadas, start=1):
            query = montar_query(ed["serie"], ed["volume"], ed["numero"])
            url_busca = f"https://www.amazon.com.br/s?k={quote_plus(query)}"

            item = {
                "indice": indice,
                "numero": ed["numero"],
                "query": query,
                "urlBusca": url_busca,
                "urlProduto": None,
                "tituloEncontradoNaBusca": None,
                "erro": None,
            }

            print(f"Buscando edição {ed['numero']}: {query}")
            try:
                page.goto(url_busca, wait_until="domcontentloaded", timeout=args.timeout_ms)
                page.wait_for_timeout(1200)
                url_produto, titulo_encontrado = descobrir_primeiro_produto(
                    page,
                    page_detalhe,
                    ed["numero"],
                    args.timeout_ms,
                    max_validacoes=args.max_validacoes,
                )
                item["urlProduto"] = url_produto
                item["tituloEncontradoNaBusca"] = titulo_encontrado
                if not item["urlProduto"]:
                    item["erro"] = "Nenhum link de produto encontrado na busca."
            except PlaywrightTimeoutError:
                item["erro"] = "Timeout ao abrir página de busca."
            except Exception as erro:
                item["erro"] = str(erro)

            resultados.append(item)
            if args.intervalo_segundos > 0 and indice < len(ordenadas):
                sleep(args.intervalo_segundos)

        page_detalhe.close()
        context.close()
        browser.close()

    salvar_saidas(args.saida_urls, args.saida_relatorio, resultados)

    encontrados = sum(1 for r in resultados if r.get("urlProduto"))
    print(f"Total edições: {len(resultados)}")
    print(f"URLs de produto encontradas: {encontrados}")
    print(f"Sem URL: {len(resultados) - encontrados}")
    print(f"TXT gerado: {args.saida_urls}")
    print(f"Relatório gerado: {args.saida_relatorio}")


def main():
    parser = argparse.ArgumentParser(
        description="Descobre URLs de produto da Amazon com navegador real (Playwright).",
    )
    parser.add_argument("--entradas-json", nargs="+", required=True)
    parser.add_argument("--saida-urls", required=True)
    parser.add_argument("--saida-relatorio", required=True)
    parser.add_argument("--intervalo-segundos", type=float, default=1.0)
    parser.add_argument("--timeout-ms", type=int, default=45000)
    parser.add_argument("--max-validacoes", type=int, default=6, help="Quantidade de candidatos de busca para validar abrindo página de produto.")
    parser.add_argument("--headed", action="store_true", help="Abre navegador visível.")
    parser.add_argument("--channel", default="msedge", help="Canal do navegador do sistema (ex.: msedge, chrome).")
    parser.add_argument("--executable-path", default=None, help="Caminho absoluto do executável do navegador.")
    args = parser.parse_args()
    executar(args)


if __name__ == "__main__":
    main()
