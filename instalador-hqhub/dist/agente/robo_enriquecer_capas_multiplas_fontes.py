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
from urllib.error import HTTPError
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
    "Texas Ranger": ("texasranger.com.br", "https://texasranger.com.br/search/?q={}"),
    "Papersera": ("papersera.net", "https://www.papersera.net/vilaxurupita/misc/omd01_20.htm"),
    "Amazon": ("amazon.com.br", "https://www.amazon.com.br/s?k={}"),
}
FONTES_OFICIAIS = {"Panini", "Pipoca & Nanquim", "Mythos", "Loja Mythos", "Devir"}


def baixar(url):
    req = Request(url, headers={"User-Agent": "Mozilla/5.0 HQ-HUB local cover finder"})
    ultimo_erro = None
    for tentativa in range(2):
        try:
            with urlopen(req, timeout=12) as resposta:
                return resposta.read().decode("utf-8", errors="replace")
        except HTTPError as erro:
            if erro.code < 500:
                raise
            ultimo_erro = erro
        except Exception as erro:
            ultimo_erro = erro
        if tentativa == 0:
            sleep(0.5)
    raise ultimo_erro


def limpar(texto):
    sem_tags = re.sub(r"<[^>]+>", " ", texto or "")
    return re.sub(r"\s+", " ", unescape(sem_tags)).strip()


def pontuacao_amazon(resultado):
    """Prioriza livros brasileiros quando a Amazon mistura outras edicoes."""
    asin = urlparse(resultado.get("url") or "").path.rstrip("/").split("/")[-1]
    titulo = unicodedata.normalize("NFKD", resultado.get("titulo") or "").encode(
        "ascii", "ignore"
    ).decode().lower()
    pontos = 0
    if asin.startswith(("65", "85")):
        pontos += 20
    if "english edition" in titulo or "kindle edition" in titulo:
        pontos -= 30
    return pontos


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


def titulo_compativel_com_numero(titulo, numero, titulo_serie=None):
    numero = str(numero or "").strip()
    if not numero.isdigit():
        return True
    normalizado = unicodedata.normalize("NFKD", titulo or "").encode("ascii", "ignore").decode().lower()
    encontrados = re.findall(r"(?:vol(?:ume)?\.?|n[ºo.]?|#)\s*0*(\d+)", normalizado)
    if encontrados:
        return int(numero) in {int(item) for item in encontrados}
    if int(numero) != 1 or not titulo_serie:
        return False
    # O primeiro volume muitas vezes e publicado sem "volume 1" no titulo.
    # Nesse caso, aceite-o somente quando o nome da serie continuar presente.
    ignorados = {"vol", "volume", "edicao", "serie"}
    termos_serie = tokens(titulo_serie) - ignorados
    termos_produto = tokens(titulo) - ignorados
    minimo = min(2, len(termos_serie))
    return minimo > 0 and len(termos_serie & termos_produto) >= minimo


def produto_multiplo(texto):
    normalizado = unicodedata.normalize(
        "NFKD", texto or ""
    ).encode("ascii", "ignore").decode().lower()
    return bool(
        re.search(r"\b(?:kit|combo|box)\b", normalizado)
        or re.search(r"\bvol(?:ume)?s\.?\s*\d+", normalizado)
    )


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
    if dominio == "amazon.com.br":
        encontrados = []
        padrao = re.compile(
            r'<div[^>]*data-asin="([A-Z0-9]{10})"[^>]*data-component-type="s-search-result"[^>]*>'
            r'(.*?)(?=<div[^>]*data-asin="[A-Z0-9]{10}"[^>]*data-component-type="s-search-result"|$)',
            re.I | re.S,
        )
        for bloco in padrao.finditer(html):
            asin, conteudo = bloco.group(1), bloco.group(2)
            titulo_html = re.search(r'<h2[^>]*>(.*?)</h2>', conteudo, re.I | re.S)
            imagem = re.search(r'<img[^>]+class="[^"]*s-image[^"]*"[^>]+src="([^"]+)"', conteudo, re.I)
            if not imagem:
                imagem = re.search(r'<img[^>]+src="([^"]+)"[^>]+class="[^"]*s-image[^"]*"', conteudo, re.I)
            encontrados.append({
                "url": f"https://www.amazon.com.br/dp/{asin}",
                "titulo": limpar(titulo_html.group(1)) if titulo_html else "",
                "urlCapa": unescape(imagem.group(1)) if imagem else None,
            })
        return encontrados
    candidatos = []
    termos = tokens(termo)
    for href in re.findall(r'href=["\']([^"\']+)', html, re.I):
        url = urljoin(url_busca, unescape(href))
        host = (urlparse(url).hostname or "").lower()
        rota = (urlparse(url).path or "").lower()
        if dominio not in host:
            continue
        if dominio == "texasranger.com.br" and (
            not rota.startswith("/produtos/") or rota == "/produtos/"
        ):
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


