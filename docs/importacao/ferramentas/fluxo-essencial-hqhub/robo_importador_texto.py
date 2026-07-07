#!/usr/bin/env python3
import argparse
import json
import re
from datetime import datetime
from html import unescape
from time import sleep
from urllib.parse import urldefrag, urljoin
from urllib.error import URLError
from urllib.request import Request, urlopen
from pathlib import Path


MESES = {
    "janeiro": "01",
    "fevereiro": "02",
    "marco": "03",
    "março": "03",
    "abril": "04",
    "maio": "05",
    "junho": "06",
    "julho": "07",
    "agosto": "08",
    "setembro": "09",
    "outubro": "10",
    "novembro": "11",
    "dezembro": "12",
}

PREFIXOS_CREDITOS = (
    "Personagens:",
    "Arco:",
    "Argumento:",
    "Roteiro:",
    "Desenho:",
    "Arte-Final:",
    "Arte:",
    "Layout:",
    "Cores:",
    "Letrista:",
    "Tradutor:",
    "Editor original:",
    "Editor:",
    "Adaptação:",
    "Adaptacao:",
)

ROTULOS_METRICAS_SITE = {
    "coleções",
    "colecoes",
    "sonho de consumo",
    "já leram",
    "ja leram",
    "estão lendo",
    "estao lendo",
    "não leram",
    "nao leram",
    "estão relendo",
    "estao relendo",
    "irão ler",
    "irao ler",
    "desistiram",
}


def normalizar_espacos(texto):
    return re.sub(r"\s+", " ", texto).strip()


def ler_texto(caminho):
    return Path(caminho).read_text(encoding="utf-8-sig")


def buscar_url(url, tentativas=3):
    requisicao = Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 HQ-HUB importador assistido",
            "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8",
        },
    )
    ultimo_erro = None
    for tentativa in range(1, tentativas + 1):
        try:
            with urlopen(requisicao, timeout=30) as resposta:
                conteudo = resposta.read()
                charset = resposta.headers.get_content_charset() or "utf-8"
            return conteudo.decode(charset, errors="replace")
        except (TimeoutError, URLError) as erro:
            ultimo_erro = erro
            if tentativa < tentativas:
                sleep(2 * tentativa)
    raise ultimo_erro


def html_para_texto(html):
    imagens = re.findall(r"https?://[^\"']+?(?:jpg|jpeg|png|webp|ShowImage\.aspx[^\"']*)", html, flags=re.IGNORECASE)
    texto = re.sub(r"<(script|style)[\s\S]*?</\1>", " ", html, flags=re.IGNORECASE)
    texto = re.sub(r"<br\s*/?>", "\n", texto, flags=re.IGNORECASE)
    texto = re.sub(r"</(p|div|li|tr|td|h1|h2|h3|span)>", "\n", texto, flags=re.IGNORECASE)
    texto = re.sub(r"<[^>]+>", " ", texto)
    
    linhas = []
    # Padrões de linhas lixo que devem ser removidas - apenas os mais seguros
    padroes_lixo = [
        r"^\s*\d+\s+votos?\s+no\s+total\s*$",
        r"^\s*Seu voto:\s+\d+\s*$",  # Seu voto: 10, Seu voto: 9, etc
        r"^\s*Faça sua avaliação:\s*$",
        r"^\s*Galeria de capas\s*$",
        r"^\s*Clique nos números para navegar pelas edições\s*$",
        r"^\s*Relate algum problema encontrado nessa edição\s*$",
        r"^\s*(?:Título|Edição|Editado por)\s+adicionado por\s*$",
        r"^\s*Please enable JavaScript to view the comments\s*$",
        r"^\s*© \d{4}-\d{4}\s+Guia dos Quadrinhos",
        r"^\s*Design e desenvolvimento:",
        r"^\s*Nas redes sociais\s*$",
    ]
    
    for linha in unescape(texto).splitlines():
        linha_limpa = normalizar_espacos(linha)
        if linha_limpa:
            # Verificar se a linha é lixo
            eh_lixo = any(re.match(padrao, linha_limpa, re.IGNORECASE) for padrao in padroes_lixo)
            if not eh_lixo:
                linhas.append(linha_limpa)

    if imagens:
        linhas.extend(dict.fromkeys(imagens))

    return "\n".join(linhas)


def extrair_codigo_colecao(url):
    encontrado = re.search(r"/([a-z]{2}\d{6})/", url, re.IGNORECASE)
    return encontrado.group(1) if encontrado else None


