#!/usr/bin/env python3
"""Enriquece uma edicao do JSON do Guia com uma capa publicada no Telegram."""

import argparse
import asyncio
import json
import os
import re
import subprocess
import tempfile
import unicodedata
import uuid
import zipfile
from datetime import datetime
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

TAMANHO_MAXIMO_CAPA = 3 * 1024 * 1024


def etapa(atual, total, texto):
    print(f"[{atual}/{total}] {texto}", flush=True)


def progresso_download(recebido, total):
    if not total:
        print(f"\r      Download: {recebido / 1024:.0f} KB", end="", flush=True)
        return
    percentual = min(100, int(recebido * 100 / total))
    preenchido = percentual // 5
    barra = "#" * preenchido + "-" * (20 - preenchido)
    print(f"\r      Download: [{barra}] {percentual:3d}%", end="", flush=True)


def variavel_obrigatoria(nome):
    valor = os.environ.get(nome, "").strip()
    if not valor:
        raise ValueError(f"Configure a variavel de ambiente {nome}.")
    return valor


def normalizar(texto):
    texto = unicodedata.normalize("NFKD", texto or "")
    texto = "".join(c for c in texto if not unicodedata.combining(c))
    tokens = re.sub(r"[^a-z0-9]+", " ", texto.lower()).split()
    return " ".join(str(int(token)) if token.isdigit() else token for token in tokens)


def detectar_imagem(caminho):
    conteudo = caminho.read_bytes()
    if not conteudo or len(conteudo) > TAMANHO_MAXIMO_CAPA:
        raise ValueError("A capa esta vazia ou excede 3 MB.")
    assinaturas = (
        (b"\xff\xd8\xff", "image/jpeg", ".jpg"),
        (b"\x89PNG\r\n\x1a\n", "image/png", ".png"),
        (b"GIF87a", "image/gif", ".gif"),
        (b"GIF89a", "image/gif", ".gif"),
    )
    for assinatura, mime, extensao in assinaturas:
        if conteudo.startswith(assinatura):
            return conteudo, mime, extensao
    if len(conteudo) >= 12 and conteudo.startswith(b"RIFF") and conteudo[8:12] == b"WEBP":
        return conteudo, "image/webp", ".webp"
    raise ValueError("O arquivo baixado do Telegram nao e uma imagem reconhecida.")


def chave_natural(nome):
    return [int(parte) if parte.isdigit() else parte.lower() for parte in re.split(r"(\d+)", nome)]


def extrair_capa_cbz(arquivo, destino):
    extensoes = (".jpg", ".jpeg", ".png", ".webp")
    with zipfile.ZipFile(arquivo) as pacote:
        imagens = sorted(
            (
                nome for nome in pacote.namelist()
                if not nome.endswith("/")
                and not nome.startswith("__MACOSX/")
                and Path(nome).suffix.lower() in extensoes
            ),
            key=chave_natural,
        )
        if not imagens:
            raise ValueError("O arquivo CBZ nao contem imagens.")
        with pacote.open(imagens[0]) as origem:
            destino.write_bytes(origem.read())
    return destino


def extrair_capa_pdf(arquivo, destino):
    try:
        import pymupdf
    except ImportError as erro:
        raise RuntimeError("Para arquivos PDF, instale: python -m pip install pymupdf") from erro
    with pymupdf.open(arquivo) as documento:
        if documento.page_count == 0:
            raise ValueError("O arquivo PDF nao possui paginas.")
        pagina = documento.load_page(0)
        pixmap = pagina.get_pixmap(matrix=pymupdf.Matrix(2, 2), alpha=False)
        destino.write_bytes(pixmap.tobytes("jpeg", jpg_quality=90))
    return destino


