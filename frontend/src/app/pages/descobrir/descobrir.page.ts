import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { catchError, forkJoin, map, of, switchMap } from 'rxjs';

import { ApiService } from '../../core/api.service';
import {
  CalculoInflacao,
  ConteudoEdicao,
  Edicao,
  EdicaoComicVine,
  ItemColecao,
  PaginaResposta,
  PessoaComicVine,
  PublicacaoHistoria,
  PublicacaoRelacionada,
  Serie,
  VolumeComicVine,
} from '../../core/modelos';

type FonteDescoberta = 'TODAS' | 'COMIC_VINE' | 'HQ_HUB';

interface VolumeDescoberta {
  fonte: 'COMIC_VINE' | 'HQ_HUB';
  idExterno: string;
  serieId: number | null;
  titulo: string;
  editora: string | null;
  anoInicio: number | null;
  quantidadeEdicoes: number | null;
  descricao: string | null;
  urlOrigem: string | null;
  urlImagem: string | null;
}

interface EdicaoDescoberta {
  fonte: 'COMIC_VINE' | 'HQ_HUB';
  idExterno: string | null;
  idInterno: number | null;
  numero: string | null;
  titulo: string | null;
  nomeVolume: string | null;
  idVolume: string | null;
  dataCapa: string | null;
  dataVenda: string | null;
  descricao: string | null;
  descricaoExibicao: string | null;
  urlOrigem: string | null;
  urlImagem: string | null;
  creditos: { idExterno: string | null; nome: string | null; papel: string | null; urlOrigem: string | null }[];
  personagens: string[];
  conteudos: string[];
}

