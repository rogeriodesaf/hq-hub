#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path
from time import sleep
from urllib.error import HTTPError, URLError
from urllib.parse import quote_plus
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


def descobrir_primeiro_produto(html):
    padrao = re.compile(r"/dp/([A-Z0-9]{10})", re.IGNORECASE)
    vistos = set()
    for encontrado in padrao.finditer(html):
        asin = encontrado.group(1).upper()
        if asin in vistos:
            continue
        vistos.add(asin)
        return f"https://www.amazon.com.br/dp/{asin}"
    return None


def salvar_saidas(saida_urls, saida_relatorio, resultados):
    linhas = []
    for item in resultados:
        linhas.append(item.get("urlProduto") or "null")

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

    # Remove duplicatas mantendo ordem pelo numero.
    unicas = {}
    for e in edicoes:
        chave = e["numero"]
        if chave not in unicas:
            unicas[chave] = e
    ordenadas = sorted(unicas.values(), key=lambda x: int(re.sub(r"\D", "", x["numero"])))

    resultados = []
    for indice, ed in enumerate(ordenadas, start=1):
        query = montar_query(ed["serie"], ed["volume"], ed["numero"])
        url_busca = f"https://www.amazon.com.br/s?k={quote_plus(query)}"

        item = {
            "indice": indice,
            "numero": ed["numero"],
            "query": query,
            "urlBusca": url_busca,
            "urlProduto": None,
            "erro": None,
        }

        print(f"Buscando edição {ed['numero']}: {query}")
        try:
            html = buscar_html(url_busca, args.tentativas)
            item["urlProduto"] = descobrir_primeiro_produto(html)
            if not item["urlProduto"]:
                item["erro"] = "Nenhum link de produto encontrado na busca."
        except Exception as erro:
            item["erro"] = str(erro)

        resultados.append(item)

        if indice < len(ordenadas) and args.intervalo_segundos > 0:
            sleep(args.intervalo_segundos)

    salvar_saidas(args.saida_urls, args.saida_relatorio, resultados)

    encontrados = sum(1 for r in resultados if r.get("urlProduto"))
    print(f"Total edições: {len(resultados)}")
    print(f"URLs de produto encontradas: {encontrados}")
    print(f"Sem URL: {len(resultados) - encontrados}")
    print(f"TXT gerado: {args.saida_urls}")
    print(f"Relatório gerado: {args.saida_relatorio}")


def main():
    parser = argparse.ArgumentParser(
        description="Descobre URLs de produto da Amazon a partir de JSONs com edições.",
    )
    parser.add_argument(
        "--entradas-json",
        nargs="+",
        required=True,
        help="Lista de JSONs de entrada com campo edicoes.",
    )
    parser.add_argument(
        "--saida-urls",
        required=True,
        help="TXT de saída com URL de produto por linha (ou null).",
    )
    parser.add_argument(
        "--saida-relatorio",
        required=True,
        help="JSON de saída com detalhes por edição.",
    )
    parser.add_argument(
        "--intervalo-segundos",
        type=float,
        default=1.0,
        help="Pausa entre requisições.",
    )
    parser.add_argument(
        "--tentativas",
        type=int,
        default=2,
        help="Tentativas por requisição.",
    )

    args = parser.parse_args()
    executar(args)


if __name__ == "__main__":
    main()