def extrair_capa_cbr(arquivo, destino):
    try:
        listagem = subprocess.run(
            ["tar", "-tf", str(arquivo)],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as erro:
        raise RuntimeError(
            "Nao foi possivel abrir o CBR. Instale o 7-Zip ou disponibilize uma miniatura no Telegram."
        ) from erro

    extensoes = (".jpg", ".jpeg", ".png", ".webp")
    imagens = sorted(
        (
            nome.strip() for nome in listagem.stdout.splitlines()
            if nome.strip()
            and not nome.startswith("__MACOSX/")
            and Path(nome).suffix.lower() in extensoes
        ),
        key=chave_natural,
    )
    if not imagens:
        raise ValueError("O arquivo CBR nao contem imagens reconhecidas.")

    try:
        with destino.open("wb") as saida:
            subprocess.run(
                ["tar", "-xOf", str(arquivo), imagens[0]],
                check=True,
                stdout=saida,
                stderr=subprocess.PIPE,
            )
    except subprocess.CalledProcessError as erro:
        raise RuntimeError("Nao foi possivel extrair a primeira imagem do CBR.") from erro
    return destino


def extrair_capa_documento(arquivo, pasta):
    extensao = arquivo.suffix.lower()
    if extensao == ".pdf":
        return extrair_capa_pdf(arquivo, pasta / "capa.jpg")
    if extensao == ".cbr":
        return extrair_capa_cbr(arquivo, pasta / "capa-extraida")
    if extensao == ".cbz" or zipfile.is_zipfile(arquivo):
        return extrair_capa_cbz(arquivo, pasta / "capa-extraida")
    raise ValueError(f"Formato nao suportado para extracao de capa: {extensao or 'sem extensao'}.")


def multipart(campos, nome_campo, nome_arquivo, mime, conteudo):
    limite = f"----hqhub{uuid.uuid4().hex}"
    partes = []
    for nome, valor in campos.items():
        partes.extend((
            f"--{limite}\r\n".encode(),
            f'Content-Disposition: form-data; name="{nome}"\r\n\r\n'.encode(),
            str(valor).encode(), b"\r\n",
        ))
    partes.extend((
        f"--{limite}\r\n".encode(),
        f'Content-Disposition: form-data; name="{nome_campo}"; filename="{nome_arquivo}"\r\n'.encode(),
        f"Content-Type: {mime}\r\n\r\n".encode(), conteudo, b"\r\n",
        f"--{limite}--\r\n".encode(),
    ))
    return b"".join(partes), limite


def enviar_backend(conteudo, mime, extensao, backend_url, token):
    corpo, limite = multipart(
        {}, "arquivo",
        f"capa{extensao}", mime, conteudo,
    )
    requisicao = Request(
        f"{backend_url.rstrip('/')}/api/importacoes/catalogo/capas/upload",
        data=corpo,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": f"multipart/form-data; boundary={limite}",
        },
        method="POST",
    )
    with urlopen(requisicao, timeout=90) as resposta:
        resultado = json.loads(resposta.read().decode("utf-8"))
    if not resultado.get("urlImagem"):
        raise RuntimeError("O backend nao retornou urlImagem para a capa.")
    return resultado["urlImagem"]


def requisicao_json(url, token, metodo="GET", dados=None):
    corpo = None if dados is None else json.dumps(dados).encode("utf-8")
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    if corpo is not None:
        headers["Content-Type"] = "application/json"
    with urlopen(Request(url, data=corpo, headers=headers, method=metodo), timeout=60) as resposta:
        return json.loads(resposta.read().decode("utf-8"))


