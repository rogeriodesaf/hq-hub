#!/usr/bin/env python3
"""Coleta capas sequenciais da Panini e atualiza uma serie no catalogo HQ-HUB."""

import argparse
import json
import os
import re
import sys
from html import unescape
from time import sleep
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


AGENTE = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) HQ-HUB/1.0"


def requisicao_json(url, token, metodo="GET", dados=None, timeout=60):
    corpo = None if dados is None else json.dumps(dados).encode("utf-8")
    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {token}",
        "User-Agent": AGENTE,
    }
    if corpo is not None:
        headers["Content-Type"] = "application/json"
    with urlopen(Request(url, data=corpo, headers=headers, method=metodo), timeout=timeout) as resposta:
        conteudo = resposta.read().decode("utf-8")
        return json.loads(conteudo) if conteudo else None


def buscar_html(url, tentativas):
    ultimo_erro = None
    for tentativa in range(1, tentativas + 1):
        try:
            requisicao = Request(
                url,
                headers={
                    "User-Agent": AGENTE,
                    "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8",
                },
            )
            with urlopen(requisicao, timeout=40) as resposta:
                return resposta.read().decode("utf-8", errors="replace")
        except (HTTPError, URLError, TimeoutError) as erro:
            ultimo_erro = erro
            if tentativa < tentativas:
                sleep(2 * tentativa)
    raise ultimo_erro


def extrair_titulo(html):
    encontrado = re.search(r"<title[^>]*>(.*?)</title>", html, re.IGNORECASE | re.DOTALL)
    return unescape(re.sub(r"\s+", " ", encontrado.group(1))).strip() if encontrado else ""


def extrair_capa(html):
    padroes = (
        r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)',
        r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image["\']',
        r'<link[^>]+itemprop=["\']image["\'][^>]+href=["\']([^"\']+)',
    )
    for padrao in padroes:
        encontrado = re.search(padrao, html, re.IGNORECASE)
        if encontrado:
            url = unescape(encontrado.group(1)).strip()
            return re.sub(r"/-S\d+-FWEBP$", "/-S897-f.webp", url, flags=re.IGNORECASE)
    return None


def paginas_api(backend_url, token, rota, parametros):
    pagina = 0
    itens = []
    while True:
        consulta = urlencode({**parametros, "pagina": pagina, "tamanho": 100})
        resposta = requisicao_json(f"{backend_url.rstrip('/')}{rota}?{consulta}", token)
        itens.extend(resposta.get("itens", []))
        if pagina + 1 >= resposta.get("totalPaginas", 0):
            return itens
        pagina += 1


def localizar_serie(backend_url, token, serie_id, busca_serie):
    if serie_id:
        return requisicao_json(f"{backend_url.rstrip('/')}/api/series/{serie_id}", token)

    series = paginas_api(backend_url, token, "/api/series", {"busca": busca_serie})
    busca_normalizada = normalizar(busca_serie)
    exatas = [serie for serie in series if normalizar(serie.get("titulo")) == busca_normalizada]
    candidatas = exatas or series
    if len(candidatas) != 1:
        detalhes = "; ".join(
            f"id={serie.get('id')} titulo={serie.get('titulo')} volume={serie.get('volume')}"
            for serie in candidatas
        ) or "nenhuma serie encontrada"
        raise ValueError(
            f"A busca '{busca_serie}' nao identificou uma unica serie: {detalhes}. "
            "Use --serie-id para escolher a serie correta."
        )
    return candidatas[0]


def normalizar(texto):
    return re.sub(r"[^a-z0-9]+", " ", (texto or "").lower()).strip()


def listar_edicoes(backend_url, token, serie_id):
    return paginas_api(backend_url, token, "/api/edicoes", {"serieId": serie_id})


def indexar_edicoes(edicoes, inicio, fim):
    por_numero = {}
    for edicao in edicoes:
        encontrado = re.fullmatch(r"0*(\d+)", str(edicao.get("numero", "")).strip())
        if encontrado:
            numero = int(encontrado.group(1))
            if inicio <= numero <= fim:
                if numero in por_numero:
                    raise ValueError(f"A serie possui mais de uma edicao com o numero {numero}.")
                por_numero[numero] = edicao
    return por_numero


def remover_edicao(backend_url, token, edicao_id):
    requisicao_json(
        f"{backend_url.rstrip('/')}/api/edicoes/{edicao_id}",
        token,
        metodo="DELETE",
    )


def remover_fora_intervalo(backend_url, token, edicoes, inicio, fim):
    removidas = []
    falhas = []
    for edicao in edicoes:
        encontrado = re.fullmatch(r"0*(\d+)", str(edicao.get("numero", "")).strip())
        numero = int(encontrado.group(1)) if encontrado else None
        if numero is not None and inicio <= numero <= fim:
            continue
        try:
            remover_edicao(backend_url, token, edicao["id"])
            removidas.append(str(edicao.get("numero") or "sem numero"))
            print(f"[LIMPEZA OK] Edicao {edicao.get('numero') or 'sem numero'} (id={edicao['id']}) removida.")
        except Exception as erro:
            falhas.append({"numero": edicao.get("numero"), "id": edicao["id"], "erro": str(erro)})
            print(f"[LIMPEZA FALHOU] Edicao {edicao.get('numero') or 'sem numero'} (id={edicao['id']}): {erro}")
    return removidas, falhas


def atualizar_capa(backend_url, token, edicao_id, url_capa):
    return requisicao_json(
        f"{backend_url.rstrip('/')}/api/edicoes/{edicao_id}/capa",
        token,
        metodo="PATCH",
        dados={"urlCapa": url_capa},
    )