def extrair_numero_url_edicao(url):
    encontrado = re.search(r"-n-(\d+[a-z]?)", url, re.IGNORECASE)
    if not encontrado:
        return 0
    return int(re.sub(r"\D", "", encontrado.group(1)) or "0")


def extrair_links_galeria(html, url_base):
    codigo = extrair_codigo_colecao(url_base)
    if not codigo:
        return [url_base]

    links = [url_base]
    for href in re.findall(r'href=["\']([^"\']*/edicao/[^"\']+)["\']', html, flags=re.IGNORECASE):
        url = urldefrag(urljoin(url_base, unescape(href))).url
        if f"/{codigo}/" in url:
            links.append(url)

    links_unicos = list(dict.fromkeys(links))
    return sorted(links_unicos, key=extrair_numero_url_edicao)


def limitar_urls_a_partir_da_inicial(urls, url_inicial, maximo_edicoes):
    if not maximo_edicoes:
        return urls

    try:
        indice_inicial = urls.index(url_inicial)
    except ValueError:
        numero_inicial = extrair_numero_url_edicao(url_inicial)
        indice_inicial = next(
            (indice for indice, url in enumerate(urls) if extrair_numero_url_edicao(url) >= numero_inicial),
            0,
        )

    return urls[indice_inicial : indice_inicial + maximo_edicoes]


def carregar_texto_e_origem(args):
    if not args.url:
        return ler_texto(args.entrada), [], []

    html_inicial = buscar_url(args.url, args.tentativas)
    if not args.seguir_galeria:
        return html_para_texto(html_inicial), [args.url], []

    urls = extrair_links_galeria(html_inicial, args.url)
    urls = limitar_urls_a_partir_da_inicial(urls, args.url, args.maximo_edicoes)

    textos = []
    urls_processadas = []
    avisos = []
    for indice, url in enumerate(urls):
        try:
            print(f"Processando {indice + 1}/{len(urls)}: {url}")
            html = html_inicial if url == args.url else buscar_url(url, args.tentativas)
            textos.append(html_para_texto(html))
            urls_processadas.append(url)
        except Exception as erro:
            avisos.append(f"Não foi possível processar {url}: {erro}")
        if indice < len(urls) - 1 and args.intervalo_segundos > 0:
            sleep(args.intervalo_segundos)

    return "\n\n".join(textos), urls_processadas, avisos


def extrair_primeiro(padrao, texto, flags=re.IGNORECASE | re.MULTILINE):
    encontrado = re.search(padrao, texto, flags)
    return normalizar_espacos(encontrado.group(1)) if encontrado else None


def converter_data_publicacao(publicado_texto):
    if not publicado_texto:
        return None

    encontrado = re.search(r"([A-Za-zçÇãÃéÉ]+)\s+de\s+(\d{4})", publicado_texto, re.IGNORECASE)
    if not encontrado:
        return None

    mes = MESES.get(encontrado.group(1).lower())
    ano = encontrado.group(2)
    return f"{ano}-{mes}-01" if mes else None


def converter_preco(preco_texto):
    if not preco_texto:
        return None

    numeros = re.sub(r"[^0-9,]", "", preco_texto)
    return float(numeros.replace(",", ".")) if numeros else None


def linha_parece_cabecalho_edicao(linha):
    if not linha:
        return False

    if linha.startswith("Publicada "):
        return False

    return bool(re.search(r"(?:^|\s)n[°º]\s*\d+[A-Za-z]?(?:\s|$)", linha))


def cabecalho_tem_metadados_de_edicao(linhas, indice):
    janela = "\n".join(linhas[indice + 1 : indice + 20])
    return "Publicado em:" in janela or "Editora:" in janela or "Licenciador:" in janela


def separar_blocos_edicoes(linhas):
    blocos = []
    bloco_atual = []

    for indice_linha, linha in enumerate(linhas):
        linha_limpa = linha.strip()
        if linha_parece_cabecalho_edicao(linha_limpa) and cabecalho_tem_metadados_de_edicao(linhas, indice_linha):
            if bloco_atual:
                blocos.append(bloco_atual)
            bloco_atual = [linha_limpa]
        elif bloco_atual:
            bloco_atual.append(linha_limpa)

    if bloco_atual:
        blocos.append(bloco_atual)

    # Fallback: pagina de edicao unica sem numero no titulo (ex: "Aniquilacao")
    if not blocos:
        for indice_linha, linha in enumerate(linhas):
            if linha.strip().startswith("Publicado em:"):
                # Recua ate 3 linhas para encontrar o titulo real da edicao
                titulo_idx = indice_linha
                for retrocesso in range(1, 4):
                    idx = indice_linha - retrocesso
                    if idx < 0:
                        break
                    candidata = linhas[idx].strip()
                    if candidata and not re.match(r"^https?://", candidata):
                        titulo_idx = idx
                        break
                blocos = [[l.strip() for l in linhas[titulo_idx:] if l.strip()]]
                break

    return blocos