def localizar_edicao_backend(backend_url, token, busca, numero):
    parametros = urlencode({"busca": busca, "pagina": 0, "tamanho": 100})
    pagina = requisicao_json(
        f"{backend_url.rstrip('/')}/api/edicoes?{parametros}", token,
    )
    numero_alvo = str(numero).lstrip("0") or "0"
    candidatas = [
        item for item in pagina.get("itens", [])
        if (str(item.get("numero", "")).lstrip("0") or "0") == numero_alvo
    ]
    if len(candidatas) != 1:
        resumos = [
            (
                f"id={item.get('id')} "
                f"serieId={item.get('serie', {}).get('id')} "
                f"serie={item.get('serie', {}).get('titulo')} "
                f"editora={item.get('serie', {}).get('editora', {}).get('nome')} "
                f"numero={item.get('numero')} "
                f"volume={item.get('nomeVolume') or '-'} "
                f"publicacao={item.get('dataPublicacao') or '-'}"
            )
            for item in candidatas
        ]
        detalhe = "; ".join(resumos) if resumos else "nenhuma candidata"
        raise LookupError(
            f"A busca '{busca}' nao identificou uma unica edicao numero {numero}: {detalhe}. "
            "Informe --edicao-id para selecionar diretamente."
        )
    return candidatas[0]


def listar_edicoes_serie(backend_url, token, serie_id, numero_inicial, numero_final):
    edicoes = []
    pagina = 0
    while True:
        parametros = urlencode({"serieId": serie_id, "pagina": pagina, "tamanho": 100})
        resposta = requisicao_json(
            f"{backend_url.rstrip('/')}/api/edicoes?{parametros}", token,
        )
        edicoes.extend(resposta.get("itens", []))
        if pagina + 1 >= resposta.get("totalPaginas", 0):
            break
        pagina += 1

    selecionadas = []
    for edicao in edicoes:
        encontrado = re.match(r"^0*(\d+)$", str(edicao.get("numero", "")).strip())
        if not encontrado:
            continue
        numero = int(encontrado.group(1))
        if numero < numero_inicial or (numero_final is not None and numero > numero_final):
            continue
        edicao["numeroInteiro"] = numero
        selecionadas.append(edicao)
    return sorted(selecionadas, key=lambda item: item["numeroInteiro"])


def atualizar_capa_backend(backend_url, token, edicao_id, url_capa):
    return requisicao_json(
        f"{backend_url.rstrip('/')}/api/edicoes/{edicao_id}/capa",
        token,
        metodo="PATCH",
        dados={"urlCapa": url_capa},
    )


async def localizar_capa(client, grupo, consulta, limite):
    alvo = normalizar(consulta)
    sem_numero = re.sub(r"\s+\d+\s*$", "", alvo).strip()
    numero = alvo.removeprefix(sem_numero).strip()
    prefixo_esperado = alvo.split()
    numero_formatado = f"{int(numero):02d}" if numero.isdigit() else numero
    # Comeca pelo padrao exato dos arquivos (ex.: "Zagor Mythos 01") e deixa
    # a busca ampla por titulo como ultimo recurso.
    consultas = list(dict.fromkeys((consulta, f"{sem_numero} {numero_formatado}", sem_numero)))
    vistos = set()
    inspecionadas = 0
    for termo in consultas:
        async for mensagem in client.iter_messages(grupo, search=termo, limit=limite):
            if mensagem.id in vistos:
                continue
            vistos.add(mensagem.id)
            inspecionadas += 1
            print(f"\r      Resultados inspecionados: {inspecionadas}", end="", flush=True)
            nome_arquivo = getattr(mensagem.file, "name", None) or ""
            tokens_nome = normalizar(nome_arquivo).split()
            # O grupo contem colecoes como "Zagor Extra" que tambem podem
            # mencionar a editora Mythos na legenda. Para impedir falsos
            # positivos, o nome do documento deve comecar exatamente pelo
            # titulo e numero pedidos: "Zagor Mythos 01 ...".
            if tokens_nome[:len(prefixo_esperado)] != prefixo_esperado:
                continue
            if mensagem.document and nome_arquivo.lower().endswith((".cbz", ".cbr", ".pdf")):
                print()
                print(f"      Arquivo selecionado: {nome_arquivo}", flush=True)
                return mensagem
    print()
    raise LookupError(f'Nenhum arquivo CBZ/CBR/PDF encontrado para "{consulta}" em {grupo}.')


