#!/usr/bin/env python3
import argparse
import json
from datetime import datetime
from pathlib import Path


def ler_urls(caminho_urls):
    linhas = Path(caminho_urls).read_text(encoding="utf-8-sig").splitlines()
    urls = []
    for linha in linhas:
        valor = linha.strip()
        if not valor or valor.startswith("#"):
            continue
        if valor.lower() == "null":
            urls.append(None)
            continue
        urls.append(valor)
    return urls


def carregar_json(caminho_entrada):
    return json.loads(Path(caminho_entrada).read_text(encoding="utf-8"))


def salvar_json(caminho_saida, dados):
    caminho_saida.parent.mkdir(parents=True, exist_ok=True)
    caminho_saida.write_text(json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def aplicar_urls(args):
    dados = carregar_json(args.entrada)
    edicoes = dados.get("edicoes") or []
    urls = ler_urls(args.urls)
    avisos = list(dados.get("avisos") or [])

    total_edicoes = len(edicoes)
    total_urls = len(urls)
    total_aplicadas = min(total_edicoes, total_urls)

    if total_edicoes == 0:
        raise ValueError("O JSON de entrada não possui edições em 'edicoes'.")
    if total_urls == 0:
        raise ValueError("O arquivo de URLs está vazio.")

    if args.estrito and total_edicoes != total_urls:
        raise ValueError(
            "Quantidade incompatível em modo estrito: "
            f"{total_edicoes} edição(ões) e {total_urls} URL(s)."
        )

    for indice in range(total_aplicadas):
        edicoes[indice]["urlCapa"] = urls[indice]

    if total_urls > total_edicoes:
        avisos.append(
            f"Foram fornecidas {total_urls} URLs, mas o JSON possui {total_edicoes} edição(ões). "
            f"As {total_urls - total_edicoes} URL(s) excedentes foram ignoradas."
        )
    elif total_edicoes > total_urls:
        avisos.append(
            f"O JSON possui {total_edicoes} edição(ões), mas foram fornecidas apenas {total_urls} URL(s). "
            f"{total_edicoes - total_urls} edição(ões) mantiveram o valor anterior de urlCapa."
        )

    dados["avisos"] = avisos
    origem = dados.setdefault("origem", {})
    origem["aplicacaoManualCapas"] = {
        "arquivoUrls": str(Path(args.urls)),
        "aplicadoEm": datetime.now().replace(microsecond=0).isoformat(),
        "totalUrlsInformadas": total_urls,
        "totalEdicoes": total_edicoes,
        "totalCapasAplicadas": total_aplicadas,
        "modo": "sequencial",
    }

    salvar_json(Path(args.saida), dados)

    print(f"Arquivo gerado: {args.saida}")
    print(f"Edições no JSON: {total_edicoes}")
    print(f"URLs informadas: {total_urls}")
    print(f"Capas aplicadas: {total_aplicadas}")
    print(f"Avisos: {len(avisos)}")


def main():
    parser = argparse.ArgumentParser(
        description="Aplica URLs de capa em ordem nas edições de um JSON de importação do HQ-HUB."
    )
    parser.add_argument("--entrada", required=True, help="JSON de entrada com o array 'edicoes'.")
    parser.add_argument("--saida", required=True, help="JSON de saída com urlCapa atualizado.")
    parser.add_argument(
        "--urls",
        required=True,
        help="Arquivo .txt com uma URL por linha, na ordem das edições.",
    )
    parser.add_argument(
        "--estrito",
        action="store_true",
        help="Falha se a quantidade de URLs for diferente da quantidade de edições.",
    )
    args = parser.parse_args()
    aplicar_urls(args)


if __name__ == "__main__":
    main()