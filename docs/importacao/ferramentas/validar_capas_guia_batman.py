"""Resolve selecao revisada e valida imagens; nao altera o HQ-HUB."""
import json
from concurrent.futures import ThreadPoolExecutor
from urllib.request import Request, urlopen
from coletar_capas_guia_batman import PASTA
from robo_enriquecer_capas_multiplas_fontes import extrair_produto


def ler(nome):
    return json.loads((PASTA / nome).read_text(encoding='utf-8'))


def validar(par):
    pos, produto = par
    try:
        if isinstance(produto, str):
            imagem, titulo = extrair_produto(produto)
            produto = dict(url=produto, titulo=titulo, urlCapa=imagem)
        assert produto.get('urlCapa'), 'Sem imagem'
        assert not any(t in produto['urlCapa'].lower() for t in ('indisponivel', 'placeholder', 'no-image')), 'Placeholder, nao e capa'
        with urlopen(Request(produto['urlCapa'], headers={'User-Agent': 'Mozilla/5.0'}), timeout=25) as r:
            tipo = r.headers.get_content_type()
            corpo = r.read()
            assert r.status == 200 and tipo.startswith('image/'), (r.status, tipo)
            assert len(corpo) > 2000, 'Imagem pequena demais'
        return dict(posicao=int(pos), produto=produto, contentType=tipo, bytes=len(corpo))
    except Exception as e:
        return dict(posicao=int(pos), erro=str(e), produto=produto)


if __name__ == '__main__':
    selecao = ler('selecao.json')
    candidatos = {str(x['item']['posicao']): x['candidatos'] for x in ler('candidatos.json')}
    complementares = ler('complementares.json')
    produtos = {p: candidatos[p][n] for p, n in selecao['candidatos'].items()}
    produtos.update({p: complementares[p][n] for p, n in selecao['complementares'].items()})
    produtos.update({p: candidatos[str(n)][i] for p, (n, i) in selecao['cruzadas'].items()})
    produtos.update(selecao['paginas'])
    produtos.update(selecao.get('imagens', {}))
    itens = {x['posicao']: x for x in ler('antes.json')['itens']}
    with ThreadPoolExecutor(max_workers=4) as pool:
        resultado = list(pool.map(validar, produtos.items()))
    for x in resultado:
        item = itens[x['posicao']]
        assert not item['urlCapa'] and item['edicaoId'] is None
        x['itemId'] = item['id']
        x['tituloReferencia'] = item['titulo']
        x['detalheReferencia'] = item['detalhe']
        print(x['posicao'], x.get('erro', 'OK'), x['produto'], flush=True)
    resultado.sort(key=lambda x: x['posicao'])
    (PASTA / 'capas-revisadas.json').write_text(json.dumps(resultado, ensure_ascii=False, indent=2), encoding='utf-8')
    assert not any('erro' in x for x in resultado), 'Ha imagens invalidas; revisar antes de migrar'