@Component({
  selector: 'app-descobrir-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Descobrir</p>
        <h1>Encontre títulos e carregue edições em ordem cronológica.</h1>
      </div>
    </section>

    <section class="barra-busca">
      <input [(ngModel)]="termo" placeholder="Amazing Spider-Man, Batman, Saga do Batman..." (keyup.enter)="buscarVolumes()" />
      <button class="botao primario" type="button" (click)="buscarVolumes()" [disabled]="carregandoVolumes()">
        {{ carregandoVolumes() ? 'Buscando...' : 'Buscar' }}
      </button>
    </section>

    <div class="alternador descobrir-fontes">
      <button type="button" [class.ativo]="fontePesquisa() === 'TODAS'" (click)="alterarFonte('TODAS')">Todas</button>
      <button type="button" [class.ativo]="fontePesquisa() === 'COMIC_VINE'" (click)="alterarFonte('COMIC_VINE')">Comic Vine</button>
      <button type="button" [class.ativo]="fontePesquisa() === 'HQ_HUB'" (click)="alterarFonte('HQ_HUB')">HQ-HUB</button>
    </div>

    @if (mensagem()) {
      <section class="estado-pesquisa">
        <p>{{ mensagem() }}</p>
      </section>
    }

    <section class="grade-volumes">
      @for (volume of volumes().itens; track chaveVolume(volume)) {
        <article class="cartao-volume" [class.selecionado]="volumeSelecionado()?.idExterno === volume.idExterno && volumeSelecionado()?.fonte === volume.fonte">
          <img [src]="volume.urlImagem || capaReserva" [alt]="volume.titulo" loading="lazy" (error)="usarCapaReserva($event)" />
          <div>
            <p class="rotulo">{{ rotuloFonteVolume(volume) }} · {{ volume.editora || 'Editora não informada' }}</p>
            <h2>{{ volume.titulo }}</h2>
            <p>{{ volume.anoInicio || 'Ano não informado' }} · {{ volume.quantidadeEdicoes ?? 'quantidade não informada' }} edições</p>
            <button class="botao compacto" type="button" (click)="selecionarVolume(volume)" [disabled]="carregandoEdicoes()">
              {{ carregandoEdicoes() && volumeSelecionado()?.idExterno === volume.idExterno ? 'Carregando...' : 'Ver edições' }}
            </button>
          </div>
        </article>
      } @empty {
        @if (!carregandoVolumes()) {
          <section class="estado-vazio compacto">
            <h2>Nenhum título carregado</h2>
            <p>Digite um termo e escolha se deseja pesquisar na Comic Vine, no HQ-HUB ou nas duas bases.</p>
          </section>
        }
      }
    </section>

    @if (volumeSelecionado()) {
      <section class="secao-edicoes" id="edicoes-volume">
        <div class="secao-titulo">
          <div>
            <p class="rotulo">{{ rotuloFonteVolume(volumeSelecionado()!) }}</p>
            <h2>{{ volumeSelecionado()?.titulo }}</h2>
          </div>
          <div class="paginacao">
            <button class="botao icone-texto" type="button" [disabled]="paginaEdicoes() === 0 || carregandoEdicoes()" (click)="mudarPagina(-1)">
              Anterior
            </button>
            <span>Página {{ paginaEdicoes() + 1 }} de {{ edicoes()?.totalPaginas || 1 }}</span>
            <button class="botao icone-texto" type="button" [disabled]="carregandoEdicoes() || paginaEdicoes() + 1 >= (edicoes()?.totalPaginas || 1)" (click)="mudarPagina(1)">
              Próxima
            </button>
          </div>
        </div>

        @if (volumeSelecionado()?.fonte === 'COMIC_VINE') {
          <section class="filtro-criador">
            <label>
              Buscar autor, desenhista, editor...
              <input [(ngModel)]="termoPessoa" placeholder="Joe Quesada, Stan Lee, Steve Ditko..." (keyup.enter)="buscarPessoas()" />
            </label>
            <label>
              Papel
              <input [(ngModel)]="papelPessoa" placeholder="roteirista, desenhista, editor..." />
            </label>
            <button class="botao compacto" type="button" (click)="buscarPessoas()" [disabled]="buscandoPessoas()">
              {{ buscandoPessoas() ? 'Buscando...' : 'Buscar pessoa' }}
            </button>
            @if (pessoaFiltro()) {
              <button class="botao compacto" type="button" (click)="limparFiltroPessoa()">
                Limpar: {{ pessoaFiltro()?.nome }}
              </button>
            }
          </section>
        }

        @if (pessoasEncontradas().length) {
          <section class="pessoas-encontradas">
            @for (pessoa of pessoasEncontradas(); track pessoa.idExterno) {
              <button type="button" (click)="selecionarPessoaFiltro(pessoa)">
                <img [src]="pessoa.urlImagem || capaReserva" [alt]="pessoa.nome || 'Pessoa'" loading="lazy" (error)="usarCapaReserva($event)" />
                <span>{{ pessoa.nome }}</span>
              </button>
            }
          </section>
        }

        @if (carregandoEdicoes()) {
          <section class="estado-carregando">
            <span></span>
            <p>Buscando edições em ordem cronológica...</p>
          </section>
        } @else if (edicoes()?.itens?.length) {
          <div class="grade-edicoes">
            @for (edicao of edicoes()?.itens || []; track chaveEdicao(edicao)) {
              <article class="cartao-edicao clicavel" (click)="abrirDetalhesEdicao(edicao)" tabindex="0" (keyup.enter)="abrirDetalhesEdicao(edicao)">
                <img
                  [src]="edicao.urlImagem || capaReserva"
                  [alt]="edicao.titulo || 'Edição sem título'"
                  loading="lazy"
                  (error)="usarCapaReserva($event)"
                />
                <div>
                  <p class="rotulo">#{{ edicao.numero || '-' }} · {{ edicao.dataCapa || 'sem data' }} · {{ rotuloFonteEdicao(edicao) }}</p>
                  <h3>{{ edicao.titulo || edicao.nomeVolume }}</h3>
                  <p>{{ limitarTexto(edicao.descricaoExibicao || edicao.descricao, 170) }}</p>
                  @if (edicao.creditos.length) {
                    <small>{{ listarCreditos(edicao) }}</small>
                  }
                </div>
              </article>
            }
          </div>
        } @else {
          <section class="estado-vazio">
            <h2>Nenhuma edição retornada</h2>
            <p>Tente outro volume ou refaça a busca.</p>
          </section>
        }
      </section>
    }

    @if (edicaoSelecionada()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da edição">
        <div class="detalhe-fundo" (click)="fecharDetalhesEdicao()"></div>
        <article class="detalhe-painel">
          <button class="fechar-detalhe" type="button" (click)="fecharDetalhesEdicao()" aria-label="Fechar detalhes">×</button>
          <div class="detalhe-cabecalho">
            <img
              [src]="edicaoSelecionada()?.urlImagem || capaReserva"
              [alt]="edicaoSelecionada()?.titulo || 'Capa da edição'"
              (error)="usarCapaReserva($event)"
            />
            <div>
              <p class="rotulo">Comic Vine · {{ edicaoSelecionada()?.nomeVolume }}</p>
              <h2>#{{ edicaoSelecionada()?.numero }} {{ edicaoSelecionada()?.titulo || '' }}</h2>
              <div class="chips">
                <span>Data de capa: {{ edicaoSelecionada()?.dataCapa || 'não informada' }}</span>
                <span>Data de venda: {{ edicaoSelecionada()?.dataVenda || 'não informada' }}</span>
              </div>
              @if (edicaoSelecionada()?.urlOrigem) {
                <a class="botao compacto" [href]="edicaoSelecionada()?.urlOrigem" target="_blank" rel="noreferrer">
                  Abrir fonte
                </a>
              }
            </div>
          </div>

          <section class="detalhe-secao">
            <h3>Descrição</h3>
            <p>{{ edicaoSelecionada()?.descricaoExibicao || edicaoSelecionada()?.descricao || 'Sem descrição disponível.' }}</p>
          </section>

          <section class="detalhe-secao">
            <h3>Conteúdos da edição</h3>
            <div class="lista-conteudos">
              @for (conteudo of edicaoSelecionada()?.conteudos || []; track conteudo) {
                <span>{{ conteudo }}</span>
              } @empty {
                <p class="texto-suave">Nenhum conteúdo interno retornado pela Comic Vine.</p>
              }
            </div>
          </section>

          <section class="detalhe-secao painel-compra">
            <div>
              <h3>Controle da sua compra</h3>
              @if (carregandoItemColecao()) {
                <p class="texto-suave">Verificando sua coleção...</p>
              } @else if (itemColecaoSelecionado()) {
                <p class="compra-confirmada">
                  Comprado dia {{ formatarData(itemColecaoSelecionado()?.dataAquisicao) }}
                </p>
                <p class="texto-suave">
                  {{ rotuloLeitura(itemColecaoSelecionado()?.statusLeitura) }}
                  @if (itemColecaoSelecionado()?.precoPago) {
                    · {{ formatarMoeda(itemColecaoSelecionado()?.precoPago || 0) }}
                  }
                </p>
              } @else {
                <p class="texto-suave">Ainda não consta na sua coleção. Quando você cadastrar essa edição, o aviso de compra aparece aqui.</p>
              }
            </div>
          </section>

          <section class="detalhe-secao calculadora-inflacao">
            <h3>Calculadora de inflação</h3>
            <div class="formulario-inline">
              <label>
                Valor da época
                <input type="number" min="0" step="0.01" [(ngModel)]="valorInflacao" placeholder="Ex.: 4.90" />
              </label>
              <label>
                Data de referência
                <input type="date" [(ngModel)]="dataInflacao" />
              </label>
              <button class="botao compacto" type="button" (click)="calcularInflacao()" [disabled]="calculandoInflacao()">
                {{ calculandoInflacao() ? 'Calculando...' : 'Calcular' }}
              </button>
            </div>
            @if (mensagemInflacao()) {
              <p class="mensagem-erro compacto">{{ mensagemInflacao() }}</p>
            }
            @if (calculoInflacao()) {
              <div class="resultado-inflacao">
                <strong>{{ formatarMoeda(calculoInflacao()?.valorOriginal || 0) }}</strong>
                <span>equivalem hoje a</span>
                <strong>{{ formatarMoeda(calculoInflacao()?.valorCorrigido || 0) }}</strong>
                <small>{{ calculoInflacao()?.percentualAcumulado }}% acumulado pelo {{ calculoInflacao()?.indice }}</small>
              </div>
            }
          </section>

          <section class="detalhe-duas-colunas">
            <div class="detalhe-secao">
              <h3>Créditos</h3>
              @for (credito of edicaoSelecionada()?.creditos || []; track $index) {
                <p class="linha-info">
                  <button class="link-pessoa" type="button" (click)="abrirDetalhesPessoa(credito)">
                    {{ credito.nome }}
                  </button>
                  <span>{{ credito.papel || 'participação' }}</span>
                </p>
              } @empty {
                <p class="texto-suave">Nenhum crédito retornado pela Comic Vine.</p>
              }
            </div>

            <div class="detalhe-secao">
              <h3>Personagens</h3>
              <div class="chips">
                @for (personagem of edicaoSelecionada()?.personagens || []; track personagem) {
                  <span>{{ personagem }}</span>
                } @empty {
                  <span>Nenhum personagem informado.</span>
                }
              </div>
            </div>
          </section>

          <section class="detalhe-secao">
            <h3>Republicações e publicações brasileiras</h3>
            @if (carregandoPublicacoes()) {
              <p class="texto-suave">Consultando republicações cadastradas...</p>
            } @else {
              @for (publicacao of publicacoesRelacionadas(); track publicacao.id) {
                <article class="publicacao-card">
                  <img
                    class="capa-publicacao"
                    [src]="publicacao.edicaoDestino.urlCapa || publicacao.edicaoOrigem.urlCapa || capaReserva"
                    [alt]="tituloPublicacao(publicacao)"
                    loading="lazy"
                    (error)="usarCapaReserva($event)"
                  />
                  <div>
                    <p class="rotulo">{{ publicacao.tipo }}</p>
                    <h4>{{ tituloPublicacao(publicacao) }}</h4>
                    <p>{{ publicacao.observacoes || 'Sem observações.' }}</p>
                  </div>
                  @if (publicacao.urlOrigem) {
                    <a class="botao compacto" [href]="publicacao.urlOrigem" target="_blank" rel="noreferrer">Fonte</a>
                  }
                </article>
              } @empty {
                <section class="estado-vazio compacto">
                  <h2>Nenhuma republicação cadastrada ainda</h2>
                  <p>Quando esta edição for importada ou vinculada ao catálogo brasileiro, as republicações aparecerão aqui.</p>
                </section>
              }
            }
          </section>
        </article>
      </section>
    }

    @if (edicaoDetalhe()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da edição interna">
        <div class="detalhe-fundo" (click)="fecharDetalheInterno()"></div>
        <article class="detalhe-painel">
          <button class="fechar-detalhe" type="button" (click)="fecharDetalheInterno()" aria-label="Fechar detalhes">×</button>
          @if (historicoDetalhes().length) {
            <button class="botao compacto voltar-detalhe" type="button" (click)="voltarDetalheAnterior()">
              Voltar
            </button>
          }

          <div class="detalhe-cabecalho">
            <img [src]="capaEdicaoDetalhe() || capaReserva" [alt]="tituloEdicaoInterna(edicaoDetalhe()!)" (error)="usarCapaReserva($event)" />
            <div>
              <p class="rotulo">HQ-HUB · {{ edicaoDetalhe()?.serie?.editora?.nome || 'Editora não informada' }}</p>
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
            </div>
          </div>

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
                          {{ rotuloFonteEdicaoInterna(publicacao.edicaoOriginal) }}
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

    @if (pessoaSelecionada()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da pessoa">
        <div class="detalhe-fundo" (click)="fecharDetalhesPessoa()"></div>
        <article class="detalhe-painel pessoa-painel">
          <button class="fechar-detalhe" type="button" (click)="fecharDetalhesPessoa()" aria-label="Fechar detalhes">×</button>
          <div class="detalhe-cabecalho">
            <img [src]="pessoaSelecionada()?.urlImagem || capaReserva" [alt]="pessoaSelecionada()?.nome || 'Pessoa'" (error)="usarCapaReserva($event)" />
            <div>
              <p class="rotulo">Comic Vine · pessoa</p>
              <h2>{{ pessoaSelecionada()?.nome }}</h2>
              <div class="chips">
                <span>{{ pessoaSelecionada()?.genero || 'gênero não informado' }}</span>
                <span>Nascimento: {{ pessoaSelecionada()?.dataNascimento || 'não informado' }}</span>
                <span>{{ pessoaSelecionada()?.pais || 'país não informado' }}</span>
              </div>
              @if (pessoaSelecionada()?.urlOrigem) {
                <a class="botao compacto" [href]="pessoaSelecionada()?.urlOrigem" target="_blank" rel="noreferrer">
                  Abrir Comic Vine
                </a>
              }
            </div>
          </div>
          <section class="detalhe-secao">
            <h3>Biografia</h3>
            <p>{{ pessoaSelecionada()?.descricao || 'Biografia não disponível.' }}</p>
          </section>
        </article>
      </section>
    }
  `,
})
export class DescobrirPage {
  private readonly api = inject(ApiService);
  private readonly sanitizador = inject(DomSanitizer);

  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly fontePesquisa = signal<FonteDescoberta>('TODAS');
  readonly volumes = signal<PaginaResposta<VolumeDescoberta>>({
    itens: [],
    pagina: 0,
    tamanho: 12,
    totalItens: 0,
    totalPaginas: 0,
  });
  readonly edicoes = signal<PaginaResposta<EdicaoDescoberta> | null>(null);
  readonly volumeSelecionado = signal<VolumeDescoberta | null>(null);
  readonly paginaEdicoes = signal(0);
  readonly mensagem = signal('');
  readonly carregandoVolumes = signal(false);
  readonly carregandoEdicoes = signal(false);
  readonly edicaoSelecionada = signal<EdicaoComicVine | null>(null);
  readonly edicaoDetalhe = signal<Edicao | null>(null);
  readonly historicoDetalhes = signal<Edicao[]>([]);
  readonly conteudosDetalhe = signal<ConteudoEdicao[]>([]);
  readonly publicacoesDetalhe = signal<PublicacaoHistoria[]>([]);
  readonly publicacoesComoOriginal = signal<PublicacaoHistoria[]>([]);
  readonly historiaEmFoco = signal<number | null>(null);
  readonly detalheComicVineInterno = signal<EdicaoComicVine | null>(null);
  readonly capasComicVineOriginais = signal<Record<number, string>>({});
  readonly carregandoDetalhe = signal(false);
  readonly publicacoesRelacionadas = signal<PublicacaoRelacionada[]>([]);
  readonly carregandoPublicacoes = signal(false);
  readonly itemColecaoSelecionado = signal<ItemColecao | null>(null);
  readonly carregandoItemColecao = signal(false);
  readonly calculoInflacao = signal<CalculoInflacao | null>(null);
  readonly calculandoInflacao = signal(false);
  readonly mensagemInflacao = signal('');
  readonly pessoasEncontradas = signal<PessoaComicVine[]>([]);
  readonly buscandoPessoas = signal(false);
  readonly pessoaFiltro = signal<PessoaComicVine | null>(null);
  readonly pessoaSelecionada = signal<PessoaComicVine | null>(null);

  termo = 'Amazing Spider-Man';
  termoPessoa = '';
  papelPessoa = '';
  valorInflacao: number | null = null;
  dataInflacao = '';

  alterarFonte(fonte: FonteDescoberta) {
    this.fontePesquisa.set(fonte);
    this.buscarVolumes();
  }

  buscarVolumes() {
    const termoBusca = this.termo.trim();
    if (!termoBusca) {
      this.mensagem.set('Digite um título para pesquisar.');
      return;
    }

    this.mensagem.set('');
    this.carregandoVolumes.set(true);
    this.volumeSelecionado.set(null);
    this.edicoes.set(null);
    this.volumes.set({ itens: [], pagina: 0, tamanho: 12, totalItens: 0, totalPaginas: 0 });

    const fonte = this.fontePesquisa();
    const buscaComicVine$ =
      fonte === 'HQ_HUB'
        ? of(this.paginaVazia<VolumeDescoberta>())
        : this.api.buscarVolumesComicVine(termoBusca, 0, 12).pipe(
            map((resposta) => ({
              ...resposta,
              itens: resposta.itens.map((volume) => this.paraVolumeComicVine(volume)),
            })),
            catchError(() => of(this.paginaVazia<VolumeDescoberta>())),
          );

    const buscaInterna$ =
      fonte === 'COMIC_VINE'
        ? of(this.paginaVazia<VolumeDescoberta>())
        : this.buscarVolumesInternos(termoBusca);

    forkJoin({ comicVine: buscaComicVine$, interno: buscaInterna$ }).subscribe({
      next: ({ comicVine, interno }) => {
        const itens = fonte === 'TODAS' ? [...interno.itens, ...comicVine.itens] : fonte === 'HQ_HUB' ? interno.itens : comicVine.itens;
        this.volumes.set({
          itens,
          pagina: 0,
          tamanho: 12,
          totalItens: itens.length,
          totalPaginas: itens.length ? 1 : 0,
        });
        this.carregandoVolumes.set(false);
        if (!itens.length) {
          this.mensagem.set('Nenhum título encontrado para este termo.');
        }
      },
      error: () => {
        this.carregandoVolumes.set(false);
        this.mensagem.set('Não foi possível buscar títulos agora.');
      },
    });
  }

  selecionarVolume(volume: VolumeDescoberta) {
    this.mensagem.set('');
    this.edicoes.set(null);
    this.pessoasEncontradas.set([]);
    this.pessoaFiltro.set(null);
    this.volumeSelecionado.set(volume);
    this.paginaEdicoes.set(0);
    this.rolarParaEdicoes();
    this.carregarEdicoes();
  }

  mudarPagina(delta: number) {
    this.paginaEdicoes.update((pagina) => Math.max(0, pagina + delta));
    this.carregarEdicoes();
  }

  carregarEdicoes() {
    const volume = this.volumeSelecionado();
    if (!volume) {
      return;
    }

    this.mensagem.set('');
    this.carregandoEdicoes.set(true);

    if (volume.fonte === 'HQ_HUB' && volume.serieId) {
      this.api.listarEdicoes('', this.paginaEdicoes(), 24, volume.serieId).subscribe({
        next: (resposta) => {
          this.edicoes.set({
            ...resposta,
            itens: resposta.itens.map((edicao) => this.paraEdicaoInterna(edicao)),
          });
          this.carregandoEdicoes.set(false);
          this.rolarParaEdicoes();
        },
        error: () => {
          this.carregandoEdicoes.set(false);
          this.mensagem.set('Não foi possível carregar as edições do HQ-HUB.');
          this.rolarParaEdicoes();
        },
      });
      return;
    }

    this.api
      .buscarEdicoesComicVine(
        volume.idExterno,
        this.paginaEdicoes(),
        24,
        this.pessoaFiltro()?.idExterno,
        this.papelPessoa || undefined,
      )
      .subscribe({
        next: (resposta) => {
          this.edicoes.set({
            ...resposta,
            itens: resposta.itens.map((edicao) => this.paraEdicaoComicVine(edicao)),
          });
          this.carregandoEdicoes.set(false);
          this.rolarParaEdicoes();
        },
        error: () => {
          this.carregandoEdicoes.set(false);
          this.mensagem.set('Não foi possível carregar as edições deste volume.');
          this.rolarParaEdicoes();
        },
      });
  }

  buscarPessoas() {
    if (!this.termoPessoa.trim()) {
      this.mensagem.set('Informe o nome de um autor, desenhista ou editor.');
      return;
    }

    this.buscandoPessoas.set(true);
    this.api.buscarPessoasComicVine(this.termoPessoa, 0, 8).subscribe({
      next: (resposta) => {
        this.pessoasEncontradas.set(resposta.itens);
        this.buscandoPessoas.set(false);
      },
      error: () => {
        this.pessoasEncontradas.set([]);
        this.buscandoPessoas.set(false);
        this.mensagem.set('Não foi possível buscar pessoas na Comic Vine.');
      },
    });
  }

  selecionarPessoaFiltro(pessoa: PessoaComicVine) {
    this.pessoaFiltro.set(pessoa);
    this.paginaEdicoes.set(0);
    this.carregarEdicoes();
  }

  limparFiltroPessoa() {
    this.pessoaFiltro.set(null);
    this.papelPessoa = '';
    this.paginaEdicoes.set(0);
    this.carregarEdicoes();
  }

  limitarTexto(texto: string | null, limite: number) {
    if (!texto) {
      return 'Sem descrição disponível.';
    }

    return texto.length > limite ? `${texto.slice(0, limite)}...` : texto;
  }

  listarCreditos(edicao: EdicaoDescoberta) {
    return edicao.creditos
      .slice(0, 3)
      .map((credito) => [credito.nome, credito.papel].filter(Boolean).join(' · '))
      .join(' / ');
  }

  abrirDetalhesEdicao(edicao: EdicaoDescoberta) {
    if (edicao.fonte === 'HQ_HUB' && edicao.idInterno) {
      this.historicoDetalhes.set([]);
      this.abrirDetalhePorId(edicao.idInterno);
      return;
    }

    if (!edicao.idExterno) {
      return;
    }

    this.edicaoSelecionada.set(this.paraEdicaoComicVineDetalhe(edicao));
    this.publicacoesRelacionadas.set([]);
    this.carregandoPublicacoes.set(true);
    this.itemColecaoSelecionado.set(null);
    this.carregandoItemColecao.set(true);
    this.calculoInflacao.set(null);
    this.mensagemInflacao.set('');
    this.valorInflacao = null;
    this.dataInflacao = edicao.dataVenda || edicao.dataCapa || '';

    this.api.buscarDetalheEdicaoComicVine(edicao.idExterno).subscribe({
      next: (detalhe) => {
        this.edicaoSelecionada.set(detalhe);
        this.dataInflacao = detalhe.dataVenda || detalhe.dataCapa || this.dataInflacao;
      },
      error: () => {
        this.mensagem.set('Não foi possível carregar o detalhe completo da Comic Vine. Exibindo os dados da listagem.');
      },
    });

    this.api.listarPublicacoesRelacionadasPorOrigemExterna('COMICVINE', edicao.idExterno).subscribe({
      next: (publicacoes) => {
        this.publicacoesRelacionadas.set(publicacoes);
        this.carregandoPublicacoes.set(false);
      },
      error: () => {
        this.publicacoesRelacionadas.set([]);
        this.carregandoPublicacoes.set(false);
      },
    });

    this.api.buscarItemColecaoPorOrigemExterna('COMICVINE', edicao.idExterno).subscribe({
      next: (item) => {
        this.itemColecaoSelecionado.set(item);
        this.carregandoItemColecao.set(false);

        if (item?.precoPago) {
          this.valorInflacao = item.precoPago;
        }
        if (item?.dataAquisicao) {
          this.dataInflacao = item.dataAquisicao;
        }
      },
      error: () => {
        this.itemColecaoSelecionado.set(null);
        this.carregandoItemColecao.set(false);
      },
    });
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
        this.edicaoDetalhe.set(edicao);
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

  fecharDetalhesEdicao() {
    this.edicaoSelecionada.set(null);
    this.publicacoesRelacionadas.set([]);
    this.itemColecaoSelecionado.set(null);
    this.calculoInflacao.set(null);
  }

  fecharDetalheInterno() {
    this.edicaoDetalhe.set(null);
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

  abrirDetalhesPessoa(credito: { idExterno: string | null }) {
    if (!credito.idExterno) {
      return;
    }

    this.api.buscarDetalhePessoaComicVine(credito.idExterno).subscribe({
      next: (pessoa) => this.pessoaSelecionada.set(pessoa),
      error: () => this.mensagem.set('Não foi possível carregar os detalhes desta pessoa.'),
    });
  }

  fecharDetalhesPessoa() {
    this.pessoaSelecionada.set(null);
  }

  tituloPublicacao(publicacao: PublicacaoRelacionada) {
    const edicao = publicacao.edicaoDestino;
    const serie = edicao.serie?.titulo ?? 'Publicação relacionada';
    return `${serie} #${edicao.numero}${edicao.titulo ? ' · ' + edicao.titulo : ''}`;
  }

  calcularInflacao() {
    if (!this.valorInflacao || !this.dataInflacao) {
      this.mensagemInflacao.set('Informe valor e data para calcular.');
      return;
    }

    this.mensagemInflacao.set('');
    this.calculandoInflacao.set(true);
    this.api.calcularInflacao(this.valorInflacao, this.dataInflacao).subscribe({
      next: (calculo) => {
        this.calculoInflacao.set(calculo);
        this.calculandoInflacao.set(false);
      },
      error: () => {
        this.calculoInflacao.set(null);
        this.mensagemInflacao.set('Não foi possível calcular a inflação agora.');
        this.calculandoInflacao.set(false);
      },
    });
  }

  formatarData(data: string | null | undefined) {
    if (!data) {
      return 'não informada';
    }

    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'long', year: 'numeric' }).format(
      new Date(`${data}T00:00:00`),
    );
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  rotuloLeitura(status: string | null | undefined) {
    return status === 'LIDO' ? 'Lido' : 'Não lido';
  }

  usarCapaReserva(evento: Event) {
    const imagem = evento.target as HTMLImageElement;
    if (!imagem.src.endsWith(this.capaReserva)) {
      imagem.src = this.capaReserva;
    }
  }

  chaveVolume(volume: VolumeDescoberta) {
    return `${volume.fonte}-${volume.idExterno}`;
  }

  chaveEdicao(edicao: EdicaoDescoberta) {
    return `${edicao.fonte}-${edicao.idInterno || edicao.idExterno || edicao.numero}`;
  }

  rotuloFonteVolume(volume: VolumeDescoberta) {
    return volume.fonte === 'HQ_HUB' ? 'HQ-HUB' : 'Comic Vine';
  }

  rotuloFonteEdicao(edicao: EdicaoDescoberta) {
    return edicao.fonte === 'HQ_HUB' ? 'HQ-HUB' : 'Comic Vine';
  }

  tituloEdicaoInterna(edicao: Edicao) {
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

  rotuloFonteEdicaoInterna(edicao: Edicao) {
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

  private buscarVolumesInternos(termoBusca: string) {
    return this.api.listarSeries(termoBusca, 0, 12).pipe(
      catchError(() => of([] as Serie[])),
      map((resposta) => Array.isArray(resposta) ? resposta : resposta.itens),
      switchMap((series) => {
        if (!series.length) {
          return of(this.paginaVazia<VolumeDescoberta>());
        }

        const contagens$ = series.map((serie) =>
          this.api.listarEdicoes('', 0, 1, serie.id).pipe(
            map((edicoes) => this.paraVolumeInterno(serie, edicoes.totalItens, edicoes.itens[0]?.urlCapa || null)),
            catchError(() => of(this.paraVolumeInterno(serie, null))),
          ),
        );

        return forkJoin(contagens$).pipe(
          map((itens) => ({
            itens,
            pagina: 0,
            tamanho: 12,
            totalItens: itens.length,
            totalPaginas: itens.length ? 1 : 0,
          })),
        );
      }),
    );
  }

  private paraVolumeComicVine(volume: VolumeComicVine): VolumeDescoberta {
    return {
      fonte: 'COMIC_VINE',
      idExterno: volume.idExterno,
      serieId: null,
      titulo: volume.titulo,
      editora: volume.editora,
      anoInicio: volume.anoInicio,
      quantidadeEdicoes: volume.quantidadeEdicoes,
      descricao: volume.descricao,
      urlOrigem: volume.urlOrigem,
      urlImagem: volume.urlImagem,
    };
  }

  private paraVolumeInterno(serie: Serie, quantidadeEdicoes: number | null, urlImagem: string | null = null): VolumeDescoberta {
    return {
      fonte: 'HQ_HUB',
      idExterno: `serie-${serie.id}`,
      serieId: serie.id,
      titulo: serie.titulo,
      editora: serie.editora?.nome || null,
      anoInicio: serie.anoInicio,
      quantidadeEdicoes,
      descricao: serie.descricao,
      urlOrigem: serie.urlOrigem,
      urlImagem,
    };
  }

  private paraEdicaoComicVine(edicao: EdicaoComicVine): EdicaoDescoberta {
    return {
      fonte: 'COMIC_VINE',
      idExterno: edicao.idExterno,
      idInterno: null,
      numero: edicao.numero,
      titulo: edicao.titulo,
      nomeVolume: edicao.nomeVolume,
      idVolume: edicao.idVolume,
      dataCapa: edicao.dataCapa,
      dataVenda: edicao.dataVenda,
      descricao: edicao.descricao,
      descricaoExibicao: edicao.descricaoExibicao,
      urlOrigem: edicao.urlOrigem,
      urlImagem: edicao.urlImagem,
      creditos: edicao.creditos,
      personagens: edicao.personagens,
      conteudos: edicao.conteudos,
    };
  }

  private paraEdicaoInterna(edicao: Edicao): EdicaoDescoberta {
    return {
      fonte: 'HQ_HUB',
      idExterno: edicao.idComicVine || edicao.idExterno,
      idInterno: edicao.id,
      numero: edicao.numero,
      titulo: edicao.titulo || edicao.serie?.titulo || null,
      nomeVolume: edicao.nomeVolume || edicao.serie?.titulo || null,
      idVolume: edicao.serie?.id ? String(edicao.serie.id) : null,
      dataCapa: edicao.dataPublicacao || edicao.dataCobertura,
      dataVenda: edicao.dataDisponibilidadeLoja,
      descricao: edicao.descricao,
      descricaoExibicao: edicao.descricaoExibicao,
      urlOrigem: edicao.urlComicVine || edicao.urlOrigem,
      urlImagem: edicao.urlCapa,
      creditos: [],
      personagens: [],
      conteudos: [],
    };
  }

  private paraEdicaoComicVineDetalhe(edicao: EdicaoDescoberta): EdicaoComicVine {
    return {
      idExterno: edicao.idExterno || '',
      numero: edicao.numero,
      titulo: edicao.titulo,
      nomeVolume: edicao.nomeVolume,
      idVolume: edicao.idVolume,
      dataCapa: edicao.dataCapa,
      dataVenda: edicao.dataVenda,
      descricao: edicao.descricao,
      descricaoOriginal: null,
      descricaoPortugues: null,
      descricaoExibicao: edicao.descricaoExibicao,
      urlOrigem: edicao.urlOrigem,
      urlImagem: edicao.urlImagem,
      creditos: edicao.creditos,
      personagens: edicao.personagens,
      conteudos: edicao.conteudos,
    };
  }

  private filtrarPublicacoesComoOriginal(publicacoes: PublicacaoHistoria[], historiaId: number | null) {
    if (!historiaId) {
      return publicacoes;
    }

    return publicacoes.filter((publicacao) => publicacao.historia.id === historiaId);
  }

  private paginaVazia<T>(): PaginaResposta<T> {
    return { itens: [], pagina: 0, tamanho: 12, totalItens: 0, totalPaginas: 0 };
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

  private rolarParaEdicoes() {
    setTimeout(() => {
      document.getElementById('edicoes-volume')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 50);
  }
}
