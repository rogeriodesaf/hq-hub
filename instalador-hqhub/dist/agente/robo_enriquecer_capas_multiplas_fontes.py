#!/usr/bin/env python3
"""Enriquece um JSON do Guia dos Quadrinhos com capas encontradas na web.

O robô é independente dos coletores existentes e nunca substitui uma capa
existente, salvo quando --substituir é informado. Os resultados ficam
registrados em origem.capasAutomaticas para revisão humana.
"""
import argparse
import base64
import gzip
from concurrent.futures import ThreadPoolExecutor, CancelledError, TimeoutError as FuturesTimeoutError, as_completed
from functools import lru_cache
import json
import re
import unicodedata
from html import unescape
from pathlib import Path
from threading import Event, local
from time import monotonic, sleep
from urllib.parse import parse_qs, parse_qsl, quote, urlencode, urljoin, urlparse, urlunparse
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
    "Mundos Infinitos": ("mundosinfinitos.com.br", "https://mundosinfinitos.com.br/geek/solucoes/busca.aspx?t={}"),
    "Ponto do Gibi": ("pontodogibi.com.br", "https://pontodogibi.com.br/search?q={}"),
    "Texas Ranger": ("texasranger.com.br", "https://texasranger.com.br/search/?q={}"),
    "Papersera": ("papersera.net", "https://www.papersera.net/vilaxurupita/misc/omd01_20.htm"),
    "Planeta Gibi": ("planetagibi.com", "https://www.planetagibi.com/busca?q={}"),
    "Quadrikomics": ("quadrikomics.blogspot.com", "https://quadrikomics.blogspot.com/search?q={}"),
    "Lojas Caverna": ("lojascaverna.com.br", "https://www.lojascaverna.com.br/search/?q={}"),
    "Excelsior Comics": ("excelsiorcomics.com.br", "https://excelsiorcomics.com.br/?s={}&post_type=product"),
    "Sebo RS Raridades": ("seborsraridades.com.br", "https://seborsraridades.com.br/?s={}&post_type=product"),
    "Mania de Gibi": ("maniadegibi.com", "https://maniadegibi.com/?s={}&post_type=product"),
    "Loja Sebo Cultural": ("lojasebocultural.com.br", "https://lojasebocultural.com.br/?s={}&post_type=product"),
    "Touché Livros": ("touchelivros.com.br", "https://www.touchelivros.com.br/?s={}&post_type=product"),
    "DC": ("dc.com", "https://www.dc.com/search?q={}"),
    "Amazon": ("amazon.com.br", "https://www.amazon.com.br/s?k={}"),
}
FONTES_OFICIAIS = {"Panini", "Pipoca & Nanquim", "Mythos", "Loja Mythos", "Devir"}
CONTEXTO_BUSCA = local()


def verificar_cancelamento():
    cancelamento = getattr(CONTEXTO_BUSCA, "cancelamento", None)
    if cancelamento is not None and cancelamento.is_set():
        raise CancelledError()
    prazo = getattr(CONTEXTO_BUSCA, "prazo", None)
    if prazo is not None and monotonic() >= prazo:
        raise TimeoutError("Tempo limite da busca desta edição esgotado.")


def timeout_requisicao(padrao):
    prazo = getattr(CONTEXTO_BUSCA, "prazo", None)
    if prazo is None:
        return padrao
    restante = prazo - monotonic()
    if restante <= 0:
        raise TimeoutError("Tempo limite da busca desta edição esgotado.")
    return min(padrao, restante)


def baixar(url):
    verificar_cancelamento()
    return baixar_cached(url)


def proxy_comix(url):
    """Contorna o bloqueio automatizado da Comix preservando o HTML original."""
    partes = urlparse(url)
    host = (partes.hostname or "").lower()
    if host not in {"comix.com.br", "www.comix.com.br"}:
        return None
    consulta = parse_qsl(partes.query, keep_blank_values=True)
    consulta.extend((
        ("_x_tr_sl", "pt"),
        ("_x_tr_tl", "en"),
        ("_x_tr_hl", "pt-BR"),
    ))
    return urlunparse(partes._replace(
        scheme="https",
        netloc="www-comix-com-br.translate.goog",
        query=urlencode(consulta),
    ))


@lru_cache(maxsize=256)
def baixar_cached(url):
    # Cache limitado a esta execucao. Erros nao ficam armazenados.
    req = Request(url, headers={
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/140.0.0.0 Safari/537.36"
        )
    })
    ultimo_erro = None
    for tentativa in range(2):
        verificar_cancelamento()
        try:
            with urlopen(req, timeout=timeout_requisicao(12)) as resposta:
                conteudo = resposta.read()
                if resposta.headers.get("Content-Encoding", "").lower() == "gzip" or conteudo.startswith(b"\x1f\x8b"):
                    conteudo = gzip.decompress(conteudo)
                return conteudo.decode("utf-8", errors="replace")
        except HTTPError as erro:
            alternativa = proxy_comix(url) if erro.code == 403 else None
            if alternativa:
                try:
                    cabecalhos = dict(req.header_items())
                    with urlopen(Request(alternativa, headers=cabecalhos), timeout=timeout_requisicao(18)) as resposta:
                        conteudo = resposta.read()
                        if resposta.headers.get("Content-Encoding", "").lower() == "gzip" or conteudo.startswith(b"\x1f\x8b"):
                            conteudo = gzip.decompress(conteudo)
                        return conteudo.decode("utf-8", errors="replace")
                except Exception as erro_proxy:
                    ultimo_erro = erro_proxy
                    continue
            if erro.code < 500:
                raise
            ultimo_erro = erro
        except Exception as erro:
            ultimo_erro = erro
        if tentativa == 0:
            verificar_cancelamento()
            sleep(min(0.5, timeout_requisicao(0.5)))
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