def extrair_cabecalho(linha):
    encontrado = re.search(r"^(?P<titulo>.+?)\s*(?:-\s*)?n[°º]\s*(?P<numero>\d+[A-Za-z]?)", linha)
    if not encontrado:
        return None, None

    return normalizar_espacos(encontrado.group("titulo")), encontrado.group("numero")


def extrair_url_capa(texto):
    urls = re.findall(r"https?://[^\s)]+", texto)
    candidatas = [
        url.rstrip(".,")
        for url in urls
        if "image" in url.lower()
        or "cloudfront" in url.lower()
        or re.search(r"\.(jpg|jpeg|png|webp)(\?|$)", url.lower())
    ]
    return candidatas[-1] if candidatas else None


def extrair_descricao(bloco):
    linhas = []
    indice_publicado = next((indice for indice, linha in enumerate(bloco) if linha.startswith("Publicado em:")), None)
    if indice_publicado is None:
        inicio = 0
    else:
        linhas.append(bloco[0])
        inicio = indice_publicado

    for indice, linha in enumerate(bloco[inicio:], start=inicio):
        if linha.startswith("Personagens:"):
            break
        if indice + 1 < len(bloco) and bloco[indice + 1].startswith("Personagens:"):
            break
        if linha.isdigit() or linha.lower() in ROTULOS_METRICAS_SITE:
            continue
        if linha:
            linhas.append(linha)
    return "\n".join(linhas).strip()


def extrair_titulo_chamada(bloco):
    for indice, linha in enumerate(bloco[1:], start=1):
        if not linha:
            continue
        if linha.isdigit() or linha.lower() in ROTULOS_METRICAS_SITE:
            continue
        if linha.startswith((
            "Vol.",
            "Reimpressão",
            "Publicado em:",
            "Editora:",
            "Licenciador:",
            "Categoria:",
            "Gênero:",
            "Status:",
            "Formato:",
            "Número de páginas:",
            "Preço de capa:",
            "Crédito da capa",
            "Colorido/",
            "Preto e branco/",
        )):
            continue
        if re.match(r"^https?://", linha):
            continue
        if linha.startswith(PREFIXOS_CREDITOS):
            return None
        if indice + 1 < len(bloco) and bloco[indice + 1].startswith("Personagens:"):
            return None
        return linha
    return None


def encontrar_titulo_historia(linhas, indice_publicacao):
    for indice in range(indice_publicacao - 1, -1, -1):
        linha = linhas[indice].strip()
        if not linha:
            continue
        if linha.startswith(PREFIXOS_CREDITOS):
            continue
        if linha.startswith("Publicado em:"):
            continue
        return linha
    return None


def extrair_titulo_original(linhas, indice_publicacao):
    janela = "\n".join(linhas[indice_publicacao : indice_publicacao + 12])
    titulo = extrair_primeiro(r'Título original:\s*"([^"\n]+)"', janela)
    if titulo and titulo != ".":
        return titulo
    titulo = extrair_primeiro(r'Títulos originais:\s*"([^"\n]+)"', janela)
    if titulo and titulo != ".":
        return titulo
    titulo = extrair_primeiro(r'Título original:\s*([^"\n.]+)', janela)
    return titulo if titulo and titulo != "." else None


def extrair_paginas(linhas, indice_publicacao):
    janela = "\n".join(linhas[indice_publicacao : indice_publicacao + 14])
    encontrado = re.search(r"(\d+)\s+Páginas", janela, re.IGNORECASE)
    return int(encontrado.group(1)) if encontrado else None


def extrair_resumo(linhas, indice_publicacao):
    resumo = []
    for linha in linhas[indice_publicacao + 1 : indice_publicacao + 14]:
        if not linha:
            continue
        if linha.startswith(("Título original:", "Títulos originais:")) or re.search(r"\d+\s+Páginas", linha, re.IGNORECASE):
            break
        if linha.startswith(PREFIXOS_CREDITOS):
            continue
        if linha_parece_cabecalho_edicao(linha):
            break
        resumo.append(linha)
    return "\n".join(resumo).strip() or None


