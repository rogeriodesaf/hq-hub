#!/usr/bin/env python3
"""Enriquece um JSON do Guia dos Quadrinhos com capas encontradas na web.

O robô é independente dos coletores existentes e nunca substitui uma capa
existente, salvo quando --substituir é informado. Os resultados ficam
registrados em origem.capasAutomaticas para revisão humana.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import re
import unicodedata
from html import unescape
from pathlib import Path
from time import sleep
from urllib.parse import quote, urljoin, urlparse
from urllib.request import Request, urlopen

FONTES = {
    "Panini": ("panini.com.br", "https://panini.com.br/catalogsearch/result/?q={}"),
    "Pipoca & Nanquim": ("pipocaenanquim.com.br", "https://pipocaenanquim.com.br/catalogsearch/result/?q={}"),
    "Mythos": ("mythoseditora.com.br", "https://www.mythoseditora.com.br/buscar?q={}"),
    "Loja Mythos": ("lojamythos.com.br", "https://www.lojamythos.com.br/buscar?q={}"),
    "Devir": ("lojaeditora.devir.com.br", "https://lojaeditora.devir.com.br/index.php?route=product/search&search={}"),
    "Rika": ("rika.com.br", "https://www.rika.com.br/{}?_q={}&map=ft"),
    "Comix": ("comix.com.br", "https://www.comix.com.br/catalogsearch/result/?q={}"),
    "Ponto do Gibi": ("pontodogibi.com.br", "https://pontodogibi.com.br/search?q={}"),
    "Amazon": ("amazon.com.br", "https://www.amazon.com.br/s?k={}"),
}
FONTES_OFICIAIS = {"Panini", "Pipoca & Nanquim", "Mythos", "Loja Mythos", "Devir"}


def baixar(url):
    req = Request(url, headers={"User-Agent": "Mozilla/5.0 HQ-HUB local cover finder"})
    with urlopen(req, timeout=8) as resposta:
        return resposta.read().decode("utf-8", errors="replace")


def limpar(texto):
    return re.sub(r"\s+", " ", unescape(texto or "")).strip()


def tokens(texto):
    base = unicodedata.normalize("NFKD", texto or "").encode("ascii", "ignore").decode().lower()
    return {
        item for item in re.findall(r"[a-z0-9]+", base)
        if (len(item) >= 3 or item.isdigit()) and item not in {"panini", "unica"}
    }


def slug(texto):
    base = unicodedata.normalize("NFKD", texto or "").encode("ascii", "ignore").decode().lower()
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", base)).strip("-")


def produto_compativel_com_numero(url, numero, exigir_volume=False):
    numero = str(numero or "").strip()
    if not numero.isdigit():
        return True
    volumes = re.findall(r"(?:vol(?:ume)?|n)[-_ ]*0*(\d+)(?:\D|$)", urlparse(url).path.lower())
    if volumes:
        return int(numero) in {int(volume) for volume in volumes}
    return not exigir_volume


def resultados_bing(consulta, dominio):
    html = baixar("https://www.bing.com/search?q=" + quote(f"site:{dominio} {consulta}"))
    encontrados = []
    for bloco in re.findall(r'<li[^>]+class="[^"]*b_algo[^"]*".*?</li>', html, re.I | re.S):
        link = re.search(r'<a[^>]+href="(https?://[^"]+)', bloco, re.I)
        titulo = re.search(r'<h2.*?>(.*?)</h2>', bloco, re.I | re.S)
        if link:
            encontrados.append({"url": unescape(link.group(1)), "titulo": limpar(titulo.group(1)) if titulo else ""})
    return encontrados[:3]


def resultados_loja(consulta, dominio, modelo_busca):
    termo = re.sub(r'["“”]', "", consulta)
    codificado = quote(termo)
    url_busca = modelo_busca.format(codificado, codificado)
    html = baixar(url_busca)
    candidatos = []
    termos = tokens(termo)
    for href in re.findall(r'href=["\']([^"\']+)', html, re.I):
        url = urljoin(url_busca, unescape(href))
        host = (urlparse(url).hostname or "").lower()
        rota = (urlparse(url).path or "").lower()
        if dominio not in host:
            continue
        if any(trecho in rota for trecho in (
            "/catalogsearch/", "/search", "/customer/", "/wishlist/",
            "/static/", "/media/", "/checkout/", "/account/", "/sales/",
            "/catalog/category/", "/assinatura", "/clubepanini/",
        )):
            continue
        if re.search(r"\.(?:js|css|png|jpe?g|webp|svg|woff2?)(?:$|\?)", rota):
            continue
        if dominio == "amazon.com.br" and "/dp/" not in rota and "/gp/product/" not in rota:
            continue
        if rota in {"", "/"}:
            continue
        if url not in candidatos:
            candidatos.append(url)
    candidatos.sort(key=lambda url: len(termos & tokens(urlparse(url).path)), reverse=True)
    return [{"url": url, "titulo": ""} for url in candidatos[:8]]


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


def fonte_aplicavel(nome, edicao, serie):
    editora = unicodedata.normalize(
        "NFKD", str(edicao.get("editora") or serie.get("editora") or "")
    ).encode("ascii", "ignore").decode().lower()
    if nome == "Panini":
        return "panini" in editora
    if nome == "Pipoca & Nanquim":
        return "pipoca" in editora and "nanquim" in editora
    if nome in {"Mythos", "Loja Mythos"}:
        return "mythos" in editora
    if nome == "Devir":
        return "devir" in editora
    return True


def buscar_fonte(nome, dominio, modelo_busca, busca_loja, busca, capas_usadas, titulo, numero):
    resultados = resultados_loja(busca_loja, dominio, modelo_busca)
    if nome == "Panini" and str(numero or "").isdigit():
        url_direta = f"https://panini.com.br/{slug(titulo)}-vol-{int(numero)}"
        resultados.insert(0, {"url": url_direta, "titulo": ""})
    if not resultados:
        resultados = resultados_bing(busca, dominio)
    for resultado in resultados:
        if not produto_compativel_com_numero(
            resultado["url"], numero, exigir_volume=nome == "Panini"
        ):
            continue
        capa = extrair_capa(resultado["url"])
        if capa and capa not in capas_usadas:
            return nome, capa, resultado["url"], None
    return nome, None, None, None


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
    mantidas = 0
    capas_usadas = set()

    for indice, edicao in enumerate(dados.get("edicoes", []), 1):
        capa_atual = str(edicao.get("urlCapa") or "").strip()
        capa_do_guia = "guiadosquadrinhos.com" in capa_atual.lower()
        if capa_atual and not capa_do_guia and not args.substituir:
            mantidas += 1
            capas_usadas.add(capa_atual)
            relatorio.append({"numero": edicao.get("numero"), "status": "mantida", "url": edicao["urlCapa"]})
            continue
        item = {"numero": edicao.get("numero"), "status": "nao_encontrada", "fontesConsultadas": []}
        busca = consulta(edicao, serie)
        titulo_busca = edicao.get("tituloChamada") or serie.get("titulo") or busca
        numero_busca = str(edicao.get("numero") or "").strip()
        busca_loja = titulo_busca
        if numero_busca and numero_busca.upper() not in {"UNICA", "ÚNICA"}:
            busca_loja = f"{titulo_busca} volume {numero_busca}"
        panini_direta_falhou = False
        if fonte_aplicavel("Panini", edicao, serie) and numero_busca.isdigit():
            url_direta = f"https://panini.com.br/{slug(titulo_busca)}-vol-{int(numero_busca)}"
            print(
                f"[CAPA {indice}/{len(dados.get('edicoes', []))}] "
                f"{edicao.get('numero')}: consultando Panini",
                flush=True,
            )
            item["fontesConsultadas"].append("Panini")
            try:
                capa_direta = extrair_capa(url_direta)
            except Exception:
                capa_direta = None
            if capa_direta and capa_direta not in capas_usadas:
                edicao["urlCapa"] = capa_direta
                capas_usadas.add(capa_direta)
                encontradas += 1
                item.update({"status": "encontrada", "fonte": "Panini", "url": capa_direta,
                             "urlProduto": url_direta, "confianca": "alta"})
                relatorio.append(item)
                print(f"[{indice}/{len(dados.get('edicoes', []))}] {edicao.get('numero')}: encontrada")
                sleep(args.intervalo_segundos)
                continue
            panini_direta_falhou = True
        fontes = [
            (nome, dominio, modelo_busca)
            for nome, (dominio, modelo_busca) in FONTES.items()
            if fonte_aplicavel(nome, edicao, serie)
        ]
        oficiais = [fonte for fonte in fontes if fonte[0] in FONTES_OFICIAIS]
        if panini_direta_falhou:
            fontes = [fonte for fonte in fontes if fonte[0] not in FONTES_OFICIAIS]
        elif oficiais:
            fontes = oficiais
        for nome, _, _ in fontes:
            print(
                f"[CAPA {indice}/{len(dados.get('edicoes', []))}] "
                f"{edicao.get('numero')}: consultando {nome}",
                flush=True,
            )
            item["fontesConsultadas"].append(nome)
        respostas = {}
        with ThreadPoolExecutor(max_workers=min(6, max(1, len(fontes)))) as executor:
            tarefas = {
                executor.submit(
                    buscar_fonte, nome, dominio, modelo_busca, busca_loja, busca,
                    capas_usadas, titulo_busca, numero_busca
                ): nome
                for nome, dominio, modelo_busca in fontes
            }
            for tarefa in as_completed(tarefas):
                nome = tarefas[tarefa]
                try:
                    respostas[nome] = tarefa.result()
                except Exception as erro:
                    item.setdefault("erros", []).append(f"{nome}: {erro}")
        for nome, _, _ in fontes:
            resposta = respostas.get(nome)
            if resposta and resposta[1]:
                _, capa, url_produto, _ = resposta
                edicao["urlCapa"] = capa
                capas_usadas.add(capa)
                encontradas += 1
                item.update({"status": "encontrada", "fonte": nome, "url": capa,
                             "urlProduto": url_produto, "confianca": "media"})
                break
        sleep(args.intervalo_segundos)
        if item["status"] != "encontrada":
            avisos.append(f"Capa não encontrada para edição {edicao.get('numero')}")
        relatorio.append(item)
        print(f"[{indice}/{len(dados.get('edicoes', []))}] {edicao.get('numero')}: {item['status']}")

    dados["avisos"] = avisos
    dados.setdefault("origem", {})["capasAutomaticas"] = {
        "fontes": list(FONTES), "resultados": relatorio,
        "capasEncontradas": encontradas,
        "capasMantidas": mantidas,
        "capasNaoEncontradas": len(dados.get("edicoes", [])) - encontradas - mantidas,
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