def titulo_base_serie(texto):
    """Remove o marcador editorial (1ª série/V1), preservando o título."""
    base = re.sub(r"\s*(?:\d+\s*[aª]?\s*s[ée]rie|v(?:ol(?:ume)?)?\.?\s*\d+)\b", "", texto or "", flags=re.I).strip()
    return re.sub(r"\s*(?:[-–—]\s*)?miniss[ée]rie\s*$", "", base, flags=re.I).strip()


def alias_catalogo_loja(nome_fonte, titulo):
    normalizado = slug(titulo)
    if nome_fonte == "Panini" and normalizado.startswith(
        "batman-o-longo-dia-das-bruxas-o-ultimo-dia-das-bruxas"
    ):
        return "Batman: O Último Dia das Bruxas"
    primeira_serie_mulher_maravilha = bool(re.match(r"mulher-maravilha-1a?-serie(?:-|$)", normalizado))
    if nome_fonte == "Rika" and primeira_serie_mulher_maravilha:
        return "Mulher Maravilha 2017"
    if nome_fonte == "Panini" and primeira_serie_mulher_maravilha:
        return "Mulher-Maravilha 2017"
    return titulo_base_serie(titulo) if nome_fonte == "Panini" else titulo


def titulo_validacao_panini(titulo):
    """Aceita o nome-base quando a Panini omite o subtitulo do produto."""
    base = titulo_base_serie(titulo)
    partes = re.split(r"\s*[:–—]\s*", base, maxsplit=1)
    if len(partes) == 2 and re.search(r"[/&]", partes[0]) and len(tokens(partes[0])) >= 2:
        return partes[0]
    return base


def capa_maior_panini(url):
    """Promove a miniatura do CDN oficial para a maior variante publica."""
    host = (urlparse(url or "").hostname or "").lower()
    if host == "d14d9vp3wdof84.cloudfront.net":
        return re.sub(r"/-S\d+-FWEBP(?:$|\?)", "/-S897-FWEBP", url, flags=re.I)
    return url


def produto_compativel_com_numero(url, numero, exigir_volume=False):
    numero = str(numero or "").strip()
    if not numero.isdigit():
        return True
    volumes = re.findall(
        r"(?:^|[-_/ ])(?:vol(?:ume)?|n)[-_ ]*0*(\d+)(?:\D|$)",
        urlparse(url).path.lower(),
    )
    if volumes:
        return int(numero) in {int(volume) for volume in volumes}
    return not exigir_volume


def titulo_compativel_com_numero(titulo, numero, titulo_serie=None):
    numero = str(numero or "").strip()
    if not numero.isdigit():
        return True
    normalizado = unicodedata.normalize("NFKD", titulo or "")
    normalizado = normalizado.replace("\u2013", "-").replace("\u2014", "-").encode("ascii", "ignore").decode().lower()
    # A Panini imprime numero local e numeracao legada (ex.: 5a Serie 3 - 61).
    # O numero da edicao cadastrada e o primeiro; o segundo nao e outra edicao.
    numeracao_dupla = re.search(
        r"\b\d+a?\s+serie\s+0*(\d+)\s*[-/]\s*0*(\d+)\b",
        normalizado,
    )
    if numeracao_dupla:
        return int(numeracao_dupla.group(1)) == int(numero)
    minisserie = re.search(r"\b0*(\d+)\s*\(\s*de\s+\d+\s*\)", normalizado)
    encontrados = [minisserie.group(1)] if minisserie else re.findall(
        r"(?:\bvol(?:ume)?\.?|\bn[ºo.]?|#)\s*0*(\d+(?:[.,]\d+)?)", normalizado
    )
    if not encontrados:
        numero_final = re.search(r"(?:^|\s)0*(\d+)\s*$", normalizado)
        if numero_final:
            encontrados = [numero_final.group(1)]
    if encontrados:
        return {float(item.replace(',', '.')) for item in encontrados} == {int(numero)}
    if int(numero) != 1 or not titulo_serie:
        return False
    # O primeiro volume muitas vezes e publicado sem "volume 1" no titulo.
    # Nesse caso, aceite-o somente quando o nome da serie continuar presente.
    ignorados = {"vol", "volume", "edicao", "serie"}
    termos_serie = tokens(titulo_serie) - ignorados
    termos_produto = tokens(titulo) - ignorados
    return bool(termos_serie) and termos_serie == termos_produto


