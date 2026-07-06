#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Converte dados coletados do Guia dos Quadrinhos para formato hq-hub
"""

import json
import argparse
from datetime import datetime

def converter_para_hqhub(arquivo_entrada, arquivo_saida, titulo_serie, editora, volume):
    """
    Converte JSON do scraper para formato hq-hub
    
    Parâmetros:
    - arquivo_entrada: JSON com dados coletados
    - arquivo_saida: Arquivo de saída no formato hq-hub
    - titulo_serie: Título da série (ex: "A Saga do Batman")
    - editora: Editora (ex: "Panini")
    - volume: Número do volume
    """
    
    print(f"\n📖 Convertendo dados para formato hq-hub...")
    print(f"   Entrada: {arquivo_entrada}")
    print(f"   Série: {titulo_serie}, Volume {volume}")
    print(f"   Editora: {editora}\n")
    
    # Ler dados coletados
    with open(arquivo_entrada, 'r', encoding='utf-8') as f:
        dados_coletados = json.load(f)
    
    total_edicoes = len(dados_coletados)
    
    # Montar estrutura hq-hub
    dados_hqhub = {
        "origem": {
            "arquivoEntrada": arquivo_entrada,
            "urlsProcessadas": [d.get('url') for d in dados_coletados if d.get('url')],
            "geradoEm": datetime.now().isoformat(),
            "gerador": "robo_converter_guia_para_hqhub.py",
            "aplicacaoManualCapas": {
                "arquivoUrls": None,
                "aplicadoEm": datetime.now().isoformat(),
                "totalUrlsInformadas": total_edicoes,
                "totalEdicoes": total_edicoes,
                "totalCapasAplicadas": sum(1 for d in dados_coletados if d.get('urlCapa')),
                "modo": "automatico_guia_dos_quadrinhos"
            }
        },
        "serieBrasileira": {
            "titulo": titulo_serie,
            "fase": None,
            "editora": editora,
            "volume": volume
        },
        "totalEdicoes": total_edicoes,
        "totalHistorias": None,
        "avisos": [],
        "edicoes": []
    }
    
    # Processar edições
    com_capa = 0
    sem_capa = 0
    
    for item in dados_coletados:
        numero = item.get('numero')
        url_capa = item.get('urlCapa')
        
        edicao = {
            "numero": numero,
            "urlCapa": url_capa,
            "descricao": None,
            "historias": []
        }
        
        dados_hqhub['edicoes'].append(edicao)
        
        if url_capa:
            com_capa += 1
        else:
            sem_capa += 1
            edicao['avisos'] = ["Sem capa disponível"]
    
    # Adicionar avisos
    if sem_capa > 0:
        dados_hqhub['avisos'].append(f"{sem_capa} edição(ões) sem capa")
    
    # Salvar
    print(f"💾 Salvando em formato hq-hub...")
    
    with open(arquivo_saida, 'w', encoding='utf-8') as f:
        json.dump(dados_hqhub, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Conversão concluída!")
    print(f"   Total de edições: {total_edicoes}")
    print(f"   Com capa: {com_capa}")
    print(f"   Sem capa: {sem_capa}")
    print(f"   Arquivo gerado: {arquivo_saida}")


def main():
    parser = argparse.ArgumentParser(
        description='Converter dados do Guia dos Quadrinhos para formato hq-hub'
    )
    parser.add_argument(
        '--entrada',
        required=True,
        help='Arquivo JSON coletado do Guia dos Quadrinhos'
    )
    parser.add_argument(
        '--saida',
        required=True,
        help='Arquivo de saída no formato hq-hub'
    )
    parser.add_argument(
        '--titulo',
        required=True,
        help='Título da série (ex: "A Saga do Batman")'
    )
    parser.add_argument(
        '--editora',
        default='Panini',
        help='Editora (padrão: Panini)'
    )
    parser.add_argument(
        '--volume',
        type=int,
        default=1,
        help='Número do volume (padrão: 1)'
    )
    
    args = parser.parse_args()
    
    converter_para_hqhub(
        args.entrada,
        args.saida,
        args.titulo,
        args.editora,
        args.volume
    )


if __name__ == '__main__':
    main()
