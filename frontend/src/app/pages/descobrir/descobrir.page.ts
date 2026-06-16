import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import {
  CalculoInflacao,
  EdicaoComicVine,
  ItemColecao,
  PaginaResposta,
  PessoaComicVine,
  PublicacaoRelacionada,
  VolumeComicVine,
} from '../../core/modelos';

@Component({
  selector: 'app-descobrir-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Busca externa</p>
        <h1>Encontre volumes e carregue edições em ordem cronológica.</h1>
      </div>
    </section>

    <section class="barra-busca">
      <input [(ngModel)]="termo" placeholder="Amazing Spider-Man, Batman, X-Men..." (keyup.enter)="buscarVolumes()" />
      <button class="botao primario" type="button" (click)="buscarVolumes()">Buscar</button>
    </section>

    @if (mensagem()) {
      <p class="mensagem-erro">{{ mensagem() }}</p>
    }

    <section class="grade-volumes">
      @for (volume of volumes().itens; track volume.idExterno) {
        <article class="cartao-volume" [class.selecionado]="volumeSelecionado()?.idExterno === volume.idExterno">
          <img [src]="volume.urlImagem || capaReserva" [alt]="volume.titulo" loading="lazy" />
          <div>
            <p class="rotulo">{{ volume.editora || 'Editora não informada' }}</p>
            <h2>{{ volume.titulo }}</h2>
            <p>{{ volume.anoInicio || 'Ano não informado' }} · {{ volume.quantidadeEdicoes || 0 }} edições</p>
            <button class="botao compacto" type="button" (click)="selecionarVolume(volume)" [disabled]="carregandoEdicoes()">
              {{ carregandoEdicoes() && volumeSelecionado()?.idExterno === volume.idExterno ? 'Carregando...' : 'Ver edições' }}
            </button>
          </div>
        </article>
      }
    </section>

    @if (volumeSelecionado()) {
      <section class="secao-edicoes" id="edicoes-volume">
        <div class="secao-titulo">
          <div>
            <p class="rotulo">Volume selecionado</p>
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

        @if (pessoasEncontradas().length) {
          <section class="pessoas-encontradas">
            @for (pessoa of pessoasEncontradas(); track pessoa.idExterno) {
              <button type="button" (click)="selecionarPessoaFiltro(pessoa)">
                <img [src]="pessoa.urlImagem || capaReserva" [alt]="pessoa.nome || 'Pessoa'" loading="lazy" />
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
            @for (edicao of edicoes()?.itens || []; track edicao.idExterno) {
              <article class="cartao-edicao clicavel" (click)="abrirDetalhesEdicao(edicao)" tabindex="0" (keyup.enter)="abrirDetalhesEdicao(edicao)">
                <img [src]="edicao.urlImagem || capaReserva" [alt]="edicao.titulo || 'Edição sem título'" loading="lazy" />
                <div>
                  <p class="rotulo">#{{ edicao.numero || '-' }} · {{ edicao.dataCapa || 'sem data' }}</p>
                  <h3>{{ edicao.titulo || edicao.nomeVolume }}</h3>
                  <p>{{ limitarTexto(edicao.descricao, 170) }}</p>
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
            <img [src]="edicaoSelecionada()?.urlImagem || capaReserva" [alt]="edicaoSelecionada()?.titulo || 'Capa da edição'" />
            <div>
              <p class="rotulo">ComicVine · {{ edicaoSelecionada()?.nomeVolume }}</p>
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
                <p class="texto-suave">Nenhum conteúdo interno retornado pela ComicVine.</p>
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
                <p class="texto-suave">Nenhum crédito retornado pela ComicVine.</p>
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

    @if (pessoaSelecionada()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da pessoa">
        <div class="detalhe-fundo" (click)="fecharDetalhesPessoa()"></div>
        <article class="detalhe-painel pessoa-painel">
          <button class="fechar-detalhe" type="button" (click)="fecharDetalhesPessoa()" aria-label="Fechar detalhes">×</button>
          <div class="detalhe-cabecalho">
            <img [src]="pessoaSelecionada()?.urlImagem || capaReserva" [alt]="pessoaSelecionada()?.nome || 'Pessoa'" />
            <div>
              <p class="rotulo">ComicVine · pessoa</p>
              <h2>{{ pessoaSelecionada()?.nome }}</h2>
              <div class="chips">
                <span>{{ pessoaSelecionada()?.genero || 'gênero não informado' }}</span>
                <span>Nascimento: {{ pessoaSelecionada()?.dataNascimento || 'não informado' }}</span>
                <span>{{ pessoaSelecionada()?.pais || 'país não informado' }}</span>
              </div>
              @if (pessoaSelecionada()?.urlOrigem) {
                <a class="botao compacto" [href]="pessoaSelecionada()?.urlOrigem" target="_blank" rel="noreferrer">
                  Abrir ComicVine
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

  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly volumes = signal<PaginaResposta<VolumeComicVine>>({
    itens: [],
    pagina: 0,
    tamanho: 12,
    totalItens: 0,
    totalPaginas: 0,
  });
  readonly edicoes = signal<PaginaResposta<EdicaoComicVine> | null>(null);
  readonly volumeSelecionado = signal<VolumeComicVine | null>(null);
  readonly paginaEdicoes = signal(0);
  readonly mensagem = signal('');
  readonly carregandoEdicoes = signal(false);
  readonly edicaoSelecionada = signal<EdicaoComicVine | null>(null);
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

  buscarVolumes() {
    this.mensagem.set('');
    this.api.buscarVolumesComicVine(this.termo, 0, 12).subscribe({
      next: (resposta) => this.volumes.set(resposta),
      error: () => this.mensagem.set('Não foi possível buscar volumes na ComicVine.'),
    });
  }

  selecionarVolume(volume: VolumeComicVine) {
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
        this.edicoes.set(resposta);
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
        this.mensagem.set('Não foi possível buscar pessoas na ComicVine.');
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

  listarCreditos(edicao: EdicaoComicVine) {
    return edicao.creditos
      .slice(0, 3)
      .map((credito) => [credito.nome, credito.papel].filter(Boolean).join(' · '))
      .join(' / ');
  }

  abrirDetalhesEdicao(edicao: EdicaoComicVine) {
    this.edicaoSelecionada.set(edicao);
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
        this.mensagem.set('Não foi possível carregar o detalhe completo da ComicVine. Exibindo os dados da listagem.');
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

  fecharDetalhesEdicao() {
    this.edicaoSelecionada.set(null);
    this.publicacoesRelacionadas.set([]);
    this.itemColecaoSelecionado.set(null);
    this.calculoInflacao.set(null);
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

  private rolarParaEdicoes() {
    setTimeout(() => {
      document.getElementById('edicoes-volume')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 50);
  }
}