def titulo_compativel_com_serie_e_fase(titulo_produto, titulo_serie, busca):
    termos_serie = {t for t in tokens(titulo_serie) if not t.isdigit()} - {"volume", "serie", "edicao"}
    termos_produto = tokens(titulo_produto)
    if not termos_serie or not termos_serie.issubset(termos_produto):
        return False
    normalizar = lambda valor: unicodedata.normalize("NFKD", valor or "").encode(
        "ascii", "ignore"
    ).decode().lower()
    fase_busca = re.search(r'\b(\d+)[a]?\s+serie\b', normalizar(busca))
    fase_produto = re.search(r'\b(\d+)[a]?\s+serie\b', normalizar(titulo_produto))
    if fase_busca and (not fase_produto or fase_busca.group(1) != fase_produto.group(1)):
        return False
    variante = {"variante", "variant"}
    if termos_produto & variante and not tokens(busca) & variante:
        return False
    # Nomes curtos como Batman/Superman existem em varias colecoes. Use o
    # contexto editorial para impedir colisao entre arcos e linhas distintas.
    contextos_distintivos = (
        {"ano", "viloes"},
        {"melhores", "mundo"},
        {"cavaleiros", "trevas", "aco"},
    )
    termos_busca = tokens(busca)
    for contexto in contextos_distintivos:
        if contexto.issubset(termos_busca) != contexto.issubset(termos_produto):
            return False
    return True


def editora_compativel_com_busca(editora_produto, busca):
    """Confere a marca informada pela loja quando a consulta traz a editora."""
    if not editora_produto:
        return True
    partes = re.findall(r'"([^"]+)"', busca or "")
    if len(partes) < 2:
        return True
    ignorados = {"editora", "comics", "brasil", "books"}
    termos_editora = lambda valor: set(re.findall(r"[a-z0-9]+", slug(valor).replace("-", " "))) - ignorados
    esperada = termos_editora(partes[1])
    encontrada = termos_editora(editora_produto)
    return not esperada or bool(encontrada) and (
        esperada.issubset(encontrada) or encontrada.issubset(esperada)
    )


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
            url = unescape(link.group(1))
            partes = urlparse(url)
            if (partes.hostname or "").lower().endswith("bing.com"):
                destino = parse_qs(partes.query).get("u", [""])[0]
                if destino.startswith("a1"):
                    codificado = destino[2:]
                    try:
                        url = base64.urlsafe_b64decode(
                            codificado + "=" * (-len(codificado) % 4)
                        ).decode("utf-8")
                    except (ValueError, UnicodeDecodeError):
                        continue
            host = (urlparse(url).hostname or "").lower()
            if host != dominio and not host.endswith("." + dominio):
                continue
            encontrados.append({"url": url, "titulo": limpar(titulo.group(1)) if titulo else ""})
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
        if host != dominio and not host.endswith('.' + dominio):
            continue
        if dominio == "texasranger.com.br" and (
            not rota.startswith("/produtos/") or rota == "/produtos/"
        ):
            continue
        if dominio == "lojascaverna.com.br" and not rota.startswith("/produtos/"):
            continue
        if dominio in {
            "excelsiorcomics.com.br",
            "seborsraridades.com.br",
            "maniadegibi.com",
            "lojasebocultural.com.br",
            "touchelivros.com.br",
        } and not rota.startswith("/produto/"):
            continue
        if dominio == "dc.com" and not rota.startswith("/comics/"):
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
    def pontuar_url(url):
        rota = urlparse(url).path
        termos_rota = tokens(rota)
        numeros_consulta = {int(item) for item in termos if item.isdigit()}
        numeros_rota = {int(item) for item in termos_rota if item.isdigit()}
        return (
            20 if rota.startswith(("/produto/", "/produtos/")) else 0,
            5 if numeros_consulta and numeros_consulta & numeros_rota else 0,
            len(termos & termos_rota),
        )
    candidatos.sort(key=pontuar_url, reverse=True)
    resultados = [{"url": url, "titulo": ""} for url in candidatos[:12]]
    if dominio == "mundosinfinitos.com.br":
        # Produtos antigos podem aparecer apenas na navegacao da colecao.
        # Abra os primeiros produtos encontrados e incorpore os volumes
        # relacionados, preservando o texto do link para validar o numero.
        relacionados = []
        vistos = {item["url"] for item in resultados}
        produtos = [
            item for item in resultados
            if urlparse(item["url"]).path.lower().startswith("/geek/produto/")
        ][:3]
        for produto in produtos:
            try:
                pagina = baixar(produto["url"])
            except (OSError, ValueError):
                continue
            for ancora in re.finditer(
                r'<a\b[^>]*href=["\']([^"\']+)["\'][^>]*>(.*?)</a>',
                pagina, re.I | re.S,
            ):
                url_relacionada = urljoin(produto["url"], unescape(ancora.group(1)))
                partes = urlparse(url_relacionada)
                url_relacionada = partes._replace(fragment="").geturl()
                if ((partes.hostname or "").lower() != dominio
                        or not partes.path.lower().startswith("/geek/produto/")):
                    continue
                titulo_relacionado = limpar(ancora.group(2))
                if url_relacionada in vistos or not titulo_relacionado:
                    continue
                relacionados.append({
                    "url": url_relacionada,
                    "titulo": titulo_relacionado,
                })
                vistos.add(url_relacionada)
        numeros_consulta = {int(item) for item in termos if item.isdigit()}
        relacionados.sort(key=lambda item: (
            bool(numeros_consulta & {
                int(numero) for numero in tokens(
                    f'{item["titulo"]} {urlparse(item["url"]).path}'
                ) if numero.isdigit()
            }),
            len(termos & tokens(f'{item["titulo"]} {item["url"]}')),
        ), reverse=True)
        resultados = relacionados + resultados
    return resultados[:12]


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
    texto_pagina = limpar(html)
    arco = re.search(
        r"(?:Esta edi[cç][aã]o pertence ao arco|This edition belongs to the arc):\s*"
        r"(.{1,100}?)\s+(?:Tipo de Produto|Product Type)",
        texto_pagina,
        re.I,
    )
    if titulo and arco:
        titulo = f"{titulo} | {arco.group(1).strip()}"
    padroes = [
        r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)',
        r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image',
        r'<meta[^>]+name=["\']twitter:image["\'][^>]+content=["\']([^"\']+)',
        r'<link[^>]+itemprop=["\']image["\'][^>]+href=["\']([^"\']+)',
    ]
    for padrao in padroes:
        achado = re.search(padrao, html, re.I)
        if achado:
            imagem = urljoin(url, unescape(achado.group(1)))
            if imagem.startswith("http://"):
                imagem = "https://" + imagem[len("http://"):]
            if re.match(r"https?://", imagem):
                return capa_maior_panini(imagem), titulo
    for bloco in re.findall(
        r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
        html, re.I | re.S,
    ):
        try:
            dados = json.loads(unescape(bloco))
        except (TypeError, ValueError):
            continue
        if not isinstance(dados, dict) or dados.get("@type") != "Product":
            continue
        titulo = limpar(dados.get("name")) or titulo
        imagem = dados.get("image")
        if isinstance(imagem, list):
            imagem = next((item for item in imagem if isinstance(item, str)), None)
        if isinstance(imagem, str):
            imagem = urljoin(url, imagem)
            if imagem.startswith("http://"):
                imagem = "https://" + imagem[len("http://"):]
            if re.match(r"https?://", imagem):
                return capa_maior_panini(imagem), titulo
    termos_titulo = tokens(titulo) - {"dc"}
    for tag in re.findall(r'<img\b[^>]*>', html, re.I):
        alt = re.search(r'\balt=["\']([^"\']+)', tag, re.I)
        src = re.search(r'\bsrc=["\']([^"\']+)', tag, re.I)
        if not alt or not src or not termos_titulo:
            continue
        if termos_titulo != tokens(unescape(alt.group(1))):
            continue
        imagem = urljoin(url, unescape(src.group(1)))
        imagem = re.sub(r"\?w=\d+$", "", imagem)
        if re.match(r"https?://", imagem):
            return capa_maior_panini(imagem), titulo
    return None, titulo


