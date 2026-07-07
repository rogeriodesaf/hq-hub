#!/usr/bin/env python3
import argparse
import re
import subprocess
import sys
from pathlib import Path
from time import sleep
from urllib.parse import urljoin
from urllib.request import Request, urlopen


def buscar_html(url, tentativas):
    ultimo_erro = None
    for tentativa in range(1, tentativas + 1):
        try:
            requisicao = Request(
                url,
                headers={
                    "User-Agent": "Mozilla/5.0 HQ-HUB robo gerador de importacao",
                    "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8",
                },
            )
            with urlopen(requisicao, timeout=30) as resposta:
                return resposta.read().decode("utf-8", errors="replace")
        except Exception as erro:
            ultimo_erro = erro
            if tentativa < tentativas:
                sleep(2 * tentativa)
    raise ultimo_erro


def extrair_numero_url_edicao(url):
    encontrado = re.search(r"-n-(\d+[a-z]?)", url, re.IGNORECASE)
    if not encontrado:
        return 0
    valor = encontrado.group(1)
    return int(re.sub(r"\D", "", valor) or 0)


def descobrir_primeira_edicao(url_guia, tentativas):
    if "/edicao/" in url_guia:
        return url_guia

    if "/capas/" not in url_guia:
        raise ValueError("Informe uma URL do Guia contendo /capas/ ou /edicao/.")

    html = buscar_html(url_guia, tentativas)
    links = []
    for href in re.findall(r'href=["\']([^"\']*/edicao/[^"\']+)["\']', html, flags=re.IGNORECASE):
        links.append(urljoin(url_guia, href))

    links_unicos = sorted(set(links), key=extrair_numero_url_edicao)
    if not links_unicos:
        raise ValueError("Nao encontrei links de edicao na pagina /capas/ do Guia.")

    return links_unicos[0]


def executar(comando):
    print("Executando:")
    print(" ".join(f'"{item}"' if " " in str(item) else str(item) for item in comando))
    subprocess.run(comando, check=True)


def caminho_temporario(saida, sufixo):
    caminho = Path(saida)
    return caminho.with_name(f"{caminho.stem}{sufixo}{caminho.suffix}")


def gerar(args):
    pasta_scripts = Path(__file__).resolve().parent
    saida = Path(args.saida)
    saida.parent.mkdir(parents=True, exist_ok=True)

    json_base = Path(args.json_base) if args.json_base else caminho_temporario(saida, "-base-guia")
    txt_capas = Path(args.txt_capas) if args.txt_capas else saida.with_name(f"{saida.stem}-capas-panini.txt")

    url_edicao_inicial = descobrir_primeira_edicao(args.url_guia, args.tentativas)
    print(f"URL inicial do Guia: {url_edicao_inicial}")

    comando_guia = [
        sys.executable,
        str(pasta_scripts / "robo_importador_texto.py"),
        "--url",
        url_edicao_inicial,
        "--seguir-galeria",
        "--maximo-edicoes",
        str(args.quantidade),
        "--saida",
        str(json_base),
        "--titulo-serie",
        args.titulo_serie,
        "--editora",
        args.editora,
        "--volume",
        str(args.volume),
        "--intervalo-segundos",
        str(args.intervalo_segundos),
        "--tentativas",
        str(args.tentativas),
    ]
    if args.fase:
        comando_guia.extend(["--fase", args.fase])
    executar(comando_guia)

    executar(
        [
            sys.executable,
            str(pasta_scripts / "robo_coletar_capas_panini_sequencial.py"),
            "--url-inicial",
            args.url_panini_inicial,
            "--quantidade",
            str(args.quantidade),
            "--saida",
            str(txt_capas),
            "--intervalo-segundos",
            str(args.intervalo_segundos),
            "--tentativas",
            str(args.tentativas),
        ]
    )

    executar(
        [
            sys.executable,
            str(pasta_scripts / "robo_aplicar_url_capa.py"),
            "--entrada",
            str(json_base),
            "--urls",
            str(txt_capas),
            "--saida",
            str(saida),
            "--estrito",
        ]
    )

    print("\nPronto.")
    print(f"JSON base: {json_base}")
    print(f"TXT capas Panini: {txt_capas}")
    print(f"JSON final: {saida}")


def main():
    parser = argparse.ArgumentParser(
        description="Gera um JSON de importacao HQ-HUB juntando dados do Guia dos Quadrinhos e capas sequenciais da Panini."
    )
    parser.add_argument("--url-guia", required=True, help="URL /capas/ ou /edicao/ do Guia dos Quadrinhos.")
    parser.add_argument("--url-panini-inicial", required=True, help="Primeira URL da sequencia da Panini.")
    parser.add_argument("--quantidade", type=int, required=True, help="Quantidade de edicoes a gerar.")
    parser.add_argument("--saida", required=True, help="JSON final pronto para importar.")
    parser.add_argument("--titulo-serie", required=True, help="Titulo da serie brasileira.")
    parser.add_argument("--fase", default=None, help="Fase textual, por exemplo: 1a Serie ou Primeira temporada.")
    parser.add_argument("--editora", default="Panini", help="Editora brasileira.")
    parser.add_argument("--volume", type=int, default=1, help="Volume interno da serie brasileira.")
    parser.add_argument("--intervalo-segundos", type=float, default=0.5, help="Pausa entre acessos.")
    parser.add_argument("--tentativas", type=int, default=2, help="Tentativas por URL.")
    parser.add_argument("--json-base", default=None, help="Opcional: caminho do JSON intermediario gerado pelo Guia.")
    parser.add_argument("--txt-capas", default=None, help="Opcional: caminho do TXT intermediario com capas Panini.")
    args = parser.parse_args()
    gerar(args)


if __name__ == "__main__":
    main()