def atualizar_json(entrada, saida, numero, url, grupo, consulta, mensagem_id):
    dados = json.loads(entrada.read_text(encoding="utf-8-sig"))
    edicao = next(
        (item for item in dados.get("edicoes", []) if str(item.get("numero")) == str(numero)),
        None,
    )
    if not edicao:
        raise ValueError(f"A edicao numero {numero} nao existe no JSON de entrada.")
    edicao["urlCapa"] = url
    dados.setdefault("origem", {})["capaTelegram"] = {
        "grupo": grupo,
        "consulta": consulta,
        "mensagemId": mensagem_id,
        "aplicadoEm": datetime.now().replace(microsecond=0).isoformat(),
        "arquivoTemporarioDescartado": True,
    }
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


async def executar(args):
    try:
        from telethon import TelegramClient
    except ImportError as erro:
        raise RuntimeError("Instale a dependencia com: pip install telethon") from erro

    api_id = int(variavel_obrigatoria("TELEGRAM_API_ID"))
    api_hash = variavel_obrigatoria("TELEGRAM_API_HASH")
    token = variavel_obrigatoria("HQHUB_API_TOKEN")
    prefixo = re.sub(r"\s+0*\d+\s*$", "", args.consulta).strip()
    if args.serie_id:
        print(f"[Preparacao] Carregando edicoes da serie {args.serie_id} no HQ-Hub...", flush=True)
        edicoes = listar_edicoes_serie(
            args.backend_url, token, args.serie_id, args.numero_inicial, args.numero_final,
        )
        if not edicoes:
            raise LookupError("Nenhuma edicao numerica encontrada no intervalo informado.")
    else:
        if args.numero is None:
            raise ValueError("Informe --numero no modo de uma unica edicao.")
        busca_hqhub = args.busca_hqhub or prefixo
        etapa(1, 7, f"Localizando a edicao {args.numero} no HQ-Hub...")
        edicoes = [
            {"id": args.edicao_id, "numero": str(args.numero), "numeroInteiro": args.numero}
            if args.edicao_id
            else {
                **localizar_edicao_backend(args.backend_url, token, busca_hqhub, args.numero),
                "numeroInteiro": args.numero,
            }
        ]
    sessao = Path(args.sessao)
    sessao.parent.mkdir(parents=True, exist_ok=True)
    sucessos = []
    falhas = []
    print(f"[Preparacao] {len(edicoes)} edicao(oes) para processar.", flush=True)
    etapa(2, 7, f"Conectando ao Telegram em {args.grupo}...")
    async with TelegramClient(str(sessao), api_id, api_hash) as client:
        for indice, edicao in enumerate(edicoes, start=1):
            numero = edicao["numeroInteiro"]
            consulta = (
                f"{numero:0{args.digitos_numero}d}"
                if args.nome_inicia_numero
                else f"{prefixo} {numero:02d}"
                if args.serie_id
                else args.consulta
            )
            print(f"\n=== Edicao {indice}/{len(edicoes)}: numero {numero} (id={edicao['id']}) ===", flush=True)
            try:
                print(f"[Busca] Procurando '{consulta}' no Telegram...", flush=True)
                mensagem = await localizar_capa(client, args.grupo, consulta, args.limite)
                with tempfile.TemporaryDirectory(prefix="hqhub-telegram-") as pasta:
                    capa = None
                    miniaturas = getattr(mensagem.document, "thumbs", None) or []
                    if miniaturas and not args.capa_original:
                        print(f"[Download] Baixando somente a miniatura da mensagem {mensagem.id}...", flush=True)
                        miniatura = await client.download_media(
                            mensagem, file=str(Path(pasta) / "miniatura"), thumb=-1,
                            progress_callback=progresso_download,
                        )
                        print()
                        if miniatura:
                            capa = Path(miniatura)
                            print("[Extracao] Miniatura do documento usada como capa.", flush=True)
                    if capa is None:
                        print(f"[Download] Baixando o arquivo completo da mensagem {mensagem.id}...", flush=True)
                        baixado = await client.download_media(
                            mensagem, file=str(Path(pasta)), progress_callback=progresso_download,
                        )
                        print()
                        if not baixado:
                            raise RuntimeError("O Telegram nao retornou o arquivo.")
                        print("[Extracao] Extraindo a primeira pagina...", flush=True)
                        capa = extrair_capa_documento(Path(baixado), Path(pasta))
                    conteudo, mime, extensao = detectar_imagem(capa)
                    print("[Upload] Enviando a capa ao HQ-Hub...", flush=True)
                    url = enviar_backend(conteudo, mime, extensao, args.backend_url, token)
                print("[Atualizacao] Gravando urlCapa na edicao...", flush=True)
                atualizar_capa_backend(args.backend_url, token, edicao["id"], url)
                sucessos.append({"numero": numero, "id": edicao["id"], "mensagemId": mensagem.id})
                print("[OK] Capa aplicada; temporarios descartados.", flush=True)
            except Exception as erro:
                falhas.append({"numero": numero, "id": edicao["id"], "erro": str(erro)})
                print(f"[FALHA] {erro}", flush=True)

    print("\n=== Relatorio final ===")
    print(f"Processadas: {len(edicoes)} | Sucessos: {len(sucessos)} | Falhas: {len(falhas)}")
    for falha in falhas:
        print(f"- Numero {falha['numero']} (id={falha['id']}): {falha['erro']}")


