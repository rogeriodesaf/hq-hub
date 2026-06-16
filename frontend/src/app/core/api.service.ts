import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';

import {
  ColecaoResumo,
  CadastroCompraPlanejada,
  CalculoInflacao,
  CompraPlanejada,
  Edicao,
  EdicaoComicVine,
  EstanteEditora,
  ItemColecao,
  PaginaResposta,
  PublicacaoRelacionada,
  RespostaAssistente,
  Serie,
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

  buscarVolumesComicVine(termo: string, pagina = 0, tamanho = 12) {
    const params = new HttpParams()
      .set('termo', termo)
      .set('pagina', pagina)
      .set('tamanho', tamanho);

    return this.http.get<PaginaResposta<VolumeComicVine>>('/api/integracoes-externas/COMICVINE/volumes', {
      params,
    });
  }

  buscarEdicoesComicVine(idVolume: string, pagina = 0, tamanho = 24) {
    const params = new HttpParams().set('pagina', pagina).set('tamanho', tamanho);

    return this.http.get<PaginaResposta<EdicaoComicVine>>(
      `/api/integracoes-externas/COMICVINE/volumes/${idVolume}/edicoes`,
      { params },
    );
  }

  obterEstante() {
    return this.http.get<EstanteEditora[]>('/api/estante');
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