def extrair_publicacao_original(linha):
    encontrado = re.search(
        r"Publicada .*? em (?P<serie>.+?)\s+n[°º]\s*(?P<numero>[^/\s]+)\s*/\s*(?P<ano>\d{4})\s*-\s*(?P<editora>.+)$",
        linha,
        re.IGNORECASE,
    )
    if not encontrado:
        return None

    serie = normalizar_espacos(encontrado.group("serie"))
    numero = normalizar_espacos(encontrado.group("numero"))
    ano = int(encontrado.group("ano"))
    editora = normalizar_espacos(encontrado.group("editora"))
    return {
        "serieOriginal": serie,
        "numeroOriginal": numero,
        "anoOriginal": ano,
        "urlOrigem": None,
        "urlCapa": None,
        "urlCompraAmazon": None,
        "texto": f"{serie} n° {numero}/{ano} - {editora}",
    }


def extrair_historias(bloco):
    historias = []
    ordem = 1

    for indice, linha in enumerate(bloco):
        if not linha.startswith("Publicada pela primeira vez em "):
            continue

        publicacao_original = extrair_publicacao_original(linha)
        titulo = encontrar_titulo_historia(bloco, indice)
        if not titulo:
            continue

        historia = {
            "ordem": ordem,
            "tituloPortugues": titulo,
            "tituloOriginal": extrair_titulo_original(bloco, indice),
            "quantidadePaginas": extrair_paginas(bloco, indice),
            "resumo": extrair_resumo(bloco, indice),
        }

        if publicacao_original:
            historia["publicacaoOriginal"] = publicacao_original

        historias.append(historia)
        ordem += 1

    return historias


def extrair_edicao(bloco, titulo_serie_padrao, editora_padrao):
    titulo_extraido, numero = extrair_cabecalho(bloco[0])
    texto = "\n".join(bloco)
    publicado_texto = extrair_primeiro(r"Publicado em:\s*([^\n]+)", texto)
    numero_paginas_texto = extrair_primeiro(r"Número de páginas:\s*(\d+)", texto)
    preco_texto = extrair_primeiro(r"Preço de capa:\s*([^\n]+)", texto)

    return {
        "numero": numero,
        "tituloChamada": extrair_titulo_chamada(bloco),
        "dataPublicacao": converter_data_publicacao(publicado_texto),
        "publicadoTexto": publicado_texto,
        "editora": extrair_primeiro(r"Editora:\s*([^\n]+)", texto) or editora_padrao,
        "licenciador": extrair_primeiro(r"Licenciador:\s*([^\n]+)", texto),
        "categoria": extrair_primeiro(r"Categoria:\s*([^\n]+)", texto),
        "genero": extrair_primeiro(r"Gênero:\s*([^\n]+)", texto),
        "status": extrair_primeiro(r"Status:\s*([^\n]+?)(?:Número de páginas:|$)", texto),
        "numeroPaginas": int(numero_paginas_texto) if numero_paginas_texto else None,
        "formato": extrair_primeiro(r"Formato:\s*([^\n]+)", texto),
        "precoCapa": converter_preco(preco_texto),
        "urlCapa": extrair_url_capa(texto),
        "descricao": extrair_descricao(bloco),
        "historias": extrair_historias(bloco),
        "_tituloSerieDetectado": titulo_extraido or titulo_serie_padrao,
    }


def montar_json(args):
    texto, urls_processadas, avisos_carregamento = carregar_texto_e_origem(args)
    linhas = texto.splitlines()
    blocos = separar_blocos_edicoes(linhas)
    avisos = list(avisos_carregamento)
    edicoes = []

    for bloco in blocos:
        edicao = extrair_edicao(bloco, args.titulo_serie, args.editora)
        if not edicao["numero"]:
            if edicao.get("editora") or edicao.get("dataPublicacao"):
                status = (edicao.get("status") or "").lower()
                if "única" in status or "unica" in status:
                    edicao["numero"] = "UNICA"
                else:
                    edicao["numero"] = "1"
            else:
                avisos.append(f"Bloco ignorado sem número: {bloco[0][:80]}")
                continue
        if not edicao["historias"] and len(bloco) <= 3:
            avisos.append(f"Edição {edicao['numero']} parece incompleta e precisa de revisão.")
        edicoes.append(edicao)

    if not args.titulo_serie and edicoes:
        args.titulo_serie = edicoes[0].pop("_tituloSerieDetectado", None)

    for edicao in edicoes:
        edicao.pop("_tituloSerieDetectado", None)

    total_historias = sum(len(edicao["historias"]) for edicao in edicoes)

    return {
        "origem": {
            "arquivoEntrada": str(Path(args.entrada).resolve()) if args.entrada else None,
            "url": args.url,
            "urlsProcessadas": urls_processadas,
            "geradoEm": datetime.now().replace(microsecond=0).isoformat(),
            "gerador": "robo_importador_texto.py",
        },
        "serieBrasileira": {
            "titulo": args.titulo_serie,
            "fase": args.fase,
            "editora": args.editora,
            "volume": args.volume,
        },
        "totalEdicoes": len(edicoes),
        "totalHistorias": total_historias,
        "avisos": avisos,
        "edicoes": edicoes,
    }


