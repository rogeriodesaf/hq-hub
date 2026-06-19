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
            requisicao = Request(url, headers={"User-Agent": "Mozilla/5.0 HQ-HUB robô de capas"})
            with urlopen(requisicao, timeout=30) as resposta:
                return resposta.read().decode("utf-8", errors="replace")
        except (HTTPError, URLError, TimeoutError) as erro:
            ultimo_erro = erro
            if tentativa < tentativas:
                sleep(2 * tentativa)
    raise ultimo_erro


def extrair_imagem_principal(html):
    encontrado = re.search(r'property=["\']og:image["\']\s+content=["\']([^"\']+)["\']', html, re.IGNORECASE)
    if encontrado:
        return melhorar_resolucao(unescape(encontrado.group(1)))

    encontrado = re.search(r'<link[^>]+itemprop=["\']image["\'][^>]+href=["\']([^"\']+)["\']', html, re.IGNORECASE)
    if encontrado:
        return melhorar_resolucao(unescape(encontrado.group(1)))

    return None


def melhorar_resolucao(url):
    return re.sub(r"/-S\d+-FWEBP$", "/-S897-f.webp", url, flags=re.IGNORECASE)


def montar_url(slug_base, numero, deslocamento_comercial):
    numero_int = int(re.sub(r"\D", "", str(numero)))
    numero_comercial = numero_int + deslocamento_comercial
    return f"https://venda.panini.com.br/{slug_base}-vol-{numero_int}-{numero_comercial}"


def enriquecer(args):
    entrada = Path(args.entrada)
    dados = json.loads(entrada.read_text(encoding="utf-8"))
    avisos = list(dados.get("avisos") or [])
    atualizadas = 0

    for indice, edicao in enumerate(dados.get("edicoes", []), start=1):
        numero = edicao.get("numero")
        if not numero:
            continue

        url_produto = montar_url(args.slug_base, numero, args.deslocamento_comercial)
        try:
            print(f"Processando capa {indice}: {url_produto}")
            html = buscar_html(url_produto, args.tentativas)
            url_capa = extrair_imagem_principal(html)
            if not url_capa:
                avisos.append(f"Capa Panini não encontrada para edição {numero}: {url_produto}")
                continue

            edicao["urlCapa"] = url_capa
            atualizadas += 1
        except Exception as erro:
            avisos.append(f"Não foi possível buscar capa Panini da edição {numero}: {erro}")

        if indice < len(dados.get("edicoes", [])) and args.intervalo_segundos > 0:
            sleep(args.intervalo_segundos)

    dados["avisos"] = avisos
    dados.setdefault("origem", {})["capasPanini"] = {
        "slugBase": args.slug_base,
        "deslocamentoComercial": args.deslocamento_comercial,
        "capasAtualizadas": atualizadas,
    }

    saida = Path(args.saida)
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Arquivo gerado: {saida}")
    print(f"Capas atualizadas: {atualizadas}")
    print(f"Avisos: {len(avisos)}")


def main():
    parser = argparse.ArgumentParser(description="Atualiza capas de um JSON de importação usando páginas da Panini.")
    parser.add_argument("--entrada", required=True, help="JSON gerado pelo robô de importação.")
    parser.add_argument("--saida", required=True, help="JSON enriquecido que será gerado.")
    parser.add_argument("--slug-base", required=True, help="Slug base do produto na Panini, sem vol-numeração.")
    parser.add_argument("--deslocamento-comercial", type=int, default=0, help="Diferença entre número da edição e número comercial Panini.")
    parser.add_argument("--intervalo-segundos", type=float, default=0.5, help="Pausa entre acessos.")
    parser.add_argument("--tentativas", type=int, default=2, help="Tentativas por URL.")
    args = parser.parse_args()
    enriquecer(args)


if __name__ == "__main__":
    main()