def executar(args):
    token = os.environ.get("HQHUB_API_TOKEN", "").strip()
    if not token:
        raise ValueError("Configure a variavel de ambiente HQHUB_API_TOKEN antes de iniciar.")

    serie = localizar_serie(args.backend_url, token, args.serie_id, args.busca_serie)
    todas_edicoes = listar_edicoes(args.backend_url, token, serie["id"])
    edicoes = indexar_edicoes(todas_edicoes, args.numero_inicial, args.numero_final)
    padrao_url = re.fullmatch(r"(.+-)(\d+)/?", args.url_inicial.strip())
    if not padrao_url:
        raise ValueError("A URL inicial da Panini deve terminar com o numero da edicao, como '-vol-1'.")
    prefixo_url, numero_panini_inicial = padrao_url.group(1), int(padrao_url.group(2))
    print(f"[Preparacao] Serie: {serie.get('titulo')} (id={serie['id']})")
    print(f"[Preparacao] Intervalo: {args.numero_inicial} a {args.numero_final}")
    print(f"[Preparacao] Edicoes localizadas no catalogo: {len(edicoes)}")

    falhas_limpeza = []
    if args.remover_fora_intervalo:
        print("[Limpeza] Removendo edicoes fora do intervalo autorizado...")
        removidas, falhas_limpeza = remover_fora_intervalo(
            args.backend_url, token, todas_edicoes, args.numero_inicial, args.numero_final,
        )
        print(f"[Limpeza] Removidas: {len(removidas)} | Falhas: {len(falhas_limpeza)}")

    sucessos = []
    falhas = []
    ignoradas = []
    total = args.numero_final - args.numero_inicial + 1

    for indice, numero in enumerate(range(args.numero_inicial, args.numero_final + 1), start=1):
        numero_panini = numero_panini_inicial + (numero - args.numero_inicial)
        url_produto = f"{prefixo_url}{numero_panini}"
        edicao = edicoes.get(numero)
        print(f"\n=== Edicao {indice}/{total}: numero {numero} ===")

        if not edicao:
            mensagem = "Edicao nao encontrada no catalogo da serie selecionada."
            falhas.append({"numero": numero, "erro": mensagem})
            print(f"[FALHA] {mensagem}")
            continue

        if args.somente_sem_capa and edicao.get("urlCapa"):
            ignoradas.append(numero)
            print("[IGNORADA] A edicao ja possui capa.")
            continue

        try:
            print(f"[Panini] Abrindo {url_produto}")
            html = buscar_html(url_produto, args.tentativas)
            titulo = extrair_titulo(html)
            if not re.search(rf"\bvol\.?\s*{numero_panini}\b", titulo, re.IGNORECASE):
                raise ValueError(f"A pagina nao confirma o volume {numero_panini}: titulo recebido '{titulo or '-'}'.")
            url_capa = extrair_capa(html)
            if not url_capa:
                raise ValueError("Imagem principal nao encontrada na pagina da Panini.")

            print(f"[Capa] {url_capa}")
            if args.simular:
                print(f"[SIMULACAO] Edicao id={edicao['id']} nao foi alterada.")
            else:
                atualizar_capa(args.backend_url, token, edicao["id"], url_capa)
                print(f"[OK] Capa aplicada na edicao id={edicao['id']}.")
            sucessos.append(numero)
        except Exception as erro:
            falhas.append({"numero": numero, "erro": str(erro)})
            print(f"[FALHA] {erro}")

        if indice < total and args.intervalo_segundos > 0:
            sleep(args.intervalo_segundos)

    print("\n=== Relatorio final ===")
    print(f"Processadas: {total} | Sucessos: {len(sucessos)} | Ignoradas: {len(ignoradas)} | Falhas: {len(falhas)}")
    if falhas_limpeza:
        print(f"Falhas na limpeza: {len(falhas_limpeza)}")
        for falha in falhas_limpeza:
            print(f"- Limpeza da edicao {falha['numero']} (id={falha['id']}): {falha['erro']}")
    for falha in falhas:
        print(f"- Numero {falha['numero']}: {falha['erro']}")
    if falhas or falhas_limpeza:
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Coleta capas sequenciais da Panini e aplica diretamente nas edicoes do HQ-HUB."
    )
    grupo_serie = parser.add_mutually_exclusive_group(required=True)
    grupo_serie.add_argument("--serie-id", type=int, help="ID exato da serie no HQ-HUB.")
    grupo_serie.add_argument("--busca-serie", help="Titulo exato da serie no HQ-HUB.")
    parser.add_argument(
        "--url-inicial",
        required=True,
        help="Pagina Panini correspondente ao primeiro numero do intervalo.",
    )
    parser.add_argument("--numero-inicial", type=int, default=1)
    parser.add_argument("--numero-final", type=int, required=True)
    parser.add_argument("--intervalo-segundos", type=float, default=0.7)
    parser.add_argument("--tentativas", type=int, default=3)
    parser.add_argument("--somente-sem-capa", action="store_true", help="Nao substitui capas que ja existem.")
    parser.add_argument(
        "--remover-fora-intervalo",
        action="store_true",
        help="Remove da serie edicoes que nao estejam dentro do intervalo numerico informado.",
    )
    parser.add_argument("--simular", action="store_true", help="Consulta tudo sem alterar o catalogo.")
    parser.add_argument(
        "--backend-url",
        default=os.environ.get("HQHUB_API_URL", "https://hqhub-backend.onrender.com"),
    )
    args = parser.parse_args()
    if args.numero_inicial < 1 or args.numero_final < args.numero_inicial:
        parser.error("O intervalo de numeros e invalido.")
    executar(args)


if __name__ == "__main__":
    main()