def extrair_produto(url):
    html = baixar(url)
    titulo = None
    titulo_meta = re.search(r'<meta[^>]+property=["\']og:title["\'][^>]+content=["\']([^"\']+)', html, re.I)
    if titulo_meta:
        titulo = limpar(titulo_meta.group(1))
    else:
        titulo_tag = re.search(r'<title[^>]*>(.*?)</title>', html, re.I | re.S)
        if titulo_tag:
            titulo = limpar(re.sub(r'<[^>]+>', ' ', titulo_tag.group(1)))
    padroes = [
        r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)',
        r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image',
        r'<meta[^>]+name=["\']twitter:image["\'][^>]+content=["\']([^"\']+)',
    ]
    for padrao in padroes:
        achado = re.search(padrao, html, re.I)
        if achado:
            imagem = urljoin(url, unescape(achado.group(1)))
            if imagem.startswith("http://"):
                imagem = "https://" + imagem[len("http://"):]
            if re.match(r"https?://", imagem):
                return imagem, titulo
    return None, titulo


def extrair_capa(url):
    return extrair_produto(url)[0]


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
    if nome == "Texas Ranger":
        licenciador = unicodedata.normalize(
            "NFKD", str(edicao.get("licenciador") or serie.get("licenciador") or "")
        ).encode("ascii", "ignore").decode().lower()
        return "bonelli" in licenciador
    if nome == "Papersera":
        titulo = " ".join(str(valor or "") for valor in (edicao.get("tituloChamada"), serie.get("titulo"))).lower()
        return "carl barks" in titulo or "melhor da disney" in titulo
    return True