def extrair_capa(url):
    return extrair_produto(url)[0]


def _resultados_rika_consulta(titulo):
    resultados = []
    for inicio in range(0, 200, 50):
        produtos = json.loads(baixar(
            'https://www.rika.com.br/api/catalog_system/pub/products/search/?ft='
            + quote(titulo) + f'&_from={inicio}&_to={inicio + 49}'
        ))
        if not isinstance(produtos, list):
            break
        for produto in produtos:
            imagens = [imagem.get('imageUrl') for sku in produto.get('items', [])
                       for imagem in sku.get('images', []) if imagem.get('imageUrl')]
            if imagens and produto.get('link'):
                resultados.append({'url': produto['link'], 'titulo': produto.get('productName', ''),
                                   'urlCapa': imagens[0], 'editora': produto.get('brand')})
        if len(produtos) < 50:
            break
    return resultados


def resultados_rika(titulo):
    """Reutiliza o catalogo e repete sem acentos quando a VTEX ignora a busca."""
    resultados = _resultados_rika_consulta(titulo)
    termos_titulo = tokens(titulo) - {"volume", "serie", "edicao", "minisserie"}
    encontrou_serie = any(
        termos_titulo and termos_titulo.issubset(tokens(item.get("titulo")))
        for item in resultados
    )
    titulo_ascii = unicodedata.normalize("NFKD", titulo or "").encode(
        "ascii", "ignore"
    ).decode()
    if encontrou_serie or titulo_ascii == titulo:
        return resultados

    # A API VTEX da Rika pode devolver o catalogo inteiro para termos
    # acentuados (por exemplo, "Maldição"). A consulta ASCII encontra a série.
    alternativos = _resultados_rika_consulta(titulo_ascii)
    urls = {item.get("url") for item in alternativos}
    return alternativos + [item for item in resultados if item.get("url") not in urls]


def resultados_rika_adjacentes(resultados, numero):
    """Infere paginas sequenciais que a API VTEX oculta quando estao esgotadas."""
    if not str(numero or "").isdigit():
        return []
    alvo = int(numero)
    candidatos = []
    for resultado in resultados:
        atual = re.search(r"#\s*0*(\d+)\b", resultado.get("titulo") or "")
        if not atual or abs(alvo - int(atual.group(1))) > 12:
            continue
        partes = re.match(r"^(.*--)(\d+)(-?)(\d{8})/p$", resultado.get("url") or "")
        if not partes or int(partes.group(2)) != int(atual.group(1)):
            continue
        referencia = int(partes.group(4)) + alvo - int(atual.group(1))
        if referencia <= 0:
            continue
        url = f"{partes.group(1)}{alvo:0{len(partes.group(2))}d}{partes.group(3)}{referencia:08d}/p"
        if url not in {item["url"] for item in candidatos}:
            candidatos.append({"url": url, "titulo": "", "inferido": True})
    return candidatos


