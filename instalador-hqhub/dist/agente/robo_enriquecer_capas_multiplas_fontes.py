#!/usr/bin/env python3
"""Enriquece um JSON do Guia dos Quadrinhos com capas encontradas na web.

O robô é independente dos coletores existentes e nunca substitui uma capa
existente, salvo quando --substituir é informado. Os resultados ficam
registrados em origem.capasAutomaticas para revisão humana.
"""
import argparse
import json
import re
from html import unescape
from pathlib import Path
from time import sleep
from urllib.parse import quote, unquote, urljoin
from urllib.request import Request, urlopen

FONTES = {
    "Panini": "panini.com.br",
    "Rika": "rika.com.br",
    "Comix": "comix.com.br",
    "Amazon": "amazon.com.br",
}


def baixar(url):
    req = Request(url, headers={"User-Agent": "Mozilla/5.0 HQ-HUB local cover finder"})
    with urlopen(req, timeout=25) as resposta:
        return resposta.read().decode("utf-8", errors="replace")


def limpar(texto):
    return re.sub(r"\s+", " ", unescape(texto or "")).strip()


def resultados_bing(consulta, dominio):
    html = baixar("https://www.bing.com/search?q=" + quote(f"site:{dominio} {consulta}"))
    encontrados = []
    for bloco in re.findall(r'<li[^>]+class="[^"]*b_algo[^"]*".*?</li>', html, re.I | re.S):
        link = re.search(r'<a[^>]+href="(https?://[^"]+)', bloco, re.I)
        titulo = re.search(r'<h2.*?>(.*?)</h2>', bloco, re.I | re.S)
        if link:
            encontrados.append({"url": unescape(link.group(1)), "titulo": limpar(titulo.group(1)) if titulo else ""})
    return encontrados[:3]


def extrair_capa(url):
    html = baixar(url)
    padroes = [
        r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)',
        r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image',
        r'<meta[^>]+name=["\']twitter:image["\'][^>]+content=["\']([^"\']+)',
    ]
    for padrao in padroes:
        achado = re.search(padrao, html, re.I)
        if achado:
            imagem = urljoin(url, unescape(achado.group(1)))
            if re.match(r"https?://", imagem):
                return imagem
    return None


def consulta(edicao, serie):
    numero = edicao.get("numero", "")
    titulo = edicao.get("tituloChamada") or serie.get("titulo") or ""
    editora = edicao.get("editora") or serie.get("editora") or ""
    return f'"{titulo}" "{editora}" "{numero}"'


def enriquecer(args):
    pasta = Path(args.pasta)
    if args.entrada:
        entrada = Path(args.entrada)
    else:
        candidatos = [
            caminho for caminho in pasta.rglob("*.json")
            if not caminho.name.endswith("-com-capas.json")
            and caminho.name not in {"resultado.json", "relatorio.json"}
        ]
        if not candidatos:
            raise SystemExit(f"Nenhum JSON encontrado em {pasta.resolve()}")
        entrada = max(candidatos, key=lambda caminho: caminho.stat().st_mtime)
        print(f"JSON identificado automaticamente: {entrada}")
    dados = json.loads(entrada.read_text(encoding="utf-8"))
    serie = dados.get("serieBrasileira", {})
    relatorio, avisos = [], list(dados.get("avisos") or [])
    encontradas = 0

    for indice, edicao in enumerate(dados.get("edicoes", []), 1):
        if edicao.get("urlCapa") and not args.substituir:
            relatorio.append({"numero": edicao.get("numero"), "status": "mantida", "url": edicao["urlCapa"]})
            continue
        item = {"numero": edicao.get("numero"), "status": "nao_encontrada", "fontesConsultadas": []}
        busca = consulta(edicao, serie)
        for nome, dominio in FONTES.items():
            item["fontesConsultadas"].append(nome)
            try:
                for resultado in resultados_bing(busca, dominio):
                    capa = extrair_capa(resultado["url"])
                    if capa:
                        edicao["urlCapa"] = capa
                        encontradas += 1
                        item.update({"status": "encontrada", "fonte": nome, "url": capa,
                                     "urlProduto": resultado["url"], "confianca": "media"})
                        break
                if item["status"] == "encontrada":
                    break
            except Exception as erro:
                item.setdefault("erros", []).append(f"{nome}: {erro}")
            sleep(args.intervalo_segundos)
        if item["status"] != "encontrada":
            avisos.append(f"Capa não encontrada para edição {edicao.get('numero')}")
        relatorio.append(item)
        print(f"[{indice}/{len(dados.get('edicoes', []))}] {edicao.get('numero')}: {item['status']}")

    dados["avisos"] = avisos
    dados.setdefault("origem", {})["capasAutomaticas"] = {
        "fontes": list(FONTES), "resultados": relatorio,
        "capasEncontradas": encontradas,
        "capasNaoEncontradas": len(dados.get("edicoes", [])) - encontradas,
    }
    saida = Path(args.saida) if args.saida else entrada.with_name(f"{entrada.stem}-com-capas.json")
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Arquivo gerado: {saida}")


def main():
    parser = argparse.ArgumentParser(description="Encontra capas em múltiplas lojas para um JSON do Guia dos Quadrinhos.")
    parser.add_argument("--entrada", help="JSON de entrada. Se omitido, usa o JSON mais recente da pasta informada.")
    parser.add_argument("--saida", help="Arquivo de saída. Se omitido, acrescenta -com-capas ao nome da entrada.")
    parser.add_argument("--pasta", default="docs/importacao/rascunhos", help="Pasta pesquisada quando --entrada é omitido.")
    parser.add_argument("--substituir", action="store_true", help="Também procura capa para edições já preenchidas.")
    parser.add_argument("--intervalo-segundos", type=float, default=1.0)
    args = parser.parse_args()
    enriquecer(args)


if __name__ == "__main__":
    main()