def buscar_fonte(nome, dominio, modelo_busca, busca_loja, busca, capas_usadas, titulo, numero):
    if nome == "Papersera" and str(numero or "").isdigit() and ("carl barks" in titulo.lower() or "melhor da disney" in titulo.lower()):
        numero_formatado = f"{int(numero):04d}"
        url_capa = f"https://www.papersera.net/vilaxurupita/misc/br_omd_{numero_formatado}a.jpg"
        if url_capa not in capas_usadas:
            return nome, url_capa, "https://www.papersera.net/vilaxurupita/misc/omd01_20.htm" if int(numero) <= 20 else "https://www.papersera.net/vilaxurupita/misc/omd21_40.htm", None
        return nome, None, None, None
    if nome == "Texas Ranger" and str(numero or "").isdigit():
        busca_loja = f"{titulo} {int(numero):03d}"
    resultados = resultados_loja(busca_loja, dominio, modelo_busca)
    if nome == "Panini":
        # Consulte primeiro o campo de pesquisa com o título exato. Isso
        # encontra especiais como /thor-antologia, que não usam sufixo de
        # volume apesar de aparecerem como nº 1 no Guia.
        exatos = resultados_loja(titulo, dominio, modelo_busca)
        resultados = exatos + [
            item for item in resultados if item.get("url") not in {
                exato.get("url") for exato in exatos
            }
        ]
    if str(numero or "").strip() == "1":
        # Algumas lojas retornam conjuntos diferentes para "volume 1" e
        # apenas "1". Combine as duas consultas para reduzir falsos vazios.
        alternativos = resultados_loja(f"{titulo} 1", dominio, modelo_busca)
        urls_encontradas = {item.get("url") for item in resultados}
        resultados.extend(
            item for item in alternativos if item.get("url") not in urls_encontradas
        )
    if nome == "Amazon":
        resultados.sort(key=pontuacao_amazon, reverse=True)
    if nome == "Panini" and str(numero or "").isdigit():
        url_direta = f"https://panini.com.br/{slug(titulo)}-vol-{int(numero)}"
        resultados.append({"url": url_direta, "titulo": ""})
        if int(numero) == 1:
            # Especiais e antologias de edição única frequentemente são
            # cadastrados como nº 1 no Guia, mas não usam "vol-1" na Panini.
            resultados.append({
                "url": f"https://panini.com.br/{slug(titulo)}",
                "titulo": "",
            })
    if not resultados:
        resultados = resultados_bing(busca, dominio)
    for resultado in resultados:
        if produto_multiplo(f"{resultado.get('titulo') or ''} {resultado['url']}"):
            continue
        if nome == "Amazon" and not titulo_compativel_com_numero(
            resultado.get("titulo"), numero, titulo
        ):
            continue
        if not produto_compativel_com_numero(
            resultado["url"], numero,
            exigir_volume=nome == "Panini" and str(numero or "").strip() != "1",
        ):
            continue
        try:
            if resultado.get("urlCapa"):
                capa, titulo_produto = resultado["urlCapa"], resultado.get("titulo")
            else:
                capa, titulo_produto = extrair_produto(resultado["url"])
        except Exception:
            continue
        if produto_multiplo(f"{titulo_produto or ''} {resultado['url']}"):
            continue
        if nome != "Amazon" and str(numero or "").isdigit():
            tem_numero_url = bool(re.findall(
                r"(?:vol(?:ume)?|n)[-_ ]*0*(\d+)(?:\D|$)",
                urlparse(resultado["url"]).path.lower(),
            ))
            if not tem_numero_url and not titulo_compativel_com_numero(
                titulo_produto, numero, titulo
            ):
                continue
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
        # As lojas catalogam os volumes pelo nome da serie, enquanto o Guia
        # costuma preencher tituloChamada com o subtitulo de cada volume. Usar
        # o subtitulo como termo principal (por exemplo, "Pecados Originais
        # volume 2") elimina resultados que aparecem para "Gideon Falls
        # volume 2".
        titulo_busca = serie.get("titulo") or edicao.get("tituloChamada") or busca
        numero_busca = str(edicao.get("numero") or "").strip()
        busca_loja = titulo_busca
        if numero_busca and numero_busca.upper() not in {"UNICA", "ÚNICA"}:
            busca_loja = f"{titulo_busca} volume {numero_busca}"
        panini_direta_falhou = False
        if fonte_aplicavel("Panini", edicao, serie) and numero_busca.isdigit():
            print(
                f"[CAPA {indice}/{len(dados.get('edicoes', []))}] "
                f"{edicao.get('numero')}: consultando Panini",
                flush=True,
            )
            item["fontesConsultadas"].append("Panini")
            try:
                resultado_panini = buscar_fonte(
                    "Panini", "panini.com.br",
                    "https://panini.com.br/catalogsearch/result/?q={}",
                    busca_loja, busca, capas_usadas, titulo_busca, numero_busca,
                )
            except Exception as erro:
                resultado_panini = None
                item.setdefault("erros", []).append(f"Panini: {erro}")
            if resultado_panini and resultado_panini[1]:
                _, capa_panini, produto_panini, _ = resultado_panini
                edicao["urlCapa"] = capa_panini
                capas_usadas.add(capa_panini)
                encontradas += 1
                item.update({"status": "encontrada", "fonte": "Panini", "url": capa_panini,
                             "urlProduto": produto_panini, "confianca": "alta"})
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
            fontes = oficiais + [fonte for fonte in fontes if fonte[0] not in FONTES_OFICIAIS]
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