def main():
    parser = argparse.ArgumentParser(
        description="Extrai a capa de um CBZ/PDF do Telegram e atualiza a edicao no HQ-Hub."
    )
    parser.add_argument("--entrada", help="JSON opcional produzido pelo robo do Guia.")
    parser.add_argument("--saida", help="Novo JSON opcional com a capa atualizada.")
    parser.add_argument("--consulta", required=True, help='Exemplo: "Zagor Mythos 01".')
    parser.add_argument("--numero", type=int, help="Numero no modo de uma unica edicao.")
    parser.add_argument("--grupo", default="@zagorbr", help="Grupo ou canal de origem.")
    parser.add_argument("--limite", type=int, default=100, help="Resultados a inspecionar.")
    parser.add_argument("--sessao", default=".telegram/hqhub", help="Sessao local Telethon.")
    parser.add_argument("--busca-hqhub", help="Termo para localizar a serie ja cadastrada no HQ-Hub.")
    parser.add_argument("--edicao-id", type=int, help="ID da edicao no HQ-Hub; evita a busca automatica.")
    parser.add_argument("--serie-id", type=int, help="Processa em sequencia todas as edicoes desta serie.")
    parser.add_argument("--numero-inicial", type=int, default=1, help="Primeiro numero do modo sequencial.")
    parser.add_argument("--numero-final", type=int, help="Ultimo numero do modo sequencial; omitido processa todos.")
    parser.add_argument(
        "--nome-inicia-numero",
        action="store_true",
        help='Procura arquivos cujo nome inicia somente pelo numero, como "001 Titulo.cbr".',
    )
    parser.add_argument(
        "--digitos-numero",
        type=int,
        default=3,
        choices=range(1, 7),
        metavar="N",
        help="Quantidade de digitos no modo --nome-inicia-numero (padrao: 3).",
    )
    parser.add_argument("--capa-original", action="store_true", help="Ignora a miniatura e extrai a capa do arquivo completo.")
    parser.add_argument(
        "--backend-url",
        default=os.environ.get("HQHUB_API_URL", "http://localhost:8080"),
        help="URL do backend HQ-Hub (padrao: HQHUB_API_URL ou http://localhost:8080).",
    )
    args = parser.parse_args()
    if bool(args.entrada) != bool(args.saida):
        parser.error("--entrada e --saida devem ser usados juntos.")
    asyncio.run(executar(args))


if __name__ == "__main__":
    main()
