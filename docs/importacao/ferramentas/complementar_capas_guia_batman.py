import json
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import quote
from coletar_capas_guia_batman import PASTA, baixar_json


def buscar(par):
    pos, q = par
    try:
        dados = baixar_json('https://www.rika.com.br/api/catalog_system/pub/products/search/?ft=' + quote(q) + '&_from=0&_to=49')
        return pos, [{'titulo': p['productName'], 'url': p['link'], 'urlCapa': p['items'][0]['images'][0]['imageUrl']} for p in dados if p['items'][0].get('images')]
    except Exception as e:
        print(pos, str(e), flush=True)
        return pos, []


if __name__ == '__main__':
    consultas = json.loads((PASTA / 'consultas.json').read_text(encoding='utf-8'))
    with ThreadPoolExecutor(max_workers=4) as pool:
        resultado = dict(pool.map(buscar, consultas.items()))
    (PASTA / 'complementares.json').write_text(json.dumps(resultado, ensure_ascii=False, indent=2), encoding='utf-8')
    for pos, itens in resultado.items():
        print(pos, [(n, p['titulo']) for n, p in enumerate(itens)], flush=True)