def salvar_json_utf8(caminho, dados):
    # Mantem acentos legiveis no JSON e grava em UTF-8 sem BOM.
    caminho.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def slugificar(texto):
    if not texto:
        return "colecao"
    texto = texto.lower().strip()
    texto = re.sub(r"[^a-z0-9]+", "-", texto)
    texto = re.sub(r"-{2,}", "-", texto)
    return texto.strip("-") or "colecao"


def numero_para_ordem(numero):
    if numero is None:
        return 10**9
    numeros = re.sub(r"\D", "", str(numero))
    return int(numeros) if numeros else 10**9


def descobrir_faixa_edicoes(edicoes):
    if not edicoes:
        return "sem-edicoes"

    numeros = [str(edicao.get("numero", "")).strip() for edicao in edicoes if str(edicao.get("numero", "")).strip()]
    if not numeros:
        return "sem-numero"

    ordenados = sorted(numeros, key=numero_para_ordem)
    if len(ordenados) == 1:
        return ordenados[0]
    return f"{ordenados[0]}-a-{ordenados[-1]}"


def resolver_caminho_saida(args, resultado):
    saida_base = Path(args.saida)
    if not args.organizar_saida_por_serie:
        return saida_base

    titulo_serie = resultado.get("serieBrasileira", {}).get("titulo")
    pasta_serie = slugificar(titulo_serie)
    faixa = descobrir_faixa_edicoes(resultado.get("edicoes", []))
    nome_base = f"{pasta_serie}-{faixa}.json"
    pasta_destino = saida_base / pasta_serie
    destino = pasta_destino / nome_base

    if destino.exists():
        sufixo = datetime.now().strftime("%Y%m%d-%H%M%S")
        destino = pasta_destino / f"{pasta_serie}-{faixa}-{sufixo}.json"

    return destino


def main():
    parser = argparse.ArgumentParser(description="Gera JSON de importação do HQ-HUB a partir de texto colado.")
    origem = parser.add_mutually_exclusive_group(required=True)
    origem.add_argument("--entrada", help="Arquivo .txt com o texto copiado da página fonte.")
    origem.add_argument("--url", help="URL de uma página de edição para extração assistida.")
    parser.add_argument("--saida", required=True, help="Arquivo .json que será gerado.")
    parser.add_argument("--titulo-serie", default=None, help="Título da série brasileira.")
    parser.add_argument("--fase", default=None, help="Fase textual da série, por exemplo: 1ª Série.")
    parser.add_argument("--editora", default="Panini", help="Editora brasileira.")
    parser.add_argument("--volume", type=int, default=1, help="Volume interno da série brasileira.")
    parser.add_argument("--seguir-galeria", action="store_true", help="Segue links da galeria da mesma coleção.")
    parser.add_argument("--intervalo-segundos", type=float, default=2.0, help="Pausa entre acessos quando seguir galeria.")
    parser.add_argument("--maximo-edicoes", type=int, default=None, help="Limita a quantidade de edições processadas.")
    parser.add_argument("--tentativas", type=int, default=3, help="Quantidade de tentativas por URL.")
    parser.add_argument(
        "--organizar-saida-por-serie",
        action="store_true",
        help=(
            "Salva em pasta da coleção com arquivo por faixa de edições. "
            "Com essa opção, --saida vira a pasta raiz de saída."
        ),
    )
    args = parser.parse_args()

    resultado = montar_json(args)
    saida = resolver_caminho_saida(args, resultado)
    saida.parent.mkdir(parents=True, exist_ok=True)
    salvar_json_utf8(saida, resultado)

    print(f"Arquivo gerado: {saida}")
    print(f"Edições: {resultado['totalEdicoes']}")
    print(f"Histórias: {resultado['totalHistorias']}")
    if resultado["avisos"]:
        print("Avisos:")
        for aviso in resultado["avisos"]:
            print(f"- {aviso}")


if __name__ == "__main__":
    main()
