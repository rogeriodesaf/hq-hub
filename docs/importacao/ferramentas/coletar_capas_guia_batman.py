"""Levantamento de candidatos para revisao das capas faltantes do guia."""
import json
import re
import unicodedata
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import quote
from urllib.request import Request, urlopen

PASTA = Path('docs/importacao/rascunhos/batman-capas-20260905')
API = 'https://hqhub-backend.onrender.com/api/publico/ordens-leitura/batman-ordem-cronologica'


def baixar_json(url):
    with urlopen(Request(url, headers={'User-Agent': 'Mozilla/5.0'}), timeout=20) as r:
        return json.load(r)


def termos(texto):
    texto = unicodedata.normalize('NFKD', texto).encode('ascii', 'ignore').decode().lower()
    return set(re.findall(r'[a-z0-9]+', texto)) - {'a', 'as', 'o', 'os', 'e', 'de', 'do', 'da', 'dos', 'das', 'um', 'uma', 'para', 'na', 'no', 'em'}


def candidatos(item):
    q = item['titulo'].replace('&', 'e').replace(':', ' ').replace('—', ' ').replace('?', '')
    try:
        resultados = baixar_json('https://www.rika.com.br/api/catalog_system/pub/products/search/?ft=' + quote(q))
        alvo = termos(q)
        resultados.sort(key=lambda r: (len(alvo & termos(r['productName'])) / max(1, len(alvo)), -len(termos(r['productName']) - alvo)), reverse=True)
        produtos = []
        for p in resultados[:10]:
            imgs = p.get('items', [{}])[0].get('images', [])
            produtos.append({'titulo': p['productName'], 'url': p['link'], 'urlCapa': imgs[0]['imageUrl'] if imgs else None,
                             'score': round(len(alvo & termos(p['productName'])) / max(1, len(alvo)), 2)})
        return {'item': item, 'candidatos': produtos}
    except Exception as e:
        return {'item': item, 'erro': str(e), 'candidatos': []}


if __name__ == '__main__':
    PASTA.mkdir(parents=True, exist_ok=True)
    guia = baixar_json(API)
    (PASTA / 'antes.json').write_text(json.dumps(guia, ensure_ascii=False, indent=2), encoding='utf-8')
    with ThreadPoolExecutor(max_workers=4) as pool:
        resultado = list(pool.map(candidatos, [i for i in guia['itens'] if not i.get('urlCapa')]))
    (PASTA / 'candidatos.json').write_text(json.dumps(resultado, ensure_ascii=False, indent=2), encoding='utf-8')
    for r in resultado:
        print(r['item']['posicao'], r['item']['titulo'], '=>', [(p['score'], p['titulo']) for p in r['candidatos'][:2]], flush=True)
