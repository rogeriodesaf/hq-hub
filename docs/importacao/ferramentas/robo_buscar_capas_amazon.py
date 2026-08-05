#!/usr/bin/env python3
"""Pesquisa edições na Amazon e extrai as capas com um navegador visível."""

import argparse
import json
import random
import re
import unicodedata
from datetime import datetime
from pathlib import Path
from time import sleep
from urllib.parse import quote_plus

try:
    from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
    from playwright.sync_api import sync_playwright
except ModuleNotFoundError as erro:
    raise SystemExit("Instale o Playwright: python -m pip install playwright") from erro


def normalizar(texto):
    valor = unicodedata.normalize("NFKD", texto or "")
    valor = "".join(letra for letra in valor if not unicodedata.combining(letra))
    return re.sub(r"[^a-z0-9]+", " ", valor.lower()).strip()


def normalizar_url_produto(url):
    encontrado = re.search(r"/dp/([A-Z0-9]{10})", url or "", re.IGNORECASE)
    return f"https://www.amazon.com.br/dp/{encontrado.group(1).upper()}" if encontrado else None


def titulo_valido(titulo, serie, numero, exclusoes):
    texto = normalizar(titulo)
    termos_serie = [termo for termo in normalizar(serie).split() if len(termo) > 1]
    if not termos_serie or not all(re.search(rf"\b{re.escape(termo)}\b", texto) for termo in termos_serie):
        return False, 0
    if any(normalizar(termo) in texto for termo in exclusoes if normalizar(termo)):
        return False, 0

    rotulados = (
        rf"\bvol(?:ume)?\s*0*{numero}\b",
        rf"\bn(?:umero)?\s*0*{numero}\b",
        rf"\bedicao\s*0*{numero}\b",
    )
    if any(re.search(padrao, texto) for padrao in rotulados):
        return True, 3
    return (True, 1) if re.search(rf"\b0*{numero}\b", texto) else (False, 0)


def precisa_verificacao(page):
    try:
        texto = normalizar(page.locator("body").inner_text(timeout=5000))
        html = page.content().lower()
    except Exception:
        texto = ""
        html = ""
    termos = (
        "robot check",
        "digite os caracteres",
        "insira os caracteres",
        "confirmar que voce nao e um robo",
        "continuar comprando",
    )
    return (
        "validatecaptcha" in page.url.lower()
        or "bm-verify" in html
        or "/_sec/verify" in html
        or any(normalizar(termo) in texto for termo in termos)
    )


def aguardar_verificacao(page):
    if not precisa_verificacao(page):
        return
    print("\nA Amazon solicitou uma verificação no Chrome.")
    print("Conclua-a manualmente; o robô não resolve nem contorna CAPTCHA.")
    input("Quando os resultados aparecerem, pressione ENTER aqui para continuar...")
    page.wait_for_load_state("domcontentloaded", timeout=60000)


def atributo(page, seletor, nome):
    elemento = page.locator(seletor)
    if elemento.count() == 0:
        return None
    valor = elemento.first.get_attribute(nome)
    return valor.strip() if valor and valor.strip() else None


def texto(page, seletor):
    elemento = page.locator(seletor)
    if elemento.count() == 0:
        return None
    valor = elemento.first.inner_text().strip()
    return " ".join(valor.split()) if valor else None


def extrair_capa(page):
    capa = atributo(page, "#landingImage", "data-old-hires")
    if capa:
        return capa

    dinamicas = atributo(page, "#landingImage", "data-a-dynamic-image")
    if dinamicas:
        try:
            imagens = json.loads(dinamicas)
            if isinstance(imagens, dict) and imagens:
                return max(
                    imagens.items(),
                    key=lambda item: (item[1][0] or 0) * (item[1][1] or 0)
                    if isinstance(item[1], list) and len(item[1]) >= 2 else 0,
                )[0]
        except Exception:
            pass

    return atributo(page, "#landingImage", "src") or atributo(page, "meta[property='og:image']", "content")


def candidatos_busca(page, args, numero):
    itens = page.locator("[data-component-type='s-search-result']")
    candidatos = []
    vistos = set()
    for indice in range(min(itens.count(), 30)):
        link = itens.nth(indice).locator("h2 a").first
        if link.count() == 0:
            continue
        url = normalizar_url_produto(link.get_attribute("href"))
        titulo = " ".join((link.inner_text() or "").split())
        valido, pontos = titulo_valido(titulo, args.serie, numero, args.excluir)
        if not url or url in vistos or not valido:
            continue
        vistos.add(url)
        candidatos.append((pontos, url, titulo))
    return sorted(candidatos, key=lambda item: item[0], reverse=True)


def validar_produto(page, candidato, args, numero):
    _, url, titulo_busca = candidato
    page.goto(url, wait_until="domcontentloaded", timeout=args.timeout_ms)
    page.wait_for_timeout(1200)
    aguardar_verificacao(page)
    titulo_produto = texto(page, "#productTitle") or titulo_busca
    valido, _ = titulo_valido(titulo_produto, args.serie, numero, args.excluir)
    if not valido:
        return None
    if args.editora and normalizar(args.editora) not in normalizar(page.locator("body").inner_text(timeout=5000)):
        return None
    capa = extrair_capa(page)
    if not capa:
        return None
    asin = re.search(r"/dp/([A-Z0-9]{10})", url, re.IGNORECASE)
    return {
        "numero": numero,
        "tituloProduto": titulo_produto,
        "urlProduto": url,
        "asin": asin.group(1).upper() if asin else None,
        "urlCapa": capa,
        "status": "ENCONTRADA",
        "erro": None,
    }


