#!/usr/bin/env python3
import argparse
import re
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
                    "User-Agent": "Mozilla/5.0 HQ-HUB robo coletor de capas",
                    "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8",
                },
            )
            with urlopen(requisicao, timeout=30) as resposta:
                return resposta.read().decode("utf-8", errors="replace")
        except (HTTPError, URLError, TimeoutError) as erro:
            ultimo_erro = erro
            if tentativa < tentativas:
                sleep(2 * tentativa)
    raise ultimo_erro


def extrair_capa(html):
    encontrado = re.search(
        r'property=["\']og:image["\']\s+content=["\']([^"\']+)["\']',
        html,
        re.IGNORECASE,
    )
    if encontrado:
        return encontrado.group(1).strip()

    encontrado = re.search(
        r'<link[^>]+itemprop=["\']image["\'][^>]+href=["\']([^"\']+)["\']',
        html,
        re.IGNORECASE,
    )
    if encontrado:
        return encontrado.group(1).strip()

    return None


def extrair_padrao_url(url_inicial):
    # Suporta formato markdown: [Titulo](https://...)
    markdown = re.match(r"^\[.*?\]\((.+?)\)\s*$", url_inicial.strip())
    if markdown:
        url_inicial = markdown.group(1)
    url_limpa = url_inicial.strip().rstrip("/")

    # Suporta dois contadores no final sem marcador "vol", exemplo:
    # .../a-saga-da-mulher-maravilha-01-08 -> ...-02-09 -> ...-03-10
    encontrado_duplo_final = re.search(
        r"^(?P<base>.+-)(?P<primeiro>\d+)-(?P<segundo>\d+)$",
        url_limpa,
        re.IGNORECASE,
    )
    if encontrado_duplo_final:
        return {
            "tipo": "duplo_final",
            "base": encontrado_duplo_final.group("base"),
            "primeiro_inicial": int(encontrado_duplo_final.group("primeiro")),
            "segundo_inicial": int(encontrado_duplo_final.group("segundo")),
            "largura_primeiro": len(encontrado_duplo_final.group("primeiro")),
            "largura_segundo": len(encontrado_duplo_final.group("segundo")),
        }

    # Suporta padrao com dois contadores, exemplo:
    # .../a-saga-do-superman-vol-1-25 -> ...vol-2-26 -> ...vol-3-27
    encontrado_duplo = re.search(
        r"^(?P<base>.+-vol-)(?P<volume>\d+)-(?P<numero>\d+)$",
        url_limpa,
        re.IGNORECASE,
    )
    if encontrado_duplo:
        return {
            "tipo": "duplo",
            "base": encontrado_duplo.group("base"),
            "volume_inicial": int(encontrado_duplo.group("volume")),
            "numero_inicial": int(encontrado_duplo.group("numero")),
        }

    # Fallback de contador unico, exemplo:
    # .../produto-25 -> .../produto-26
    encontrado_simples = re.search(r"^(?P<prefixo>.+-)(?P<numero>\d+)$", url_limpa)
    if encontrado_simples:
        return {
            "tipo": "simples",
            "prefixo": encontrado_simples.group("prefixo"),
            "numero_inicial": int(encontrado_simples.group("numero")),
            "largura_numero": len(encontrado_simples.group("numero")),
        }

    raise ValueError(
        "Nao foi possivel identificar o padrao numerico da URL inicial. "
        "Exemplo valido: https://panini.com.br/a-saga-do-superman-vol-1-25"
    )


def montar_url(padrao_url, deslocamento):
    if padrao_url["tipo"] == "duplo_final":
        primeiro = padrao_url["primeiro_inicial"] + deslocamento
        segundo = padrao_url["segundo_inicial"] + deslocamento
        primeiro_formatado = str(primeiro).zfill(padrao_url["largura_primeiro"])
        segundo_formatado = str(segundo).zfill(padrao_url["largura_segundo"])
        return f"{padrao_url['base']}{primeiro_formatado}-{segundo_formatado}"

    if padrao_url["tipo"] == "duplo":
        volume = padrao_url["volume_inicial"] + deslocamento
        numero = padrao_url["numero_inicial"] + deslocamento
        return f"{padrao_url['base']}{volume}-{numero}"

    numero = padrao_url["numero_inicial"] + deslocamento
    largura = padrao_url.get("largura_numero", 0)
    numero_formatado = str(numero).zfill(largura) if largura > 1 else str(numero)
    return f"{padrao_url['prefixo']}{numero_formatado}"


def coletar(args):
    padrao_url = extrair_padrao_url(args.url_inicial)
    linhas_saida = []
    falhas = 0

    for deslocamento in range(args.quantidade):
        url_produto = montar_url(padrao_url, deslocamento)

        try:
            print(f"Processando {deslocamento + 1}/{args.quantidade}: {url_produto}")
            html = buscar_html(url_produto, args.tentativas)
            url_capa = extrair_capa(html)

            if url_capa:
                linhas_saida.append(url_capa)
            else:
                falhas += 1
                linhas_saida.append("null")
                print(f"Aviso: capa nao encontrada em {url_produto}")
        except Exception as erro:
            falhas += 1
            linhas_saida.append("null")
            print(f"Aviso: erro ao processar {url_produto}: {erro}")

        if deslocamento < args.quantidade - 1 and args.intervalo_segundos > 0:
            sleep(args.intervalo_segundos)

    destino = Path(args.saida)
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text("\n".join(linhas_saida) + "\n", encoding="utf-8")

    print(f"Arquivo gerado: {destino}")
    print(f"Total solicitado: {args.quantidade}")
    print(f"Falhas: {falhas}")
    print(f"Capas encontradas: {args.quantidade - falhas}")


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Coleta URLs de capa de paginas sequenciais da Panini e salva em um TXT, "
            "uma URL por linha."
        )
    )
    parser.add_argument(
        "--url-inicial",
        required=True,
        help=(
            "URL inicial da sequencia. Exemplo: "
            "https://panini.com.br/a-saga-do-superman-vol-1-25"
        ),
    )
    parser.add_argument(
        "--quantidade",
        type=int,
        default=18,
        help="Quantidade de paginas sequenciais para percorrer.",
    )
    parser.add_argument(
        "--saida",
        required=True,
        help="Arquivo TXT de saida com uma URL de capa por linha.",
    )
    parser.add_argument(
        "--intervalo-segundos",
        type=float,
        default=0.5,
        help="Pausa entre requisicoes para evitar bloqueio.",
    )
    parser.add_argument(
        "--tentativas",
        type=int,
        default=2,
        help="Tentativas por URL em caso de erro de rede.",
    )

    args = parser.parse_args()
    coletar(args)


if __name__ == "__main__":
    main()
