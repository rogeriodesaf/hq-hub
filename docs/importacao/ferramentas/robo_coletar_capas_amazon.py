#!/usr/bin/env python3
import argparse
import json
import re
from html import unescape
from pathlib import Path
from time import sleep
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def buscar_html(url, tentativas):
    ultimo_erro = None
    for tentativa in range(1, tentativas + 1):
        try:
            requisicao = Request(
                url,
                headers={
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36",
                    "Accept-Language": "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7",
                    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                },
            )
            with urlopen(requisicao, timeout=30) as resposta:
                return resposta.read().decode("utf-8", errors="replace")
        except (HTTPError, URLError, TimeoutError) as erro:
            ultimo_erro = erro
            if tentativa < tentativas:
                sleep(2 * tentativa)
    raise ultimo_erro


def extrair_product_title(html):
    padrao = re.compile(
        r'<span[^>]*id=["\']productTitle["\'][^>]*>(.*?)</span>',
        re.IGNORECASE | re.DOTALL,
    )
    encontrado = padrao.search(html)
    if not encontrado:
        return None

    texto = unescape(encontrado.group(1))
    texto = re.sub(r"\s+", " ", texto).strip()
    return texto or None


def extrair_capa(html):
    # 1) Padrão mais rico na página de produto da Amazon.
    padrao_old_hires = re.compile(
        r'<img[^>]*id=["\']landingImage["\'][^>]*data-old-hires=["\']([^"\']+)["\']',
        re.IGNORECASE | re.DOTALL,
    )
    encontrado = padrao_old_hires.search(html)
    if encontrado and encontrado.group(1).strip():
        return unescape(encontrado.group(1).strip())

    # 2) JSON com múltiplas resoluções.
    padrao_dynamic = re.compile(
        r'data-a-dynamic-image=["\'](\{.*?\})["\']',
        re.IGNORECASE | re.DOTALL,
    )
    encontrado = padrao_dynamic.search(html)
    if encontrado:
        bruto = unescape(encontrado.group(1))
        try:
            imagens = json.loads(bruto)
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
        except json.JSONDecodeError:
            pass

    # 3) Fallback para src de landingImage.
    padrao_src = re.compile(
        r'<img[^>]*id=["\']landingImage["\'][^>]*src=["\']([^"\']+)["\']',
        re.IGNORECASE | re.DOTALL,
    )
    encontrado = padrao_src.search(html)
    if encontrado and encontrado.group(1).strip():
        return unescape(encontrado.group(1).strip())

    # 4) Meta tag de compartilhamento.
    padrao_og = re.compile(
        r'<meta[^>]*property=["\']og:image["\'][^>]*content=["\']([^"\']+)["\']',
        re.IGNORECASE | re.DOTALL,
    )
    encontrado = padrao_og.search(html)
    if encontrado and encontrado.group(1).strip():
        return unescape(encontrado.group(1).strip())

    return None


def carregar_urls(caminho):
    linhas = Path(caminho).read_text(encoding="utf-8").splitlines()
    urls = []
    for linha in linhas:
        valor = linha.strip()
        if not valor or valor.startswith("#"):
            continue
        urls.append(valor)
    return urls


def salvar_resultados(saida_urls, saida_relatorio, resultados):
    linhas = []
    for item in resultados:
        linhas.append(item.get("urlCapa") or "null")

    caminho_urls = Path(saida_urls)
    caminho_urls.parent.mkdir(parents=True, exist_ok=True)
    caminho_urls.write_text("\n".join(linhas) + "\n", encoding="utf-8")

    if saida_relatorio:
        caminho_relatorio = Path(saida_relatorio)
        caminho_relatorio.parent.mkdir(parents=True, exist_ok=True)
        caminho_relatorio.write_text(
            json.dumps(resultados, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def coletar_capas(args):
    urls = carregar_urls(args.entrada_urls)
    resultados = []

    for indice, url in enumerate(urls, start=1):
        print(f"Processando {indice}/{len(urls)}: {url}")
        item = {
            "indice": indice,
            "urlProduto": url,
            "productTitle": None,
            "urlCapa": None,
            "erro": None,
        }

        try:
            html = buscar_html(url, args.tentativas)
            item["productTitle"] = extrair_product_title(html)
            item["urlCapa"] = extrair_capa(html)
            if not item["urlCapa"]:
                item["erro"] = "Capa não encontrada no HTML."
        except Exception as erro:
            item["erro"] = str(erro)

        resultados.append(item)

        if indice < len(urls) and args.intervalo_segundos > 0:
            sleep(args.intervalo_segundos)

    salvar_resultados(args.saida_urls, args.saida_relatorio, resultados)

    total_ok = sum(1 for r in resultados if r.get("urlCapa"))
    total_erro = len(resultados) - total_ok
    print(f"Total de URLs processadas: {len(resultados)}")
    print(f"Capas encontradas: {total_ok}")
    print(f"Sem capa/erro: {total_erro}")
    print(f"Arquivo TXT gerado: {args.saida_urls}")
    if args.saida_relatorio:
        print(f"Relatório JSON gerado: {args.saida_relatorio}")


def main():
    parser = argparse.ArgumentParser(
        description="Extrai productTitle e capa de páginas da Amazon a partir de uma lista de URLs.",
    )
    parser.add_argument(
        "--entrada-urls",
        required=True,
        help="TXT com uma URL de produto Amazon por linha.",
    )
    parser.add_argument(
        "--saida-urls",
        required=True,
        help="TXT de saída com uma URL de capa por linha (ou null).",
    )
    parser.add_argument(
        "--saida-relatorio",
        default=None,
        help="JSON detalhado opcional com productTitle, capa e erro por URL.",
    )
    parser.add_argument(
        "--intervalo-segundos",
        type=float,
        default=1.0,
        help="Pausa entre requisições para reduzir bloqueio.",
    )
    parser.add_argument(
        "--tentativas",
        type=int,
        default=2,
        help="Tentativas por URL em caso de erro.",
    )

    args = parser.parse_args()
    coletar_capas(args)


if __name__ == "__main__":
    main()
