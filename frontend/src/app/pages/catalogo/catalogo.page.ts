import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { forkJoin } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import {
  ConteudoEdicao,
  Edicao,
  EdicaoComicVine,
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

    <section class="barra-busca">
      <input
        [(ngModel)]="busca"
        placeholder="Buscar HQ no catálogo ou na Comic Vine"
        (keyup.enter)="carregar()"
      />
      <button class="botao primario" type="button" (click)="carregar()" [disabled]="carregandoResultados()">
        {{ carregandoResultados() ? 'Buscando...' : 'Buscar' }}
      </button>
    </section>

    @if (mensagem()) {
      <section class="estado-pesquisa">
        <p>{{ mensagem() }}</p>
      </section>
    }

    <section class="catalogo-layout">
      <article class="bloco">
        <div class="secao-titulo">
          <div>
            <h2>Séries internas</h2>
            <p class="texto-suave">Acervo já cadastrado no HQ-HUB.</p>
          </div>
          <span>{{ series().totalItens }} itens</span>
        </div>

        <div class="controles-series">
          <input
            [(ngModel)]="buscaSeries"
            placeholder="Filtrar séries internas"
            (ngModelChange)="agendarBuscaSeries()"
          />
          <div class="indice-alfabetico" aria-label="Filtro alfabético de séries">
            <button type="button" [class.ativo]="inicialSeries() === ''" (click)="alterarInicialSeries('')">Todas</button>
            @for (letra of letrasIndice; track letra) {
              <button type="button" [class.ativo]="inicialSeries() === letra" (click)="alterarInicialSeries(letra)">
                {{ letra }}
              </button>
            }
          </div>
        </div>

        <div class="lista-linhas">
          @for (serie of series().itens; track serie.id) {
            <button type="button" [class.ativo]="serieSelecionada()?.id === serie.id" (click)="selecionarSerie(serie)">
              <strong>{{ serie.titulo }}</strong>
              <span>{{ serie.editora?.nome || 'Sem editora' }} · V{{ serie.volume || '-' }}</span>
            </button>
          } @empty {
            <section class="estado-vazio compacto">
              <h2>Nenhuma série interna cadastrada</h2>
              <p>Esta área mostra apenas os títulos já salvos no banco do HQ-HUB.</p>
            </section>
          }
        </div>

        @if (series().totalPaginas > 1) {
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

      <article class="bloco">
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
                [alt]="resultado.titulo || resultado.numero || 'Edição'"
                loading="lazy"
                (error)="usarCapaReserva($event)"
              />
              <strong>#{{ resultado.numero || '-' }}</strong>
              <span>{{ resultado.titulo || resultado.nomeVolume || 'Sem título' }}</span>
              <small>{{ resultado.nomeVolume || 'Volume não informado' }}</small>
              <em>{{ rotuloFonte(resultado) }}</em>
              @if (resultado.jaCadastrada && resultado.id) {
                <button class="botao compacto" type="button" (click)="abrirInterna(resultado)">
                  Ver detalhes
                </button>
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

    @if (edicaoDetalhe()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da edição">
        <div class="detalhe-fundo" (click)="fecharDetalhe()"></div>
        <article class="detalhe-painel">
          <button class="fechar-detalhe" type="button" (click)="fecharDetalhe()" aria-label="Fechar detalhes">×</button>
          @if (historicoDetalhes().length) {
            <button class="botao compacto voltar-detalhe" type="button" (click)="voltarDetalheAnterior()">
              Voltar
            </button>
          }

          <div class="detalhe-cabecalho">
            <img [src]="capaEdicaoDetalhe() || capaReserva" [alt]="tituloEdicao(edicaoDetalhe()!)" (error)="usarCapaReserva($event)" />
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
                @if (edicaoDetalhe()?.precoCapa) {
                  <span>{{ formatarMoeda(edicaoDetalhe()?.precoCapa || 0) }}</span>
                }
              </div>
              <div
                class="descricao-formatada"
                [innerHTML]="formatarDescricao(descricaoEdicaoDetalhe())"
              ></div>
              @if (podeEditarCatalogo()) {
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
                </div>
              }
            </div>
          </div>

          @if (editandoDetalhe()) {
            <section class="painel-formulario editor-edicao-detalhe">
              <h2>Dados editoriais da edicao</h2>
              <div class="grade-formulario">
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

          @if (publicacoesDetalhe().length || !publicacoesComoOriginal().length) {
            <section class="detalhe-secao">
              <h3>Histórias publicadas nesta edição</h3>
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
                  </div>
                </article>
              } @empty {
                <p class="texto-suave">Nenhuma publicação brasileira vinculada a esta edição ainda.</p>
              }
            </section>
          }

          @if (publicacoesComoOriginal().length || !publicacoesDetalhe().length) {
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
        </article>
      </section>
    }
  `,
})
export class CatalogoPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);
  private readonly sanitizador = inject(DomSanitizer);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly letrasIndice = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  readonly podeEditarCatalogo = this.autenticacao.podeRevisarCatalogo;
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
  readonly historiaEmFoco = signal<number | null>(null);
  readonly detalheComicVineInterno = signal<EdicaoComicVine | null>(null);
  readonly capasComicVineOriginais = signal<Record<number, string>>({});
  readonly carregandoResultados = signal(false);
  readonly carregandoDetalhe = signal(false);
  readonly editandoDetalhe = signal(false);
  readonly salvandoDetalhe = signal(false);
  readonly mensagem = signal('');
  readonly paginaResultados = signal(0);
  readonly inicialSeries = signal('');
  readonly tamanhoResultados = 20;
  readonly tamanhoSeries = 12;
  busca = '';
  buscaSeries = '';
  formularioEdicao = this.formularioEdicaoVazio();
  private temporizadorBuscaSeries: ReturnType<typeof setTimeout> | null = null;

  ngOnInit() {
    this.carregarSeriesInternas();
    this.carregar();
  }

  carregar() {
    this.paginaResultados.set(0);
    this.buscarResultados(0);
  }

  selecionarSerie(serie: Serie) {
    this.serieSelecionada.set(serie);
    this.busca = serie.titulo;
    this.paginaResultados.set(0);
    this.buscarResultados(0);
  }

  agendarBuscaSeries() {
    if (this.temporizadorBuscaSeries) {
      clearTimeout(this.temporizadorBuscaSeries);
    }

    this.temporizadorBuscaSeries = setTimeout(() => this.carregarSeriesInternas(0), 300);
  }

  alterarInicialSeries(inicial: string) {
    this.inicialSeries.set(inicial);
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
      this.buscarResultados(this.paginaResultados() - 1);
    }
  }

  proximaPagina() {
    if (this.paginaResultados() + 1 < this.resultadosCatalogo().totalPaginas) {
      this.buscarResultados(this.paginaResultados() + 1);
    }
  }

  rotuloFonte(resultado: ResultadoPesquisaCatalogo) {
    return resultado.fonte === 'HQ_HUB' ? 'Catálogo HQ-HUB' : 'Comic Vine';
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

  abrirDetalhePorId(edicaoId: number, historiaId: number | null = null) {
    this.carregandoDetalhe.set(true);
    this.mensagem.set('');
    forkJoin({
      edicao: this.api.buscarEdicaoPorId(edicaoId),
      conteudos: this.api.listarConteudosPorEdicao(edicaoId),
      publicacoes: this.api.listarPublicacoesPorEdicaoPublicada(edicaoId),
      publicacoesOriginais: this.api.listarPublicacoesPorEdicaoOriginal(edicaoId),
    }).subscribe({
      next: ({ edicao, conteudos, publicacoes, publicacoesOriginais }) => {
        const atual = this.edicaoDetalhe();
        if (atual && atual.id !== edicao.id) {
          this.historicoDetalhes.update((historico) => [...historico, atual]);
        }
        this.editandoDetalhe.set(false);
        this.edicaoDetalhe.set(edicao);
        this.formularioEdicao = this.formularioAPartirDaEdicao(edicao);
        this.conteudosDetalhe.set(conteudos);
        this.publicacoesDetalhe.set(publicacoes);
        this.publicacoesComoOriginal.set(this.filtrarPublicacoesComoOriginal(publicacoesOriginais, historiaId));
        this.historiaEmFoco.set(historiaId);
        this.carregarCapasOriginaisComicVine(publicacoes);
        this.carregarComplementoComicVine(edicao);
        this.carregandoDetalhe.set(false);
      },
      error: () => {
        this.carregandoDetalhe.set(false);
        this.mensagem.set('Não foi possível carregar os detalhes desta edição.');
      },
    });
  }

  fecharDetalhe() {
    this.edicaoDetalhe.set(null);
    this.editandoDetalhe.set(false);
    this.salvandoDetalhe.set(false);
    this.formularioEdicao = this.formularioEdicaoVazio();
    this.conteudosDetalhe.set([]);
    this.publicacoesDetalhe.set([]);
    this.publicacoesComoOriginal.set([]);
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
    this.abrirDetalhePorId(anterior.id);
  }

  iniciarEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    if (!edicao || !this.podeEditarCatalogo()) {
      return;
    }

    this.formularioEdicao = this.formularioAPartirDaEdicao(edicao);
    this.editandoDetalhe.set(true);
  }

  cancelarEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    this.formularioEdicao = edicao ? this.formularioAPartirDaEdicao(edicao) : this.formularioEdicaoVazio();
    this.editandoDetalhe.set(false);
  }

  salvarEdicaoDetalhe() {
    const edicao = this.edicaoDetalhe();
    const numero = this.formularioEdicao.numero.trim();
    const serieId = edicao?.serie?.id;
    if (!edicao || !serieId) {
      this.mensagem.set('Nao foi possivel identificar a serie desta edicao.');
      return;
    }

    if (!numero) {
      this.mensagem.set('Informe o nÃºmero da ediÃ§Ã£o antes de salvar.');
      return;
    }

    this.salvandoDetalhe.set(true);
    this.mensagem.set('');
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
        this.edicaoDetalhe.set(atualizada);
        this.formularioEdicao = this.formularioAPartirDaEdicao(atualizada);
        this.resultadosCatalogo.update((pagina) => ({
          ...pagina,
          itens: pagina.itens.map((resultado) => resultado.id === atualizada.id ? this.paraResultadoInterno(atualizada) : resultado),
        }));
        this.editandoDetalhe.set(false);
        this.salvandoDetalhe.set(false);
        this.mensagem.set('Dados da edicao atualizados.');
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
      || publicacao.edicaoPublicada.urlCapa
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

    const termo = this.termoBuscaComicVine(edicao);
    if (!termo) {
      return;
    }

    this.api.buscarEdicoesComicVinePorTermo(termo, 0, 20).subscribe({
      next: (resposta) => {
        const resultado = resposta.itens.find((item) => this.resultadoComicVineCombina(edicao, item));
        if (resultado?.idExterno) {
          this.carregarDetalheComicVine(edicao, resultado.idExterno);
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

    const termo = this.termoBuscaComicVine(edicao);
    if (!termo) {
      return;
    }

    this.api.buscarEdicoesComicVinePorTermo(termo, 0, 20).subscribe({
      next: (resposta) => {
        const resultado = resposta.itens.find((item) => this.resultadoComicVineCombina(edicao, item));
        if (resultado?.idExterno) {
          this.carregarDetalheComicVineParaCapaOriginal(edicao.id, resultado.idExterno);
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
      next: (resposta) => this.series.set(resposta),
      error: () => this.mensagem.set('Não foi possível carregar as séries internas agora.'),
    });
  }

  private buscarResultados(pagina: number) {
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
        this.mensagem.set(resposta.itens.length ? '' : `Nenhum resultado encontrado para "${termo}".`);
      },
      error: () => {
        this.resultadosCatalogo.set({ itens: [], pagina, tamanho: this.tamanhoResultados, totalItens: 0, totalPaginas: 0 });
        this.carregandoResultados.set(false);
        this.mensagem.set('Não foi possível pesquisar no catálogo agora.');
      },
    });
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
      numero: '',
      titulo: '',
      descricao: '',
      dataPublicacao: '',
      urlCapa: '',
      codigoBarras: '',
      quantidadePaginas: null as number | null,
      precoCapa: null as number | null,
      formato: '',
      urlOrigem: '',
    };
  }

  private formularioAPartirDaEdicao(edicao: Edicao) {
    return {
      numero: edicao.numero || '',
      titulo: edicao.titulo || '',
      descricao: edicao.descricao || edicao.descricaoExibicao || '',
      dataPublicacao: edicao.dataPublicacao || '',
      urlCapa: edicao.urlCapa || '',
      codigoBarras: edicao.codigoBarras || '',
      quantidadePaginas: edicao.quantidadePaginas,
      precoCapa: edicao.precoCapa,
      formato: edicao.formato || '',
      urlOrigem: edicao.urlOrigem || edicao.urlComicVine || '',
    };
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

  private filtrarPublicacoesComoOriginal(publicacoes: PublicacaoHistoria[], historiaId: number | null) {
    if (!historiaId) {
      return publicacoes;
    }

    return publicacoes.filter((publicacao) => publicacao.historia.id === historiaId);
  }

  private paraResultadoInterno(edicao: Edicao): ResultadoPesquisaCatalogo {
    return {
      id: edicao.id,
      idExterno: edicao.idComicVine || edicao.idExterno,
      fonte: 'HQ_HUB',
      titulo: edicao.titulo || edicao.serie?.titulo || null,
      numero: edicao.numero,
      nomeVolume: edicao.nomeVolume || edicao.serie?.titulo || null,
      urlCapa: edicao.urlCapa,
      dataPublicacao: edicao.dataPublicacao,
      jaCadastrada: true,
      urlOrigem: edicao.urlComicVine || edicao.urlOrigem,
    };
  }
}