def marca_produto_rika(url):
    """Confirma a editora dos produtos inferidos, ausentes da busca VTEX."""
    html = baixar(url)
    for bloco in re.findall(
        r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
        html, re.I | re.S,
    ):
        try:
            dados = json.loads(unescape(bloco))
        except (TypeError, ValueError):
            continue
        if isinstance(dados, dict) and dados.get("@type") == "Product":
            marca = dados.get("brand")
            return marca.get("name") if isinstance(marca, dict) else marca
    return None


def buscar_quadrikomics(busca_loja, busca, capas_usadas, titulo, numero):
    """Encontra a capa pela galeria de uma postagem do Quadrikomics."""
    partes_busca = re.findall(r'"([^"]+)"', busca)
    consulta_site = " ".join(partes_busca[:2]) if len(partes_busca) > 1 else titulo
    consulta_classificacao = " ".join(partes_busca[:-1]) if len(partes_busca) > 1 else titulo
    resultados = []
    try:
        feed = json.loads(baixar(
            "https://quadrikomics.blogspot.com/feeds/posts/default?q="
            + quote(consulta_site) + "&alt=json&max-results=50"
        ))
        for entrada in feed.get("feed", {}).get("entry", []):
            link = next(
                (item.get("href") for item in entrada.get("link", [])
                 if item.get("rel") == "alternate"),
                None,
            )
            if link:
                resultados.append({
                    "url": link,
                    "titulo": entrada.get("title", {}).get("$t", ""),
                })
        termos_consulta = tokens(consulta_classificacao)
        consulta_ascii = unicodedata.normalize("NFKD", consulta_classificacao).encode(
            "ascii", "ignore"
        ).decode().lower()
        fase_consulta = re.search(r'\b(\d+)[a]?\s+serie\b', consulta_ascii)
        def pontuar_resultado(item):
            pontos = len(termos_consulta & tokens(item.get("titulo")))
            titulo_ascii = unicodedata.normalize("NFKD", item.get("titulo") or "").encode(
                "ascii", "ignore"
            ).decode().lower()
            fase_resultado = re.search(r'\b(\d+)[a]?\s+serie\b', titulo_ascii)
            if fase_consulta and fase_resultado and fase_consulta.group(1) == fase_resultado.group(1):
                pontos += 100
            return pontos
        resultados.sort(
            key=pontuar_resultado,
            reverse=True,
        )
    except Exception:
        resultados = []
    if not resultados:
        resultados = resultados_bing(busca, "quadrikomics.blogspot.com")
    numero_texto = str(numero or "").strip()
    if not numero_texto.isdigit():
        return "Quadrikomics", None, None, None
    termos_titulo = tokens(titulo) - {"volume", "serie", "edicao"}
    for resultado in resultados:
        try:
            html = baixar(resultado["url"])
        except Exception:
            continue
        titulo_pagina = re.search(r'<title[^>]*>(.*?)</title>', html, re.I | re.S)
        termos_pagina = tokens(limpar(titulo_pagina.group(1))) if titulo_pagina else set()
        if termos_titulo and not termos_titulo.issubset(termos_pagina):
            continue
        corpo = re.search(
            r'<div[^>]+class=["\'][^"\']*post-body[^"\']*["\'][^>]*>(.*?)'
            r'<div[^>]+class=["\'][^"\']*post-footer',
            html,
            re.I | re.S,
        )
        trecho = corpo.group(1) if corpo else html
        imagens, identificadores = [], set()
        for imagem in re.findall(r'(?:src|href)=["\'](https?://[^"\']+)', trecho, re.I):
            imagem = unescape(imagem).replace("&amp;", "&")
            host = (urlparse(imagem).hostname or "").lower()
            if "googleusercontent.com" not in host and "blogspot.com" not in host:
                continue
            caminho = urlparse(imagem).path
            identificador = re.search(r'/AVvXs[^/]+', caminho)
            chave = identificador.group(0) if identificador else re.sub(
                r'/s\d+(?:-[^/]+)?/', "/", caminho
            )
            if chave in identificadores:
                continue
            identificadores.add(chave)
            nome = unescape(caminho.rsplit("/", 1)[-1]).lower()
            if not re.search(r'bat(?:man)?|(?:^|[+_ -])0*\d{1,3}(?:[+_. -]|$)', nome):
                continue
            # Nunca use a posicao da imagem: faltas e variantes deslocam a galeria.
            numeros = re.findall(r'(?:^|[+_ -])0*(\d+)(?=\.[a-z]+$|[+_ -]|$)', nome)
            if len(numeros) == 1 and int(numeros[0]) == int(numero_texto):
                imagens.append(imagem)
        if len(imagens) == 1:
            capa = imagens[0]
            if capa not in capas_usadas:
                return "Quadrikomics", capa, resultado["url"], None
    return "Quadrikomics", None, None, None


def consulta(edicao, serie):
    numero = edicao.get("numero", "")
    titulo = serie.get("titulo") or edicao.get("tituloChamada") or ""
    editora = edicao.get("editora") or serie.get("editora") or ""
    fase = str(edicao.get("fase") or serie.get("fase") or "").strip()
    if not fase:
        descricao = str(edicao.get("descricao") or "")
        arco = re.search(r"(?:^|\n)\s*Arco:\s*([^\n]+)", descricao, re.I)
        if arco:
            fase = arco.group(1).strip()
    parte_fase = f' "{fase}"' if fase else ""
    return f'"{titulo}" "{editora}"{parte_fase} "{numero}"'


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
        return "melhor da disney" in titulo and "abril" in editora
    return True


