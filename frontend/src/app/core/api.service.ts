import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';

import {
  Amizade,
  ColecaoResumo,
  CadastroItemColecao,
  CadastroCompraPlanejada,
  CalculoInflacao,
  CompraPlanejada,
  Edicao,
  EdicaoComicVine,
  EstanteEditora,
  ItemColecao,
  PaginaResposta,
  PessoaComicVine,
  PublicacaoRelacionada,
  ResultadoPesquisaCatalogo,
  RespostaAssistente,
  Serie,
  Usuario,
  VolumeComicVine,
} from './modelos';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);

  obterResumoColecao() {
    return this.http.get<ColecaoResumo>('/api/colecao/resumo');
  }

  listarSeries(busca = '', pagina = 0, tamanho = 12) {
    const params = new HttpParams()
      .set('busca', busca)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

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

  pesquisarCatalogo(termo: string) {
    const params = new HttpParams().set('termo', termo);
    return this.http.get<ResultadoPesquisaCatalogo[]>('/api/catalogo/pesquisa', { params });
  }

  listarUsuarios() {
    return this.http.get<Usuario[]>('/api/usuarios');
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

  cadastrarItemColecao(dto: CadastroItemColecao) {
    return this.http.post<ItemColecao>('/api/colecao/itens', dto);
  }

  atualizarItemColecao(id: number, dto: CadastroItemColecao) {
    return this.http.put<ItemColecao>(`/api/colecao/itens/${id}`, dto);
  }

  listarItensColecao() {
    return this.http.get<ItemColecao[]>('/api/colecao/itens');
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

  listarComprasPlanejadas(mes?: number, ano?: number) {
    let params = new HttpParams();
    if (mes) {
      params = params.set('mes', mes);
    }
    if (ano) {
      params = params.set('ano', ano);
    }

    return this.http.get<CompraPlanejada[]>('/api/compras-planejadas', { params });
  }

  cadastrarCompraPlanejada(dto: CadastroCompraPlanejada) {
    return this.http.post<CompraPlanejada>('/api/compras-planejadas', dto);
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

  listarPublicacoesRelacionadasPorOrigemExterna(fonteExterna: string, idExterno: string) {
    return this.http.get<PublicacaoRelacionada[]>(
      `/api/publicacoes-relacionadas/fontes/${fonteExterna}/itens/${idExterno}`,
    );
  }
}
