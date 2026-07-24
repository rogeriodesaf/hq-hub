import { CommonModule } from '@angular/common';
import { Component, ElementRef, OnDestroy, OnInit, ViewChild, computed, effect, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { ActivatedRoute } from '@angular/router';
import { firstValueFrom, forkJoin } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import {
  ConteudoEdicao,
  CapaEdicao,
  Edicao,
  EdicaoComicVine,
  EditoraResumo,
  LinkEdicao,
  PaginaResposta,
  PublicacaoHistoria,
  ResultadoPesquisaCatalogo,
  Serie,
} from '../../core/modelos';

@Component({
  selector: 'app-catalogo-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Catálogo</p>
        <h1>Busque no acervo interno e também em fontes externas.</h1>
      </div>
    </section>

    @if (mensagem()) {
      <aside class="toast-sistema" [class.sucesso]="tipoMensagem() === 'sucesso'" [class.erro]="tipoMensagem() === 'erro'" [class.info]="tipoMensagem() === 'info'" role="status" aria-live="polite">
        <p>{{ mensagem() }}</p>
        <button type="button" class="fechar-toast" (click)="fecharMensagem()" aria-label="Fechar mensagem">×</button>
      </aside>
    }

    <section class="catalogo-layout">
      <article class="bloco">
        <div class="secao-titulo">
          <div>
            <h2>Séries internas</h2>
            <p class="texto-suave">Acervo já cadastrado no HQ-HUB.</p>
          </div>
          @if (seriesConsultadas()) {
            <span>{{ series().totalItens }} itens</span>
          }
        </div>

        <div class="controles-series">
          <input
            [(ngModel)]="buscaSeries"
            placeholder="Filtrar séries internas"
            (keyup.enter)="buscarSeriesInternas()"
          />
          <button class="botao primario compacto" type="button" (click)="buscarSeriesInternas()">
            Buscar
          </button>
          <div class="indice-alfabetico" aria-label="Filtro alfabético de séries">
            <button type="button" [class.ativo]="inicialSeries() === '' && seriesConsultadas()" (click)="alterarInicialSeries('')">Todas</button>
            @for (letra of letrasIndice; track letra) {
              <button type="button" [class.ativo]="inicialSeries() === letra" (click)="alterarInicialSeries(letra)">
                {{ letra }}
              </button>
            }
          </div>
        </div>

        @if (seriesConsultadas()) {
        <div class="lista-linhas">
          @for (serie of series().itens; track serie.id) {
            <div class="linha-serie">
              <button type="button" [class.ativo]="serieSelecionada()?.id === serie.id" (click)="selecionarSerie(serie)">
                <strong>{{ serie.titulo }}</strong>
                <span>{{ serie.editora?.nome || 'Sem editora' }} · V{{ serie.volume || '-' }}</span>
              </button>
              @if (podeEditarCatalogo()) {
                <button
                  class="botao secundario compacto"
                  type="button"
                  (click)="editarVolumeSerie(serie)"
                  [disabled]="salvandoSerie() === serie.id || removendoSerie() === serie.id"
                >
                  {{ salvandoSerie() === serie.id ? '...' : 'Editar' }}
                </button>
                @if (podeExcluirCatalogo()) {
                  <button
                    class="botao perigo compacto botao-remover-serie"
                    type="button"
                    (click)="removerSerie(serie)"
                    [disabled]="removendoSerie() === serie.id"
                    aria-label="Excluir série"
                  >
                    {{ removendoSerie() === serie.id ? '...' : 'Excluir' }}
                  </button>
                }
              }
            </div>
          } @empty {
            <section class="estado-vazio compacto">
              <h2>Nenhuma série interna cadastrada</h2>
              <p>Esta área mostra apenas os títulos já salvos no banco do HQ-HUB.</p>
            </section>
          }
        </div>
        }

        @if (seriesConsultadas() && series().totalPaginas > 1) {
          <div class="paginacao catalogo-paginacao">
            <button class="botao secundario compacto" type="button" (click)="paginaAnteriorSeries()" [disabled]="series().pagina === 0">
              Anterior
            </button>
            <span>Página {{ series().pagina + 1 }} de {{ series().totalPaginas }}</span>
            <button
              class="botao secundario compacto"
              type="button"
              (click)="proximaPaginaSeries()"
              [disabled]="series().pagina + 1 >= series().totalPaginas"
            >
              Próxima
            </button>
          </div>
        }
      </article>

      <article class="bloco resultados-catalogo-bloco" #resultadosCatalogoBloco>
        <div class="secao-titulo">
          <div>
            <h2>Resultados da busca</h2>
            <p class="texto-suave">Clique em uma edição interna para ver capa, histórias e publicações originais.</p>
          </div>
          <span>{{ resultadosCatalogo().totalItens }} itens</span>
        </div>

        <div class="grade-mini-capas">
          @for (resultado of resultadosCatalogo().itens; track chaveResultado(resultado)) {
            <article class="mini-capa resultado-catalogo" [class.externo]="resultado.fonte === 'COMIC_VINE'">
              <img
                [src]="resultado.urlCapa || capaReserva"
                [alt]="tituloResultadoCartao(resultado)"
                loading="lazy"
                (error)="usarCapaReserva($event)"
              />
              <strong>#{{ resultado.numero || '-' }}</strong>
              <span [title]="tituloResultadoCartao(resultado)">{{ tituloResultadoCartao(resultado) }}</span>
              @if (subtituloResultadoCartao(resultado)) {
                <small [title]="subtituloResultadoCartao(resultado)">{{ subtituloResultadoCartao(resultado) }}</small>
              }
              <em>{{ rotuloFonte(resultado) }}</em>
              @if (resultado.jaCadastrada && resultado.id) {
                <div class="resultado-catalogo-acoes">
                  <button class="botao compacto" type="button" (click)="abrirInterna(resultado)">
                    Ver detalhes
                  </button>
                  <button
                    class="botao primario compacto"
                    type="button"
                    (click)="abrirModalAdicionarNaEstante(resultado)"
                    [disabled]="salvandoItemColecao() === resultado.id"
                  >
                    {{ salvandoItemColecao() === resultado.id ? 'Adicionando...' : 'Adicionar à minha estante' }}
                  </button>
                </div>
              } @else if (resultado.urlOrigem) {
                <a class="botao compacto" [href]="resultado.urlOrigem" target="_blank" rel="noreferrer">
                  Abrir Comic Vine
                </a>
              } @else {
                <button class="botao compacto" type="button" disabled>
                  Importação pendente
                </button>
              }
            </article>
          } @empty {
            <section class="estado-vazio compacto">
              <h2>Nenhuma edição encontrada</h2>
              <p>Digite um termo para buscar no HQ-HUB e na Comic Vine.</p>
            </section>
          }
        </div>

        @if (resultadosCatalogo().totalPaginas > 1) {
          <div class="paginacao catalogo-paginacao">
            <button class="botao secundario compacto" type="button" (click)="paginaAnterior()" [disabled]="paginaResultados() === 0">
              Anterior
            </button>
            <span>Página {{ paginaResultados() + 1 }} de {{ resultadosCatalogo().totalPaginas }}</span>
            <button
              class="botao secundario compacto"
              type="button"
              (click)="proximaPagina()"
              [disabled]="paginaResultados() + 1 >= resultadosCatalogo().totalPaginas"
            >
              Próxima
            </button>
          </div>
        }
      </article>
    </section>

    @if (resultadoParaEstante()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Adicionar edição à estante">
        <div class="detalhe-fundo" (click)="fecharModalAdicionarNaEstante()"></div>
        <article class="detalhe-painel modal-estante-catalogo">
          <button class="fechar-detalhe" type="button" (click)="fecharModalAdicionarNaEstante()" aria-label="Fechar adição à estante">×</button>
          <div class="detalhe-cabecalho">
            <img
              [src]="resultadoParaEstante()?.urlCapa || capaReserva"
              [alt]="tituloResultadoEstante()"
              (error)="usarCapaReserva($event)"
            />
            <div>
              <p class="rotulo">Adicionar à estante</p>
              <h2>{{ tituloResultadoEstante() }}</h2>
              <div class="chips">
                <span>#{{ resultadoParaEstante()?.numero || '-' }}</span>
                <span>{{ resultadoParaEstante()?.nomeVolume || 'Volume não informado' }}</span>
              </div>
            </div>
          </div>

          <form class="painel-formulario grade-formulario modal-estante-formulario" (ngSubmit)="confirmarAdicionarNaEstante()">
            <label>
              Conservação
              <select [(ngModel)]="formularioItemColecao.estadoConservacao" name="estadoConservacaoCatalogo">
                <option value="NOVO">Novo</option>
                <option value="EXCELENTE">Excelente</option>
                <option value="MUITO_BOM">Muito bom</option>
                <option value="BOM">Bom</option>
                <option value="REGULAR">Regular</option>
                <option value="RUIM">Ruim</option>
              </select>
            </label>

            <label>
              Data da compra
              <input type="date" [(ngModel)]="formularioItemColecao.dataAquisicao" name="dataAquisicaoCatalogo" />
            </label>

            <label>
              Preço pago
              <input type="number" min="0" step="0.01" [(ngModel)]="formularioItemColecao.precoPago" name="precoPagoCatalogo" placeholder="Vazio usa preço de capa" />
            </label>

            <label>
              Leitura
              <select [(ngModel)]="formularioItemColecao.statusLeitura" name="statusLeituraCatalogo">
                <option value="NAO_LIDO">Não lido</option>
                <option value="LIDO">Lido</option>
              </select>
            </label>

            <label class="campo-largo">
              Observações
              <input [(ngModel)]="formularioItemColecao.observacoes" name="observacoesCatalogo" placeholder="Ex.: comprado em promoção, capa variante..." />
            </label>

            <div class="acoes-formulario campo-largo">
              <button class="botao primario" type="submit" [disabled]="!!salvandoItemColecao()">
                {{ salvandoItemColecao() ? 'Adicionando...' : 'Adicionar à estante' }}
              </button>
              <button class="botao secundario" type="button" (click)="fecharModalAdicionarNaEstante()" [disabled]="!!salvandoItemColecao()">
                Cancelar
              </button>
            </div>
          </form>
        </article>
      </section>
    }

    @if (exibirPainelDetalhe()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da edição">
        <div class="detalhe-fundo" (click)="fecharDetalhe()"></div>
        <article class="detalhe-painel detalhe-painel-catalogo" #detalhePainel>
          <button class="fechar-detalhe" type="button" (click)="fecharDetalhe()" aria-label="Fechar detalhes">×</button>
          @if (historicoDetalhes().length) {
            <button class="botao compacto voltar-detalhe" type="button" (click)="voltarDetalheAnterior()">
              Voltar
            </button>
          }

          @if (edicaoDetalhe()) {
          <div class="detalhe-cabecalho">
            <img [src]="capaEdicaoDetalhe() || capaReserva" [alt]="edicaoDetalhe() ? tituloEdicao(edicaoDetalhe()!) : 'Edicao'" (error)="usarCapaReserva($event)" />
            <div>
              <p class="rotulo">{{ edicaoDetalhe()?.serie?.editora?.nome || 'Editora não informada' }}</p>
              <h2>{{ edicaoDetalhe()?.serie?.titulo }} #{{ edicaoDetalhe()?.numero }}</h2>
              <div class="chips">
                <span>{{ edicaoDetalhe()?.dataPublicacao || 'data não informada' }}</span>
                @if (edicaoDetalhe()?.quantidadePaginas) {
                  <span>{{ edicaoDetalhe()?.quantidadePaginas }} páginas</span>
                }
                @if (edicaoDetalhe()?.formato) {
                  <span>{{ edicaoDetalhe()?.formato }}</span>
                }
              </div>
              <div
                class="descricao-formatada"
                [innerHTML]="formatarDescricao(descricaoEdicaoDetalhe())"
              ></div>
              @if (linksAmazonDetalhe().length || edicaoDetalhe()?.serie?.titulo) {
                <div class="bloco-compra">
                  @if (edicaoDetalhe()?.precoCapa) {
                    <p class="preco-capa-referencia">
                      <span class="preco-capa-valor">{{ formatarMoeda(edicaoDetalhe()?.precoCapa || 0) }}</span>
                      <span class="preco-capa-rotulo">preço de capa</span>
                    </p>
                  }
                  <div class="acoes-detalhe-edicao">
                    @for (link of linksAmazonDetalhe(); track link.id) {
                      <a class="botao compacto botao-amazon" [href]="link.url" target="_blank" rel="noreferrer" [attr.aria-label]="link.titulo || 'Comprar na Amazon'">
                        <span>Comprar na</span>
                        <span class="amazon-marca" aria-hidden="true">amazon</span>
                        @if (link.preco) {
                          <span class="amazon-preco">R$ {{ link.preco | number:'1.2-2':'pt-BR' }}</span>
                        }
                      </a>
                      @if (link.preco && link.dataCapturacaoPreco) {
                        <span class="preco-captura-data">capturado em {{ link.dataCapturacaoPreco | date:'dd/MM/yyyy' }}</span>
                      }
                    }
                    @if (edicaoDetalhe()?.serie?.titulo) {
                      <a class="botao compacto botao-ml" [href]="urlBuscaMercadoLivre()" target="_blank" rel="noreferrer" aria-label="Buscar no Mercado Livre">
                        <span class="ml-marca">Mercado Livre</span>
                      </a>
                    }
                  </div>
                </div>
              }
              @if (edicaoDetalhe() && podeEditarCatalogo()) {
                <div class="acoes-detalhe-edicao">
                  @if (!editandoDetalhe()) {
                    <button class="botao compacto" type="button" (click)="iniciarEdicaoDetalhe()">
                      Editar dados
                    </button>
                  } @else {
                    <button class="botao compacto" type="button" (click)="cancelarEdicaoDetalhe()" [disabled]="salvandoDetalhe()">
                      Cancelar
                    </button>
                  }
                  @if (podeExcluirCatalogo()) {
                    <button class="botao perigo compacto" type="button" (click)="removerEdicaoDetalhe()" [disabled]="removendoEdicao() || salvandoDetalhe()">
                      {{ removendoEdicao() ? 'Excluindo...' : 'Excluir' }}
                    </button>
                  }
                </div>
              }
            </div>
          </div>
          }

          @if (edicaoDetalhe()) {
            <section class="detalhe-secao capa-gestao">
              <div class="secao-titulo">
                <div>
                  <h3>Capas da edição</h3>
                  <p class="texto-suave">A capa oficial só muda depois de aprovada.</p>
                </div>
              </div>

              <div class="grade-formulario">
                <label>
                  Enviar arquivo
                  <input type="file" accept="image/jpeg,image/png,image/webp" (change)="selecionarArquivoCapa($event)" />
                </label>
                <label class="campo-largo">
                  Enviar URL de capa
                  <input [(ngModel)]="urlCapaEnvio" name="urlCapaEnvioCatalogo" placeholder="https://..." />
                </label>
              </div>

              @if (previewCapaSelecionada()) {
                <div class="previa-capa">
                  <img [src]="previewCapaSelecionada()" alt="Prévia da capa selecionada" />
                </div>
              }

              <div class="acoes-formulario">
                <button class="botao primario" type="button" (click)="enviarCapaArquivo()" [disabled]="!arquivoCapaSelecionado || enviandoCapa()">
                  {{ enviandoCapa() ? 'Enviando...' : 'Enviar arquivo' }}
                </button>
                <button class="botao secundario" type="button" (click)="enviarCapaUrl()" [disabled]="!urlCapaEnvio.trim() || enviandoCapa()">
                  Enviar URL
                </button>
              </div>

              @if (capasDetalhe().length) {
                <div class="lista-capas-edicao">
                  @for (capa of capasDetalhe(); track capa.id) {
                    <article class="publicacao-card capa-edicao-card">
                      <img class="capa-publicacao" [src]="capa.urlImagem" [alt]="'Capa ' + capa.id" loading="lazy" (error)="usarCapaReserva($event)" />
                      <div>
                        <p class="rotulo">{{ rotuloStatusCapa(capa.status) }} · {{ rotuloOrigemCapa(capa.origem) }}</p>
                        <h4>{{ capa.enviadoPorNome || 'Usuário' }}</h4>
                        <p>{{ capa.dataEnvio | date:'short' }}</p>
                        @if (capa.observacao) {
                          <p>{{ capa.observacao }}</p>
                        }
                        @if (podeEditarCatalogo() && capa.status === 'PENDENTE') {
                          <div class="acoes-detalhe-edicao">
                            <button class="botao compacto" type="button" (click)="aprovarCapa(capa)" [disabled]="revisandoCapa() === capa.id">
                              {{ revisandoCapa() === capa.id ? 'Salvando...' : 'Aprovar' }}
                            </button>
                            <button class="botao compacto secundario" type="button" (click)="rejeitarCapa(capa)" [disabled]="revisandoCapa() === capa.id">
                              Rejeitar
                            </button>
                          </div>
                        }
                      </div>
                    </article>
                  }
                </div>
              } @else {
                <p class="texto-suave">Nenhuma capa enviada para análise ainda.</p>
              }
            </section>
          }

          @if (editandoDetalhe()) {
            <section class="painel-formulario editor-edicao-detalhe">
              <h2>Dados editoriais da edicao</h2>
              <div class="grade-formulario">
                <label class="campo-largo">
                  Serie
                  <div class="campo-busca-serie-edicao">
                    <input
                      [(ngModel)]="buscaSerieEdicao"
                      name="buscaSerieEdicaoCatalogo"
                      placeholder="Ex.: Saga do Batman"
                      (keyup.enter)="buscarSeriesParaEdicao()"
                    />
                    <button
                      class="botao secundario compacto"
                      type="button"
                      (click)="buscarSeriesParaEdicao()"
                      [disabled]="carregandoSeriesEdicao()"
                    >
                      {{ carregandoSeriesEdicao() ? 'Buscando...' : 'Buscar serie' }}
                    </button>
                  </div>
                  <select [(ngModel)]="formularioEdicao.serieId" name="serieEdicaoCatalogo" required>
                    @for (serie of seriesParaEdicao(); track serie.id) {
                      <option [ngValue]="serie.id">
                        {{ serie.titulo }} · volume {{ serie.volume || '-' }} · {{ serie.editora?.nome || 'Sem editora' }} (ID {{ serie.id }})
                      </option>
                    }
                  </select>
                </label>
                <label>
                  Numero
                  <input [(ngModel)]="formularioEdicao.numero" name="numeroEdicaoCatalogo" required />
                </label>
                <label>
                  Titulo
                  <input [(ngModel)]="formularioEdicao.titulo" name="tituloEdicaoCatalogo" />
                </label>
                <label>
                  Publicacao
                  <input [(ngModel)]="formularioEdicao.dataPublicacao" name="dataPublicacaoEdicaoCatalogo" type="date" />
                </label>
                <label>
                  Paginas
                  <input [(ngModel)]="formularioEdicao.quantidadePaginas" name="paginasEdicaoCatalogo" type="number" min="1" />
                </label>
                <label>
                  Preco de capa
                  <input [(ngModel)]="formularioEdicao.precoCapa" name="precoEdicaoCatalogo" type="number" min="0" step="0.01" />
                </label>
                <label>
                  Formato
                  <input [(ngModel)]="formularioEdicao.formato" name="formatoEdicaoCatalogo" />
                </label>
                <label>
                  Codigo de barras
                  <input [(ngModel)]="formularioEdicao.codigoBarras" name="codigoBarrasEdicaoCatalogo" />
                </label>
                <label class="campo-largo">
                  URL da capa
                  <input [(ngModel)]="formularioEdicao.urlCapa" name="urlCapaEdicaoCatalogo" />
                </label>
                <label class="campo-largo">
                  Link Amazon
                  <input [(ngModel)]="formularioEdicao.urlCompraAmazon" name="urlCompraAmazonEdicaoCatalogo" />
                </label>
                <label class="campo-largo">
                  Fonte
                  <input [(ngModel)]="formularioEdicao.urlOrigem" name="urlOrigemEdicaoCatalogo" />
                </label>
                <label class="campo-largo campo-descricao-edicao">
                  Descricao
                  <textarea [(ngModel)]="formularioEdicao.descricao" name="descricaoEdicaoCatalogo" rows="7"></textarea>
                </label>
              </div>
              <div class="acoes-formulario">
                <button class="botao primario" type="button" (click)="salvarEdicaoDetalhe()" [disabled]="salvandoDetalhe()">
                  {{ salvandoDetalhe() ? 'Salvando...' : 'Salvar dados' }}
                </button>
                <button class="botao secundario" type="button" (click)="cancelarEdicaoDetalhe()" [disabled]="salvandoDetalhe()">
                  Cancelar
                </button>
              </div>
            </section>
          }

          @if (carregandoDetalhe()) {
            <section class="estado-carregando">
              <span></span>
              <p>Carregando detalhes da edição...</p>
            </section>
          }

          @if (!carregandoDetalhe() && (publicacoesDetalhe().length || !publicacoesComoOriginal().length)) {
            <section class="detalhe-secao">
              <h3>Histórias publicadas nesta edição</h3>
              @if (podeEditarCatalogo()) {
                <section class="painel-formulario vinculo-original-form">
                  <h2>Vincular HQ original</h2>
                  <div class="grade-formulario">
                    <label class="campo-largo">
                      Buscar no catálogo
                      <input [(ngModel)]="formularioVinculoOriginal.buscaOriginal" name="buscaOriginalVinculo" placeholder="Amazing Spider-Man 300" (keyup.enter)="buscarOriginaisParaVinculo()" />
                    </label>
                    <label>
                      ID da edição original
                      <input [(ngModel)]="formularioVinculoOriginal.edicaoOriginalId" name="edicaoOriginalIdVinculo" type="number" min="1" />
                    </label>
                    <label class="campo-largo">
                      História ou conteúdo
                      <input [(ngModel)]="formularioVinculoOriginal.tituloHistoria" name="tituloHistoriaVinculo" placeholder="Titulo da historia" />
                    </label>
                    <label class="campo-largo">
                      Título usado nesta edição
                      <input [(ngModel)]="formularioVinculoOriginal.tituloUsado" name="tituloUsadoVinculo" />
                    </label>
                    <label>
                      Páginas publicadas
                      <input [(ngModel)]="formularioVinculoOriginal.paginasPublicadas" name="paginasPublicadasVinculo" type="number" min="1" />
                    </label>
                    <label>
                      Status
                      <select [(ngModel)]="formularioVinculoOriginal.status" name="statusVinculoOriginal">
                        <option value="COMPLETA">Completa</option>
                        <option value="PARCIAL">Parcial</option>
                        <option value="CORTADA">Cortada</option>
                        <option value="ADAPTADA">Adaptada</option>
                        <option value="DESCONHECIDA">Desconhecida</option>
                      </select>
                    </label>
                    <label class="campo-largo">
                      Observações
                      <input [(ngModel)]="formularioVinculoOriginal.observacoes" name="observacoesVinculoOriginal" />
                    </label>
                  </div>
                  <div class="acoes-formulario">
                    <button class="botao secundario" type="button" (click)="buscarOriginaisParaVinculo()" [disabled]="buscandoOriginaisVinculo() || !formularioVinculoOriginal.buscaOriginal.trim()">
                      {{ buscandoOriginaisVinculo() ? 'Buscando...' : 'Buscar original' }}
                    </button>
                    <button class="botao primario" type="button" (click)="salvarVinculoOriginal()" [disabled]="salvandoVinculoOriginal()">
                      {{ salvandoVinculoOriginal() ? 'Salvando...' : 'Salvar vínculo' }}
                    </button>
                  </div>
                  @if (resultadosOriginaisVinculo().length) {
                    <div class="series-capa resultados-vinculo-original">
                      @for (resultado of resultadosOriginaisVinculo(); track chaveResultado(resultado)) {
                        <button type="button" (click)="selecionarOriginalParaVinculo(resultado)" [class.ativo]="formularioVinculoOriginal.edicaoOriginalId === resultado.id">
                          <strong>{{ resultado.nomeVolume || resultado.titulo || 'Edição original' }} #{{ resultado.numero || '-' }}</strong>
                          <span>ID {{ resultado.id }}</span>
                        </button>
                      }
                    </div>
                  }
                </section>
              }
              @for (publicacao of publicacoesDetalhe(); track publicacao.id) {
                <article class="publicacao-card">
                  <img
                    class="capa-publicacao"
                    [src]="capaPublicacaoOriginal(publicacao) || capaReserva"
                    [alt]="tituloEdicaoOriginal(publicacao)"
                    loading="lazy"
                    (error)="usarCapaReserva($event)"
                  />
                  <div>
                    <p class="rotulo">{{ rotuloStatus(publicacao.status) }}</p>
                    <h4>{{ publicacao.historia.tituloExibicao || publicacao.historia.titulo }}</h4>
                    <p>
                      Publicada originalmente em
                      <button class="link-edicao-original" type="button" (click)="abrirDetalheOriginal(publicacao)">
                        {{ tituloEdicaoOriginal(publicacao) }}
                      </button>
                      @if (linkEdicaoOriginal(publicacao)) {
                        <a class="link-fonte-original" [href]="linkEdicaoOriginal(publicacao)" target="_blank" rel="noreferrer">
                          {{ rotuloFonteEdicao(publicacao.edicaoOriginal) }}
                        </a>
                      }
                    </p>
                    @if (publicacao.historia.tituloOriginal) {
                      <p>Título original: {{ publicacao.historia.tituloOriginal }}</p>
                    }
                    @if (publicacao.paginasPublicadas) {
                      <p>{{ publicacao.paginasPublicadas }} páginas</p>
                    }
                    @if (publicacao.historia.descricaoExibicao) {
                      <p>{{ publicacao.historia.descricaoExibicao }}</p>
                    }
                    @if (podeEditarCatalogo()) {
                      <div class="acoes-detalhe-edicao">
                        <input
                          class="input-capa-publicacao"
                          [ngModel]="urlCapaPublicacao(publicacao)"
                          (ngModelChange)="alterarUrlCapaPublicacao(publicacao, $event)"
                          [name]="'urlCapaPublicacao' + publicacao.id"
                          placeholder="URL da capa original"
                        />
                        <button class="botao compacto" type="button" (click)="salvarCapaPublicacao(publicacao)" [disabled]="salvandoCapaPublicacao() === publicacao.id">
                          {{ salvandoCapaPublicacao() === publicacao.id ? 'Salvando...' : 'Salvar capa' }}
                        </button>
                        @if (podeExcluirCatalogo()) {
                          <button class="botao compacto secundario" type="button" (click)="removerPublicacaoDetalhe(publicacao)" [disabled]="removendoPublicacao() === publicacao.id">
                            {{ removendoPublicacao() === publicacao.id ? 'Excluindo...' : 'Excluir publicacao' }}
                          </button>
                        }
                      </div>
                    }
                  </div>
                </article>
              } @empty {
                <p class="texto-suave">Nenhuma publicação brasileira vinculada a esta edição ainda.</p>
              }
            </section>
          }

          @if (!carregandoDetalhe() && (publicacoesComoOriginal().length || !publicacoesDetalhe().length)) {
            <section class="detalhe-secao">
              @if (historiaEmFoco()) {
                <h3>Edições que publicaram esta história</h3>
              } @else {
              <h3>Publicações brasileiras desta edição original</h3>
              }
              @for (publicacao of publicacoesComoOriginal(); track publicacao.id) {
                <article class="publicacao-card">
                  <img
                    class="capa-publicacao"
                    [src]="publicacao.edicaoPublicada.urlCapa || publicacao.edicaoOriginal.urlCapa || capaReserva"
                    [alt]="tituloEdicaoPublicada(publicacao)"
                    loading="lazy"
                    (error)="usarCapaReserva($event)"
                  />
                  <div>
                    <p class="rotulo">{{ rotuloStatus(publicacao.status) }}</p>
                    <h4>{{ publicacao.historia.tituloExibicao || publicacao.historia.titulo }}</h4>
                    <p>
                      Publicada no Brasil em
                      <button class="link-edicao-original" type="button" (click)="abrirDetalhePorId(publicacao.edicaoPublicada.id)">
                        {{ tituloEdicaoPublicada(publicacao) }}
                      </button>
                    </p>
                    @if (publicacao.paginasPublicadas) {
                      <p>{{ publicacao.paginasPublicadas }} páginas</p>
                    }
                    @if (publicacao.observacoes) {
                      <p>{{ publicacao.observacoes }}</p>
                    }
                  </div>
                </article>
              } @empty {
                <p class="texto-suave">Esta edição original ainda não tem republicações brasileiras vinculadas.</p>
              }
            </section>
          }

          @if (!carregandoDetalhe()) {
          <section class="detalhe-secao">
            <h3>Conteúdos cadastrados diretamente nesta edição</h3>
            @for (conteudo of conteudosDetalhe(); track conteudo.id) {
              <article class="publicacao-card">
                <div>
                  <p class="rotulo">Ordem {{ conteudo.ordem }}</p>
                  <h4>{{ conteudo.tituloUsado || conteudo.historia.tituloExibicao || conteudo.historia.titulo }}</h4>
                  <p>{{ conteudo.historia.descricaoExibicao || conteudo.observacoes || 'Sem descrição.' }}</p>
                </div>
              </article>
            } @empty {
              <p class="texto-suave">Esta edição não tem conteúdos diretos cadastrados.</p>
            }
          </section>
          }
        </article>
      </section>
    }

    @if (editandoSerie()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Editar série">
        <div class="detalhe-fundo" (click)="fecharEdicaoSerie()"></div>
        <article class="detalhe-painel">
          <button class="fechar-detalhe" type="button" (click)="fecharEdicaoSerie()" aria-label="Fechar edição">×</button>
          <div class="detalhe-cabecalho">
            <div>
              <p class="rotulo">Série do catálogo</p>
              <h2>Editar série</h2>
              <div class="chips">
                <span>{{ serieEmEdicao()?.titulo || 'Série sem título' }}</span>
                <span>{{ serieEmEdicao()?.editora?.nome || 'Sem editora' }}</span>
              </div>
            </div>
          </div>

          <section class="painel-formulario editor-edicao-detalhe">
            <h2>Dados da série</h2>
            <div class="chips">
              <span>ID {{ serieEmEdicao()?.id || '-' }}</span>
              <span>Volume {{ serieEmEdicao()?.volume || '-' }}</span>
              <span>Ordem {{ serieEmEdicao()?.ordemCronologica || '-' }}</span>
              <span>{{ serieEmEdicao()?.editora?.nome || 'Sem editora' }}</span>
            </div>
            <div class="grade-formulario">
              <label class="campo-largo">
                Titulo
                <input [(ngModel)]="formularioSerieEdicao.titulo" name="tituloSerieCatalogo" required />
              </label>
              <label>
                Volume
                <input [(ngModel)]="formularioSerieEdicao.volume" name="volumeSerieCatalogo" type="number" min="1" />
              </label>
              <label>
                Ordem cronologica
                <input [(ngModel)]="formularioSerieEdicao.ordemCronologica" name="ordemSerieCatalogo" type="number" min="1" />
              </label>
              <label class="campo-largo">
                Editora
                <input [(ngModel)]="formularioSerieEdicao.editoraNome" name="editoraSerieCatalogo" list="listaEditorasCatalogo" required />
                <datalist id="listaEditorasCatalogo">
                  @for (editora of editoras(); track editora.id) {
                    <option [value]="editora.nome"></option>
                  }
                </datalist>
              </label>
              <label>
                Ano inicio
                <input [(ngModel)]="formularioSerieEdicao.anoInicio" name="anoInicioSerieCatalogo" type="number" min="0" />
              </label>
              <label>
                Ano fim
                <input [(ngModel)]="formularioSerieEdicao.anoFim" name="anoFimSerieCatalogo" type="number" min="0" />
              </label>
              <label class="campo-largo">
                URL da fonte
                <input [(ngModel)]="formularioSerieEdicao.urlOrigem" name="urlOrigemSerieCatalogo" />
              </label>
              <label class="campo-largo">
                Fonte externa
                <input [(ngModel)]="formularioSerieEdicao.fonteExterna" name="fonteExternaSerieCatalogo" />
              </label>
              <label class="campo-largo">
                Id externo
                <input [(ngModel)]="formularioSerieEdicao.idExterno" name="idExternoSerieCatalogo" />
              </label>
              <label class="campo-largo campo-descricao-edicao">
                Descricao
                <textarea [(ngModel)]="formularioSerieEdicao.descricao" name="descricaoSerieCatalogo" rows="5"></textarea>
              </label>
            </div>
            <div class="acoes-formulario">
              <button class="botao primario" type="button" (click)="salvarEdicaoSerie()" [disabled]="salvandoSerie() !== null">
                {{ salvandoSerie() !== null ? 'Salvando...' : 'Salvar série' }}
              </button>
              <button class="botao secundario" type="button" (click)="fecharEdicaoSerie()" [disabled]="salvandoSerie() !== null">
                Cancelar
              </button>
            </div>
          </section>
        </article>
      </section>
    }
  `,
})
export class CatalogoPage implements OnInit, OnDestroy {
  @ViewChild('resultadosCatalogoBloco') private resultadosCatalogoBloco?: ElementRef<HTMLElement>;
  @ViewChild('detalhePainel') private detalhePainel?: ElementRef<HTMLElement>;

  private readonly api = inject(ApiService);
  private readonly rota = inject(ActivatedRoute);
  private readonly autenticacao = inject(AutenticacaoService);
  private readonly sanitizador = inject(DomSanitizer);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly letrasIndice = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  readonly podeEditarCatalogo = this.autenticacao.podeRevisarCatalogo;
  readonly podeExcluirCatalogo = this.autenticacao.ehAdministrador;
  readonly editoras = signal<EditoraResumo[]>([]);
  readonly series = signal<PaginaResposta<Serie>>({ itens: [], pagina: 0, tamanho: 12, totalItens: 0, totalPaginas: 0 });
  readonly resultadosCatalogo = signal<PaginaResposta<ResultadoPesquisaCatalogo>>({
    itens: [],
    pagina: 0,
    tamanho: 20,
    totalItens: 0,
    totalPaginas: 0,
  });
  readonly serieSelecionada = signal<Serie | null>(null);
  readonly edicaoDetalhe = signal<Edicao | null>(null);
  readonly historicoDetalhes = signal<Edicao[]>([]);
  readonly conteudosDetalhe = signal<ConteudoEdicao[]>([]);
  readonly publicacoesDetalhe = signal<PublicacaoHistoria[]>([]);
  readonly publicacoesComoOriginal = signal<PublicacaoHistoria[]>([]);
  readonly linksDetalhe = signal<LinkEdicao[]>([]);
  readonly capasDetalhe = signal<CapaEdicao[]>([]);
  readonly historiaEmFoco = signal<number | null>(null);
  readonly detalheComicVineInterno = signal<EdicaoComicVine | null>(null);
  readonly capasComicVineOriginais = signal<Record<number, string>>({});
  readonly carregandoResultados = signal(false);
  readonly carregandoDetalhe = signal(false);
  readonly editandoDetalhe = signal(false);
  readonly salvandoDetalhe = signal(false);
  readonly removendoEdicao = signal(false);
  readonly salvandoSerie = signal<number | null>(null);
  readonly removendoSerie = signal<number | null>(null);
  readonly removendoPublicacao = signal<number | null>(null);
  readonly salvandoCapaPublicacao = signal<number | null>(null);
  readonly carregandoSeriesEdicao = signal(false);
  readonly seriesParaEdicao = signal<Serie[]>([]);
  readonly salvandoVinculoOriginal = signal(false);
  readonly buscandoOriginaisVinculo = signal(false);
  readonly resultadosOriginaisVinculo = signal<ResultadoPesquisaCatalogo[]>([]);
  readonly enviandoCapa = signal(false);
  readonly revisandoCapa = signal<number | null>(null);
  readonly salvandoItemColecao = signal<number | null>(null);
  readonly resultadoParaEstante = signal<ResultadoPesquisaCatalogo | null>(null);
  readonly seriesConsultadas = signal(false);
  readonly previewCapaSelecionada = signal<string | null>(null);
  readonly urlsCapasPublicacoes = signal<Record<number, string>>({});
  readonly mensagem = signal('');
  readonly tipoMensagem = computed<'sucesso' | 'erro' | 'info'>(() => this.classificarMensagem(this.mensagem()));
  readonly paginaResultados = signal(0);
  readonly inicialSeries = signal('');
  readonly tamanhoResultados = 20;
  readonly tamanhoSeries = 12;
  readonly editandoSerie = signal(false);
  readonly serieEmEdicao = signal<Serie | null>(null);
  busca = '';
  buscaSeries = '';
  buscaSerieEdicao = '';
  urlCapaEnvio = '';
  arquivoCapaSelecionado: File | null = null;
  formularioEdicao = this.formularioEdicaoVazio();
  formularioSerieEdicao = this.formularioSerieEdicaoVazio();
  formularioVinculoOriginal = this.formularioVinculoOriginalVazio();
  formularioItemColecao = this.formularioItemColecaoVazio();
  private temporizadorMensagem: ReturnType<typeof setTimeout> | null = null;

  constructor() {
    effect(() => {
      const texto = this.mensagem();

      if (this.temporizadorMensagem) {
        clearTimeout(this.temporizadorMensagem);
        this.temporizadorMensagem = null;
      }

      if (!texto) {
        return;
      }

      const duracao = this.tipoMensagem() === 'erro' ? 7000 : 4500;
      this.temporizadorMensagem = setTimeout(() => {
        this.mensagem.set('');
      }, duracao);
    }, { allowSignalWrites: true });
  }

  ngOnInit() {
    this.carregarEditoras();
    const serieId = Number(this.rota.snapshot.queryParamMap.get('serieId'));
    if (Number.isFinite(serieId) && serieId > 0) {
      this.carregarEdicoesDaSerieImportada(serieId);
    }
  }

  ngOnDestroy() {
    if (this.temporizadorMensagem) {
      clearTimeout(this.temporizadorMensagem);
      this.temporizadorMensagem = null;
    }
  }

  fecharMensagem() {
    this.mensagem.set('');
  }

  carregar() {
    this.paginaResultados.set(0);
    this.buscarResultados(0);
  }

  private carregarEdicoesDaSerieImportada(serieId: number) {
    this.serieSelecionada.set(null);
    this.busca = '';
    this.seriesConsultadas.set(false);
    this.carregandoResultados.set(true);
    this.mensagem.set('Carregando edicoes da serie importada...');

    this.api.listarEdicoes('', 0, this.tamanhoResultados, serieId).subscribe({
      next: (resposta) => {
        this.resultadosCatalogo.set({
          ...resposta,
          itens: resposta.itens.map((edicao) => this.paraResultadoInterno(edicao)),
        });
        this.paginaResultados.set(resposta.pagina);
        this.carregandoResultados.set(false);
        this.mensagem.set(resposta.itens.length ? 'Edicoes da serie importada carregadas.' : 'Nenhuma edicao encontrada para a serie importada.');
      },
      error: () => {
        this.resultadosCatalogo.set({ itens: [], pagina: 0, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
        this.carregandoResultados.set(false);
        this.mensagem.set('Nao foi possivel carregar as edicoes da serie importada agora.');
      },
    });
  }

  selecionarSerie(serie: Serie) {
    this.serieSelecionada.set(serie);
    this.limparPesquisaSeries();
    this.paginaResultados.set(0);
    this.buscarResultados(0, true);
  }

  editarVolumeSerie(serie: Serie) {
    if (!this.podeEditarCatalogo()) {
      return;
    }
    this.serieEmEdicao.set(serie);
    this.formularioSerieEdicao = this.formularioAPartirDaSerie(serie);
    this.editandoSerie.set(true);
  }

  removerSerie(serie: Serie) {
    if (!this.podeExcluirCatalogo()) {
      return;
    }

    const rotulo = `${serie.titulo} - ${serie.editora?.nome || 'Sem editora'} - V${serie.volume || '-'}`;
    const confirmar = window.confirm(`Excluir a série "${rotulo}"? Só é possível excluir séries sem edições.`);
    if (!confirmar) {
      return;
    }

    this.removendoSerie.set(serie.id);
    this.mensagem.set('');
    this.api.removerSerie(serie.id).subscribe({
      next: () => {
        this.removendoSerie.set(null);
        if (this.serieSelecionada()?.id === serie.id) {
          this.serieSelecionada.set(null);
          this.resultadosCatalogo.set({ itens: [], pagina: 0, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
        }
        this.mensagem.set('Série excluída do catálogo.');
        this.carregarSeriesInternas(this.series().pagina);
      },
      error: () => {
        this.removendoSerie.set(null);
        this.mensagem.set('Não foi possível excluir esta série. Remova as edições dela primeiro.');
      },
    });
  }

  fecharEdicaoSerie() {
    this.editandoSerie.set(false);
    this.serieEmEdicao.set(null);
    this.formularioSerieEdicao = this.formularioSerieEdicaoVazio();
  }

  salvarEdicaoSerie() {
    const serie = this.serieEmEdicao();
    if (!serie) {
      return;
    }

    const titulo = this.formularioSerieEdicao.titulo.trim();
    const nomeEditora = this.formularioSerieEdicao.editoraNome.trim();
    if (!titulo) {
      this.mensagem.set('Informe o título da série antes de salvar.');
      return;
    }

    if (!nomeEditora) {
      this.mensagem.set('Informe o nome da editora da série.');
      return;
    }

    this.salvandoSerie.set(serie.id);
    this.mensagem.set('');
    this.atualizarSerieComEditora(serie.id, titulo, nomeEditora);
  }

  buscarSeriesInternas() {
    this.serieSelecionada.set(null);
    this.carregarSeriesInternas(0);
  }

  private formularioSerieEdicaoVazio() {
    return {
      titulo: '',
      descricao: '',
      anoInicio: null as number | null,
      anoFim: null as number | null,
      volume: null as number | null,
      ordemCronologica: null as number | null,
      fonteExterna: '',
      idExterno: '',
      urlOrigem: '',
      editoraNome: '',
    };
  }

  private formularioAPartirDaSerie(serie: Serie) {
    return {
      titulo: serie.titulo || '',
      descricao: serie.descricao || '',
      anoInicio: serie.anoInicio,
      anoFim: serie.anoFim,
      volume: serie.volume,
      ordemCronologica: serie.ordemCronologica,
      fonteExterna: serie.fonteExterna || '',
      idExterno: serie.idExterno || '',
      urlOrigem: serie.urlOrigem || '',
      editoraNome: serie.editora?.nome || '',
    };
  }

  private async atualizarSerieComEditora(serieId: number, titulo: string, nomeEditora: string) {
    try {
      const editoraId = await this.obterOuCriarEditoraId(nomeEditora);
      const serieAtualizada = await firstValueFrom(this.api.atualizarSerie(serieId, {
        titulo,
        descricao: this.valorTextoOuNull(this.formularioSerieEdicao.descricao),
        anoInicio: this.numeroOuNull(this.formularioSerieEdicao.anoInicio),
        anoFim: this.numeroOuNull(this.formularioSerieEdicao.anoFim),
        volume: this.numeroOuNull(this.formularioSerieEdicao.volume),
        ordemCronologica: this.numeroOuNull(this.formularioSerieEdicao.ordemCronologica),
        fonteExterna: this.valorTextoOuNull(this.formularioSerieEdicao.fonteExterna),
        idExterno: this.valorTextoOuNull(this.formularioSerieEdicao.idExterno),
        urlOrigem: this.valorTextoOuNull(this.formularioSerieEdicao.urlOrigem),
        editoraId,
      }));

      this.series.update((pagina) => ({
        ...pagina,
        itens: pagina.itens.map((item) => item.id === serieAtualizada.id ? serieAtualizada : item),
      }));
      if (this.serieSelecionada()?.id === serieAtualizada.id) {
        this.serieSelecionada.set(serieAtualizada);
      }
      this.formularioSerieEdicao = this.formularioAPartirDaSerie(serieAtualizada);
      this.editandoSerie.set(false);
      this.serieEmEdicao.set(null);
      this.mensagem.set('Série atualizada.');
    } catch {
      this.mensagem.set('Não foi possível atualizar a série. Verifique se já existe outra série com este título e editora.');
    } finally {
      this.salvandoSerie.set(null);
    }
  }

  private async obterOuCriarEditoraId(nomeEditora: string) {
    const nome = nomeEditora.trim();
    const editoras = await firstValueFrom(this.api.listarEditoras());
    const existente = editoras.find((editora) => this.normalizarComparacao(editora.nome) === this.normalizarComparacao(nome));
    if (existente) {
      this.editoras.set(editoras);
      return existente.id;
    }

    const novaEditora = await firstValueFrom(this.api.cadastrarEditora({
      nome,
      descricao: null,
      paisOrigem: null,
      fonteExterna: null,
      idExterno: null,
      urlOrigem: null,
    }));

    this.editoras.set([...editoras, novaEditora]);
    return novaEditora.id;
  }

  alterarInicialSeries(inicial: string) {
    this.inicialSeries.set(inicial);
    this.buscaSeries = '';
    this.serieSelecionada.set(null);
    this.carregarSeriesInternas(0);
  }

  paginaAnteriorSeries() {
    if (this.series().pagina > 0) {
      this.carregarSeriesInternas(this.series().pagina - 1);
    }
  }

  proximaPaginaSeries() {
    if (this.series().pagina + 1 < this.series().totalPaginas) {
      this.carregarSeriesInternas(this.series().pagina + 1);
    }
  }

  paginaAnterior() {
    if (this.paginaResultados() > 0) {
      this.buscarResultados(this.paginaResultados() - 1, true);
    }
  }

  proximaPagina() {
    if (this.paginaResultados() + 1 < this.resultadosCatalogo().totalPaginas) {
      this.buscarResultados(this.paginaResultados() + 1, true);
    }
  }

  rotuloFonte(resultado: ResultadoPesquisaCatalogo) {
    return resultado.fonte === 'HQ_HUB' ? 'Catálogo HQ-HUB' : 'Comic Vine';
  }

  tituloResultadoCartao(resultado: ResultadoPesquisaCatalogo) {
    return resultado.titulo || resultado.nomeVolume || 'Sem título';
  }

  subtituloResultadoCartao(resultado: ResultadoPesquisaCatalogo) {
    const nomeVolume = String(resultado.nomeVolume || '').trim();
    if (!nomeVolume) {
      return '';
    }

    const titulo = this.tituloResultadoCartao(resultado);
    return this.normalizarComparacao(nomeVolume) === this.normalizarComparacao(titulo)
      ? ''
      : nomeVolume;
  }

  chaveResultado(resultado: ResultadoPesquisaCatalogo) {
    return `${resultado.fonte}-${resultado.id || resultado.idExterno || resultado.numero}`;
  }

  abrirInterna(resultado: ResultadoPesquisaCatalogo) {
    if (!resultado.id) {
      return;
    }

    this.historicoDetalhes.set([]);
    this.abrirDetalhePorId(resultado.id);
  }

  abrirModalAdicionarNaEstante(resultado: ResultadoPesquisaCatalogo) {
    if (!resultado.id || resultado.fonte !== 'HQ_HUB') {
      this.mensagem.set('Selecione uma edição interna para adicionar à estante.');
      return;
    }

    this.resultadoParaEstante.set(resultado);
    this.formularioItemColecao = this.formularioItemColecaoVazio();
    this.mensagem.set('');
  }

  fecharModalAdicionarNaEstante() {
    if (this.salvandoItemColecao()) {
      return;
    }

    this.resultadoParaEstante.set(null);
    this.formularioItemColecao = this.formularioItemColecaoVazio();
  }

  tituloResultadoEstante() {
    const resultado = this.resultadoParaEstante();
    if (!resultado) {
      return 'Edição';
    }

    return resultado.titulo || resultado.nomeVolume || `Edição #${resultado.numero || '-'}`;
  }

  confirmarAdicionarNaEstante() {
    const resultado = this.resultadoParaEstante();
    if (!resultado?.id) {
      this.mensagem.set('Selecione uma edição interna para adicionar à estante.');
      return;
    }

    this.salvandoItemColecao.set(resultado.id);
    this.mensagem.set('');
    this.api.cadastrarItemColecao({
      edicaoId: resultado.id,
      estadoConservacao: this.formularioItemColecao.estadoConservacao,
      dataAquisicao: this.formularioItemColecao.dataAquisicao || null,
      precoPago: this.formularioItemColecao.precoPago,
      statusLeitura: this.formularioItemColecao.statusLeitura,
      observacoes: this.formularioItemColecao.observacoes.trim() || null,
    }).subscribe({
      next: () => {
        this.salvandoItemColecao.set(null);
        this.resultadoParaEstante.set(null);
        this.formularioItemColecao = this.formularioItemColecaoVazio();
        this.mensagem.set('Edição adicionada à sua estante.');
      },
      error: (erro) => {
        this.salvandoItemColecao.set(null);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível adicionar a edição. Verifique se ela já está na sua estante.'));
      },
    });
  }

  abrirDetalhePorId(edicaoId: number, historiaId: number | null = null) {
    this.carregandoDetalhe.set(true);
    this.mensagem.set('');
    this.rolarPainelDetalheMobile();
    forkJoin({
      edicao: this.api.buscarEdicaoPorId(edicaoId),
      conteudos: this.api.listarConteudosPorEdicao(edicaoId),
      publicacoes: this.api.listarPublicacoesPorEdicaoPublicada(edicaoId),
      publicacoesOriginais: this.api.listarPublicacoesPorEdicaoOriginal(edicaoId),
      links: this.api.listarLinksPorEdicao(edicaoId),
      capas: this.api.listarCapasEdicao(edicaoId),
    }).subscribe({
      next: ({ edicao, conteudos, publicacoes, publicacoesOriginais, links, capas }) => {
        const atual = this.edicaoDetalhe();
        if (atual && atual.id !== edicao.id) {
          this.historicoDetalhes.update((historico) => [...historico, atual]);
        }
        this.editandoDetalhe.set(false);
        this.edicaoDetalhe.set(edicao);
        this.formularioEdicao = this.formularioAPartirDaEdicao(edicao);
        this.formularioEdicao.urlCompraAmazon = this.primeiroLinkAmazon(links);
        this.conteudosDetalhe.set(conteudos);
        this.publicacoesDetalhe.set(publicacoes);
        this.urlsCapasPublicacoes.set(this.montarUrlsCapasPublicacoes(publicacoes));
        this.publicacoesComoOriginal.set(this.filtrarPublicacoesComoOriginal(publicacoesOriginais, historiaId));
        this.linksDetalhe.set(links);
        this.capasDetalhe.set(capas);
        this.historiaEmFoco.set(historiaId);
        this.carregarCapasOriginaisComicVine(publicacoes);
        this.carregarComplementoComicVine(edicao);
        this.carregandoDetalhe.set(false);
        this.rolarPainelDetalheMobile();
      },
      error: () => {
        this.carregandoDetalhe.set(false);
        this.mensagem.set('Não foi possível carregar os detalhes desta edição.');
      },
    });
  }

  exibirPainelDetalhe() {
    return !!this.edicaoDetalhe() || (this.carregandoDetalhe() && this.ehViewportMobile());
  }

  fecharDetalhe() {
    this.edicaoDetalhe.set(null);
    this.editandoDetalhe.set(false);
    this.salvandoDetalhe.set(false);
    this.removendoEdicao.set(false);
    this.removendoPublicacao.set(null);
    this.salvandoCapaPublicacao.set(null);
    this.formularioEdicao = this.formularioEdicaoVazio();
    this.conteudosDetalhe.set([]);
    this.publicacoesDetalhe.set([]);
    this.publicacoesComoOriginal.set([]);
    this.urlsCapasPublicacoes.set({});
    this.linksDetalhe.set([]);
    this.capasDetalhe.set([]);
    this.limparFormularioCapa();
    this.limparFormularioVinculoOriginal();
    this.historiaEmFoco.set(null);
    this.detalheComicVineInterno.set(null);
    this.capasComicVineOriginais.set({});
    this.historicoDetalhes.set([]);
  }

  voltarDetalheAnterior() {
    const historico = this.historicoDetalhes();
    const anterior = historico[historico.length - 1];
    if (!anterior) {
      return;
    }

    this.historicoDetalhes.set(historico.slice(0, -1));
    this.edicaoDetalhe.set(null);
    this.detalheComicVineInterno.set(null);
    this.capasComicVineOriginais.set({});
    this.linksDetalhe.set([]);
    this.urlsCapasPublicacoes.set({});
    this.capasDetalhe.set([]);
    this.limparFormularioCapa();
    this.limparFormularioVinculoOriginal();
    this.abrirDetalhePorId(anterior.id);
  }

  linksAmazonDetalhe() {
    return this.linksDetalhe().filter((link) => link.tipo === 'AMAZON');
  }

  urlBuscaMercadoLivre() {
    const titulo = this.edicaoDetalhe()?.serie?.titulo;
    if (!titulo) return '#';
    return `https://lista.mercadolivre.com.br/${encodeURIComponent(titulo)}`;
  }

  urlCapaPublicacao(publicacao: PublicacaoHistoria) {
    return this.urlsCapasPublicacoes()[publicacao.id] || '';
  }

  alterarUrlCapaPublicacao(publicacao: PublicacaoHistoria, url: string) {
    this.urlsCapasPublicacoes.update((urls) => ({
      ...urls,
      [publicacao.id]: url,
    }));
  }

  salvarCapaPublicacao(publicacao: PublicacaoHistoria) {
    if (!this.podeEditarCatalogo()) {
      return;
    }

    const urlCapa = this.urlCapaPublicacao(publicacao).trim();
    const edicaoOriginal = publicacao.edicaoOriginal;
    const serieId = edicaoOriginal.serie?.id;
    if (!urlCapa) {
      this.mensagem.set('Informe a URL da capa original antes de salvar.');
      return;
    }
    if (!serieId) {
      this.mensagem.set('Nao foi possivel identificar a serie da edicao original.');
      return;
    }

    this.salvandoCapaPublicacao.set(publicacao.id);
    this.mensagem.set('');
    this.api.atualizarEdicao(edicaoOriginal.id, {
      numero: edicaoOriginal.numero,
      titulo: edicaoOriginal.titulo,
      descricao: edicaoOriginal.descricao,
      dataPublicacao: edicaoOriginal.dataPublicacao,
      urlCapa,
      codigoBarras: edicaoOriginal.codigoBarras,
      quantidadePaginas: edicaoOriginal.quantidadePaginas,
      precoCapa: edicaoOriginal.precoCapa,
      formato: edicaoOriginal.formato,
      fonteExterna: edicaoOriginal.fonteExterna,
      idExterno: edicaoOriginal.idExterno,
      urlOrigem: edicaoOriginal.urlOrigem,
      serieId,
    }).subscribe({
      next: (edicaoAtualizada) => {
        this.atualizarEdicaoOriginalNasPublicacoes(edicaoAtualizada);
        this.capasComicVineOriginais.update((capas) => {
          const atualizadas = { ...capas };
          delete atualizadas[edicaoAtualizada.id];
          return atualizadas;
        });
        this.salvandoCapaPublicacao.set(null);
        this.mensagem.set('Capa da edicao original salva.');
      },
      error: () => {
        this.salvandoCapaPublicacao.set(null);
        this.mensagem.set('Nao foi possivel salvar a capa da edicao original.');
      },
    });
  }

  selecionarArquivoCapa(evento: Event) {
    const input = evento.target as HTMLInputElement;
    const arquivo = input.files?.[0] || null;
    this.arquivoCapaSelecionado = null;
    this.previewCapaSelecionada.set(null);

    if (!arquivo) {
      return;
    }

    if (!['image/jpeg', 'image/png', 'image/webp'].includes(arquivo.type)) {
      this.mensagem.set('Use apenas imagens JPG, PNG ou WEBP.');
      input.value = '';
      return;
    }

    if (arquivo.size > 3 * 1024 * 1024) {
      this.mensagem.set('A imagem deve ter no maximo 3 MB.');
      input.value = '';
      return;
    }

    this.arquivoCapaSelecionado = arquivo;
    this.previewCapaSelecionada.set(URL.createObjectURL(arquivo));
  }

  enviarCapaArquivo() {
    const edicao = this.edicaoDetalhe();
    if (!edicao || !this.arquivoCapaSelecionado) {
      return;
    }

    this.enviandoCapa.set(true);
    this.mensagem.set('');
    this.api.enviarCapaEdicaoArquivo(edicao.id, this.arquivoCapaSelecionado).subscribe({
      next: (capa) => {
        this.capasDetalhe.update((capas) => [capa, ...capas]);
        this.limparFormularioCapa();
        this.enviandoCapa.set(false);
        this.mensagem.set('Capa enviada para analise.');
      },
      error: () => {
        this.enviandoCapa.set(false);
        this.mensagem.set('Nao foi possivel enviar a capa.');
      },
    });
  }

  enviarCapaUrl() {
    const edicao = this.edicaoDetalhe();
    const urlImagem = this.urlCapaEnvio.trim();
    if (!edicao || !urlImagem) {
      return;
    }

    this.enviandoCapa.set(true);
    this.mensagem.set('');
    this.api.enviarCapaEdicaoUrl(edicao.id, urlImagem).subscribe({
      next: (capa) => {
        this.capasDetalhe.update((capas) => [capa, ...capas]);
        this.urlCapaEnvio = '';
        this.enviandoCapa.set(false);
        this.mensagem.set('Capa enviada para analise.');
      },
      error: () => {
        this.enviandoCapa.set(false);
        this.mensagem.set('Nao foi possivel baixar e enviar esta capa.');
      },
    });
  }

  aprovarCapa(capa: CapaEdicao) {
    if (!this.podeEditarCatalogo()) {
      return;
    }

    this.revisandoCapa.set(capa.id);
    this.api.aprovarCapaEdicao(capa.id).subscribe({
      next: (atualizada) => {
        this.capasDetalhe.update((capas) => capas.map((item) => {
          if (item.id === atualizada.id) {
            return atualizada;
          }
          return item.status === 'APROVADA' ? { ...item, status: 'REJEITADA' } : item;
        }));
        this.atualizarCapaOficial(atualizada.urlImagem);
        this.revisandoCapa.set(null);
        this.mensagem.set('Capa aprovada e definida como oficial.');
      },
      error: () => {
        this.revisandoCapa.set(null);
        this.mensagem.set('Nao foi possivel aprovar esta capa.');
      },
    });
  }

  rejeitarCapa(capa: CapaEdicao) {
    if (!this.podeEditarCatalogo()) {
      return;
    }

    this.revisandoCapa.set(capa.id);
    this.api.rejeitarCapaEdicao(capa.id).subscribe({
      next: (atualizada) => {
        this.capasDetalhe.update((capas) => capas.map((item) => item.id === atualizada.id ? atualizada : item));
        this.revisandoCapa.set(null);
        this.mensagem.set('Capa rejeitada.');
      },
      error: () => {
        this.revisandoCapa.set(null);
        this.mensagem.set('Nao foi possivel rejeitar esta capa.');
      },
    });
  }

  buscarOriginaisParaVinculo() {
    const termo = this.formularioVinculoOriginal.buscaOriginal.trim();
    if (!termo) {
      this.mensagem.set('Digite um termo para buscar a HQ original.');
      return;
    }

    this.buscandoOriginaisVinculo.set(true);
    this.api.pesquisarCatalogo(termo, 0, 8).subscribe({
      next: (resposta) => {
        this.resultadosOriginaisVinculo.set(resposta.itens.filter((resultado) => resultado.fonte === 'HQ_HUB' && !!resultado.id));
        this.buscandoOriginaisVinculo.set(false);
        if (!this.resultadosOriginaisVinculo().length) {
          this.mensagem.set('Nenhuma edicao interna encontrada para vincular.');
        }
      },
      error: () => {
        this.buscandoOriginaisVinculo.set(false);
        this.mensagem.set('Nao foi possivel buscar HQs originais agora.');
      },
    });
  }

  selecionarOriginalParaVinculo(resultado: ResultadoPesquisaCatalogo) {
    if (!resultado.id) {
      return;
    }

    this.formularioVinculoOriginal.edicaoOriginalId = resultado.id;
    this.formularioVinculoOriginal.buscaOriginal = `${resultado.nomeVolume || resultado.titulo || 'Edicao'} #${resultado.numero || ''}`.trim();
  }

  async salvarVinculoOriginal() {
    const edicao = this.edicaoDetalhe();
    const edicaoOriginalId = this.numeroOuNull(this.formularioVinculoOriginal.edicaoOriginalId);
    const tituloHistoria = this.formularioVinculoOriginal.tituloHistoria.trim();

    if (!edicao) {
      return;
    }

    if (!edicaoOriginalId) {
      this.mensagem.set('Selecione ou informe a edicao original.');
      return;
    }

    if (edicaoOriginalId === edicao.id) {
      this.mensagem.set('A HQ original precisa ser diferente da edicao brasileira.');
      return;
    }

    if (!tituloHistoria) {
      this.mensagem.set('Informe a historia ou conteudo que veio da HQ original.');
      return;
    }

    if (this.vinculoOriginalJaExiste(edicaoOriginalId, tituloHistoria)) {
      this.mensagem.set('Esta historia ja esta vinculada a esta edicao original.');
      return;
    }

    this.salvandoVinculoOriginal.set(true);
    this.mensagem.set('');

    try {
      const historia = await firstValueFrom(this.api.cadastrarHistoria({
        titulo: tituloHistoria,
        tituloOriginal: null,
        descricao: null,
        quantidadePaginas: this.numeroOuNull(this.formularioVinculoOriginal.paginasPublicadas),
        tipo: 'HISTORIA',
        fonteExterna: null,
        idExterno: null,
        urlOrigem: null,
      }));

      const publicacao = await firstValueFrom(this.api.cadastrarPublicacaoHistoria({
        historiaId: historia.id,
        edicaoOriginalId,
        edicaoPublicadaId: edicao.id,
        status: this.formularioVinculoOriginal.status,
        tipoPublicacaoHistoria: 'PUBLICACAO_BRASILEIRA',
        fonteInformacao: 'Cadastro manual no catalogo',
        urlFonteInformacao: null,
        tituloUsado: this.valorTextoOuNull(this.formularioVinculoOriginal.tituloUsado),
        paginasPublicadas: this.numeroOuNull(this.formularioVinculoOriginal.paginasPublicadas),
        paginasCortadas: null,
        fonteExterna: null,
        urlOrigem: null,
        observacoes: this.valorTextoOuNull(this.formularioVinculoOriginal.observacoes),
      }));

      this.publicacoesDetalhe.update((publicacoes) => [...publicacoes, publicacao]);
      this.urlsCapasPublicacoes.update((urls) => ({
        ...urls,
        [publicacao.id]: publicacao.edicaoOriginal.urlCapa || '',
      }));
      if (!publicacao.edicaoOriginal.urlCapa) {
        this.carregarCapaComicVineOriginal(publicacao.edicaoOriginal);
      }
      this.limparFormularioVinculoOriginal();
      this.mensagem.set('HQ original vinculada a esta edicao.');
    } catch {
      this.mensagem.set('Nao foi possivel vincular a HQ original.');
    } finally {
      this.salvandoVinculoOriginal.set(false);
    }
  }

  removerPublicacaoDetalhe(publicacao: PublicacaoHistoria) {
    if (!this.podeExcluirCatalogo()) {
      return;
    }

    const titulo = publicacao.historia.tituloExibicao || publicacao.historia.titulo;
    const confirmar = window.confirm(`Excluir o vinculo da historia "${titulo}" desta edicao?`);
    if (!confirmar) {
      return;
    }

    this.removendoPublicacao.set(publicacao.id);
    this.mensagem.set('');
    this.api.removerPublicacaoHistoria(publicacao.id).subscribe({
      next: () => {
        this.publicacoesDetalhe.update((publicacoes) => publicacoes.filter((item) => item.id !== publicacao.id));
        this.publicacoesComoOriginal.update((publicacoes) => publicacoes.filter((item) => item.id !== publicacao.id));
        this.removendoPublicacao.set(null);
        this.mensagem.set('Publicacao removida desta edicao.');
      },
      error: () => {
        this.removendoPublicacao.set(null);
        this.mensagem.set('Nao foi possivel remover esta publicacao.');
      },
    });
  }

  removerEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    if (!edicao || !this.podeExcluirCatalogo()) {
      return;
    }

    const confirmar = window.confirm(`Excluir a edicao "${this.tituloEdicao(edicao)}"? Esta acao nao pode ser desfeita.`);
    if (!confirmar) {
      return;
    }

    this.removendoEdicao.set(true);
    this.mensagem.set('');
    this.api.removerEdicao(edicao.id).subscribe({
      next: () => {
        this.resultadosCatalogo.update((pagina) => ({
          ...pagina,
          itens: pagina.itens.filter((resultado) => resultado.id !== edicao.id),
          totalItens: Math.max(0, pagina.totalItens - 1),
        }));
        this.fecharDetalhe();
        this.mensagem.set('Edicao excluida do catalogo.');
        this.buscarResultados(this.paginaResultados());
        this.carregarSeriesInternas(this.series().pagina);
      },
      error: () => {
        this.removendoEdicao.set(false);
        this.mensagem.set('Nao foi possivel excluir esta edicao. Verifique se ela possui vinculos no catalogo ou na colecao.');
      },
    });
  }

  iniciarEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    if (!edicao || !this.podeEditarCatalogo()) {
      return;
    }

    this.formularioEdicao = this.formularioAPartirDaEdicao(edicao);
    this.formularioEdicao.urlCompraAmazon = this.primeiroLinkAmazon(this.linksDetalhe());
    this.buscaSerieEdicao = this.termoBuscaSerieRelacionada(edicao.serie?.titulo || '');
    this.seriesParaEdicao.set(edicao.serie ? [{
      id: edicao.serie.id,
      titulo: edicao.serie.titulo,
      descricao: null,
      anoInicio: null,
      anoFim: null,
      volume: edicao.serie.volume,
      ordemCronologica: null,
      fonteExterna: null,
      idExterno: null,
      urlOrigem: null,
      editora: edicao.serie.editora,
    }] : []);
    this.editandoDetalhe.set(true);
    this.buscarSeriesParaEdicao();
  }

  cancelarEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    this.formularioEdicao = edicao ? this.formularioAPartirDaEdicao(edicao) : this.formularioEdicaoVazio();
    this.formularioEdicao.urlCompraAmazon = this.primeiroLinkAmazon(this.linksDetalhe());
    this.seriesParaEdicao.set([]);
    this.buscaSerieEdicao = '';
    this.editandoDetalhe.set(false);
  }

  buscarSeriesParaEdicao() {
    const edicao = this.edicaoDetalhe();
    const busca = this.buscaSerieEdicao.trim();
    if (!edicao || !busca || this.carregandoSeriesEdicao()) {
      return;
    }

    this.carregandoSeriesEdicao.set(true);
    this.api.listarSeries(busca, 0, 50).subscribe({
      next: (pagina) => {
        const atual = edicao.serie;
        const candidatas = atual && !pagina.itens.some((serie) => serie.id === atual.id)
          ? [{
              id: atual.id,
              titulo: atual.titulo,
              descricao: null,
              anoInicio: null,
              anoFim: null,
              volume: atual.volume,
              ordemCronologica: null,
              fonteExterna: null,
              idExterno: null,
              urlOrigem: null,
              editora: atual.editora,
            }, ...pagina.itens]
          : pagina.itens;
        this.seriesParaEdicao.set(candidatas);
        this.carregandoSeriesEdicao.set(false);
      },
      error: () => {
        this.carregandoSeriesEdicao.set(false);
        this.mensagem.set('Nao foi possivel buscar as series.');
      },
    });
  }

  salvarEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    const numero = this.formularioEdicao.numero.trim();
    const serieId = Number(this.formularioEdicao.serieId);
    if (!edicao || !serieId) {
      this.mensagem.set('Selecione a serie desta edicao.');
      return;
    }

    if (!numero) {
      this.mensagem.set('Informe o número da edição antes de salvar.');
      return;
    }

    this.salvandoDetalhe.set(true);
    this.mensagem.set('');
    const urlAmazon = this.valorTextoOuNull(this.formularioEdicao.urlCompraAmazon);
    this.api.atualizarEdicao(edicao.id, {
      numero,
      titulo: this.valorTextoOuNull(this.formularioEdicao.titulo),
      descricao: this.valorTextoOuNull(this.formularioEdicao.descricao),
      dataPublicacao: this.valorTextoOuNull(this.formularioEdicao.dataPublicacao),
      urlCapa: this.valorTextoOuNull(this.formularioEdicao.urlCapa),
      codigoBarras: this.valorTextoOuNull(this.formularioEdicao.codigoBarras),
      quantidadePaginas: this.numeroOuNull(this.formularioEdicao.quantidadePaginas),
      precoCapa: this.numeroOuNull(this.formularioEdicao.precoCapa),
      formato: this.valorTextoOuNull(this.formularioEdicao.formato),
      fonteExterna: edicao.fonteExterna,
      idExterno: edicao.idExterno,
      urlOrigem: this.valorTextoOuNull(this.formularioEdicao.urlOrigem),
      serieId,
    }).subscribe({
      next: (atualizada) => {
        const linksAtuais = this.linksDetalhe();
        const jaExisteAmazon = !!urlAmazon
          && linksAtuais.some((link) => link.tipo === 'AMAZON' && link.url === urlAmazon);

        if (urlAmazon && !jaExisteAmazon) {
          this.api.cadastrarLinkEdicao({
            edicaoId: atualizada.id,
            tipo: 'AMAZON',
            titulo: 'Comprar na Amazon',
            url: urlAmazon,
            observacoes: 'Link salvo no modal de detalhes do catálogo.',
          }).subscribe({
            next: (novoLink) => {
              this.finalizarSalvamentoDetalhe(atualizada, [...linksAtuais, novoLink], 'Dados da edicao atualizados.');
            },
            error: () => {
              this.finalizarSalvamentoDetalhe(
                atualizada,
                linksAtuais,
                'Dados da edicao atualizados, mas nao foi possivel salvar o link da Amazon.',
              );
            },
          });
          return;
        }

        this.finalizarSalvamentoDetalhe(atualizada, linksAtuais, 'Dados da edicao atualizados.');
      },
      error: () => {
        this.salvandoDetalhe.set(false);
        this.mensagem.set('Nao foi possivel salvar os dados desta edicao.');
      },
    });
  }

  tituloEdicao(edicao: Edicao) {
    return `${edicao.serie?.titulo || 'Edição'} #${edicao.numero}`;
  }

  capaEdicaoDetalhe() {
    return this.edicaoDetalhe()?.urlCapa || this.detalheComicVineInterno()?.urlImagem || null;
  }

  capaPublicacaoOriginal(publicacao: PublicacaoHistoria) {
    return publicacao.edicaoOriginal.urlCapa
      || this.capasComicVineOriginais()[publicacao.edicaoOriginal.id]
      || null;
  }

  descricaoEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    const comicVine = this.detalheComicVineInterno();
    return this.descricaoInternaUtil(edicao?.descricaoExibicao)
      || this.descricaoInternaUtil(edicao?.descricao)
      || comicVine?.descricaoExibicao
      || comicVine?.descricao
      || 'Sem descrição cadastrada.';
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  usarCapaReserva(evento: Event) {
    const imagem = evento.target as HTMLImageElement;
    if (!imagem.src.endsWith(this.capaReserva)) {
      imagem.src = this.capaReserva;
    }
  }

  formatarDescricao(texto: string): SafeHtml {
    const partes: string[] = [];
    const regexLink = /\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g;
    let indiceAnterior = 0;
    let resultado: RegExpExecArray | null;

    while ((resultado = regexLink.exec(texto)) !== null) {
      partes.push(this.escaparHtml(texto.slice(indiceAnterior, resultado.index)));
      partes.push(
        `<a href="${this.escaparAtributo(resultado[2])}" target="_blank" rel="noreferrer">${this.escaparHtml(resultado[1])}</a>`,
      );
      indiceAnterior = regexLink.lastIndex;
    }

    partes.push(this.escaparHtml(texto.slice(indiceAnterior)));
    return this.sanitizador.bypassSecurityTrustHtml(partes.join('').replace(/\r?\n/g, '<br>'));
  }

  rotuloStatus(status: string) {
    const rotulos: Record<string, string> = {
      COMPLETA: 'Publicação completa',
      PARCIAL: 'Publicação parcial',
      CORTADA: 'Publicação cortada',
      ADAPTADA: 'Publicação adaptada',
      DESCONHECIDA: 'Status desconhecido',
    };
    return rotulos[status] || status;
  }

  rotuloStatusCapa(status: string) {
    const rotulos: Record<string, string> = {
      PENDENTE: 'Pendente',
      APROVADA: 'Aprovada',
      REJEITADA: 'Rejeitada',
    };
    return rotulos[status] || status;
  }

  rotuloOrigemCapa(origem: string) {
    const rotulos: Record<string, string> = {
      COMIC_VINE: 'Comic Vine',
      UPLOAD_MANUAL: 'Upload manual',
      URL_MANUAL: 'URL manual',
      IMPORTACAO_JSON: 'Importacao JSON',
    };
    return rotulos[origem] || origem;
  }

  tituloEdicaoOriginal(publicacao: PublicacaoHistoria) {
    return `${publicacao.edicaoOriginal.serie?.titulo || 'Edição original'} #${publicacao.edicaoOriginal.numero}`;
  }

  tituloEdicaoPublicada(publicacao: PublicacaoHistoria) {
    return `${publicacao.edicaoPublicada.serie?.titulo || 'Edição brasileira'} #${publicacao.edicaoPublicada.numero}`;
  }

  linkEdicaoOriginal(publicacao: PublicacaoHistoria) {
    return publicacao.edicaoOriginal.urlComicVine || publicacao.edicaoOriginal.urlOrigem;
  }

  abrirDetalheOriginal(publicacao: PublicacaoHistoria) {
    this.abrirDetalhePorId(publicacao.edicaoOriginal.id, publicacao.historia.id);
  }

  rotuloFonteEdicao(edicao: Edicao) {
    if (edicao.urlComicVine) {
      return 'Comic Vine';
    }

    if (edicao.urlOrigem?.includes('guiadosquadrinhos.com')) {
      return 'Guia dos Quadrinhos';
    }

    return 'Fonte';
  }

  private carregarComplementoComicVine(edicao: Edicao) {
    this.detalheComicVineInterno.set(null);

    if (edicao.idComicVine) {
      this.carregarDetalheComicVine(edicao, edicao.idComicVine);
      return;
    }

    if (edicao.urlCapa) {
      return;
    }

    if (!edicao.serie?.titulo || !edicao.numero) {
      return;
    }

    this.api.resolverEdicaoComicVine(edicao.serie.titulo, edicao.numero).subscribe({
      next: (detalhe) => {
        if (this.edicaoDetalhe()?.id === edicao.id) {
          this.detalheComicVineInterno.set(detalhe);
        }
      },
      error: () => undefined,
    });
  }

  private carregarCapasOriginaisComicVine(publicacoes: PublicacaoHistoria[]) {
    this.capasComicVineOriginais.set({});

    const edicoesOriginais = new Map<number, Edicao>();
    publicacoes.forEach((publicacao) => {
      if (!publicacao.edicaoOriginal.urlCapa) {
        edicoesOriginais.set(publicacao.edicaoOriginal.id, publicacao.edicaoOriginal);
      }
    });

    edicoesOriginais.forEach((edicao) => this.carregarCapaComicVineOriginal(edicao));
  }

  private carregarCapaComicVineOriginal(edicao: Edicao) {
    if (edicao.idComicVine) {
      this.carregarDetalheComicVineParaCapaOriginal(edicao.id, edicao.idComicVine);
      return;
    }

    if (!edicao.serie?.titulo || !edicao.numero) {
      return;
    }

    this.api.resolverEdicaoComicVine(edicao.serie.titulo, edicao.numero).subscribe({
      next: (detalhe) => {
        if (detalhe.urlImagem) {
          this.capasComicVineOriginais.update((capas) => ({ ...capas, [edicao.id]: detalhe.urlImagem! }));
        }
      },
      error: () => undefined,
    });
  }

  private carregarDetalheComicVineParaCapaOriginal(edicaoId: number, idComicVine: string) {
    this.api.buscarDetalheEdicaoComicVine(idComicVine).subscribe({
      next: (detalhe) => {
        if (detalhe.urlImagem) {
          this.capasComicVineOriginais.update((capas) => ({ ...capas, [edicaoId]: detalhe.urlImagem! }));
        }
      },
      error: () => undefined,
    });
  }

  private carregarDetalheComicVine(edicao: Edicao, idComicVine: string) {
    this.api.buscarDetalheEdicaoComicVine(idComicVine).subscribe({
      next: (detalhe) => {
        if (this.edicaoDetalhe()?.id === edicao.id) {
          this.detalheComicVineInterno.set(detalhe);
        }
      },
      error: () => undefined,
    });
  }

  private resultadoComicVineCombina(edicao: Edicao, resultado: EdicaoComicVine) {
    if (!this.mesmoNumeroEdicao(edicao.numero, resultado.numero)) {
      return false;
    }

    const tokensSerie = this.tokensBusca(edicao.serie?.titulo || '');
    const textoResultado = this.normalizarBusca(`${resultado.nomeVolume || ''} ${resultado.titulo || ''}`);
    return tokensSerie.length === 0 || tokensSerie.every((token) => textoResultado.includes(token));
  }

  private termoBuscaComicVine(edicao: Edicao) {
    const serie = this.tituloSerieParaBusca(edicao.serie?.titulo || '');
    return [serie, edicao.numero].filter(Boolean).join(' ').trim();
  }

  private tituloSerieParaBusca(titulo: string) {
    return titulo
      .replace(/\(\d{4}\)/g, ' ')
      .replace(/,\s*the\b/gi, ' ')
      .replace(/\bthe\b/gi, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private tokensBusca(texto: string) {
    return this.normalizarBusca(this.tituloSerieParaBusca(texto))
      .split(' ')
      .filter((token) => token.length > 2);
  }

  private mesmoNumeroEdicao(primeiro: string | null | undefined, segundo: string | null | undefined) {
    return this.normalizarNumeroEdicao(primeiro) === this.normalizarNumeroEdicao(segundo);
  }

  private normalizarNumeroEdicao(numero: string | null | undefined) {
    return (numero || '').toLowerCase().replace(/^#/, '').trim();
  }

  private normalizarBusca(texto: string) {
    return texto
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private descricaoInternaUtil(texto: string | null | undefined) {
    if (!texto || !texto.trim()) {
      return null;
    }

    return this.normalizarBusca(texto).startsWith('descricao nao disponivel') ? null : texto;
  }

  private carregarSeriesInternas(pagina = this.series().pagina) {
    this.api.listarSeries(this.buscaSeries, pagina, this.tamanhoSeries, this.inicialSeries()).subscribe({
      next: (resposta) => {
        this.series.set(resposta);
        this.seriesConsultadas.set(true);
      },
      error: () => {
        this.seriesConsultadas.set(true);
        this.mensagem.set('Não foi possível carregar as séries internas agora.');
      },
    });
  }

  private limparPesquisaSeries() {
    this.busca = '';
    this.buscaSeries = '';
    this.inicialSeries.set('');
    this.seriesConsultadas.set(false);
    this.series.set({ itens: [], pagina: 0, tamanho: this.tamanhoSeries, totalItens: 0, totalPaginas: 0 });
  }

  private carregarEditoras() {
    if (this.editoras().length) {
      return;
    }

    this.api.listarEditoras().subscribe({
      next: (editoras) => this.editoras.set(editoras),
      error: () => undefined,
    });
  }

  private classificarMensagem(texto: string): 'sucesso' | 'erro' | 'info' {
    const normalizado = texto
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase();

    if (normalizado.includes('nao foi possivel') || normalizado.includes('erro')) {
      return 'erro';
    }

    if (normalizado.startsWith('pesquisando') || normalizado.startsWith('carregando') || normalizado.startsWith('digite') || normalizado.startsWith('nenhum')) {
      return 'info';
    }

    return 'sucesso';
  }

  private buscarResultados(pagina: number, rolarAoResultadoMobile = false) {
    const termoBusca = this.busca.trim();
    if (!termoBusca && !this.serieSelecionada()) {
      this.resultadosCatalogo.set({ itens: [], pagina: 0, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
      this.mensagem.set('Digite um termo para pesquisar no catálogo.');
      return;
    }

    this.carregandoResultados.set(true);
    this.mensagem.set('Pesquisando catálogo...');

    const termo = this.serieSelecionada()?.titulo || termoBusca;
    if (this.serieSelecionada()) {
      this.api.listarEdicoes('', pagina, this.tamanhoResultados, this.serieSelecionada()!.id).subscribe({
        next: (resposta) => {
          this.resultadosCatalogo.set({
            ...resposta,
            itens: resposta.itens.map((edicao) => this.paraResultadoInterno(edicao)),
          });
          this.paginaResultados.set(resposta.pagina);
          this.carregandoResultados.set(false);
          if (rolarAoResultadoMobile) {
            this.rolarParaResultadosMobile();
          }
          this.mensagem.set(resposta.itens.length ? '' : `Nenhuma edição cadastrada para "${termo}".`);
        },
        error: () => {
          this.resultadosCatalogo.set({ itens: [], pagina, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
          this.carregandoResultados.set(false);
          this.mensagem.set('Não foi possível carregar as edições desta série agora.');
        },
      });
      return;
    }

    this.api.pesquisarCatalogo(termo, pagina, this.tamanhoResultados).subscribe({
      next: (resposta) => {
        this.resultadosCatalogo.set(resposta);
        this.paginaResultados.set(resposta.pagina);
        this.carregandoResultados.set(false);
        if (rolarAoResultadoMobile) {
          this.rolarParaResultadosMobile();
        }
        this.mensagem.set(resposta.itens.length ? '' : `Nenhum resultado encontrado para "${termo}".`);
      },
      error: () => {
        this.resultadosCatalogo.set({ itens: [], pagina, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
        this.carregandoResultados.set(false);
        this.mensagem.set('Não foi possível pesquisar no catálogo agora.');
      },
    });
  }

  private rolarParaResultadosMobile() {
    if (!this.ehViewportMobile()) {
      return;
    }

    setTimeout(() => {
      this.resultadosCatalogoBloco?.nativeElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 50);
  }

  private rolarPainelDetalheMobile() {
    if (!this.ehViewportMobile()) {
      return;
    }

    setTimeout(() => {
      this.detalhePainel?.nativeElement.scrollTo({ top: 0, behavior: 'smooth' });
    }, 50);
  }

  private ehViewportMobile() {
    return window.matchMedia('(max-width: 980px)').matches;
  }

  private escaparHtml(valor: string) {
    return valor
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  private escaparAtributo(valor: string) {
    return encodeURI(valor).replace(/"/g, '&quot;');
  }

  private formularioEdicaoVazio() {
    return {
      serieId: null as number | null,
      numero: '',
      titulo: '',
      descricao: '',
      dataPublicacao: '',
      urlCapa: '',
      urlCompraAmazon: '',
      codigoBarras: '',
      quantidadePaginas: null as number | null,
      precoCapa: null as number | null,
      formato: '',
      urlOrigem: '',
    };
  }

  private formularioItemColecaoVazio() {
    return {
      estadoConservacao: 'MUITO_BOM',
      dataAquisicao: '',
      precoPago: null as number | null,
      statusLeitura: 'NAO_LIDO',
      observacoes: '',
    };
  }

  private formularioVinculoOriginalVazio(): {
    buscaOriginal: string;
    edicaoOriginalId: number | string | null;
    tituloHistoria: string;
    tituloUsado: string;
    paginasPublicadas: number | string | null;
    status: 'COMPLETA' | 'PARCIAL' | 'CORTADA' | 'ADAPTADA' | 'DESCONHECIDA';
    observacoes: string;
  } {
    return {
      buscaOriginal: '',
      edicaoOriginalId: null,
      tituloHistoria: '',
      tituloUsado: '',
      paginasPublicadas: null,
      status: 'COMPLETA',
      observacoes: '',
    };
  }

  private formularioAPartirDaEdicao(edicao: Edicao) {
    return {
      serieId: edicao.serie?.id || null,
      numero: edicao.numero || '',
      titulo: edicao.titulo || '',
      descricao: edicao.descricao || edicao.descricaoExibicao || '',
      dataPublicacao: edicao.dataPublicacao || '',
      urlCapa: edicao.urlCapa || '',
      urlCompraAmazon: '',
      codigoBarras: edicao.codigoBarras || '',
      quantidadePaginas: edicao.quantidadePaginas,
      precoCapa: edicao.precoCapa,
      formato: edicao.formato || '',
      urlOrigem: edicao.urlOrigem || edicao.urlComicVine || '',
    };
  }

  private termoBuscaSerieRelacionada(titulo: string) {
    return titulo
      .replace(/\b\d+\s*[ªºa]?\s*(?:temporada|serie|série)\b/giu, '')
      .replace(/^(?:a|as|o|os)\s+/iu, '')
      .replace(/,\s*(?:a|as|o|os)$/iu, '')
      .replace(/\s{2,}/g, ' ')
      .replace(/[,\s]+$/g, '')
      .trim() || titulo;
  }

  private primeiroLinkAmazon(links: LinkEdicao[]) {
    return links.find((link) => link.tipo === 'AMAZON')?.url || '';
  }

  private finalizarSalvamentoDetalhe(edicao: Edicao, links: LinkEdicao[], mensagem: string) {
    this.edicaoDetalhe.set(edicao);
    this.linksDetalhe.set(links);
    this.formularioEdicao = this.formularioAPartirDaEdicao(edicao);
    this.formularioEdicao.urlCompraAmazon = this.primeiroLinkAmazon(links);
    this.resultadosCatalogo.update((pagina) => ({
      ...pagina,
      itens: pagina.itens.map((resultado) => resultado.id === edicao.id ? this.paraResultadoInterno(edicao) : resultado),
    }));
    this.editandoDetalhe.set(false);
    this.salvandoDetalhe.set(false);
    this.mensagem.set(mensagem);
  }

  private atualizarCapaOficial(urlImagem: string) {
    const edicao = this.edicaoDetalhe();
    if (!edicao) {
      return;
    }

    const atualizada = { ...edicao, urlCapa: urlImagem };
    this.edicaoDetalhe.set(atualizada);
    this.formularioEdicao = this.formularioAPartirDaEdicao(atualizada);
    this.resultadosCatalogo.update((pagina) => ({
      ...pagina,
      itens: pagina.itens.map((resultado) => resultado.id === atualizada.id ? this.paraResultadoInterno(atualizada) : resultado),
    }));
  }

  private limparFormularioCapa() {
    this.arquivoCapaSelecionado = null;
    this.previewCapaSelecionada.set(null);
    this.urlCapaEnvio = '';
    this.enviandoCapa.set(false);
    this.revisandoCapa.set(null);
  }

  private limparFormularioVinculoOriginal() {
    this.formularioVinculoOriginal = this.formularioVinculoOriginalVazio();
    this.resultadosOriginaisVinculo.set([]);
    this.buscandoOriginaisVinculo.set(false);
    this.salvandoVinculoOriginal.set(false);
  }

  private montarUrlsCapasPublicacoes(publicacoes: PublicacaoHistoria[]) {
    return publicacoes.reduce<Record<number, string>>((urls, publicacao) => {
      urls[publicacao.id] = publicacao.edicaoOriginal.urlCapa || '';
      return urls;
    }, {});
  }

  private atualizarEdicaoOriginalNasPublicacoes(edicao: Edicao) {
    const atualizar = (publicacao: PublicacaoHistoria) => (
      publicacao.edicaoOriginal.id === edicao.id
        ? { ...publicacao, edicaoOriginal: edicao }
        : publicacao
    );

    this.publicacoesDetalhe.update((publicacoes) => publicacoes.map(atualizar));
    this.publicacoesComoOriginal.update((publicacoes) => publicacoes.map(atualizar));
    this.urlsCapasPublicacoes.update((urls) => {
      const atualizadas = { ...urls };
      for (const publicacao of this.publicacoesDetalhe()) {
        if (publicacao.edicaoOriginal.id === edicao.id) {
          atualizadas[publicacao.id] = edicao.urlCapa || '';
        }
      }
      return atualizadas;
    });
  }

  private valorTextoOuNull(valor: string | null) {
    const texto = valor?.trim();
    return texto ? texto : null;
  }

  private numeroOuNull(valor: number | string | null) {
    if (valor === null || valor === '') {
      return null;
    }

    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : null;
  }

  private extrairMensagemErro(erro: unknown, mensagemPadrao: string) {
    const resposta = erro as { error?: { mensagem?: string } };
    return resposta.error?.mensagem ?? mensagemPadrao;
  }

  private filtrarPublicacoesComoOriginal(publicacoes: PublicacaoHistoria[], historiaId: number | null) {
    const publicacoesBrasileiras = publicacoes.filter((publicacao) =>
      !this.mesmaEdicaoCatalografica(publicacao.edicaoOriginal, publicacao.edicaoPublicada)
    );

    if (!historiaId) {
      return publicacoesBrasileiras;
    }

    return publicacoesBrasileiras.filter((publicacao) => publicacao.historia.id === historiaId);
  }

  private mesmaEdicaoCatalografica(original: Edicao, publicada: Edicao) {
    if (original.id === publicada.id) {
      return true;
    }

    return this.normalizarComparacao(original.numero) === this.normalizarComparacao(publicada.numero)
      && this.normalizarComparacao(original.serie?.titulo) === this.normalizarComparacao(publicada.serie?.titulo);
  }

  private normalizarComparacao(valor: string | null | undefined) {
    return (valor || '').trim().toLocaleLowerCase('pt-BR');
  }

  private vinculoOriginalJaExiste(edicaoOriginalId: number, tituloHistoria: string) {
    const titulo = this.normalizarBusca(tituloHistoria);
    return this.publicacoesDetalhe().some((publicacao) =>
      publicacao.edicaoOriginal.id === edicaoOriginalId
      && this.normalizarBusca(publicacao.historia.tituloExibicao || publicacao.historia.titulo) === titulo
    );
  }

  private paraResultadoInterno(edicao: Edicao): ResultadoPesquisaCatalogo {
    return {
      id: edicao.id,
      idExterno: edicao.idComicVine || edicao.idExterno,
      fonte: 'HQ_HUB',
      titulo: edicao.titulo || edicao.serie?.titulo || null,
      numero: edicao.numero,
      nomeVolume: edicao.nomeVolume || edicao.serie?.titulo || null,
      serieVolume: edicao.serie?.volume ?? null,
      urlCapa: edicao.urlCapa,
      dataPublicacao: edicao.dataPublicacao,
      jaCadastrada: true,
      urlOrigem: edicao.urlComicVine || edicao.urlOrigem,
    };
  }
}