def resultado_vazio(numero, erro):
    return {
        "numero": numero,
        "tituloProduto": None,
        "urlProduto": None,
        "asin": None,
        "urlCapa": None,
        "status": "NAO_ENCONTRADA",
        "erro": erro,
    }


def salvar(args, resultados):
    caminho_urls = Path(args.saida_urls)
    caminho_urls.parent.mkdir(parents=True, exist_ok=True)
    caminho_urls.write_text(
        "\n".join(item.get("urlCapa") or "null" for item in resultados) + "\n",
        encoding="utf-8",
    )
    relatorio = {
        "geradoEm": datetime.now().isoformat(timespec="seconds"),
        "serie": args.serie,
        "editora": args.editora,
        "inicio": args.inicio,
        "fim": args.fim,
        "exclusoes": args.excluir,
        "resultados": resultados,
    }
    caminho_relatorio = Path(args.saida_relatorio)
    caminho_relatorio.parent.mkdir(parents=True, exist_ok=True)
    caminho_relatorio.write_text(json.dumps(relatorio, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def abrir_navegador(playwright):
    ultimo_erro = None
    for canal in ("chrome", "msedge", None):
        try:
            opcoes = {"headless": False}
            if canal:
                opcoes["channel"] = canal
            return playwright.chromium.launch(**opcoes)
        except Exception as erro:
            ultimo_erro = erro
    raise RuntimeError(f"Não foi possível abrir Chrome ou Edge: {ultimo_erro}")


def executar(args):
    resultados = []
    with sync_playwright() as playwright:
        navegador = abrir_navegador(playwright)
        contexto = navegador.new_context(locale="pt-BR", viewport={"width": 1365, "height": 900})
        pagina_busca = contexto.new_page()
        pagina_produto = contexto.new_page()
        try:
            for numero in range(args.inicio, args.fim + 1):
                query = f"{args.serie} {numero} {args.editora}".strip()
                url = f"https://www.amazon.com.br/s?k={quote_plus(query)}&i=stripbooks"
                print(f"\nBuscando {args.serie} #{numero}: {query}")
                try:
                    pagina_busca.goto(url, wait_until="domcontentloaded", timeout=args.timeout_ms)
                    pagina_busca.wait_for_timeout(1500)
                    aguardar_verificacao(pagina_busca)
                    encontrado = None
                    for candidato in candidatos_busca(pagina_busca, args, numero)[:args.maximo_candidatos]:
                        encontrado = validar_produto(pagina_produto, candidato, args, numero)
                        if encontrado:
                            break
                    resultados.append(encontrado or resultado_vazio(numero, "Nenhuma correspondência segura."))
                    print("Capa encontrada." if encontrado else "Sem correspondência; gravado null.")
                except PlaywrightTimeoutError:
                    resultados.append(resultado_vazio(numero, "Tempo esgotado ao abrir a Amazon."))
                except Exception as erro:
                    resultados.append(resultado_vazio(numero, str(erro)))
                salvar(args, resultados)
                if numero < args.fim:
                    pausa = random.uniform(args.pausa_minima, args.pausa_maxima)
                    print(f"Aguardando {pausa:.1f} segundo(s)...")
                    sleep(pausa)
        except KeyboardInterrupt:
            print("\nInterrompido pelo usuário; resultados parciais preservados.")
        finally:
            salvar(args, resultados)
            contexto.close()
            navegador.close()

    encontradas = sum(1 for item in resultados if item.get("urlCapa"))
    print(f"\nProcessadas: {len(resultados)} | Capas: {encontradas} | Ausentes: {len(resultados) - encontradas}")
    print(f"TXT: {args.saida_urls}\nRelatório: {args.saida_relatorio}")


def main():
    parser = argparse.ArgumentParser(description="Pesquisa revistas na Amazon e extrai capas com Chrome visível.")
    parser.add_argument("--serie", required=True)
    parser.add_argument("--editora", default="Mythos")
    parser.add_argument("--inicio", type=int, required=True)
    parser.add_argument("--fim", type=int, required=True)
    parser.add_argument("--excluir", action="append", default=[])
    parser.add_argument("--saida-urls", required=True)
    parser.add_argument("--saida-relatorio", required=True)
    parser.add_argument("--pausa-minima", type=float, default=3.0)
    parser.add_argument("--pausa-maxima", type=float, default=6.0)
    parser.add_argument("--maximo-candidatos", type=int, default=6)
    parser.add_argument("--timeout-ms", type=int, default=60000)
    args = parser.parse_args()
    if args.inicio < 1 or args.fim < args.inicio:
        parser.error("Informe um intervalo válido.")
    if args.pausa_minima < 0 or args.pausa_maxima < args.pausa_minima:
        parser.error("Intervalo de pausa inválido.")
    executar(args)


if __name__ == "__main__":
    main()