def buscar_fonte(nome, dominio, modelo_busca, busca_loja, busca, capas_usadas, titulo, numero):
    if nome == "Quadrikomics":
        return buscar_quadrikomics(
            busca_loja, busca, capas_usadas, titulo, numero
        )
    if nome == "Papersera" and str(numero or "").isdigit() and 1 <= int(numero) <= 41 and "melhor da disney" in titulo.lower():
        numero_formatado = f"{int(numero):04d}"
        url_capa = f"https://www.papersera.net/vilaxurupita/misc/br_omd_{numero_formatado}a.jpg"
        if url_capa not in capas_usadas:
            return nome, url_capa, "https://www.papersera.net/vilaxurupita/misc/omd01_20.htm" if int(numero) <= 20 else "https://www.papersera.net/vilaxurupita/misc/omd21_40.htm", None
        return nome, None, None, None
    if nome == "Texas Ranger" and str(numero or "").isdigit():
        busca_loja = f"{titulo} {int(numero):03d}"
    if nome == "Rika":
        try:
            resultados = resultados_rika(alias_catalogo_loja(nome, titulo))
        except (OSError, ValueError):
            resultados = []
        # A VTEX mistura editoras homonimas (ex.: Superman 3a Serie
        # Panini/Ebal). Uma edicao da outra editora nao deve impedir a
        # inferencia do produto Panini ausente dos primeiros resultados.
        resultados = [
            item for item in resultados
            if editora_compativel_com_busca(item.get("editora"), busca)
        ]
        if not resultados:
            resultados = resultados_loja(busca_loja, dominio, modelo_busca)
        elif str(numero or "").isdigit() and not any(
            titulo_compativel_com_numero(item.get("titulo"), numero, titulo)
            and titulo_compativel_com_serie_e_fase(item.get("titulo"), titulo, busca)
            for item in resultados
        ):
            resultados.extend(resultados_rika_adjacentes(resultados, numero))
    elif nome == "Mundos Infinitos":
        # A busca da loja interpreta "volume" literalmente e deixa de
        # mostrar colecoes antigas. O titulo seguido apenas do numero encontra
        # a colecao, cuja navegacao revela a pagina de cada edicao.
        termo = f"{titulo} {numero}" if str(numero or "").isdigit() else titulo
        resultados = resultados_loja(termo, dominio, modelo_busca)
        colecao = resultados_loja(titulo, dominio, modelo_busca)
        urls_encontradas = {item.get("url") for item in resultados}
        resultados.extend(
            item for item in colecao if item.get("url") not in urls_encontradas
        )
    elif nome == "Comix":
        # A busca Magento da Comix pode devolver somente categorias mesmo
        # quando existe uma pagina de produto exata. Priorize o indice externo
        # e use a busca interna apenas quando ele nao localizar o produto.
        try:
            resultados = resultados_bing(busca, dominio)
        except (OSError, ValueError):
            resultados = []
        if not resultados:
            resultados = resultados_loja(busca_loja, dominio, modelo_busca)
        if str(numero or "").isdigit():
            # Muitos produtos da Comix seguem o slug titulo-n-01.html. A
            # pagina individual confirma numero e arco e evita homonimos.
            url_direta = (
                f"https://www.comix.com.br/{slug(titulo_base_serie(titulo))}"
                f"-n-{int(numero):02d}.html"
            )
            resultados = [{"url": url_direta, "titulo": ""}] + [
                item for item in resultados if item.get("url") != url_direta
            ]
    else:
        resultados = resultados_loja(busca_loja, dominio, modelo_busca)
    if nome in {
        "Lojas Caverna",
        "Excelsior Comics",
        "Sebo RS Raridades",
        "Mania de Gibi",
        "Loja Sebo Cultural",
        "Touché Livros",
    } and str(numero or "").isdigit():
        fase = re.findall(r'"([^"]+)"', busca)
        fase = fase[-2] if len(fase) >= 4 else ""
        titulo_ascii = unicodedata.normalize("NFKD", titulo).encode(
            "ascii", "ignore"
        ).decode()
        marcador_serie = re.search(r"\b(\d+)\s*a?\s+serie\b", titulo_ascii, re.I)
        titulo_sem_serie = titulo_base_serie(titulo)
        consultas = [
            f"{titulo} {int(numero)}",
            f"{titulo} n {int(numero):02d}",
            f"{titulo} {fase} {int(numero):02d}" if fase else "",
            # A busca WordPress da Excelsior nao encontra "6ª Série", mas o
            # proprio catalogo responde a "Batman 6 1". A validacao posterior
            # ainda exige que titulo, fase e numero sejam exatamente os alvos.
            f"{titulo_sem_serie} {marcador_serie.group(1)} {int(numero)}"
            if marcador_serie else "",
        ]
        urls_encontradas = {item.get("url") for item in resultados}
        for termo in consultas:
            if not termo:
                continue
            for item in resultados_loja(termo, dominio, modelo_busca):
                if item.get("url") not in urls_encontradas:
                    resultados.append(item)
                    urls_encontradas.add(item.get("url"))
    if nome == "Panini":
        # Consulte primeiro o campo de pesquisa com o título exato. Isso
        # encontra especiais como /thor-antologia, que não usam sufixo de
        # volume apesar de aparecerem como nº 1 no Guia.
        titulo_panini = alias_catalogo_loja(nome, titulo)
        exatos = resultados_loja(titulo_panini, dominio, modelo_busca)
        titulo_indice = titulo_validacao_panini(titulo_panini)
        if titulo_indice != titulo_panini:
            encontrados_reduzidos = resultados_loja(
                titulo_indice, dominio, modelo_busca
            )
            urls_reduzidas = {
                item.get("url") for item in encontrados_reduzidos
            }
            exatos = encontrados_reduzidos + [
                item for item in exatos
                if item.get("url") not in urls_reduzidas
            ]
        resultados = exatos + [
            item for item in resultados if item.get("url") not in {
                exato.get("url") for exato in exatos
            }
        ]
        try:
            externos = resultados_bing(f'"{titulo_indice}"', dominio)
        except (OSError, ValueError):
            externos = []
        urls_encontradas = {item.get("url") for item in resultados}
        resultados.extend(
            item for item in externos if item.get("url") not in urls_encontradas
        )
    if str(numero or "").strip() == "1" and nome != "Rika":
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
        url_direta = f"https://panini.com.br/{slug(titulo_panini)}-vol-{int(numero)}"
        resultados.append({"url": url_direta, "titulo": ""})
        if slug(titulo_panini) == "batman-o-ultimo-dia-das-bruxas":
            resultados.append({
                "url": f"https://panini.com.br/{slug(titulo_panini)}-{int(numero):02d}",
                "titulo": "",
            })
        # Minisserias recentes usam slugs como "-03-de-4", nao "-vol-3".
        for total in range(int(numero), 13):
            resultados.append({
                "url": f"https://panini.com.br/{slug(titulo_panini)}-{int(numero):02d}-de-{total}",
                "titulo": "",
            })
        if int(numero) == 1:
            # Especiais e antologias de edição única frequentemente são
            # cadastrados como nº 1 no Guia, mas não usam "vol-1" na Panini.
            resultados.append({
                "url": f"https://panini.com.br/{slug(titulo_panini)}",
                "titulo": "",
            })
    if not resultados:
        resultados = resultados_bing(busca, dominio)
    for resultado in resultados:
        verificar_cancelamento()
        if nome == "Rika":
            try:
                editora_resultado = (
                    marca_produto_rika(resultado["url"])
                    if resultado.get("inferido") else resultado.get("editora")
                )
            except Exception:
                continue
            if resultado.get("inferido") and not editora_resultado:
                continue
            if not editora_compativel_com_busca(editora_resultado, busca):
                continue
        if produto_multiplo(f"{resultado.get('titulo') or ''} {resultado['url']}"):
            continue
        if nome == "Amazon" and not titulo_compativel_com_numero(
            resultado.get("titulo"), numero, titulo
        ):
            continue
        if not produto_compativel_com_numero(
            resultado["url"], numero,
            exigir_volume=False,
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
        alias_titulo = alias_catalogo_loja(nome, titulo)
        titulo_validacao = titulo_validacao_panini(alias_titulo) if nome in {
            "Panini", "Mundos Infinitos"
        } else (
            titulo_base_serie(titulo) if nome == "Rika" else titulo
        )
        busca_validacao = titulo_validacao if alias_titulo != titulo else busca
        if not titulo_produto or not titulo_compativel_com_serie_e_fase(
            titulo_produto, titulo_validacao, busca_validacao
        ):
            continue
        if nome != "Amazon" and str(numero or "").isdigit():
            numero_compativel = titulo_compativel_com_numero(
                titulo_produto, numero, titulo_validacao
            )
            termos_base = tokens(titulo_validacao) - {"volume", "serie", "edicao"}
            termos_produto = tokens(titulo_produto) - {"volume", "serie", "edicao"}
            complemento_editorial_rika = (
                nome == "Rika" and int(numero) == 1
                and termos_produto - termos_base <= {"outras", "historias"}
                and termos_base.issubset(termos_produto)
                and not re.search(r"(?:\bvol(?:ume)?\.?|\bn[ºo.]?|#)\s*\d+", titulo_produto, re.I)
            )
            numero_compativel = numero_compativel or complemento_editorial_rika
            especial_panini = (
                nome == "Panini" and int(numero) == 1
                and titulo_compativel_com_serie_e_fase(
                    titulo_produto, titulo_validacao, busca_validacao
                )
                and not re.search(
                    r"(?:\bvol(?:ume)?\.?|\bn[ºo.]?|#)\s*\d+",
                    titulo_produto, re.I,
                )
            )
            if not numero_compativel and not especial_panini:
                continue
        if capa and capa not in capas_usadas:
            return nome, capa, resultado["url"], None
    return nome, None, None, None


def consultar_fontes(executor, fontes, busca_loja, busca, capas_usadas, titulo, numero, item, tempo_limite_segundos=45):
    """Aceita o primeiro resultado validado sem bloquear por uma loja lenta."""
    cancelamento = Event()
    usadas = frozenset(capas_usadas)
    prazo = monotonic() + tempo_limite_segundos

    def executar(fonte):
        CONTEXTO_BUSCA.cancelamento = cancelamento
        CONTEXTO_BUSCA.prazo = prazo
        try:
            verificar_cancelamento()
            return buscar_fonte(*fonte, busca_loja, busca, usadas, titulo, numero)
        finally:
            CONTEXTO_BUSCA.cancelamento = None
            CONTEXTO_BUSCA.prazo = None

    tarefas = {executor.submit(executar, fonte): fonte[0] for fonte in fontes}
    try:
        for tarefa in as_completed(tarefas, timeout=tempo_limite_segundos):
            nome = tarefas[tarefa]
            try:
                resposta = tarefa.result()
            except Exception as erro:
                item.setdefault("erros", []).append(f"{nome}: {erro}")
                continue
            if resposta and resposta[1]:
                return resposta
        return None
    except FuturesTimeoutError:
        item.setdefault("erros", []).append(f"Tempo limite de {tempo_limite_segundos:g} segundos esgotado para esta edição.")
        return None
    finally:
        cancelamento.set()
        for tarefa in tarefas:
            tarefa.cancel()


def enriquecer(args):
    baixar_cached.cache_clear()
    # O mesmo pool atende todas as edicoes: no maximo seis consultas ativas.
    # Requisicoes HTTP ja iniciadas respeitam o timeout existente ao encerrar.
    try:
        with ThreadPoolExecutor(max_workers=6) as executor:
            enriquecer_com_executor(args, executor)
    finally:
        baixar_cached.cache_clear()


def enriquecer_com_executor(args, executor):
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
    edicoes = dados.get("edicoes", [])
    edicoes.sort(key=lambda edicao: (
        0, int(str(edicao.get("numero") or "").strip())
    ) if str(edicao.get("numero") or "").strip().isdigit() else (
        1, str(edicao.get("numero") or "").strip()
    ))
    serie = dados.get("serieBrasileira", {})
    relatorio, avisos = [], list(dados.get("avisos") or [])
    encontradas = 0
    mantidas = 0
    capas_usadas = set()

    total_edicoes = len(edicoes)
    for indice, edicao in enumerate(edicoes, 1):
        capa_atual = str(edicao.get("urlCapa") or "").strip()
        capa_do_guia = "guiadosquadrinhos.com" in capa_atual.lower()
        if capa_atual and not capa_do_guia and not args.substituir:
            mantidas += 1
            capas_usadas.add(capa_atual)
            relatorio.append({"numero": edicao.get("numero"), "status": "mantida", "url": edicao["urlCapa"]})
            print(f"[{indice}/{total_edicoes}] {edicao.get('numero')}: mantida", flush=True)
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
        fontes = [
            (nome, dominio, modelo_busca)
            for nome, (dominio, modelo_busca) in FONTES.items()
            if fonte_aplicavel(nome, edicao, serie)
        ]
        oficiais = [fonte for fonte in fontes if fonte[0] in FONTES_OFICIAIS]
        if oficiais:
            fontes = oficiais + [fonte for fonte in fontes if fonte[0] not in FONTES_OFICIAIS]
        item["fontesConsultadas"] = [fonte[0] for fonte in fontes]
        print(
            f"[CAPA {indice}/{total_edicoes}] {edicao.get('numero')}: "
            f"consultando em paralelo: {', '.join(item['fontesConsultadas'])}",
            flush=True,
        )
        tempo_limite = getattr(args, "tempo_limite_edicao", 45)
        prazo_edicao = monotonic() + tempo_limite
        resposta = None
        # A 3a serie do Superman tem homonimos de outras editoras e fases.
        # A Rika identifica explicitamente serie, numero e editora; so depois
        # de esgotar essa verificacao consultamos as fontes menos especificas.
        editora_busca = str(edicao.get("editora") or serie.get("editora") or "")
        if (slug(titulo_busca) in {"superman-3a-serie", "superman-3-serie"}
                and slug(editora_busca).startswith("panini")):
            rika = [fonte for fonte in fontes if fonte[0] == "Rika"]
            if rika:
                resposta = consultar_fontes(
                    executor, rika, busca_loja, busca, capas_usadas,
                    titulo_busca, numero_busca, item, min(15, tempo_limite),
                )
                fontes = [fonte for fonte in fontes if fonte[0] != "Rika"]
        restante = prazo_edicao - monotonic()
        if not resposta and fontes and restante > 0:
            resposta = consultar_fontes(
                executor, fontes, busca_loja, busca, capas_usadas,
                titulo_busca, numero_busca, item, restante,
            )
        if resposta and resposta[1]:
            nome, capa, url_produto, _ = resposta
            edicao["urlCapa"] = capa
            capas_usadas.add(capa)
            encontradas += 1
            item.update({"status": "encontrada", "fonte": nome, "url": capa,
                         "urlProduto": url_produto,
                         "confianca": "alta" if nome == "Panini" else "media"})
        sleep(args.intervalo_segundos)
        if item["status"] != "encontrada":
            avisos.append(f"Capa não encontrada para edição {edicao.get('numero')}")
        relatorio.append(item)
        detalhe = f" via {item['fonte']}" if item.get("fonte") else ""
        print(f"[{indice}/{total_edicoes}] {edicao.get('numero')}: {item['status']}{detalhe}", flush=True)

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
    parser.add_argument("--tempo-limite-edicao", type=float, default=45,
                        help="Prazo máximo de busca por edição, em segundos (padrão: 45).")
    args = parser.parse_args()
    if args.tempo_limite_edicao <= 0:
        parser.error("--tempo-limite-edicao deve ser maior que zero.")
    enriquecer(args)


if __name__ == "__main__":
    main()
