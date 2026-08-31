import { CommonModule } from '@angular/common';
import { Component, ElementRef, HostListener, OnDestroy, OnInit, ViewChild, computed, effect, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { ActivatedRoute } from '@angular/router';
import { LucideArrowLeft, LucideBookOpen, LucideSearch, LucideShare2 } from '@lucide/angular';
import { firstValueFrom, forkJoin } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { CompartilhamentoService } from '../../core/compartilhamento.service';
import { environment } from '../../../environments/environment';
import {
  ConteudoEdicao,
  CapaEdicao,
  Edicao,
  EdicaoComicVine,
  EditoraResumo,
  LinkEdicao,
  PaginaResposta,
  PublicacaoHistoria,
  PublicacaoBrasileiraResumo,
  PublicacoesBrasileirasEdicaoOriginal,
  ResultadoBackfillComicVine,
  ResultadoPesquisaCatalogo,
  Serie,
  TipoConteudoEdicao,
} from '../../core/modelos';

@Component({
  selector: 'app-catalogo-page',
  imports: [CommonModule, FormsModule, RouterLink, LucideArrowLeft, LucideBookOpen, LucideSearch, LucideShare2],
  template: `
    <section class="cabecalho-pagina catalogo-cabecalho">
      <div>
        <p class="rotulo">Catálogo</p>
        <h1>Encontre quadrinhos no acervo do HQ-HUB e na Comic Vine.</h1>
      </div>
      <a class="botao secundario compacto" routerLink="/titulos-estrangeiros">Títulos estrangeiros</a>
    </section>

    @if (mensagem()) {
      <aside class="toast-sistema" [class.sucesso]="tipoMensagem() === 'sucesso'" [class.erro]="tipoMensagem() === 'erro'" [class.info]="tipoMensagem() === 'info'" role="status" aria-live="polite">
        <p>{{ mensagem() }}</p>
        <button type="button" class="fechar-toast" (click)="fecharMensagem()" aria-label="Fechar mensagem">×</button>
      </aside>
    }

    <section class="catalogo-layout" [class.modo-edicoes-mobile]="!!serieSelecionada()">
      <article class="bloco catalogo-bloco-series">
        <div class="secao-titulo">
          <div>
            <h2>Séries internas</h2>
            <p class="texto-suave">Pesquise primeiro no acervo do HQ-HUB. Se não encontrarmos, a busca poderá continuar na Comic Vine.</p>
          </div>
          @if (seriesConsultadas()) {
            <span>{{ series().totalItens === 1 ? '1 série' : series().totalItens + ' séries' }}</span>
          }
        </div>

        <div class="controles-series">
          <label class="campo-busca-catalogo">
            <span class="sr-only">Pesquisar quadrinhos</span>
            <svg lucideSearch size="19" aria-hidden="true"></svg>
            <input
              [(ngModel)]="buscaSeries"
              placeholder="Pesquise Batman, X-Men, Spawn..."
              (keyup.enter)="buscarCatalogoCompleto()"
            />
          </label>
          <button class="botao primario compacto botao-busca-catalogo" type="button" (click)="buscarCatalogoCompleto()" aria-label="Buscar no catálogo">
            <svg lucideSearch size="18" aria-hidden="true"></svg>
            Buscar
          </button>
          <div class="filtro-alfabetico-catalogo">
            <span class="rotulo-indice">Filtrar por letra</span>
            <div class="indice-alfabetico" aria-label="Filtro alfabético de séries">
              <button type="button" [class.ativo]="inicialSeries() === '' && seriesConsultadas()" (click)="alterarInicialSeries('')" aria-label="Mostrar todas as letras">Todas</button>
              @for (letra of letrasIndice; track letra) {
                <button type="button" [class.ativo]="inicialSeries() === letra" (click)="alterarInicialSeries(letra)" [attr.aria-label]="'Filtrar séries pela letra ' + letra">
                  {{ letra }}
                </button>
              }
            </div>
          </div>
        </div>

        @if (seriesConsultadas()) {
        <div class="lista-linhas">
          @for (serie of series().itens; track serie.id) {
            <div class="linha-serie">
              <button type="button" [attr.data-serie-id]="serie.id" [class.ativo]="serieSelecionada()?.id === serie.id" (click)="selecionarSerie(serie)">
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

        @if (serieSelecionada() && podeExcluirCatalogo()) {
          <aside class="acao-capas-serie" aria-live="polite">
            <div>
              <strong>Capas ausentes de {{ serieSelecionada()!.titulo }}</strong>
              <span>Procura correspondências únicas por título e número. Capas existentes nunca serão substituídas.</span>
            </div>
            <button class="botao primario compacto" type="button" (click)="preencherCapasSerieSelecionada()" [disabled]="preenchendoCapasSerie()">
              {{ preenchendoCapasSerie() ? 'Buscando capas...' : 'Buscar capas ausentes na Comic Vine' }}
            </button>
            @if (resumoCapasSerie(); as resumoCapas) {
              <div class="resumo-capas-comic-vine">
                <span><strong>{{ resumoCapas.processadas }}</strong> analisadas</span>
                <span class="sucesso"><strong>{{ resumoCapas.atualizadas }}</strong> salvas</span>
                <span><strong>{{ resumoCapas.semCorrespondencia }}</strong> sem correspondência única</span>
                <span [class.erro]="resumoCapas.falhas > 0"><strong>{{ resumoCapas.falhas }}</strong> falhas da API</span>
                @if (resumoCapas.avisos.length) {
                  <details>
                    <summary>Ver detalhes</summary>
                    <ul>
                      @for (aviso of resumoCapas.avisos; track $index) { <li>{{ aviso }}</li> }
                    </ul>
                  </details>
                }
              </div>
            }
          </aside>
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
        @if (serieSelecionada(); as serieAtual) {
          <header class="cabecalho-colecao-selecionada">
            <button class="voltar-colecoes" type="button" (click)="voltarParaColecoes()">
              <svg lucideArrowLeft size="20" aria-hidden="true"></svg>
              <span>Voltar para coleções</span>
            </button>
            <div class="titulo-colecao-selecionada">
              <p class="rotulo">Coleção selecionada</p>
              <h2 #tituloColecao tabindex="-1">{{ serieAtual.titulo }}</h2>
              <p class="metadados-colecao">
                <span>{{ serieAtual.editora?.nome || 'Sem editora' }}</span>
                <span>Volume {{ serieAtual.volume || '-' }}</span>
                <span>{{ resultadosCatalogo().totalItens === 1 ? '1 edição' : resultadosCatalogo().totalItens + ' edições' }}</span>
              </p>
            </div>
          </header>
        }

        <div class="secao-titulo" [class.secao-titulo-colecao]="!!serieSelecionada()">
          @if (!serieSelecionada()) {
            <div>
              <h2>Resultados da busca</h2>
              <p class="texto-suave">Clique em uma edição interna para ver capa, histórias e publicações originais.</p>
            </div>
          }
          <div class="resultado-catalogo-acoes">
            @if (!serieSelecionada()) {
              <span>{{ rotuloContadorResultados() }}</span>
            }
            @if (exibirColecaoPublicaMarvelDeluxe()) {
              <a
                class="botao secundario compacto"
                routerLink="/guia-de-leitura-app/colecao-marvel-deluxe-capa-preta"
              >
                Ver coleção Marvel Deluxe completa
              </a>
            }
            @if (serieSelecionada() && autenticado() && resultadosCatalogo().totalItens > 0) {
              <button
                class="botao primario compacto"
                type="button"
                (click)="abrirModalAdicionarSerieNaEstante()"
                [disabled]="adicionandoSerieInteira()"
              >
                Adicionar série inteira à minha estante
              </button>
            }
          </div>
        </div>

        @if (exibirNotaInicioTexEdicaoHistoricaMythos()) {
          <aside class="aviso-edicoes-anteriores">
            Continuação da numeração das edições da Ed. Globo.
          </aside>
        }

        @if (exibirAvisoEdicoesAnterioresTex()) {
          <aside class="aviso-edicoes-anteriores">
            <a
              routerLink="/catalogo"
              [queryParams]="{ colecaoTex: colecaoAnteriorTex() }"
            >
              {{ textoEdicoesAnterioresTex() }}
            </a>
          </aside>
        }

        @if (exibirNotaTexRgeSegundaEdicao()) {
          <aside class="aviso-edicoes-anteriores">
            Continuação do nº 94 da ed. Vecchi (que republicou a HQ só pela metade). A RGE concluiu a aventura chamando esta edição de "nº 94-A".
          </aside>
        }

        @if (exibirAvisoEdicoesPosterioresTex()) {
          <aside class="aviso-edicoes-anteriores">
            <a
              routerLink="/catalogo"
              [queryParams]="{ colecaoTex: colecaoPosteriorTex() }"
            >
              {{ textoEdicoesPosterioresTex() }}
            </a>
          </aside>
        }

        @if (exibirAvisoTexColecaoGlobo()) {
          <aside class="aviso-edicoes-anteriores">
            <a
              routerLink="/catalogo"
              [queryParams]="{ colecaoTexColecao: 'globo' }"
            >
              A série "Tex Coleção" continuou sendo publicada pela Editora Globo, a partir do nº 2.
            </a>
          </aside>
        }

        @if (exibirNotaInicioTexColecaoGlobo()) {
          <aside class="aviso-edicoes-anteriores">
            O número 1 foi publicado pela RGE.<br />
            Continua em
            <a
              routerLink="/catalogo"
              [queryParams]="{ colecaoTexColecao: 'mythos' }"
            >
              Tex Coleção nº 144/Mythos
            </a>
            .
          </aside>
        }

        <div class="grade-mini-capas">
          @for (resultado of resultadosCatalogo().itens; track chaveResultado(resultado)) {
            <article class="mini-capa resultado-catalogo" [class.externo]="resultado.fonte === 'COMIC_VINE'">
              <img
                [src]="resultado.urlCapa || capaReserva"
                [alt]="tituloResultadoCartao(resultado)"
                loading="lazy"
                (error)="usarCapaReserva($event)"
              />
              @if (resultado.jaCadastrada && resultado.id) {
                <button class="compartilhar-capa-catalogo" type="button" (click)="compartilharResultado(resultado, $event)" [attr.aria-label]="'Compartilhar ' + tituloResultadoCartao(resultado)" title="Compartilhar edição">
                  <svg lucideShare2 size="19" aria-hidden="true"></svg>
                </button>
              }
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
            <section class="estado-vazio estado-vazio-catalogo">
              @if (resultadosConsultados()) {
                <svg lucideSearch size="34" aria-hidden="true"></svg>
                <h2>Nenhuma edição encontrada</h2>
                <p>Tente outro termo, verifique a grafia ou escolha uma letra diferente.</p>
              } @else {
                <svg lucideBookOpen size="34" aria-hidden="true"></svg>
                <h2>Encontre sua próxima leitura</h2>
                <p>Digite o nome de uma série, personagem ou editora, ou escolha uma letra acima.</p>
                <div class="sugestoes-catalogo" aria-label="Sugestões rápidas de pesquisa">
                  @for (sugestao of sugestoesPesquisa; track sugestao) {
                    <button type="button" (click)="buscarSugestao(sugestao)">{{ sugestao }}</button>
                  }
                </div>
              }
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

    @if (serieSelecionada() && mostrarVoltarColecoesFlutuante()) {
      <button class="voltar-colecoes-flutuante" type="button" (click)="voltarParaColecoes()" aria-label="Voltar para a lista de coleções">
        <svg lucideArrowLeft size="18" aria-hidden="true"></svg>
        <span>Voltar às coleções</span>
      </button>
    }

    @if (originalPublicacoesAberta()) {
      <section class="detalhe-edicao modal-publicacoes-brasil" role="dialog" aria-modal="true" aria-labelledby="tituloPublicacoesBrasil" (keydown)="navegarTecladoModalPublicacoes($event)">
        <div class="detalhe-fundo" (click)="fecharPublicacoesBrasil()"></div>
        <article class="detalhe-painel publicacoes-brasil-painel" #modalPublicacoesBrasil tabindex="-1">
          <button class="fechar-detalhe" type="button" (click)="fecharPublicacoesBrasil()" aria-label="Fechar publicações no Brasil">×</button>
          <header class="publicacoes-brasil-cabecalho">
            <p class="rotulo">🇧🇷 Publicações no Brasil</p>
            <h2 id="tituloPublicacoesBrasil">{{ tituloEdicao(originalPublicacoesAberta()!) }}</h2>
            <p>{{ originalPublicacoesAberta()?.serie?.editora?.nome || 'Editora não informada' }}<span *ngIf="anoEdicao(originalPublicacoesAberta()) as ano"> · {{ ano }}</span></p>
          </header>
          @if (carregandoPublicacoesBrasil()) {
            <section class="estado-carregando publicacoes-brasil-estado" aria-live="polite"><span></span><p>Carregando publicações brasileiras...</p></section>
          } @else if (erroPublicacoesBrasil()) {
            <section class="publicacoes-brasil-estado" role="alert"><p>Não foi possível carregar as outras publicações agora.</p><button class="botao secundario compacto" type="button" (click)="tentarNovamentePublicacoesBrasil()">Tentar novamente</button></section>
          } @else if (publicacoesBrasil(); as resultado) {
            <p class="resumo-publicacoes-brasil">Esta edição/história foi publicada no Brasil em {{ resultado.totalPublicacoes }} {{ resultado.totalPublicacoes === 1 ? 'edição' : 'edições' }}.</p>
            <div class="lista-publicacoes-brasil">
              @for (publicacao of resultado.publicacoes; track publicacao.id) {
                <article class="publicacao-brasil-card" [class.edicao-atual]="publicacao.id === edicaoDetalhe()?.id">
                  <button class="publicacao-brasil-conteudo" type="button" (click)="abrirPublicacaoBrasileira(publicacao)" [disabled]="publicacao.id === edicaoDetalhe()?.id" [attr.aria-label]="publicacao.id === edicaoDetalhe()?.id ? 'Edição atual: ' + publicacao.titulo : 'Abrir ' + publicacao.titulo">
                    <img [src]="publicacao.capa || capaReserva" [alt]="'Capa de ' + publicacao.titulo + ' #' + publicacao.numero" loading="lazy" (error)="usarCapaReserva($event)" />
                    <span class="publicacao-brasil-dados"><strong>{{ publicacao.titulo }} #{{ publicacao.numero }}</strong><small>{{ publicacao.editora }}<span *ngIf="publicacao.ano"> · {{ publicacao.ano }}</span></small>@if (publicacao.colecao && publicacao.colecao !== publicacao.titulo) { <small>{{ publicacao.colecao }}</small> }<span class="publicacao-brasil-selos">@if (publicacao.id === edicaoDetalhe()?.id) { <em>✓ Você está nesta edição</em> } @if (publicacao.primeiraPublicacao) { <em>⭐ Primeira publicação no Brasil</em> } @else { <em>Republicação</em> } @if (publicacao.publicacaoCompleta === true) { <em>✓ Publicação completa</em> } @if (publicacao.publicacaoCompleta === false) { <em>◐ Publicação parcial</em> }</span></span>
                  </button>
                  @if (publicacao.publicacaoCompleta !== null) { <button class="detalhar-historias-publicacao" type="button" (click)="alternarHistoriasPublicacao(publicacao.id)" [attr.aria-expanded]="publicacaoHistoriasAberta() === publicacao.id">{{ publicacaoHistoriasAberta() === publicacao.id ? 'Ocultar histórias' : 'Ver histórias presentes' }}</button> }
                  @if (publicacaoHistoriasAberta() === publicacao.id) { <ul class="historias-publicacao-brasil">@for (historia of publicacao.historias; track historia.id) { <li [class.ausente]="!historia.presente">{{ historia.presente ? '✓' : '✕' }} {{ historia.titulo }}</li> }</ul> }
                  <div class="acao-estante-publicacao">@if (publicacao.naEstante) { <span>✓ Na sua estante</span> } @else { <button type="button" (click)="adicionarPublicacaoBrasileiraNaEstante(publicacao)">+ Adicionar à estante</button> }</div>
                </article>
              } @empty { <p class="estado-republicacoes-vazio">Até o momento, não encontramos outras publicações brasileiras desta história no catálogo do HQ-HUB.</p> }
            </div>
          }
        </article>
      </section>
    }

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

    @if (exibindoModalSerieEstante() && serieSelecionada()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Adicionar série inteira à estante">
        <div class="detalhe-fundo" (click)="fecharModalAdicionarSerieNaEstante()"></div>
        <article class="detalhe-painel modal-estante-catalogo">
          <button class="fechar-detalhe" type="button" (click)="fecharModalAdicionarSerieNaEstante()" aria-label="Fechar adição da série">×</button>
          <div class="detalhe-cabecalho">
            <img
              [src]="resultadosCatalogo().itens[0]?.urlCapa || capaReserva"
              [alt]="serieSelecionada()!.titulo"
              (error)="usarCapaReserva($event)"
            />
            <div>
              <p class="rotulo">Adicionar série inteira</p>
              <h2>{{ serieSelecionada()!.titulo }}</h2>
              <div class="chips">
                <span>{{ resultadosCatalogo().totalItens }} revista(s)</span>
                <span>Volume {{ serieSelecionada()!.volume || '-' }}</span>
              </div>
            </div>
          </div>

          <p class="texto-suave">
            Todas as revistas ainda ausentes serão adicionadas. As que já estiverem na sua estante serão ignoradas automaticamente.
          </p>

          <form class="painel-formulario grade-formulario modal-estante-formulario" (ngSubmit)="confirmarAdicionarSerieNaEstante()">
            <label>
              Conservação de todas
              <select [(ngModel)]="formularioSerieColecao.estadoConservacao" name="estadoConservacaoSerieCatalogo">
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
              <input type="date" [(ngModel)]="formularioSerieColecao.dataAquisicao" name="dataAquisicaoSerieCatalogo" />
            </label>

            <label>
              Preço pago por revista
              <input type="number" min="0" step="0.01" [(ngModel)]="formularioSerieColecao.precoPago" name="precoPagoSerieCatalogo" placeholder="Vazio usa o preço de capa" />
            </label>

            <label>
              Leitura de todas
              <select [(ngModel)]="formularioSerieColecao.statusLeitura" name="statusLeituraSerieCatalogo">
                <option value="NAO_LIDO">Não lido</option>
                <option value="LIDO">Lido</option>
              </select>
            </label>

            <label class="campo-largo">
              Observações
              <input [(ngModel)]="formularioSerieColecao.observacoes" name="observacoesSerieCatalogo" placeholder="Aplicadas às revistas adicionadas" />
            </label>

            <div class="acoes-formulario campo-largo">
              <button class="botao primario" type="submit" [disabled]="adicionandoSerieInteira()">
                {{ adicionandoSerieInteira() ? 'Adicionando...' : 'Confirmar série inteira' }}
              </button>
              <button class="botao secundario" type="button" (click)="fecharModalAdicionarSerieNaEstante()" [disabled]="adicionandoSerieInteira()">
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
          <header class="detalhe-acoes-topo">
            @if (historicoDetalhes().length) {
              <button class="botao compacto voltar-detalhe" type="button" (click)="voltarDetalheAnterior()">
                Voltar
              </button>
            }
            @if (edicaoDetalhe()) {
              <button class="botao secundario compacto compartilhar-edicao-detalhe" type="button" (click)="compartilharEdicaoDetalhe()" [disabled]="compartilhandoEdicao()">
                <svg lucideShare2 size="18" aria-hidden="true"></svg>
                {{ compartilhandoEdicao() ? 'Compartilhando...' : 'Compartilhar edição' }}
              </button>
            }
            <button class="fechar-detalhe" type="button" (click)="fecharDetalhe()" aria-label="Fechar detalhes">×</button>
          </header>

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

          @if (edicaoDetalhe() && autenticado()) {
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
              @if (publicacoesOriginaisAgrupadas().length) {
                <section class="publicacoes-originais-edicao" aria-labelledby="tituloPublicacaoOriginal">
                  <h3 id="tituloPublicacaoOriginal">🌎 Publicação original</h3>
                  <div class="grade-publicacoes-originais">
                    @for (grupo of publicacoesOriginaisAgrupadas(); track grupo.edicao.id) {
                      <article class="publicacao-original-resumo">
                        <img [src]="grupo.edicao.urlCapa || capaReserva" [alt]="'Capa de ' + tituloEdicao(grupo.edicao)" loading="lazy" (error)="usarCapaReserva($event)" />
                        <div><h4>{{ tituloEdicao(grupo.edicao) }}</h4><p>{{ grupo.edicao.serie?.editora?.nome || 'Editora não informada' }}<span *ngIf="anoEdicao(grupo.edicao) as ano"> · {{ ano }}</span></p><small>{{ grupo.quantidadeHistorias }} {{ grupo.quantidadeHistorias === 1 ? 'história relacionada' : 'histórias relacionadas' }}</small><div class="acoes-publicacao-original"><button type="button" (click)="abrirDetalheOriginalAgrupada(grupo.edicao)">Ver edição original →</button><button type="button" (click)="abrirPublicacoesBrasil(grupo.edicao, $event)" [attr.aria-label]="'Ver outras publicações no Brasil de ' + tituloEdicao(grupo.edicao)">🇧🇷 Ver outras publicações no Brasil</button></div></div>
                      </article>
                    }
                  </div>
                </section>
              }
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
              @if (publicacoesDetalhe().length) {
                <header class="mapa-historias-cabecalho">
                  <div>
                    <p class="rotulo">Mapa de republicações</p>
                    <h3>{{ publicacoesDetalhe().length }} história(s) identificada(s)</h3>
                    <p>Abra uma história para descobrir em quais outras revistas brasileiras ela também foi publicada.</p>
                  </div>
                  <span>{{ publicacoesDetalhe().length }}</span>
                </header>
              }
              <div class="lista-historias-editorial">
                @for (publicacao of publicacoesDetalhe(); track publicacao.id; let ordem = $index) {
                  <article class="historia-editorial-card" [class.expandida]="historiaExpandida() === publicacao.historia.id">
                    <div class="historia-editorial-resumo">
                      <span class="historia-ordem">{{ ordem + 1 }}</span>
                      <img class="capa-historia-original" [src]="capaPublicacaoOriginal(publicacao) || capaReserva" [alt]="tituloEdicaoOriginal(publicacao)" loading="lazy" (error)="usarCapaReserva($event)" />
                      <div class="historia-editorial-texto">
                        <div class="historia-selos">
                          <span>{{ rotuloStatusCurto(publicacao.status) }}</span>
                          @if (publicacao.paginasPublicadas) { <span>{{ publicacao.paginasPublicadas }} páginas</span> }
                        </div>
                        <h4>{{ publicacao.historia.tituloExibicao || publicacao.historia.titulo }}</h4>
                        @if (publicacao.historia.tituloOriginal) { <p class="titulo-original-historia">{{ publicacao.historia.tituloOriginal }}</p> }
                        @if (publicacao.historia.descricaoExibicao) { <p class="descricao-historia">{{ publicacao.historia.descricaoExibicao }}</p> }
                        <p class="origem-historia">Publicação original: <button type="button" (click)="abrirDetalheOriginal(publicacao)">{{ tituloEdicaoOriginal(publicacao) }}</button></p>
                        <button class="botao-republicacoes" type="button" (click)="alternarRepublicacoes(publicacao)" [disabled]="carregandoRepublicacoes() !== null" [attr.aria-expanded]="historiaExpandida() === publicacao.historia.id">
                          {{ carregandoRepublicacoes() === publicacao.historia.id ? 'Buscando outras edições...' : historiaExpandida() === publicacao.historia.id ? 'Ocultar outras edições' : 'Ver onde mais esta história foi publicada' }}
                        </button>
                      </div>
                    </div>
                    @if (historiaExpandida() === publicacao.historia.id) {
                      <section class="republicacoes-historia" aria-live="polite">
                        <div class="republicacoes-titulo"><strong>Outras edições brasileiras</strong><span>{{ republicacoesHistoria(publicacao.historia.id).length }} resultado(s) no catálogo</span></div>
                        @if (republicacoesHistoria(publicacao.historia.id).length) {
                          <div class="grade-republicacoes">
                            @for (republicacao of republicacoesHistoria(publicacao.historia.id); track republicacao.id) {
                              <button type="button" class="republicacao-card" (click)="abrirDetalhePorId(republicacao.edicaoPublicada.id)">
                                <img [src]="republicacao.edicaoPublicada.urlCapa || capaReserva" [alt]="tituloEdicaoPublicada(republicacao)" loading="lazy" (error)="usarCapaReserva($event)" />
                                <span><strong>{{ tituloEdicaoPublicada(republicacao) }}</strong><small>{{ rotuloStatusCurto(republicacao.status) }}</small></span>
                              </button>
                            }
                          </div>
                        } @else {
                          <p class="estado-republicacoes-vazio">Ainda não há outra publicação brasileira vinculada a esta história.</p>
                        }
                      </section>
                    }
                    @if (podeEditarCatalogo()) {
                      <details class="ferramentas-historia-admin"><summary>Ferramentas de catálogo</summary>
                        <div class="acoes-detalhe-edicao">
                          <input class="input-capa-publicacao" [ngModel]="urlCapaPublicacao(publicacao)" (ngModelChange)="alterarUrlCapaPublicacao(publicacao, $event)" [name]="'urlCapaPublicacao' + publicacao.id" placeholder="URL da capa original" />
                          <button class="botao compacto" type="button" (click)="salvarCapaPublicacao(publicacao)" [disabled]="salvandoCapaPublicacao() === publicacao.id">{{ salvandoCapaPublicacao() === publicacao.id ? 'Salvando...' : 'Salvar capa' }}</button>
                          @if (podeExcluirCatalogo()) { <button class="botao compacto secundario" type="button" (click)="removerPublicacaoDetalhe(publicacao)" [disabled]="removendoPublicacao() === publicacao.id">{{ removendoPublicacao() === publicacao.id ? 'Excluindo...' : 'Excluir vínculo' }}</button> }
                        </div>
                      </details>
                    }
                  </article>
                } @empty { <p class="texto-suave">Nenhuma publicação brasileira vinculada a esta edição ainda.</p> }
              </div>
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
            <div class="secao-titulo compacta">
              <div>
                <h3>Histórias e conteúdos desta edição</h3>
                <p class="texto-suave">Estas informações podem ser acrescentadas ou corrigidas depois que a revista já estiver no catálogo.</p>
              </div>
              @if (podeEditarCatalogo() && !exibindoFormularioConteudo()) {
                <button class="botao primario compacto" type="button" (click)="iniciarNovoConteudo()">
                  + Adicionar história
                </button>
              }
            </div>

            @if (podeEditarCatalogo() && exibindoFormularioConteudo()) {
              <section class="painel-formulario formulario-conteudo-edicao">
                <div class="secao-titulo compacta">
                  <div>
                    <h2>{{ editandoConteudo() ? 'Editar história' : 'Adicionar história depois' }}</h2>
                    <p class="texto-suave">Você pode salvar agora mesmo que a revista tenha sido cadastrada anteriormente.</p>
                  </div>
                </div>
                <div class="grade-formulario">
                  <label class="campo-largo">
                    Título da história
                    <input [(ngModel)]="formularioConteudo.titulo" name="tituloConteudoCatalogo" placeholder="Ex.: Bens congelados" required />
                  </label>
                  <label class="campo-largo">
                    Título original
                    <input [(ngModel)]="formularioConteudo.tituloOriginal" name="tituloOriginalConteudoCatalogo" placeholder="Opcional" />
                  </label>
                  <label>
                    Ordem na revista
                    <input [(ngModel)]="formularioConteudo.ordem" name="ordemConteudoCatalogo" type="number" min="1" />
                  </label>
                  <label>
                    Páginas
                    <input [(ngModel)]="formularioConteudo.quantidadePaginas" name="paginasConteudoCatalogo" type="number" min="1" />
                  </label>
                  <label>
                    Tipo
                    <select [(ngModel)]="formularioConteudo.tipo" name="tipoConteudoCatalogo">
                      <option value="HISTORIA">História</option>
                      <option value="MATERIAL_EDITORIAL">Material editorial</option>
                      <option value="EXTRA">Extra</option>
                      <option value="CAPA">Capa</option>
                      <option value="PINUP">Pin-up</option>
                      <option value="EDITORIAL">Editorial</option>
                      <option value="ENTREVISTA">Entrevista</option>
                      <option value="OUTRO">Outro</option>
                    </select>
                  </label>
                  <label class="campo-largo">
                    Título usado nesta edição
                    <input [(ngModel)]="formularioConteudo.tituloUsado" name="tituloUsadoConteudoCatalogo" placeholder="Preencha apenas se for diferente" />
                  </label>
                  <label class="campo-largo">
                    Fonte consultada
                    <input [(ngModel)]="formularioConteudo.urlOrigem" name="urlOrigemConteudoCatalogo" placeholder="https://..." />
                  </label>
                  <label class="campo-largo campo-descricao-edicao">
                    Resumo ou descrição
                    <textarea [(ngModel)]="formularioConteudo.descricao" name="descricaoConteudoCatalogo" rows="5"></textarea>
                  </label>
                  <label class="campo-largo">
                    Observações
                    <input [(ngModel)]="formularioConteudo.observacoes" name="observacoesConteudoCatalogo" />
                  </label>
                </div>
                <div class="acoes-formulario">
                  <button class="botao primario" type="button" (click)="salvarConteudoDetalhe()" [disabled]="salvandoConteudo()">
                    {{ salvandoConteudo() ? 'Salvando...' : editandoConteudo() ? 'Salvar alterações' : 'Adicionar à edição' }}
                  </button>
                  <button class="botao secundario" type="button" (click)="cancelarFormularioConteudo()" [disabled]="salvandoConteudo()">
                    Cancelar
                  </button>
                </div>
              </section>
            }

            @for (conteudo of conteudosDetalhe(); track conteudo.id) {
              <article class="publicacao-card">
                <div>
                  <p class="rotulo">Ordem {{ conteudo.ordem }} · {{ rotuloTipoConteudo(conteudo.tipo) }}</p>
                  <h4>{{ conteudo.tituloUsado || conteudo.historia.tituloExibicao || conteudo.historia.titulo }}</h4>
                  <p>{{ conteudo.historia.descricaoExibicao || conteudo.observacoes || 'Sem descrição.' }}</p>
                  @if (conteudo.quantidadePaginas || conteudo.historia.quantidadePaginas) {
                    <p>{{ conteudo.quantidadePaginas || conteudo.historia.quantidadePaginas }} páginas</p>
                  }
                  @if (podeEditarCatalogo()) {
                    <div class="acoes-detalhe-edicao">
                      <button class="botao compacto" type="button" (click)="iniciarEdicaoConteudo(conteudo)">Editar história</button>
                      @if (podeExcluirCatalogo()) {
                        <button class="botao compacto perigo" type="button" (click)="removerConteudoDetalhe(conteudo)" [disabled]="removendoConteudo() === conteudo.id">
                          {{ removendoConteudo() === conteudo.id ? 'Removendo...' : 'Remover da edição' }}
                        </button>
                      }
                    </div>
                  }
                </div>
              </article>
            } @empty {
              <section class="estado-vazio compacto">
                <p>Nenhuma história foi informada ainda.</p>
                @if (podeEditarCatalogo() && !exibindoFormularioConteudo()) {
                  <button class="botao primario compacto" type="button" (click)="iniciarNovoConteudo()">Adicionar quando a informação estiver disponível</button>
                }
              </section>
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
  @ViewChild('tituloColecao') private tituloColecao?: ElementRef<HTMLElement>;
  @ViewChild('detalhePainel') private detalhePainel?: ElementRef<HTMLElement>;
  @ViewChild('modalPublicacoesBrasil') private modalPublicacoesBrasil?: ElementRef<HTMLElement>;

  private readonly api = inject(ApiService);
  private readonly rota = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly autenticacao = inject(AutenticacaoService);
  private readonly sanitizador = inject(DomSanitizer);
  private readonly compartilhamento = inject(CompartilhamentoService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly letrasIndice = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  readonly sugestoesPesquisa = ['Batman', 'Homem-Aranha', 'X-Men', 'Superman', 'Spawn'];
  readonly podeEditarCatalogo = this.autenticacao.podeRevisarCatalogo;
  readonly podeExcluirCatalogo = this.autenticacao.ehAdministrador;
  readonly autenticado = this.autenticacao.autenticado;
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
  readonly compartilhandoEdicao = signal(false);
  readonly mostrarVoltarColecoesFlutuante = signal(false);
  readonly edicaoDetalhe = signal<Edicao | null>(null);
  readonly historicoDetalhes = signal<Edicao[]>([]);
  readonly conteudosDetalhe = signal<ConteudoEdicao[]>([]);
  readonly publicacoesDetalhe = signal<PublicacaoHistoria[]>([]);
  readonly publicacoesComoOriginal = signal<PublicacaoHistoria[]>([]);
  readonly historiaExpandida = signal<number | null>(null);
  readonly carregandoRepublicacoes = signal<number | null>(null);
  readonly republicacoesPorHistoria = signal<Record<number, PublicacaoHistoria[]>>({});
  readonly originalPublicacoesAberta = signal<Edicao | null>(null);
  readonly publicacoesBrasil = signal<PublicacoesBrasileirasEdicaoOriginal | null>(null);
  readonly carregandoPublicacoesBrasil = signal(false);
  readonly erroPublicacoesBrasil = signal(false);
  readonly publicacaoHistoriasAberta = signal<number | null>(null);
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
  readonly preenchendoCapasSerie = signal(false);
  readonly resumoCapasSerie = signal<{
    processadas: number;
    atualizadas: number;
    semCorrespondencia: number;
    falhas: number;
    avisos: string[];
  } | null>(null);
  readonly exibindoFormularioConteudo = signal(false);
  readonly editandoConteudo = signal<ConteudoEdicao | null>(null);
  readonly salvandoConteudo = signal(false);
  readonly removendoConteudo = signal<number | null>(null);
  readonly carregandoSeriesEdicao = signal(false);
  readonly seriesParaEdicao = signal<Serie[]>([]);
  readonly salvandoVinculoOriginal = signal(false);
  readonly buscandoOriginaisVinculo = signal(false);
  readonly resultadosOriginaisVinculo = signal<ResultadoPesquisaCatalogo[]>([]);
  readonly enviandoCapa = signal(false);
  readonly revisandoCapa = signal<number | null>(null);
  readonly salvandoItemColecao = signal<number | null>(null);
  readonly resultadoParaEstante = signal<ResultadoPesquisaCatalogo | null>(null);
  readonly exibindoModalSerieEstante = signal(false);
  readonly adicionandoSerieInteira = signal(false);
  readonly seriesConsultadas = signal(false);
  readonly resultadosConsultados = signal(false);
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
  formularioConteudo = this.formularioConteudoVazio();
  formularioVinculoOriginal = this.formularioVinculoOriginalVazio();
  formularioItemColecao = this.formularioItemColecaoVazio();
  formularioSerieColecao = this.formularioItemColecaoVazio();
  private temporizadorMensagem: ReturnType<typeof setTimeout> | null = null;
  private sequenciaBuscaResultados = 0;
  private posicaoRolagemAntesDaSerie = 0;
  private serieAbertaId: number | null = null;
  private historicoSerieAtivo = false;
  private paginaEdicaoPublica = false;
  private focoAntesDasPublicacoesBrasil: HTMLElement | null = null;
  private estadoResultadosAntesDaSerie: {
    resultados: PaginaResposta<ResultadoPesquisaCatalogo>;
    pagina: number;
    consultados: boolean;
  } | null = null;

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
    const edicaoIdRota = Number(this.rota.snapshot.paramMap.get('id'));
    this.paginaEdicaoPublica = Number.isFinite(edicaoIdRota) && edicaoIdRota > 0;
    const edicaoId = this.paginaEdicaoPublica
      ? edicaoIdRota
      : Number(this.rota.snapshot.queryParamMap.get('edicaoId'));
    if (Number.isFinite(edicaoId) && edicaoId > 0) {
      if (this.autenticado()) {
        this.abrirDetalhePorId(edicaoId);
      } else {
        this.abrirDetalhePublico(edicaoId);
        return;
      }
    }

    this.carregarEditoras();
    const serieId = Number(this.rota.snapshot.queryParamMap.get('serieId'));
    if (Number.isFinite(serieId) && serieId > 0) {
      this.carregarEdicoesDaSerieImportada(serieId);
    }

    this.rota.queryParamMap.subscribe((parametros) => {
      const colecaoTex = parametros.get('colecaoTex');
      if (colecaoTex === 'globo' || colecaoTex === 'rge' || colecaoTex === 'vecchi') {
        this.carregarColecaoTexPorEditora(colecaoTex);
      }

      const colecaoTexColecao = parametros.get('colecaoTexColecao');
      if (colecaoTexColecao === 'globo' || colecaoTexColecao === 'mythos') {
        this.carregarTexColecaoPorEditora(colecaoTexColecao);
      }
    });
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
    const sequencia = ++this.sequenciaBuscaResultados;
    this.serieSelecionada.set(null);
    this.busca = '';
    this.seriesConsultadas.set(false);
    this.carregandoResultados.set(true);
    this.resultadosConsultados.set(true);
    this.mensagem.set('Carregando edicoes da serie importada...');

    forkJoin({
      serie: this.api.buscarSeriePorId(serieId),
      edicoes: this.api.listarEdicoes('', 0, this.tamanhoResultados, serieId),
    }).subscribe({
      next: ({ serie, edicoes: resposta }) => {
        if (sequencia !== this.sequenciaBuscaResultados) return;
        this.serieSelecionada.set(serie);
        this.resultadosCatalogo.set({
          ...resposta,
          itens: resposta.itens.map((edicao) => this.paraResultadoInterno(edicao)),
        });
        this.paginaResultados.set(resposta.pagina);
        this.carregandoResultados.set(false);
        this.mensagem.set(resposta.itens.length ? 'Edicoes da serie importada carregadas.' : 'Nenhuma edicao encontrada para a serie importada.');
      },
      error: () => {
        if (sequencia !== this.sequenciaBuscaResultados) return;
        this.resultadosCatalogo.set({ itens: [], pagina: 0, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
        this.carregandoResultados.set(false);
        this.mensagem.set('Nao foi possivel carregar as edicoes da serie importada agora.');
      },
    });
  }

  selecionarSerie(serie: Serie) {
    this.serieAbertaId = serie.id;
    if (!this.serieSelecionada()) {
      this.posicaoRolagemAntesDaSerie = window.scrollY;
      this.estadoResultadosAntesDaSerie = {
        resultados: this.resultadosCatalogo(),
        pagina: this.paginaResultados(),
        consultados: this.resultadosConsultados(),
      };
      window.history.pushState({ ...(window.history.state || {}), catalogoSerie: serie.id }, '');
      this.historicoSerieAtivo = true;
    }
    this.serieSelecionada.set(serie);
    this.resumoCapasSerie.set(null);
    this.paginaResultados.set(0);
    this.buscarResultados(0, true);
  }

  voltarParaColecoes() {
    if (!this.serieSelecionada()) return;
    if (this.historicoSerieAtivo) {
      window.history.back();
      return;
    }
    this.restaurarListaColecoes();
  }

  @HostListener('window:popstate')
  aoVoltarNoHistorico() {
    if (!this.serieSelecionada()) return;
    this.historicoSerieAtivo = false;
    this.restaurarListaColecoes();
  }

  @HostListener('window:scroll')
  aoRolarPagina() {
    if (!this.serieSelecionada() || !this.ehViewportMobile()) {
      this.mostrarVoltarColecoesFlutuante.set(false);
      return;
    }
    const topoResultados = this.resultadosCatalogoBloco?.nativeElement.offsetTop || 0;
    this.mostrarVoltarColecoesFlutuante.set(window.scrollY > topoResultados + 260);
  }

  private restaurarListaColecoes() {
    this.serieSelecionada.set(null);
    this.resumoCapasSerie.set(null);
    this.mostrarVoltarColecoesFlutuante.set(false);
    if (this.estadoResultadosAntesDaSerie) {
      this.resultadosCatalogo.set(this.estadoResultadosAntesDaSerie.resultados);
      this.paginaResultados.set(this.estadoResultadosAntesDaSerie.pagina);
      this.resultadosConsultados.set(this.estadoResultadosAntesDaSerie.consultados);
      this.estadoResultadosAntesDaSerie = null;
    }
    const posicao = this.posicaoRolagemAntesDaSerie;
    const serieId = this.serieAbertaId;
    this.serieAbertaId = null;
    setTimeout(() => {
      window.scrollTo({ top: posicao, behavior: 'auto' });
      document.querySelector<HTMLElement>(`[data-serie-id="${serieId}"]`)?.focus({ preventScroll: true });
    }, 0);
  }

  async preencherCapasSerieSelecionada() {
    const serie = this.serieSelecionada();
    if (!serie || !this.podeExcluirCatalogo() || this.preenchendoCapasSerie()) return;

    this.preenchendoCapasSerie.set(true);
    let cursor: number | null = null;
    let processadas = 0;
    let atualizadas = 0;
    let semCorrespondencia = 0;
    let falhas = 0;
    const avisos: string[] = [];
    this.resumoCapasSerie.set(null);
    try {
      do {
        this.mensagem.set(`Buscando capas de ${serie.titulo}: ${processadas} edição(ões) processada(s)...`);
        const lote: ResultadoBackfillComicVine = await firstValueFrom(
          this.api.preencherCapasComicVineImportacao(serie.id, cursor),
        );
        processadas += lote.processadas;
        atualizadas += lote.atualizadas;
        semCorrespondencia += lote.semCorrespondencia;
        falhas += lote.falhas || 0;
        avisos.push(...(lote.avisos || []));
        cursor = lote.proximoCursor;
        if (!lote.possuiMais) break;
        await new Promise((resolve) => setTimeout(resolve, 250));
      } while (processadas < 5000);

      this.buscarResultados(0);
      this.resumoCapasSerie.set({
        processadas,
        atualizadas,
        semCorrespondencia,
        falhas,
        avisos: avisos.slice(0, 100),
      });
      this.mensagem.set(falhas > 0 && processadas === 0
        ? 'A consulta não pôde ser concluída. Abra “Ver detalhes” para conferir o erro da Comic Vine.'
        : processadas === 0
          ? 'Todas as edições relacionadas já possuem capa.'
          : `Comic Vine concluída: ${atualizadas} capa(s) salva(s), ${semCorrespondencia} sem correspondência única e ${falhas} falha(s) de consulta.`);
    } catch (erro: any) {
      this.mensagem.set(erro?.error?.mensagem || 'Não foi possível preencher as capas automaticamente.');
    } finally {
      this.preenchendoCapasSerie.set(false);
    }
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

  private abrirDetalhePublico(edicaoId: number) {
    this.carregandoDetalhe.set(true);
    this.api.obterDetalheCatalogoPublico(edicaoId).subscribe({
      next: ({ edicao, links, conteudos, publicacoes, publicacoesOriginais }) => {
        this.edicaoDetalhe.set(edicao);
        this.linksDetalhe.set(links);
        this.conteudosDetalhe.set(conteudos);
        this.publicacoesDetalhe.set(publicacoes);
        this.urlsCapasPublicacoes.set(this.montarUrlsCapasPublicacoes(publicacoes));
        this.publicacoesComoOriginal.set(publicacoesOriginais);
        this.capasDetalhe.set([]);
        this.carregandoDetalhe.set(false);
      },
      error: () => {
        this.carregandoDetalhe.set(false);
        this.mensagem.set('Nao foi possivel carregar os detalhes desta edicao.');
      },
    });
  }

  buscarCatalogoCompleto() {
    const termo = this.buscaSeries.trim();
    this.buscarSeriesInternas();
    if (!termo) {
      return;
    }
    this.busca = termo;
    this.carregar();
  }

  buscarSugestao(termo: string) {
    this.buscaSeries = termo;
    this.buscarCatalogoCompleto();
  }

  rotuloContadorResultados() {
    const total = this.resultadosCatalogo().totalItens;
    if (total === 1) {
      return '1 edição encontrada';
    }
    return total > 1 ? `${total} edições encontradas` : 'Nenhuma edição encontrada';
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

  compartilharResultado(resultado: ResultadoPesquisaCatalogo, evento: Event) {
    evento.stopPropagation();
    if (!resultado.id) return;
    void this.compartilharEdicao(resultado.id, this.tituloResultadoCartao(resultado));
  }

  compartilharEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    if (!edicao) return;
    void this.compartilharEdicao(edicao.id, this.tituloEdicao(edicao));
  }

  private async compartilharEdicao(edicaoId: number, titulo: string) {
    if (this.compartilhandoEdicao()) return;
    this.compartilhandoEdicao.set(true);
    const url = `${environment.compartilhamentoUrl}/edicoes/${edicaoId}?v=1`;
    try {
      const resultado = await this.compartilhamento.compartilhar({
        title: `${titulo} | HQ-HUB`,
        text: `Conheça ${titulo} no catálogo do HQ-HUB.`,
        url,
      });
      if (resultado === 'copiado') this.mensagem.set('Link da edição copiado');
    } catch {
      this.mensagem.set('Não foi possível compartilhar esta edição agora.');
    } finally {
      this.compartilhandoEdicao.set(false);
    }
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
        this.mensagem.set('Adicionado à estante');
      },
      error: (erro) => {
        this.salvandoItemColecao.set(null);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível adicionar a edição. Verifique se ela já está na sua estante.'));
      },
    });
  }

  abrirModalAdicionarSerieNaEstante() {
    if (!this.serieSelecionada() || !this.autenticado()) {
      this.mensagem.set('Selecione uma série interna para adicionar à estante.');
      return;
    }
    this.formularioSerieColecao = this.formularioItemColecaoVazio();
    this.exibindoModalSerieEstante.set(true);
    this.mensagem.set('');
  }

  fecharModalAdicionarSerieNaEstante() {
    if (this.adicionandoSerieInteira()) {
      return;
    }
    this.exibindoModalSerieEstante.set(false);
    this.formularioSerieColecao = this.formularioItemColecaoVazio();
  }

  confirmarAdicionarSerieNaEstante() {
    const serie = this.serieSelecionada();
    if (!serie || this.adicionandoSerieInteira()) {
      return;
    }

    this.adicionandoSerieInteira.set(true);
    this.mensagem.set('');
    this.api.cadastrarSerieNaColecao({
      serieId: serie.id,
      estadoConservacao: this.formularioSerieColecao.estadoConservacao,
      dataAquisicao: this.formularioSerieColecao.dataAquisicao || null,
      precoPago: this.formularioSerieColecao.precoPago,
      statusLeitura: this.formularioSerieColecao.statusLeitura,
      observacoes: this.formularioSerieColecao.observacoes.trim() || null,
    }).subscribe({
      next: (resultado) => {
        this.adicionandoSerieInteira.set(false);
        this.exibindoModalSerieEstante.set(false);
        this.formularioSerieColecao = this.formularioItemColecaoVazio();
        this.mensagem.set(
          resultado.adicionadas > 0
            ? `${resultado.adicionadas} revista(s) adicionada(s) à estante. ${resultado.jaExistentes} já existente(s) foram ignorada(s).`
            : `Nenhuma revista adicionada: as ${resultado.jaExistentes} edição(ões) já estavam na sua estante.`,
        );
      },
      error: (erro) => {
        this.adicionandoSerieInteira.set(false);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível adicionar a série inteira à estante.'));
      },
    });
  }

  abrirDetalhePorId(edicaoId: number, historiaId: number | null = null) {
    this.carregandoDetalhe.set(true);
    this.historiaExpandida.set(null);
    this.carregandoRepublicacoes.set(null);
    this.republicacoesPorHistoria.set({});
    this.mensagem.set('');
    this.exibindoFormularioConteudo.set(false);
    this.editandoConteudo.set(null);
    this.salvandoConteudo.set(false);
    this.formularioConteudo = this.formularioConteudoVazio();
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
    if (this.paginaEdicaoPublica) {
      const origemInterna = document.referrer.startsWith(window.location.origin);
      if (origemInterna && window.history.length > 1) {
        window.history.back();
      } else {
        void this.router.navigate(['/catalogo']);
      }
      return;
    }
    this.edicaoDetalhe.set(null);
    this.editandoDetalhe.set(false);
    this.salvandoDetalhe.set(false);
    this.removendoEdicao.set(false);
    this.removendoPublicacao.set(null);
    this.salvandoCapaPublicacao.set(null);
    this.exibindoFormularioConteudo.set(false);
    this.editandoConteudo.set(null);
    this.salvandoConteudo.set(false);
    this.removendoConteudo.set(null);
    this.formularioConteudo = this.formularioConteudoVazio();
    this.formularioEdicao = this.formularioEdicaoVazio();
    this.conteudosDetalhe.set([]);
    this.publicacoesDetalhe.set([]);
    this.publicacoesComoOriginal.set([]);
    this.historiaExpandida.set(null);
    this.carregandoRepublicacoes.set(null);
    this.republicacoesPorHistoria.set({});
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

  iniciarNovoConteudo() {
    if (!this.edicaoDetalhe() || !this.podeEditarCatalogo()) {
      return;
    }

    const proximaOrdem = this.conteudosDetalhe().reduce(
      (maior, conteudo) => Math.max(maior, conteudo.ordem),
      0,
    ) + 1;
    this.editandoConteudo.set(null);
    this.formularioConteudo = {
      ...this.formularioConteudoVazio(),
      ordem: proximaOrdem,
    };
    this.exibindoFormularioConteudo.set(true);
  }

  iniciarEdicaoConteudo(conteudo: ConteudoEdicao) {
    if (!this.podeEditarCatalogo()) {
      return;
    }

    this.editandoConteudo.set(conteudo);
    this.formularioConteudo = {
      titulo: conteudo.historia.tituloExibicao || conteudo.historia.titulo,
      tituloOriginal: conteudo.historia.tituloOriginal || '',
      descricao: conteudo.historia.descricaoExibicao || conteudo.historia.descricao || '',
      ordem: conteudo.ordem,
      quantidadePaginas: conteudo.quantidadePaginas || conteudo.historia.quantidadePaginas,
      tipo: conteudo.tipo,
      tituloUsado: conteudo.tituloUsado || '',
      urlOrigem: conteudo.historia.urlOrigem || '',
      observacoes: conteudo.observacoes || '',
    };
    this.exibindoFormularioConteudo.set(true);
  }

  cancelarFormularioConteudo() {
    if (this.salvandoConteudo()) {
      return;
    }

    this.exibindoFormularioConteudo.set(false);
    this.editandoConteudo.set(null);
    this.formularioConteudo = this.formularioConteudoVazio();
  }

  async salvarConteudoDetalhe() {
    const edicao = this.edicaoDetalhe();
    const conteudoEmEdicao = this.editandoConteudo();
    const titulo = this.formularioConteudo.titulo.trim();
    const ordem = this.numeroOuNull(this.formularioConteudo.ordem);
    const tipo = this.formularioConteudo.tipo;

    if (!edicao || !this.podeEditarCatalogo()) {
      return;
    }
    if (!titulo) {
      this.mensagem.set('Informe o título da história ou conteúdo.');
      return;
    }
    if (!ordem || ordem < 1) {
      this.mensagem.set('Informe uma ordem válida para o conteúdo.');
      return;
    }

    this.salvandoConteudo.set(true);
    this.mensagem.set('');

    try {
      const quantidadePaginas = this.numeroOuNull(this.formularioConteudo.quantidadePaginas);
      const dadosHistoria = {
        titulo,
        tituloOriginal: this.valorTextoOuNull(this.formularioConteudo.tituloOriginal),
        descricao: this.valorTextoOuNull(this.formularioConteudo.descricao),
        quantidadePaginas,
        tipo,
        fonteExterna: conteudoEmEdicao?.historia.fonteExterna || null,
        idExterno: conteudoEmEdicao?.historia.idExterno || null,
        urlOrigem: this.valorTextoOuNull(this.formularioConteudo.urlOrigem),
      };
      const dadosConteudo = {
        ordem,
        tituloUsado: this.valorTextoOuNull(this.formularioConteudo.tituloUsado),
        paginaInicio: null,
        paginaFim: null,
        quantidadePaginas,
        tipo,
        observacoes: this.valorTextoOuNull(this.formularioConteudo.observacoes),
      };

      let conteudoSalvo: ConteudoEdicao;
      if (conteudoEmEdicao) {
        const historia = await firstValueFrom(
          this.api.atualizarHistoria(conteudoEmEdicao.historia.id, dadosHistoria),
        );
        const vinculo = await firstValueFrom(
          this.api.atualizarConteudoEdicao(conteudoEmEdicao.id, dadosConteudo),
        );
        conteudoSalvo = { ...vinculo, historia };
        this.conteudosDetalhe.update((conteudos) => this.ordenarConteudos(
          conteudos.map((conteudo) => conteudo.id === conteudoSalvo.id ? conteudoSalvo : conteudo),
        ));
      } else {
        const historia = await firstValueFrom(this.api.cadastrarHistoria(dadosHistoria));
        conteudoSalvo = await firstValueFrom(this.api.cadastrarConteudoEdicao({
          edicaoId: edicao.id,
          historiaId: historia.id,
          ...dadosConteudo,
        }));
        this.conteudosDetalhe.update((conteudos) => this.ordenarConteudos([...conteudos, conteudoSalvo]));
      }

      this.salvandoConteudo.set(false);
      this.cancelarFormularioConteudo();
      this.mensagem.set(conteudoEmEdicao
        ? 'História atualizada nesta edição.'
        : 'História adicionada à edição.');
    } catch (erro: any) {
      this.mensagem.set(this.extrairMensagemErro(
        erro,
        conteudoEmEdicao
          ? 'Não foi possível atualizar esta história.'
          : 'Não foi possível adicionar esta história.',
      ));
    } finally {
      this.salvandoConteudo.set(false);
    }
  }

  removerConteudoDetalhe(conteudo: ConteudoEdicao) {
    if (!this.podeExcluirCatalogo()) {
      return;
    }

    const titulo = conteudo.tituloUsado || conteudo.historia.tituloExibicao || conteudo.historia.titulo;
    if (!window.confirm(`Remover "${titulo}" desta edição?`)) {
      return;
    }

    this.removendoConteudo.set(conteudo.id);
    this.api.removerConteudoEdicao(conteudo.id).subscribe({
      next: () => {
        this.conteudosDetalhe.update((conteudos) => conteudos.filter((item) => item.id !== conteudo.id));
        if (this.editandoConteudo()?.id === conteudo.id) {
          this.cancelarFormularioConteudo();
        }
        this.removendoConteudo.set(null);
        this.mensagem.set('Conteúdo removido desta edição.');
      },
      error: (erro) => {
        this.removendoConteudo.set(null);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível remover este conteúdo.'));
      },
    });
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

  exibirColecaoPublicaMarvelDeluxe() {
    const serie = this.serieSelecionada();
    return !!serie
      && this.normalizarComparacao(serie.editora?.nome || '') === 'panini'
      && this.normalizarComparacao(serie.titulo).startsWith('marvel deluxe:');
  }

  exibirAvisoEdicoesAnterioresTex() {
    const serie = this.serieSelecionada();
    if (!serie || this.paginaResultados() !== 0) {
      return false;
    }

    const editora = this.normalizarComparacao(serie.editora?.nome || '');
    return this.normalizarComparacao(serie.titulo) === 'tex'
      && (editora.includes('mythos') || editora.includes('globo') || editora.includes('rge') || editora.includes('rio grafica'));
  }

  exibirNotaInicioTexEdicaoHistoricaMythos() {
    const serie = this.serieSelecionada();
    return !!serie
      && this.paginaResultados() === 0
      && this.normalizarComparacao(serie.titulo) === 'tex edicao historica'
      && this.normalizarComparacao(serie.editora?.nome || '').includes('mythos');
  }

  textoEdicoesAnterioresTex() {
    const editora = this.editoraSelecionadaTex();
    if (editora.includes('globo')) {
      return 'Os números anteriores foram publicados pela editora RGE';
    }
    if (editora.includes('rge') || editora.includes('rio grafica')) {
      return 'Os números anteriores foram publicados pela editora Vecchi';
    }
    return 'Os números anteriores foram publicados pela editora Globo';
  }

  colecaoAnteriorTex() {
    const editora = this.editoraSelecionadaTex();
    if (editora.includes('globo')) return 'rge';
    if (editora.includes('rge') || editora.includes('rio grafica')) return 'vecchi';
    return 'globo';
  }

  exibirNotaTexRgeSegundaEdicao() {
    const serie = this.serieSelecionada();
    if (!serie || this.paginaResultados() !== 0 || serie.volume !== 2) {
      return false;
    }

    const editora = this.editoraSelecionadaTex();
    return this.normalizarComparacao(serie.titulo) === 'tex'
      && (editora.includes('rge') || editora.includes('rio grafica'));
  }

  exibirAvisoEdicoesPosterioresTex() {
    const serie = this.serieSelecionada();
    const totalPaginas = this.resultadosCatalogo().totalPaginas;
    if (!serie || totalPaginas < 1 || this.paginaResultados() !== totalPaginas - 1) {
      return false;
    }

    const editora = this.editoraSelecionadaTex();
    return this.normalizarComparacao(serie.titulo) === 'tex'
      && (editora.includes('vecchi') || editora.includes('rge') || editora.includes('rio grafica'));
  }

  textoEdicoesPosterioresTex() {
    const editora = this.editoraSelecionadaTex();
    return editora.includes('vecchi')
      ? 'Os números posteriores foram publicados pela editora RGE'
      : 'Os números posteriores foram publicados pela Globo';
  }

  colecaoPosteriorTex() {
    return this.editoraSelecionadaTex().includes('vecchi') ? 'rge' : 'globo';
  }

  exibirAvisoTexColecaoGlobo() {
    const serie = this.serieSelecionada();
    const totalPaginas = this.resultadosCatalogo().totalPaginas;
    if (!serie || totalPaginas < 1 || this.paginaResultados() !== totalPaginas - 1) {
      return false;
    }

    return this.normalizarComparacao(serie.titulo) === 'tex colecao'
      && this.normalizarComparacao(serie.editora?.nome || '').includes('vecchi');
  }

  exibirNotaInicioTexColecaoGlobo() {
    const serie = this.serieSelecionada();
    return !!serie
      && this.paginaResultados() === 0
      && this.normalizarComparacao(serie.titulo) === 'tex colecao'
      && this.normalizarComparacao(serie.editora?.nome || '').includes('globo');
  }

  private editoraSelecionadaTex() {
    return this.normalizarComparacao(this.serieSelecionada()?.editora?.nome || '');
  }

  private async carregarColecaoTexPorEditora(colecao: 'globo' | 'rge' | 'vecchi') {
    try {
      const resposta = await firstValueFrom(this.api.listarSeries('Tex', 0, 100));
      const serie = resposta.itens.find((item) => {
        if (this.normalizarComparacao(item.titulo) !== 'tex') return false;
        const editora = this.normalizarComparacao(item.editora?.nome || '');
        if (colecao === 'globo') return editora.includes('globo');
        if (colecao === 'rge') return editora.includes('rge') || editora.includes('rio grafica');
        return editora.includes('vecchi');
      });

      if (!serie) {
        this.mensagem.set('A coleção de Tex solicitada ainda não está disponível no catálogo.');
        return;
      }

      this.selecionarSerie(serie);
    } catch {
      this.mensagem.set('Não foi possível abrir a coleção de Tex agora.');
    }
  }

  private async carregarTexColecaoPorEditora(editoraAlvo: 'globo' | 'mythos') {
    try {
      const resposta = await firstValueFrom(this.api.listarSeries('Tex Coleção', 0, 100));
      const serie = resposta.itens.find((item) =>
        this.normalizarComparacao(item.titulo) === 'tex colecao'
        && this.normalizarComparacao(item.editora?.nome || '').includes(editoraAlvo),
      );

      if (!serie) {
        this.mensagem.set(`A coleção Tex Coleção da ${editoraAlvo} ainda não está disponível no catálogo.`);
        return;
      }

      this.selecionarSerie(serie);
    } catch {
      this.mensagem.set(`Não foi possível abrir Tex Coleção da ${editoraAlvo} agora.`);
    }
  }

  rotuloStatusCurto(status: string) {
    const rotulos: Record<string, string> = {
      COMPLETA: 'Completa',
      PARCIAL: 'Parcial',
      CORTADA: 'Cortada',
      ADAPTADA: 'Adaptada',
      DESCONHECIDA: 'Status não informado',
    };
    return rotulos[status] || status;
  }

  republicacoesHistoria(historiaId: number) {
    return this.republicacoesPorHistoria()[historiaId] || [];
  }

  alternarRepublicacoes(publicacao: PublicacaoHistoria) {
    const historiaId = publicacao.historia.id;
    if (this.historiaExpandida() === historiaId) {
      this.historiaExpandida.set(null);
      return;
    }

    if (this.carregandoRepublicacoes() !== null) {
      return;
    }

    if (Object.prototype.hasOwnProperty.call(this.republicacoesPorHistoria(), historiaId)) {
      this.historiaExpandida.set(historiaId);
      return;
    }

    const edicaoAtualId = this.edicaoDetalhe()?.id;
    this.carregandoRepublicacoes.set(historiaId);
    this.api.listarPublicacoesPorHistoria(historiaId).subscribe({
      next: (publicacoes) => {
        if (this.edicaoDetalhe()?.id !== edicaoAtualId) {
          return;
        }
        const idsVistos = new Set<number>();
        const republicacoes = publicacoes
          .filter((item) => item.edicaoPublicada.id !== edicaoAtualId)
          .filter((item) => {
            if (idsVistos.has(item.edicaoPublicada.id)) {
              return false;
            }
            idsVistos.add(item.edicaoPublicada.id);
            return true;
          })
          .sort((a, b) => this.tituloEdicaoPublicada(a).localeCompare(
            this.tituloEdicaoPublicada(b),
            'pt-BR',
            { numeric: true },
          ));

        this.republicacoesPorHistoria.update((atuais) => ({ ...atuais, [historiaId]: republicacoes }));
        this.carregandoRepublicacoes.set(null);
        this.historiaExpandida.set(historiaId);
      },
      error: () => {
        if (this.edicaoDetalhe()?.id !== edicaoAtualId) {
          return;
        }
        this.carregandoRepublicacoes.set(null);
        this.mensagem.set('Não foi possível consultar as outras edições desta história.');
      },
    });
  }

  rotuloTipoConteudo(tipo: TipoConteudoEdicao) {
    const rotulos: Record<string, string> = {
      HISTORIA: 'História',
      POSTER: 'Pôster',
      GALERIA: 'Galeria',
      MATERIAL_EDITORIAL: 'Material editorial',
      EXTRA: 'Extra',
      CAPA: 'Capa',
      PINUP: 'Pin-up',
      EDITORIAL: 'Editorial',
      CHECKLIST: 'Checklist',
      ENTREVISTA: 'Entrevista',
      MATERIA: 'Matéria',
      PROPAGANDA: 'Propaganda',
      OUTRO: 'Outro',
    };
    return rotulos[tipo] || tipo;
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

  publicacoesOriginaisAgrupadas() {
    const grupos = new Map<number, { edicao: Edicao; historias: Set<number> }>();
    for (const publicacao of this.publicacoesDetalhe()) {
      const existente = grupos.get(publicacao.edicaoOriginal.id);
      if (existente) {
        existente.historias.add(publicacao.historia.id);
      } else {
        grupos.set(publicacao.edicaoOriginal.id, {
          edicao: publicacao.edicaoOriginal,
          historias: new Set([publicacao.historia.id]),
        });
      }
    }
    return [...grupos.values()].map((grupo) => ({
      edicao: grupo.edicao,
      quantidadeHistorias: grupo.historias.size,
    }));
  }

  anoEdicao(edicao: Edicao | null | undefined) {
    const data = edicao?.dataPublicacao || edicao?.dataCobertura;
    return data ? Number(data.slice(0, 4)) : null;
  }

  abrirDetalheOriginalAgrupada(edicao: Edicao) {
    this.abrirDetalhePorId(edicao.id);
  }

  abrirPublicacoesBrasil(edicao: Edicao, evento: Event) {
    this.focoAntesDasPublicacoesBrasil = evento.currentTarget as HTMLElement;
    this.originalPublicacoesAberta.set(edicao);
    this.publicacaoHistoriasAberta.set(null);
    this.carregarPublicacoesBrasil(edicao.id);
    setTimeout(() => this.modalPublicacoesBrasil?.nativeElement.focus(), 0);
  }

  tentarNovamentePublicacoesBrasil() {
    const original = this.originalPublicacoesAberta();
    if (original) this.carregarPublicacoesBrasil(original.id);
  }

  fecharPublicacoesBrasil(restaurarFoco = true) {
    this.originalPublicacoesAberta.set(null);
    this.publicacoesBrasil.set(null);
    this.carregandoPublicacoesBrasil.set(false);
    this.erroPublicacoesBrasil.set(false);
    this.publicacaoHistoriasAberta.set(null);
    if (restaurarFoco) setTimeout(() => this.focoAntesDasPublicacoesBrasil?.focus(), 0);
  }

  abrirPublicacaoBrasileira(publicacao: PublicacaoBrasileiraResumo) {
    if (publicacao.id === this.edicaoDetalhe()?.id) return;
    this.fecharPublicacoesBrasil(false);
    this.abrirDetalhePorId(publicacao.id);
  }

  alternarHistoriasPublicacao(edicaoId: number) {
    this.publicacaoHistoriasAberta.update((atual) => atual === edicaoId ? null : edicaoId);
  }

  adicionarPublicacaoBrasileiraNaEstante(publicacao: PublicacaoBrasileiraResumo) {
    this.fecharPublicacoesBrasil(false);
    this.abrirModalAdicionarNaEstante({
      id: publicacao.id,
      idExterno: null,
      fonte: 'HQ_HUB',
      titulo: publicacao.titulo,
      numero: publicacao.numero,
      nomeVolume: publicacao.colecao,
      serieVolume: publicacao.volume,
      urlCapa: publicacao.capa,
      dataPublicacao: publicacao.ano ? `${publicacao.ano}-01-01` : null,
      jaCadastrada: true,
      urlOrigem: null,
    });
  }

  navegarTecladoModalPublicacoes(evento: KeyboardEvent) {
    if (evento.key === 'Escape') {
      evento.preventDefault();
      this.fecharPublicacoesBrasil();
      return;
    }
    if (evento.key !== 'Tab') return;
    const elementos = [...(this.modalPublicacoesBrasil?.nativeElement.querySelectorAll<HTMLElement>(
      'button:not([disabled]), [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
    ) || [])];
    if (!elementos.length) return;
    const primeiro = elementos[0];
    const ultimo = elementos[elementos.length - 1];
    if (evento.shiftKey && document.activeElement === primeiro) {
      evento.preventDefault();
      ultimo.focus();
    } else if (!evento.shiftKey && document.activeElement === ultimo) {
      evento.preventDefault();
      primeiro.focus();
    }
  }

  private carregarPublicacoesBrasil(edicaoOriginalId: number) {
    this.carregandoPublicacoesBrasil.set(true);
    this.erroPublicacoesBrasil.set(false);
    this.publicacoesBrasil.set(null);
    this.api.listarPublicacoesBrasileirasDaOriginal(edicaoOriginalId).subscribe({
      next: (resultado) => {
        if (this.originalPublicacoesAberta()?.id !== edicaoOriginalId) return;
        this.publicacoesBrasil.set(resultado);
        this.carregandoPublicacoesBrasil.set(false);
      },
      error: () => {
        if (this.originalPublicacoesAberta()?.id !== edicaoOriginalId) return;
        this.carregandoPublicacoesBrasil.set(false);
        this.erroPublicacoesBrasil.set(true);
      },
    });
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
          this.persistirCapaComicVine(edicao, detalhe.urlImagem);
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
          this.persistirCapaComicVine(edicao, detalhe.urlImagem);
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
    const sequencia = ++this.sequenciaBuscaResultados;
    const termoBusca = this.busca.trim();
    if (!termoBusca && !this.serieSelecionada()) {
      this.resultadosCatalogo.set({ itens: [], pagina: 0, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
      this.mensagem.set('Digite um termo para pesquisar no catálogo.');
      return;
    }

    this.resultadosConsultados.set(true);
    this.carregandoResultados.set(true);
    this.mensagem.set('Pesquisando catálogo...');

    const termo = this.serieSelecionada()?.titulo || termoBusca;
    if (this.serieSelecionada()) {
      this.api.listarEdicoes('', pagina, this.tamanhoResultados, this.serieSelecionada()!.id).subscribe({
        next: (resposta) => {
          if (sequencia !== this.sequenciaBuscaResultados) return;
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
          if (sequencia !== this.sequenciaBuscaResultados) return;
          this.resultadosCatalogo.set({ itens: [], pagina, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
          this.carregandoResultados.set(false);
          this.mensagem.set('Não foi possível carregar as edições desta série agora.');
        },
      });
      return;
    }

    this.api.pesquisarCatalogo(termo, pagina, this.tamanhoResultados).subscribe({
      next: (resposta) => {
        if (sequencia !== this.sequenciaBuscaResultados) return;
        this.resultadosCatalogo.set(resposta);
        this.paginaResultados.set(resposta.pagina);
        this.carregandoResultados.set(false);
        if (rolarAoResultadoMobile) {
          this.rolarParaResultadosMobile();
        }
        this.mensagem.set(resposta.itens.length ? '' : `Nenhum resultado encontrado para "${termo}".`);
      },
      error: () => {
        if (sequencia !== this.sequenciaBuscaResultados) return;
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
      this.tituloColecao?.nativeElement.focus({ preventScroll: true });
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

  private persistirCapaComicVine(edicao: Edicao, urlImagem: string | null) {
    if (!urlImagem || edicao.urlCapa || !this.podeEditarCatalogo()) {
      return;
    }
    this.api.atualizarCapaEdicao(edicao.id, urlImagem).subscribe({
      next: (atualizada) => {
        if (this.edicaoDetalhe()?.id === atualizada.id) {
          this.edicaoDetalhe.set(atualizada);
        }
        this.resultadosCatalogo.update((pagina) => ({
          ...pagina,
          itens: pagina.itens.map((item) => item.id === atualizada.id ? { ...item, urlCapa: atualizada.urlCapa } : item),
        }));
      },
      error: () => undefined,
    });
  }

  private formularioConteudoVazio(): {
    titulo: string;
    tituloOriginal: string;
    descricao: string;
    ordem: number | null;
    quantidadePaginas: number | null;
    tipo: TipoConteudoEdicao;
    tituloUsado: string;
    urlOrigem: string;
    observacoes: string;
  } {
    return {
      titulo: '',
      tituloOriginal: '',
      descricao: '',
      ordem: null,
      quantidadePaginas: null,
      tipo: 'HISTORIA',
      tituloUsado: '',
      urlOrigem: '',
      observacoes: '',
    };
  }

  private ordenarConteudos(conteudos: ConteudoEdicao[]) {
    return [...conteudos].sort((a, b) => a.ordem - b.ordem || a.id - b.id);
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
    return (valor || '')
      .trim()
      .toLocaleLowerCase('pt-BR')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
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
