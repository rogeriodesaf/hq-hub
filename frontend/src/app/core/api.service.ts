import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { map } from 'rxjs';

import { environment } from '../../environments/environment';
import { normalizarUrlMidia } from './midia-url';

import {
  Anuncio,
  Amizade,
  CadastroAnuncio,
  ColecaoResumo,
  ConfiguracaoColecao,
  CadastroItemColecao,
  CadastroCompraPlanejada,
  CalculoInflacao,
  CompraPlanejada,
  ContatoAnuncio,
  ConteudoEdicao,
  ConversaDireta,
  ContribuicaoCatalogo,
  CruzamentoEdicao,
  Edicao,
  EditoraResumo,
  EdicaoComicVine,
  EstanteEditora,
  EstatisticasPublicasColecao,
  Historia,
  ItemColecao,
  LinkEdicao,
  MensagemDireta,
  PaginaResposta,
  PessoaComicVine,
  PostagemFeed,
  ImagemFeed,
  PublicacaoRelacionada,
  PublicacaoHistoria,
  ResultadoDeduplicacaoEdicoes,
  ResultadoDeduplicacaoSeries,
  ResultadoPesquisaCatalogo,
  ResultadoImportacaoCatalogo,
  RespostaAssistente,
  AssistenteFaqBase,
  Serie,
  TipoContribuicaoCatalogo,
  StatusPublicacaoHistoria,
  TipoConteudoEdicao,
  TipoPublicacaoHistoria,
  Usuario,
  VolumeComicVine,
} from './modelos';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);

  obterResumoColecao() {
    return this.http.get<ColecaoResumo>('/api/colecao/resumo');
  }

  obterConfiguracaoColecao() {
    return this.http.get<ConfiguracaoColecao>('/api/colecao/configuracao');
  }

  atualizarConfiguracaoColecao(dto: { visibilidadeColecao: 'PRIVADA' | 'AMIGOS' | 'PUBLICA'; exibirValorColecao: boolean }) {
    return this.http.put<ConfiguracaoColecao>('/api/colecao/configuracao', dto);
  }

  listarFeed(pagina = 0, tamanho = 20) {
    const params = new HttpParams()
      .set('pagina', pagina)
      .set('tamanho', tamanho);
    return this.http.get<PostagemFeed[]>('/api/feed', { params }).pipe(
      map((postagens) => postagens.map((postagem) => this.normalizarPostagem(postagem))),
    );
  }

  obterFeedUsuario(usuarioId: number, pagina = 0, tamanho = 20) {
    const params = new HttpParams()
      .set('pagina', pagina)
      .set('tamanho', tamanho);
    return this.http.get<PostagemFeed[]>(`/api/feed/usuarios/${usuarioId}`, { params }).pipe(
      map((postagens) => postagens.map((postagem) => this.normalizarPostagem(postagem))),
    );
  }

  enviarImagensFeed(arquivos: File[]) {
    const dados = new FormData();
    arquivos.forEach((arquivo) => dados.append('imagens', arquivo));
    return this.http.post<ImagemFeed[]>('/api/feed/imagens', dados).pipe(
      map((imagens) => imagens.map((imagem) => this.normalizarImagem(imagem))),
    );
  }

  publicarNoFeed(dto: { conteudo: string; urlImagem: string | null; imagens?: ImagemFeed[] }) {
    return this.http.post<PostagemFeed>('/api/feed', dto).pipe(map((postagem) => this.normalizarPostagem(postagem)));
  }

  alternarCurtidaPostagem(id: number) {
    return this.http
      .post<PostagemFeed>(`/api/feed/${id}/curtidas`, {})
      .pipe(map((postagem) => this.normalizarPostagem(postagem)));
  }

  comentarPostagem(id: number, texto: string) {
    return this.http
      .post<PostagemFeed>(`/api/feed/${id}/comentarios`, { texto })
      .pipe(map((postagem) => this.normalizarPostagem(postagem)));
  }

  removerPostagemFeed(id: number) {
    return this.http.delete<void>(`/api/feed/${id}`);
  }

  removerComentarioFeed(postagemId: number, comentarioId: number) {
    return this.http
      .delete<PostagemFeed>(`/api/feed/${postagemId}/comentarios/${comentarioId}`)
      .pipe(map((postagem) => this.normalizarPostagem(postagem)));
  }

  listarSeries(busca = '', pagina = 0, tamanho = 12, inicial = '') {
    let params = new HttpParams()
      .set('busca', busca)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    if (inicial) {
      params = params.set('inicial', inicial);
    }

    return this.http.get<PaginaResposta<Serie>>('/api/series', { params });
  }

  listarEdicoes(busca = '', pagina = 0, tamanho = 24, serieId?: number) {
    let params = new HttpParams()
      .set('busca', busca)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    if (serieId) {
      params = params.set('serieId', serieId);
    }

    return this.http.get<PaginaResposta<Edicao>>('/api/edicoes', { params });
  }

  buscarEdicaoPorId(id: number) {
    return this.http.get<Edicao>(`/api/edicoes/${id}`);
  }

  atualizarCapaEdicao(id: number, urlCapa: string) {
    return this.http.patch<Edicao>(`/api/edicoes/${id}/capa`, { urlCapa });
  }

  pesquisarCatalogo(termo: string, pagina = 0, tamanho = 20) {
    const params = new HttpParams()
      .set('termo', termo)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    return this.http.get<PaginaResposta<ResultadoPesquisaCatalogo>>('/api/catalogo/pesquisa', { params });
  }

  listarUsuarios(busca = '') {
    let params = new HttpParams();
    if (busca.trim()) {
      params = params.set('busca', busca.trim());
    }

    return this.http.get<Usuario[]>('/api/usuarios', { params }).pipe(map((usuarios) => usuarios.map((usuario) => this.normalizarUsuario(usuario))));
  }

  obterMeuPerfil() {
    return this.http.get<Usuario>('/api/usuarios/me').pipe(map((usuario) => this.normalizarUsuario(usuario)));
  }

  atualizarMeuPerfil(dto: { nome: string; bio: string | null }) {
    return this.http.put<Usuario>('/api/usuarios/me/perfil', dto).pipe(map((usuario) => this.normalizarUsuario(usuario)));
  }

  atualizarFotoPerfil(arquivo: File) {
    const dados = new FormData();
    dados.append('foto', arquivo);
    return this.http.post<Usuario>('/api/usuarios/me/foto', dados).pipe(map((usuario) => this.normalizarUsuario(usuario)));
  }

  obterPerfilUsuario(id: number) {
    return this.http.get<Usuario>(`/api/usuarios/${id}`).pipe(map((usuario) => this.normalizarUsuario(usuario)));
  }

  obterRelacionamentoAmizade(usuarioId: number) {
    return this.http.get<Amizade | null>(`/api/amizades/relacionamento/${usuarioId}`);
  }

  obterEstantePublica(usuarioId: number) {
    return this.http.get<EstanteEditora[]>(`/api/estante/usuarios/${usuarioId}`);
  }

  obterEstantePublicaPaginada(usuarioId: number, pagina = 0, tamanho = 24, busca = '') {
    let params = new HttpParams()
      .set('pagina', pagina)
      .set('tamanho', tamanho);
    if (busca) params = params.set('busca', busca);
    return this.http.get<PaginaResposta<EstanteEditora>>(`/api/estante/usuarios/${usuarioId}/paginada`, { params });
  }

  obterEstatisticasPublicasColecao(usuarioId: number) {
    return this.http.get<EstatisticasPublicasColecao>(`/api/colecao/resumo/usuarios/${usuarioId}`);
  }

  listarEditoras() {
    return this.http.get<EditoraResumo[]>('/api/editoras');
  }

  cadastrarEditora(dto: {
    nome: string;
    descricao: string | null;
    paisOrigem: string | null;
    fonteExterna: string | null;
    idExterno: string | null;
    urlOrigem: string | null;
  }) {
    return this.http.post<EditoraResumo>('/api/editoras', dto);
  }

  cadastrarSerie(dto: {
    titulo: string;
    descricao: string | null;
    anoInicio: number | null;
    anoFim: number | null;
    volume: number | null;
    ordemCronologica: number | null;
    fonteExterna: string | null;
    idExterno: string | null;
    urlOrigem: string | null;
    editoraId: number;
  }) {
    return this.http.post<Serie>('/api/series', dto);
  }

  atualizarSerie(id: number, dto: {
    titulo: string;
    descricao: string | null;
    anoInicio: number | null;
    anoFim: number | null;
    volume: number | null;
    ordemCronologica: number | null;
    fonteExterna: string | null;
    idExterno: string | null;
    urlOrigem: string | null;
    editoraId: number;
  }) {
    return this.http.put<Serie>(`/api/series/${id}`, dto);
  }

  cadastrarEdicao(dto: {
    numero: string;
    titulo: string | null;
    descricao: string | null;
    dataPublicacao: string | null;
    urlCapa: string | null;
    codigoBarras: string | null;
    quantidadePaginas: number | null;
    precoCapa: number | null;
    formato: string | null;
    fonteExterna: string | null;
    idExterno: string | null;
    urlOrigem: string | null;
    serieId: number;
  }) {
    return this.http.post<Edicao>('/api/edicoes', dto);
  }

  atualizarEdicao(id: number, dto: {
    numero: string;
    titulo: string | null;
    descricao: string | null;
    dataPublicacao: string | null;
    urlCapa: string | null;
    codigoBarras: string | null;
    quantidadePaginas: number | null;
    precoCapa: number | null;
    formato: string | null;
    fonteExterna: string | null;
    idExterno: string | null;
    urlOrigem: string | null;
    serieId: number;
  }) {
    return this.http.put<Edicao>(`/api/edicoes/${id}`, dto);
  }

  removerEdicao(id: number) {
    return this.http.delete<void>(`/api/edicoes/${id}`);
  }

  buscarVolumesComicVine(termo: string, pagina = 0, tamanho = 12) {
    const params = new HttpParams()
      .set('termo', termo)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    return this.http.get<PaginaResposta<VolumeComicVine>>('/api/integracoes-externas/COMICVINE/volumes', {
      params,
    });
  }

  buscarEdicoesComicVine(idVolume: string, pagina = 0, tamanho = 24, idPessoa?: string, papel?: string) {
    let params = new HttpParams().set('pagina', pagina).set('tamanho', tamanho);

    if (idPessoa) {
      params = params.set('idPessoa', idPessoa);
    }
    if (papel) {
      params = params.set('papel', papel);
    }

    return this.http.get<PaginaResposta<EdicaoComicVine>>(
      `/api/integracoes-externas/COMICVINE/volumes/${idVolume}/edicoes`,
      { params },
    );
  }

  buscarEdicoesComicVinePorTermo(termo: string, pagina = 0, tamanho = 20) {
    const params = new HttpParams()
      .set('termo', termo)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    return this.http.get<PaginaResposta<EdicaoComicVine>>('/api/integracoes-externas/COMICVINE/edicoes', { params });
  }

  resolverEdicaoComicVine(serie: string, numero: string) {
    const params = new HttpParams()
      .set('serie', serie)
      .set('numero', numero);

    return this.http.get<EdicaoComicVine>('/api/integracoes-externas/COMICVINE/edicoes/resolver', { params });
  }

  buscarDetalheEdicaoComicVine(idEdicao: string) {
    return this.http.get<EdicaoComicVine>(`/api/integracoes-externas/COMICVINE/edicoes/${idEdicao}/detalhes`);
  }

  buscarPessoasComicVine(termo: string, pagina = 0, tamanho = 8) {
    const params = new HttpParams()
      .set('termo', termo)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    return this.http.get<PaginaResposta<PessoaComicVine>>('/api/integracoes-externas/COMICVINE/pessoas', { params });
  }

  buscarDetalhePessoaComicVine(idPessoa: string) {
    return this.http.get<PessoaComicVine>(`/api/integracoes-externas/COMICVINE/pessoas/${idPessoa}/detalhes`);
  }

  obterEstante() {
    return this.http.get<EstanteEditora[]>('/api/estante');
  }

  obterEstantePaginada(busca = '', statusLeitura: 'TODAS' | 'LIDO' | 'NAO_LIDO' = 'TODAS', pagina = 0, tamanho = 48) {
    let params = new HttpParams()
      .set('busca', busca)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    if (statusLeitura !== 'TODAS') {
      params = params.set('statusLeitura', statusLeitura);
    }

    return this.http.get<PaginaResposta<EstanteEditora>>('/api/estante/paginada', { params });
  }

  cadastrarItemColecao(dto: CadastroItemColecao) {
    return this.http.post<ItemColecao>('/api/colecao/itens', dto);
  }

  buscarItemColecao(id: number) {
    return this.http.get<ItemColecao>(`/api/colecao/itens/${id}`);
  }

  atualizarItemColecao(id: number, dto: CadastroItemColecao) {
    return this.http.put<ItemColecao>(`/api/colecao/itens/${id}`, dto);
  }

  listarItensColecao() {
    return this.http.get<ItemColecao[]>('/api/colecao/itens');
  }

  removerItemColecao(id: number) {
    return this.http.delete<void>(`/api/colecao/itens/${id}`);
  }

  exportarColecao(formato: 'EXCEL' | 'GOOGLE') {
    const params = new HttpParams().set('formato', formato);
    return this.http.get('/api/colecao/itens/exportar', {
      params,
      responseType: 'blob',
    });
  }

  deduplicarEdicoes() {
    return this.http.post<ResultadoDeduplicacaoEdicoes>('/api/edicoes/deduplicar', {});
  }

  deduplicarSeries() {
    return this.http.post<ResultadoDeduplicacaoSeries>('/api/series/deduplicar', {});
  }

  enviarSolicitacaoAmizade(usuarioSolicitadoId: number) {
    return this.http.post<Amizade>('/api/amizades/solicitacoes', { usuarioSolicitadoId });
  }

  listarAmigos() {
    return this.http.get<Amizade[]>('/api/amizades/amigos');
  }

  listarSolicitacoesRecebidas() {
    return this.http.get<Amizade[]>('/api/amizades/solicitacoes/recebidas');
  }

  contarSolicitacoesRecebidas() {
    return this.http.get<{ total: number }>('/api/amizades/solicitacoes/recebidas/total');
  }

  contarAlteracoesEstanteAmigos(desde?: number) {
    let params = new HttpParams();
    if (desde && desde > 0) {
      params = params.set('desde', desde);
    }

    return this.http.get<{ total: number }>('/api/contribuicoes-catalogo/alteracoes-estante-amigos/total', {
      params,
    });
  }

  listarAlteracoesEstanteAmigos(desde?: number) {
    let params = new HttpParams();
    if (desde && desde > 0) {
      params = params.set('desde', desde);
    }

    return this.http.get<ContribuicaoCatalogo[]>('/api/contribuicoes-catalogo/alteracoes-estante-amigos', {
      params,
    });
  }

  listarSolicitacoesEnviadas() {
    return this.http.get<Amizade[]>('/api/amizades/solicitacoes/enviadas');
  }

  aceitarSolicitacaoAmizade(id: number) {
    return this.http.post<Amizade>(`/api/amizades/solicitacoes/${id}/aceitar`, {});
  }

  recusarSolicitacaoAmizade(id: number) {
    return this.http.post<Amizade>(`/api/amizades/solicitacoes/${id}/recusar`, {});
  }

  removerAmigo(usuarioId: number) {
    return this.http.delete<void>(`/api/amizades/amigos/${usuarioId}`);
  }

  listarConversasDiretas() {
    return this.http.get<ConversaDireta[]>('/api/mensagens/conversas').pipe(
      map((conversas) => conversas.map((conversa) => this.normalizarConversa(conversa))),
    );
  }

  listarMensagensDiretas(usuarioId: number) {
    return this.http.get<MensagemDireta[]>(`/api/mensagens/usuarios/${usuarioId}`).pipe(
      map((mensagens) => mensagens.map((mensagem) => this.normalizarMensagem(mensagem))),
    );
  }

  enviarMensagemDireta(destinatarioId: number, texto: string) {
    return this.http
      .post<MensagemDireta>('/api/mensagens', { destinatarioId, texto })
      .pipe(map((mensagem) => this.normalizarMensagem(mensagem)));
  }

  contarMensagensNaoLidas() {
    return this.http.get<{ total: number }>('/api/mensagens/nao-lidas/total');
  }

  listarComprasPlanejadas(mes?: number, ano?: number, periodo?: { mesInicio: number; anoInicio: number; mesFim: number; anoFim: number }) {
    let params = new HttpParams();
    if (periodo) {
      params = params
        .set('mesInicio', periodo.mesInicio)
        .set('anoInicio', periodo.anoInicio)
        .set('mesFim', periodo.mesFim)
        .set('anoFim', periodo.anoFim);
    } else if (mes) {
      params = params.set('mes', mes);
    }
    if (!periodo && ano) {
      params = params.set('ano', ano);
    }

    return this.http.get<CompraPlanejada[]>('/api/compras-planejadas', { params });
  }

  cadastrarCompraPlanejada(dto: CadastroCompraPlanejada) {
    return this.http.post<CompraPlanejada>('/api/compras-planejadas', dto);
  }

  atualizarCompraPlanejada(id: number, dto: Omit<CadastroCompraPlanejada, 'edicaoId'>) {
    return this.http.put<CompraPlanejada>(`/api/compras-planejadas/${id}`, dto);
  }

  buscarItemColecaoPorOrigemExterna(fonteExterna: string, idExterno: string) {
    return this.http.get<ItemColecao | null>(`/api/colecao/itens/fontes/${fonteExterna}/itens/${idExterno}`);
  }

  calcularInflacao(valor: number, dataReferencia: string) {
    const params = new HttpParams()
      .set('valor', valor)
      .set('dataReferencia', dataReferencia);

    return this.http.get<CalculoInflacao>('/api/calculadora-inflacao', { params });
  }

  perguntarAoAssistente(pergunta: string) {
    return this.http.post<RespostaAssistente>('/api/assistente/perguntar', { pergunta });
  }

  obterFaqAssistente() {
    return this.http.get<AssistenteFaqBase>('/assets/assistente/faq-assistente-hq-hub.v2.json');
  }

  listarAnuncios() {
    return this.http.get<Anuncio[]>('/api/anuncios');
  }

  listarAnunciosPorUsuario(usuarioId: number) {
    return this.http.get<Anuncio[]>(`/api/anuncios/usuarios/${usuarioId}`);
  }

  listarMeusAnuncios() {
    return this.http.get<Anuncio[]>('/api/anuncios/meus');
  }

  cadastrarAnuncio(dto: CadastroAnuncio) {
    return this.http.post<Anuncio>('/api/anuncios', dto);
  }

  pausarAnuncio(id: number) {
    return this.http.post<Anuncio>(`/api/anuncios/${id}/pausar`, {});
  }

  reativarAnuncio(id: number) {
    return this.http.post<Anuncio>(`/api/anuncios/${id}/reativar`, {});
  }

  encerrarAnuncio(id: number) {
    return this.http.post<Anuncio>(`/api/anuncios/${id}/encerrar`, {});
  }

  obterContatoAnuncio(id: number) {
    return this.http.get<ContatoAnuncio>(`/api/anuncios/${id}/contato`);
  }

  listarPublicacoesRelacionadasPorOrigemExterna(fonteExterna: string, idExterno: string) {
    return this.http.get<PublicacaoRelacionada[]>(
      `/api/publicacoes-relacionadas/fontes/${fonteExterna}/itens/${idExterno}`,
    );
  }

  cadastrarHistoria(dto: {
    titulo: string;
    tituloOriginal: string | null;
    descricao: string | null;
    quantidadePaginas: number | null;
    tipo: TipoConteudoEdicao;
    fonteExterna: string | null;
    idExterno: string | null;
    urlOrigem: string | null;
  }) {
    return this.http.post<Historia>('/api/historias', dto);
  }

  cadastrarConteudoEdicao(dto: {
    edicaoId: number;
    historiaId: number;
    ordem: number;
    tituloUsado: string | null;
    paginaInicio: number | null;
    paginaFim: number | null;
    quantidadePaginas: number | null;
    tipo: TipoConteudoEdicao;
    observacoes: string | null;
  }) {
    return this.http.post<ConteudoEdicao>('/api/conteudos-edicoes', dto);
  }

  listarConteudosPorEdicao(edicaoId: number) {
    return this.http.get<ConteudoEdicao[]>(`/api/conteudos-edicoes/edicoes/${edicaoId}`);
  }

  cadastrarPublicacaoHistoria(dto: {
    historiaId: number;
    edicaoOriginalId: number;
    edicaoPublicadaId: number;
    status: StatusPublicacaoHistoria;
    tipoPublicacaoHistoria: TipoPublicacaoHistoria;
    fonteInformacao: string | null;
    urlFonteInformacao: string | null;
    tituloUsado: string | null;
    paginasPublicadas: number | null;
    paginasCortadas: number | null;
    fonteExterna: string | null;
    urlOrigem: string | null;
    observacoes: string | null;
  }) {
    return this.http.post<PublicacaoHistoria>('/api/publicacoes-historias', dto);
  }

  listarPublicacoesPorHistoria(historiaId: number) {
    return this.http.get<PublicacaoHistoria[]>(`/api/publicacoes-historias/historias/${historiaId}`);
  }

  listarPublicacoesPorEdicaoPublicada(edicaoId: number) {
    return this.http.get<PublicacaoHistoria[]>(`/api/publicacoes-historias/edicoes-publicadas/${edicaoId}`);
  }

  listarPublicacoesPorEdicaoOriginal(edicaoId: number) {
    return this.http.get<PublicacaoHistoria[]>(`/api/publicacoes-historias/edicoes-originais/${edicaoId}`);
  }

  removerPublicacaoHistoria(id: number) {
    return this.http.delete<void>(`/api/publicacoes-historias/${id}`);
  }

  listarLinksPorEdicao(edicaoId: number) {
    return this.http.get<LinkEdicao[]>(`/api/links-edicoes/edicoes/${edicaoId}`);
  }

  cadastrarLinkEdicao(dto: {
    edicaoId: number;
    tipo: 'AMAZON' | 'COMPRA' | 'REFERENCIA' | 'WIKIPEDIA' | 'GUIA_DOS_QUADRINHOS' | 'OUTRO';
    titulo: string;
    url: string;
    observacoes: string | null;
  }) {
    return this.http.post<LinkEdicao>('/api/links-edicoes', dto);
  }

  cruzarEdicoes(edicaoOriginalId: number, edicaoComparadaId: number) {
    const params = new HttpParams()
      .set('edicaoOriginalId', edicaoOriginalId)
      .set('edicaoComparadaId', edicaoComparadaId);

    return this.http.get<CruzamentoEdicao>('/api/cruzamentos-edicoes', { params });
  }

  importarCatalogo(jsonImportacao: unknown) {
    return this.http.post<ResultadoImportacaoCatalogo>('/api/importacoes/catalogo', jsonImportacao);
  }

  cadastrarContribuicaoCatalogo(dto: {
    edicaoId: number;
    tipo: TipoContribuicaoCatalogo;
    urlCapaSugerida: string | null;
    edicaoDestinoId: number | null;
    tipoPublicacaoRelacionada: string | null;
    fonteExterna: string | null;
    urlFonte: string | null;
    dadosSugeridosJson: string | null;
    observacoes: string | null;
  }) {
    return this.http.post<ContribuicaoCatalogo>('/api/contribuicoes-catalogo', dto);
  }

  listarContribuicoesPendentes() {
    return this.http.get<ContribuicaoCatalogo[]>('/api/contribuicoes-catalogo/pendentes');
  }

  contarContribuicoesPendentes() {
    return this.http.get<{ total: number }>('/api/contribuicoes-catalogo/pendentes/total');
  }

  aprovarContribuicaoCatalogo(id: number, mensagemRevisao: string | null) {
    return this.http.post<ContribuicaoCatalogo>(`/api/contribuicoes-catalogo/${id}/aprovar`, { mensagemRevisao });
  }

  recusarContribuicaoCatalogo(id: number, mensagemRevisao: string | null) {
    return this.http.post<ContribuicaoCatalogo>(`/api/contribuicoes-catalogo/${id}/recusar`, { mensagemRevisao });
  }

  private normalizarUrlMidia(url: string | null | undefined): string | null {
    return normalizarUrlMidia(url);
  }

  private normalizarUsuario(usuario: Usuario): Usuario {
    return {
      ...usuario,
      fotoPerfilUrl: this.normalizarUrlMidia(usuario.fotoPerfilUrl),
      fotoPerfilThumbnailUrl: this.normalizarUrlMidia(usuario.fotoPerfilThumbnailUrl),
    };
  }

  private normalizarImagem(imagem: ImagemFeed): ImagemFeed {
    return {
      ...imagem,
      urlImagem: this.normalizarUrlMidia(imagem.urlImagem) || imagem.urlImagem,
      urlThumbnail: this.normalizarUrlMidia(imagem.urlThumbnail) || imagem.urlThumbnail,
    };
  }

  private normalizarPostagem(postagem: PostagemFeed): PostagemFeed {
    return {
      ...postagem,
      usuario: this.normalizarUsuario(postagem.usuario),
      urlImagem: this.normalizarUrlMidia(postagem.urlImagem),
      imagens: (postagem.imagens || []).map((imagem) => this.normalizarImagem(imagem)),
      comentarios: (postagem.comentarios || []).map((comentario) => ({
        ...comentario,
        usuario: this.normalizarUsuario(comentario.usuario),
      })),
    };
  }

  private normalizarMensagem(mensagem: MensagemDireta): MensagemDireta {
    return {
      ...mensagem,
      remetente: this.normalizarUsuario(mensagem.remetente),
      destinatario: this.normalizarUsuario(mensagem.destinatario),
    };
  }

  private normalizarConversa(conversa: ConversaDireta): ConversaDireta {
    return {
      ...conversa,
      usuario: this.normalizarUsuario(conversa.usuario),
      ultimaMensagem: this.normalizarMensagem(conversa.ultimaMensagem),
    };
  }
}
