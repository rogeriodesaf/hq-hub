import { DOCUMENT } from '@angular/common';
import { Injectable, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';

interface ConfiguracaoSeo {
  titulo: string;
  descricao: string;
  caminhoCanonico: string;
  indexavel: boolean;
}

const URL_BASE = 'https://hqhub.space';
const TITULO_PADRAO = 'Coleciona HQ | Organize sua coleção de quadrinhos';
const DESCRICAO_PADRAO =
  'Organize sua coleção de quadrinhos, encontre edições, acompanhe sua estante e consulte guias de leitura no Coleciona HQ.';

const GUIAS: Record<string, Pick<ConfiguracaoSeo, 'titulo' | 'descricao'>> = {
  'ordem-de-leitura-mutante': {
    titulo: 'Ordem de Leitura dos X-Men | Coleciona HQ',
    descricao: 'Acompanhe a ordem cronológica dos X-Men e do universo mutante com as edições publicadas no Brasil.',
  },
  'batman-ordem-cronologica': {
    titulo: 'Ordem Cronológica do Batman | Coleciona HQ',
    descricao: 'Consulte uma ordem cronológica de leitura do Batman, dos primeiros anos de Gotham às fases modernas.',
  },
  'tex-ordem-publicacao-brasileira': {
    titulo: 'Tex: Ordem de Publicação Brasileira | Coleciona HQ',
    descricao: 'Consulte as coleções e edições brasileiras de Tex em ordem de publicação.',
  },
  'colecao-marvel-deluxe-capa-preta': {
    titulo: 'Marvel Deluxe: Coleção Completa | Coleciona HQ',
    descricao: 'Confira a coleção brasileira Marvel Deluxe da Panini, conhecida pelas capas pretas.',
  },
  'marvel-omnibus': {
    titulo: 'Marvel Omnibus publicados no Brasil | Coleciona HQ',
    descricao: 'Confira os títulos da linha Marvel Omnibus publicados no Brasil e cadastrados no Coleciona HQ.',
  },
  'colecao-nova-marvel': {
    titulo: 'Coleção Nova Marvel: Guia Editorial | Coleciona HQ',
    descricao: 'Consulte a ordem editorial dos encadernados da Coleção Nova Marvel publicados pela Panini.',
  },
};

@Injectable({ providedIn: 'root' })
export class SeoService {
  private readonly documento = inject(DOCUMENT);
  private readonly meta = inject(Meta);
  private readonly title = inject(Title);

  atualizar(url: string) {
    const caminho = (url.split(/[?#]/, 1)[0] || '/').replace(/\/$/, '') || '/';
    const configuracao = this.configuracao(caminho);
    const urlCanonica = `${URL_BASE}${configuracao.caminhoCanonico === '/' ? '' : configuracao.caminhoCanonico}`;

    this.title.setTitle(configuracao.titulo);
    this.meta.updateTag({ name: 'description', content: configuracao.descricao });
    this.meta.updateTag({
      name: 'robots',
      content: configuracao.indexavel
        ? 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1'
        : 'noindex, nofollow',
    });
    this.meta.updateTag({ property: 'og:title', content: configuracao.titulo });
    this.meta.updateTag({ property: 'og:description', content: configuracao.descricao });
    this.meta.updateTag({ property: 'og:url', content: urlCanonica });
    this.meta.updateTag({ name: 'twitter:title', content: configuracao.titulo });
    this.meta.updateTag({ name: 'twitter:description', content: configuracao.descricao });
    this.atualizarCanonica(urlCanonica);
  }

  private configuracao(caminho: string): ConfiguracaoSeo {
    if (caminho === '/' || caminho === '/entrar') {
      return this.publica(TITULO_PADRAO, DESCRICAO_PADRAO, '/');
    }
    if (caminho === '/catalogo') {
      return this.publica(
        'Catálogo de quadrinhos | Coleciona HQ',
        'Pesquise séries, edições e capas de quadrinhos publicados no Brasil no catálogo do Coleciona HQ.',
        '/catalogo',
      );
    }
    if (caminho === '/classificados') {
      return this.publica(
        'Classificados de quadrinhos | Coleciona HQ',
        'Encontre quadrinhos anunciados para venda ou troca por colecionadores no Coleciona HQ.',
        '/classificados',
      );
    }

    const guia = caminho.match(/^\/guia-de-leitura(?:-app)?\/([^/]+)$/);
    if (guia) {
      const slug = guia[1];
      const dados = GUIAS[slug];
      if (dados) {
        return this.publica(dados.titulo, dados.descricao, `/guia-de-leitura-app/${slug}`);
      }
    }

    if (/^\/edicoes\/\d+$/.test(caminho)) {
      return this.publica(
        'Edição de quadrinho | Coleciona HQ',
        'Consulte os dados desta edição de quadrinho no catálogo do Coleciona HQ.',
        caminho,
      );
    }

    return {
      titulo: TITULO_PADRAO,
      descricao: DESCRICAO_PADRAO,
      caminhoCanonico: caminho,
      indexavel: false,
    };
  }

  private publica(titulo: string, descricao: string, caminhoCanonico: string): ConfiguracaoSeo {
    return { titulo, descricao, caminhoCanonico, indexavel: true };
  }

  private atualizarCanonica(url: string) {
    let canonical = this.documento.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
    if (!canonical) {
      canonical = this.documento.createElement('link');
      canonical.rel = 'canonical';
      this.documento.head.appendChild(canonical);
    }
    canonical.href = url;
  }
}
