#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Encontra IDs faltantes testando URLs sequencialmente
"""

import requests
import time
from bs4 import BeautifulSoup

def testar_id(titulo_serie, cod_serie, numero_edicao, id_teste):
    """Testa se um ID é válido para uma edição"""
    url = f"http://www.guiadosquadrinhos.com/edicao/{titulo_serie}-n-{numero_edicao}/{cod_serie}/{id_teste}"
    
    try:
        response = requests.get(url, timeout=5, headers={'User-Agent': 'Mozilla/5.0'})
        if response.status_code == 200:
            # Verificar se a página realmente contém a edição esperada
            soup = BeautifulSoup(response.content, 'html.parser')
            titulo = soup.find('h1')
            if titulo and f'n° {numero_edicao}' in titulo.get_text():
                return True, url
        return False, None
    except:
        return False, None

def encontrar_ids_faltantes(titulo_serie, cod_serie, ultim_id_conhecido=174632, quantidade_faltante=6):
    """Procura pelos IDs das próximas edições"""
    print(f"🔍 Buscando {quantidade_faltante} IDs faltantes...")
    print(f"   Iniciando busca a partir de ID: {ultim_id_conhecido + 1}\n")
    
    ids_encontrados = []
    numero_edicao = 31
    id_teste = ultim_id_conhecido + 1
    max_tentativas = 5000  # Limite de tentativas para não rodar infinitamente
    tentativas = 0
    
    while len(ids_encontrados) < quantidade_faltante and tentativas < max_tentativas:
        found, url = testar_id(titulo_serie, cod_serie, numero_edicao, id_teste)
        
        if found:
            print(f"✓ Edição {numero_edicao}: ID {id_teste}")
            ids_encontrados.append(id_teste)
            numero_edicao += 1
            id_teste += 1
        else:
            # Mostrar progresso a cada 100 tentativas
            if tentativas % 100 == 0:
                print(f"  Testados: {tentativas} IDs... (testando ID {id_teste})")
            id_teste += 1
        
        tentativas += 1
        time.sleep(0.1)  # Pequeno delay para não sobrecarregar servidor
    
    if ids_encontrados:
        print(f"\n✅ Encontrados {len(ids_encontrados)} IDs:")
        print(", ".join(map(str, ids_encontrados)))
    else:
        print(f"\n❌ Nenhum ID encontrado após {tentativas} tentativas")
    
    return ids_encontrados

if __name__ == '__main__':
    encontrar_ids_faltantes(
        "saga-do-batman-a-1-serie",
        "sa011126",
        ultim_id_conhecido=174632,
        quantidade_faltante=6
    )
