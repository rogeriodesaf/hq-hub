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
    for bloco in re.findall(r'<li class="b_algo".*?</li>', html, re.I | re.S):
        link = re.search(r'<a href="(https?://[^"&]+)', bloco, re.I)
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
    entrada = Path(args.entrada)
    dados = json.loads(entrada.read_text(encoding="utf-8"))
    serie = dados.get("serieBrasileira", {})
    relatorio, avisos = [], list(dados.get("avisos") or [])

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
    dados.setdefault("origem", {})["capasAutomaticas"] = {"fontes": list(FONTES), "resultados": relatorio}
    saida = Path(args.saida)
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Arquivo gerado: {saida}")


def main():
    parser = argparse.ArgumentParser(description="Encontra capas em múltiplas lojas para um JSON do Guia dos Quadrinhos.")
    parser.add_argument("--entrada", required=True)
    parser.add_argument("--saida", required=True)
    parser.add_argument("--substituir", action="store_true", help="Também procura capa para edições já preenchidas.")
    parser.add_argument("--intervalo-segundos", type=float, default=1.0)
    args = parser.parse_args()
    enriquecer(args)


if __name__ == "__main__":
    main()
