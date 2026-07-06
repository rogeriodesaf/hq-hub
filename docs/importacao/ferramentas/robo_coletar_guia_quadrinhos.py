#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Robô para coletar dados de edições do Guia dos Quadrinhos
Extrai: número, capa, preço, data, editora, descrição
"""

import argparse
import json
import time
import requests
from bs4 import BeautifulSoup
from datetime import datetime
from urllib.parse import urljoin


def extrair_dados_edicao(url_edicao, tentativas=3):
    """Extrai dados de uma edição específica do Guia dos Quadrinhos"""
    for tentativa in range(tentativas):
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
            response = requests.get(url_edicao, headers=headers, timeout=10)
            response.encoding = 'utf-8'
            
            if response.status_code == 404:
                return None
            
            if response.status_code != 200:
                print(f"  ⚠️  HTTP {response.status_code}")
                if tentativa < tentativas - 1:
                    time.sleep(1)
                    continue
                return None
            
            soup = BeautifulSoup(response.content, 'html.parser')
            
            dados = {
                'url': url_edicao,
                'numero': None,
                'urlCapa': None,
                'urlProxima': None
            }
            
            # Extrair número da edição do título
            titulo_elem = soup.find('h1')
            if titulo_elem:
                titulo_text = titulo_elem.get_text(strip=True)
                if 'n°' in titulo_text:
                    try:
                        num_part = titulo_text.split('n°')[1].strip().split()[0]
                        dados['numero'] = int(num_part) if num_part.isdigit() else None
                    except (IndexError, ValueError):
                        pass
            
            # Extrair imagem da capa (og:image)
            og_image = soup.find('meta', property='og:image')
            if og_image and og_image.get('content'):
                dados['urlCapa'] = og_image['content']
            
            # Procurar link "próxima edição"
            # Pattern: href contém a próxima edição
            links = soup.find_all('a')
            for link in links:
                href = link.get('href', '')
                if 'saga-do-batman-a-1-serie-n-' in href and '/edicao/' in href:
                    # Verificar se não é a mesma edição
                    if href != url_edicao and 'n-' in href:
                        # Extrair número da próxima edição
                        try:
                            link_text = link.get_text(strip=True)
                            if 'n°' in link_text or '>' in link_text:
                                dados['urlProxima'] = urljoin(url_edicao, href)
                                break
                        except:
                            pass
            
            return dados
            
        except requests.exceptions.Timeout:
            print(f"  ⏱️  Timeout")
            if tentativa < tentativas - 1:
                time.sleep(2)
        except Exception as e:
            print(f"  ⚠️  {type(e).__name__}")
            if tentativa < tentativas - 1:
                time.sleep(1)
    
    return None


def extrair_proximas_edicoes(url_inicial, quantidade_faltante=6, intervalo_segundos=1):
    """Segue os links de próximas edições para encontrar IDs faltantes"""
    print(f"\n🔗 Buscando {quantidade_faltante} edições faltantes via navegação...")
    
    urls_encontradas = []
    url_atual = url_inicial
    
    for i in range(quantidade_faltante):
        print(f"  [{i+1}/{quantidade_faltante}] Visitando...")
        
        dados = extrair_dados_edicao(url_atual, tentativas=2)
        
        if not dados:
            print(f"  ❌ Falha ao extrair")
            break
        
        if dados.get('urlProxima'):
            urls_encontradas.append(dados['urlProxima'])
            print(f"  ✓ Encontrada próxima: {dados['urlProxima']}")
            url_atual = dados['urlProxima']
            time.sleep(intervalo_segundos)
        else:
            print(f"  ❌ Próxima edição não encontrada")
            break
    
    return urls_encontradas


def coletar_edicoes(titulo_serie, cod_serie, quantidade, saida, intervalo_segundos=1, tentativas=2):
    """
    Coleta dados de múltiplas edições a partir da galeria
    
    Parâmetros:
    - titulo_serie: Título da série (ex: "saga-do-batman-a-1-serie")
    - cod_serie: Código da série (ex: "sa011126")
    - quantidade: Número de edições a coletar
    - saida: Arquivo de saída JSON
    - intervalo_segundos: Delay entre requisições
    - tentativas: Número de tentativas por URL
    """
    
    print(f"\n📚 Coleta Guia dos Quadrinhos: {titulo_serie}")
    print(f"   Edições: {quantidade}")
    print(f"   Intervalo: {intervalo_segundos}s")
    print(f"   Tentativas: {tentativas}\n")
    
    # IDs extraídos manualmente da galeria (edições 1-30)
    ids_conhecidos = [
        157954, 159263, 159938, 160328, 160507, 161036, 161264, 161805, 162127, 162566,
        162979, 163367, 163845, 164283, 164895, 165390, 165762, 166364, 166711, 169167,
        169468, 169909, 170219, 172262, 172800, 173278, 173700, 174134, 174372, 174632
    ]
    
    # Coletar dados
    edicoes = []
    
    # Se pedir mais de 30, tentar navegar para encontrar os IDs restantes
    if quantidade > len(ids_conhecidos):
        quantidade_faltante = quantidade - len(ids_conhecidos)
        url_ed30 = f"http://www.guiadosquadrinhos.com/edicao/{titulo_serie}-n-30/{cod_serie}/{ids_conhecidos[-1]}"
        urls_adicionais = extrair_proximas_edicoes(url_ed30, quantidade_faltante, intervalo_segundos)
        
        # Extrair IDs dos URLs adicionais
        for url in urls_adicionais:
            try:
                id_extra = int(url.split('/')[-1])
                ids_conhecidos.append(id_extra)
            except:
                pass
    
    ids_para_usar = ids_conhecidos[:quantidade]
    
    for idx, ed_id in enumerate(ids_para_usar, 1):
        url_edicao = f"http://www.guiadosquadrinhos.com/edicao/{titulo_serie}-n-{idx}/{cod_serie}/{ed_id}"
        
        print(f"[{idx:2d}/{quantidade}] Coletando edição {idx}...")
        
        dados = extrair_dados_edicao(url_edicao, tentativas=tentativas)
        
        if dados and dados['urlCapa']:
            edicoes.append(dados)
            print(f"      ✓ Capa: {dados['urlCapa'][:60]}...")
        else:
            print(f"      ✗ Falha ao coletar")
        
        if idx < quantidade:
            time.sleep(intervalo_segundos)
    
    # Salvar JSON
    print(f"\n💾 Salvando {len(edicoes)} edições em: {saida}")
    
    with open(saida, 'w', encoding='utf-8') as f:
        json.dump(edicoes, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Arquivo gerado com sucesso!")
    print(f"   Total: {len(edicoes)} edições")
    print(f"   Com capa: {sum(1 for e in edicoes if e.get('urlCapa'))}")
    print(f"   Sem capa: {sum(1 for e in edicoes if not e.get('urlCapa'))}")


def main():
    parser = argparse.ArgumentParser(
        description='Coletar dados de edições do Guia dos Quadrinhos'
    )
    parser.add_argument(
        '--titulo-serie',
        required=True,
        help='Título da série (ex: saga-do-batman-a-1-serie)'
    )
    parser.add_argument(
        '--cod-serie',
        required=True,
        help='Código da série (ex: sa011126)'
    )
    parser.add_argument(
        '--quantidade',
        type=int,
        required=True,
        help='Número de edições a coletar'
    )
    parser.add_argument(
        '--saida',
        required=True,
        help='Arquivo de saída JSON'
    )
    parser.add_argument(
        '--intervalo-segundos',
        type=float,
        default=1,
        help='Delay entre requisições (padrão: 1s)'
    )
    parser.add_argument(
        '--tentativas',
        type=int,
        default=2,
        help='Número de tentativas por URL (padrão: 2)'
    )
    
    args = parser.parse_args()
    
    coletar_edicoes(
        args.titulo_serie,
        args.cod_serie,
        args.quantidade,
        args.saida,
        args.intervalo_segundos,
        args.tentativas
    )


if __name__ == '__main__':
    main()
