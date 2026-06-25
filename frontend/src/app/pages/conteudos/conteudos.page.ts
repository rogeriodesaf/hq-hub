import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { forkJoin, Observable, of, switchMap } from 'rxjs';

import { ApiService } from '../../core/api.service';
import {
  ConteudoEdicao,
  CruzamentoEdicao,
  Edicao,
  PublicacaoHistoria,
  StatusPublicacaoHistoria,
  TipoConteudoEdicao,
  TipoPublicacaoHistoria,
} from '../../core/modelos';

@Component({
  selector: 'app-conteudos-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Conteúdos</p>
        <h1>Vincule histórias originais às publicações brasileiras.</h1>
      </div>
    </section>

    <section class="conteudos-layout">
      <article class="bloco painel-conteudo">
        <div class="secao-titulo">
          <div>
            <h2>Edição original</h2>
            <p class="texto-suave">Escolha a edição de origem da história.</p>
          </div>
        </div>

        <div class="barra-busca interna">
          <input [(ngModel)]="buscaOriginal" placeholder="Ex.: Spectacular Spider-Man 97" (keyup.enter)="buscarOriginais()" />
          <button class="botao compacto" type="button" (click)="buscarOriginais()" [disabled]="carregandoOriginais()">
            {{ carregandoOriginais() ? 'Buscando...' : 'Buscar' }}
          </button>
        </div>

        <div class="lista-linhas lista-compacta">
          @for (edicao of originaisEncontradas(); track edicao.id) {
            <button type="button" [class.ativo]="edicaoOriginal()?.id === edicao.id" (click)="selecionarOriginal(edicao)">
              <strong>{{ tituloEdicao(edicao) }}</strong>
              <span>{{ edicao.serie?.titulo || 'Série não informada' }} · {{ edicao.serie?.editora?.nome || 'Editora não informada' }}</span>
            </button>
          }
        </div>

        @if (edicaoOriginal()) {
          <section class="resumo-selecao">
            <strong>{{ tituloEdicao(edicaoOriginal()!) }}</strong>
            <span>{{ edicaoOriginal()?.serie?.titulo }}</span>
          </section>

          <div class="grade-formulario conteudo-formulario">
            <label class="campo-largo">
              URL da capa da edição original
              <input [(ngModel)]="urlCapaOriginal" name="urlCapaOriginal" placeholder="Cole a URL da capa confirmada" />
            </label>
            <label class="campo-largo">
              Link de compra da Amazon
              <input [(ngModel)]="urlCompraAmazonOriginal" name="urlCompraAmazonOriginal" placeholder="Cole seu link da Amazon" />
            </label>
          </div>

          <div class="acoes-formulario">
            <button
              class="botao compacto"
              type="button"
              (click)="salvarDadosOriginaisManual()"
              [disabled]="salvandoDadosOriginais()"
            >
              {{ salvandoDadosOriginais() ? 'Salvando...' : 'Salvar capa/link da edição original' }}
            </button>
          </div>

          <form class="grade-formulario conteudo-formulario" (ngSubmit)="cadastrarConteudoOriginal()">
            <label class="campo-largo">
              Título da história
              <input [(ngModel)]="tituloHistoria" name="tituloHistoria" placeholder="Ex.: The Sinister Six!" />
            </label>
            <label>
              Título original
              <input [(ngModel)]="tituloOriginal" name="tituloOriginal" placeholder="Opcional" />
            </label>
            <label>
              Ordem na edição
              <input type="number" min="1" [(ngModel)]="ordemConteudo" name="ordemConteudo" />
            </label>
            <label>
              Páginas
              <input type="number" min="1" [(ngModel)]="quantidadePaginas" name="quantidadePaginas" />
            </label>
            <label>
              Tipo
              <select [(ngModel)]="tipoConteudo" name="tipoConteudo">
                <option value="HISTORIA">História</option>
                <option value="MATERIAL_EDITORIAL">Material editorial</option>
                <option value="EXTRA">Extra</option>
                <option value="OUTRO">Outro</option>
              </select>
            </label>
            <label class="campo-largo">
              Fonte consultada
              <input [(ngModel)]="urlOrigemHistoria" name="urlOrigemHistoria" placeholder="URL do Guia, Marvel, Comic Vine ou outra fonte" />
            </label>
            <label class="campo-largo">
              Observações
              <input [(ngModel)]="observacoesConteudo" name="observacoesConteudo" placeholder="Ex.: história principal, título usado no Brasil..." />
            </label>
            <button class="botao primario" type="submit" [disabled]="salvandoConteudo()">
              {{ salvandoConteudo() ? 'Salvando...' : 'Cadastrar história nesta edição' }}
            </button>
          </form>
        }
      </article>

      <article class="bloco painel-conteudo">
        <div class="secao-titulo">
          <div>
            <h2>Edição brasileira ou republicação</h2>
            <p class="texto-suave">Escolha onde a história também foi publicada.</p>
          </div>
        </div>

        <div class="barra-busca interna">
          <input [(ngModel)]="buscaPublicada" placeholder="Ex.: Homem-Aranha Abril 45" (keyup.enter)="buscarPublicadas()" />
          <button class="botao compacto" type="button" (click)="buscarPublicadas()" [disabled]="carregandoPublicadas()">
            {{ carregandoPublicadas() ? 'Buscando...' : 'Buscar' }}
          </button>
        </div>

        <div class="lista-linhas lista-compacta">
          @for (edicao of publicadasEncontradas(); track edicao.id) {
            <button type="button" [class.ativo]="edicaoPublicada()?.id === edicao.id" (click)="selecionarPublicada(edicao)">
              <strong>{{ tituloEdicao(edicao) }}</strong>
              <span>{{ edicao.serie?.titulo || 'Série não informada' }} · {{ edicao.serie?.editora?.nome || 'Editora não informada' }}</span>
            </button>
          }
        </div>

        @if (edicaoPublicada()) {
          <section class="resumo-selecao">
            <strong>{{ tituloEdicao(edicaoPublicada()!) }}</strong>
            <span>{{ edicaoPublicada()?.serie?.titulo }}</span>
          </section>

          <div class="grade-formulario conteudo-formulario">
            <label>
              Status da publicação
              <select [(ngModel)]="statusPublicacao" name="statusPublicacao">
                <option value="COMPLETA">Completa</option>
                <option value="PARCIAL">Parcial</option>
                <option value="CORTADA">Cortada</option>
                <option value="ADAPTADA">Adaptada</option>
                <option value="DESCONHECIDA">Desconhecida</option>
              </select>
            </label>
            <label>
              Tipo de vínculo
              <select [(ngModel)]="tipoPublicacao" name="tipoPublicacao">
                <option value="PUBLICACAO_BRASILEIRA">Publicação brasileira</option>
                <option value="REPUBLICACAO">Republicação</option>
                <option value="PUBLICACAO_ESTRANGEIRA">Publicação estrangeira</option>
              </select>
            </label>
            <label class="campo-largo">
              URL da fonte
              <input [(ngModel)]="urlFontePublicacao" name="urlFontePublicacao" placeholder="URL do Guia dos Quadrinhos ou fonte conferida" />
            </label>
          </div>
        }
      </article>
    </section>

    @if (mensagem()) {
      <p class="mensagem-erro">{{ mensagem() }}</p>
    }

    @if (conteudosOriginais().length) {
      <section class="bloco bloco-conteudos">
        <div class="secao-titulo">
          <div>
            <h2>Histórias da edição original</h2>
            <p class="texto-suave">Vincule cada história às edições onde ela saiu.</p>
          </div>
          <button class="botao compacto" type="button" (click)="cruzarEdicoesSelecionadas()" [disabled]="!edicaoPublicada() || cruzando()">
            {{ cruzando() ? 'Comparando...' : 'Comparar com edição escolhida' }}
          </button>
        </div>

        <div class="grade-historias">
          @for (conteudo of conteudosOriginais(); track conteudo.id) {
            <article class="historia-card">
              <div>
                <p class="rotulo">Ordem {{ conteudo.ordem }} · {{ rotuloTipoConteudo(conteudo.tipo) }}</p>
                <h3>{{ conteudo.tituloUsado || conteudo.historia.tituloExibicao || conteudo.historia.titulo }}</h3>
                <p>{{ conteudo.historia.descricaoExibicao || conteudo.observacoes || 'Sem descrição cadastrada.' }}</p>
              </div>

              <div class="historia-acoes">
                <button class="botao compacto" type="button" (click)="vincularPublicacao(conteudo)" [disabled]="!edicaoPublicada() || salvandoPublicacao()">
                  Vincular à edição escolhida
                </button>
              </div>

              <div class="publicacoes-lista">
                @for (publicacao of publicacoesPorHistoria()[conteudo.historia.id] || []; track publicacao.id) {
                  <div>
                    <strong>{{ tituloEdicao(publicacao.edicaoPublicada) }}</strong>
                    <span>{{ publicacao.edicaoPublicada.serie?.titulo }} · {{ rotuloStatus(publicacao.status) }}</span>
                  </div>
                } @empty {
                  <p class="texto-suave">Nenhuma publicação vinculada ainda.</p>
                }
              </div>
            </article>
          }
        </div>
      </section>
    }

    @if (cruzamento()) {
      <section class="bloco painel-cruzamento">
        <div class="secao-titulo">
          <div>
            <h2>Comparação de conteúdo</h2>
            <p class="texto-suave">
              {{ cruzamento()?.totalHistoriasIncluidas }} de {{ cruzamento()?.totalConteudosOriginais }} histórias vinculadas.
            </p>
          </div>
        </div>

        <div class="cruzamento-colunas">
          <article>
            <h3>Incluídas</h3>
            @for (publicacao of cruzamento()?.historiasIncluidas || []; track publicacao.id) {
              <p>{{ publicacao.historia.tituloExibicao || publicacao.historia.titulo }}</p>
            } @empty {
              <p class="texto-suave">Nenhuma história vinculada a esta edição ainda.</p>
            }
          </article>
          <article>
            <h3>Ficaram de fora</h3>
            @for (conteudo of cruzamento()?.conteudosFora || []; track conteudo.id) {
              <p>{{ conteudo.historia.tituloExibicao || conteudo.historia.titulo }}</p>
            } @empty {
              <p class="texto-suave">Nada ficou de fora segundo os vínculos cadastrados.</p>
            }
          </article>
        </div>
      </section>
    }
  `,
})
export class ConteudosPage {
  private readonly api = inject(ApiService);

  readonly originaisEncontradas = signal<Edicao[]>([]);
  readonly publicadasEncontradas = signal<Edicao[]>([]);
  readonly edicaoOriginal = signal<Edicao | null>(null);
  readonly edicaoPublicada = signal<Edicao | null>(null);
  readonly conteudosOriginais = signal<ConteudoEdicao[]>([]);
  readonly publicacoesPorHistoria = signal<Record<number, PublicacaoHistoria[]>>({});
  readonly cruzamento = signal<CruzamentoEdicao | null>(null);
  readonly carregandoOriginais = signal(false);
  readonly carregandoPublicadas = signal(false);
  readonly salvandoConteudo = signal(false);
  readonly salvandoPublicacao = signal(false);
  readonly salvandoDadosOriginais = signal(false);
  readonly cruzando = signal(false);
  readonly mensagem = signal('');

  buscaOriginal = '';
  buscaPublicada = '';
  tituloHistoria = '';
  tituloOriginal = '';
  ordemConteudo: number | null = 1;
  quantidadePaginas: number | null = null;
  tipoConteudo: TipoConteudoEdicao = 'HISTORIA';
  urlOrigemHistoria = '';
  observacoesConteudo = '';
  urlCapaOriginal = '';
  urlCompraAmazonOriginal = '';
  statusPublicacao: StatusPublicacaoHistoria = 'COMPLETA';
  tipoPublicacao: TipoPublicacaoHistoria = 'PUBLICACAO_BRASILEIRA';
  urlFontePublicacao = '';

  buscarOriginais() {
    this.buscarEdicoes(this.buscaOriginal, this.carregandoOriginais, this.originaisEncontradas);
  }

  buscarPublicadas() {
    this.buscarEdicoes(this.buscaPublicada, this.carregandoPublicadas, this.publicadasEncontradas);
  }

  selecionarOriginal(edicao: Edicao) {
    this.edicaoOriginal.set(edicao);
    this.urlCapaOriginal = edicao.urlCapa || '';
    this.carregarLinkAmazonOriginal(edicao);
    this.cruzamento.set(null);
    this.carregarConteudos();
  }

  selecionarPublicada(edicao: Edicao) {
    this.edicaoPublicada.set(edicao);
    this.cruzamento.set(null);
  }

  cadastrarConteudoOriginal() {
    const edicao = this.edicaoOriginal();
    if (!edicao || !this.tituloHistoria.trim() || !this.ordemConteudo) {
      this.mensagem.set('Escolha uma edição original e informe título e ordem da história.');
      return;
    }

    this.salvandoConteudo.set(true);
    this.mensagem.set('');

    this.api
      .cadastrarHistoria({
        titulo: this.tituloHistoria.trim(),
        tituloOriginal: this.tituloOriginal.trim() || null,
        descricao: this.observacoesConteudo.trim() || null,
        quantidadePaginas: this.quantidadePaginas,
        tipo: this.tipoConteudo,
        fonteExterna: null,
        idExterno: null,
        urlOrigem: this.urlOrigemHistoria.trim() || null,
      })
      .subscribe({
        next: (historia) => {
          this.api
            .cadastrarConteudoEdicao({
              edicaoId: edicao.id,
              historiaId: historia.id,
              ordem: this.ordemConteudo || 1,
              tituloUsado: this.tituloHistoria.trim(),
              paginaInicio: null,
              paginaFim: null,
              quantidadePaginas: this.quantidadePaginas,
              tipo: this.tipoConteudo,
              observacoes: this.observacoesConteudo.trim() || null,
            })
            .subscribe({
              next: () => {
                this.salvandoConteudo.set(false);
                this.mensagem.set('História cadastrada na edição original.');
                this.limparFormularioHistoria();
                this.carregarConteudos();
              },
              error: (erro) => {
                this.salvandoConteudo.set(false);
                this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível cadastrar o conteúdo da edição.'));
              },
            });
        },
        error: (erro) => {
          this.salvandoConteudo.set(false);
          this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível cadastrar a história.'));
        },
      });
  }

  vincularPublicacao(conteudo: ConteudoEdicao) {
    const original = this.edicaoOriginal();
    const publicada = this.edicaoPublicada();

    if (!original || !publicada) {
      this.mensagem.set('Escolha a edição original e a edição publicada antes de vincular.');
      return;
    }

    this.salvandoPublicacao.set(true);
    this.mensagem.set('');

    this.api
      .cadastrarPublicacaoHistoria({
        historiaId: conteudo.historia.id,
        edicaoOriginalId: original.id,
        edicaoPublicadaId: publicada.id,
        status: this.statusPublicacao,
        tipoPublicacaoHistoria: this.tipoPublicacao,
        fonteInformacao: this.urlFontePublicacao.trim() ? 'Fonte informada pelo usuário' : null,
        urlFonteInformacao: this.urlFontePublicacao.trim() || null,
        tituloUsado: conteudo.tituloUsado,
        paginasPublicadas: conteudo.quantidadePaginas,
        paginasCortadas: null,
        fonteExterna: null,
        urlOrigem: this.urlFontePublicacao.trim() || null,
        observacoes: null,
      })
      .pipe(switchMap(() => this.salvarDadosManuaisOriginal(original)))
      .subscribe({
        next: () => {
          this.salvandoPublicacao.set(false);
          this.mensagem.set('Publicação vinculada à história.');
          this.carregarPublicacoesHistorias();
        },
        error: (erro) => {
          this.salvandoPublicacao.set(false);
          this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível vincular esta publicação.'));
        },
      });
  }

  salvarDadosOriginaisManual() {
    const original = this.edicaoOriginal();
    if (!original) {
      this.mensagem.set('Escolha uma edição original antes de salvar capa e link.');
      return;
    }

    this.salvandoDadosOriginais.set(true);
    this.mensagem.set('');

    this.salvarDadosManuaisOriginal(original).subscribe({
      next: () => {
        this.salvandoDadosOriginais.set(false);
        this.mensagem.set('Dados da edição original salvos.');
      },
      error: (erro: unknown) => {
        this.salvandoDadosOriginais.set(false);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível salvar capa/link da edição original.'));
      },
    });
    private salvarDadosManuaisOriginal(edicao: Edicao): Observable<unknown> {
  }

  cruzarEdicoesSelecionadas() {
    const original = this.edicaoOriginal();
    const publicada = this.edicaoPublicada();

    if (!original || !publicada) {
      this.mensagem.set('Escolha as duas edições para comparar.');
      return;
    }

    this.cruzando.set(true);
    this.api.cruzarEdicoes(original.id, publicada.id).subscribe({
      next: (resposta) => {
        this.cruzamento.set(resposta);
        this.cruzando.set(false);
      },
      error: (erro) => {
        this.cruzando.set(false);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível comparar as edições.'));
      },
    });
  }

  tituloEdicao(edicao: Edicao) {
    return `#${edicao.numero}${edicao.titulo ? ' - ' + edicao.titulo : ''}`;
  }

  rotuloTipoConteudo(tipo: TipoConteudoEdicao) {
    const rotulos: Record<string, string> = {
      HISTORIA: 'História',
      MATERIAL_EDITORIAL: 'Material editorial',
      EXTRA: 'Extra',
      OUTRO: 'Outro',
    };
    return rotulos[tipo] || tipo;
  }

  rotuloStatus(status: StatusPublicacaoHistoria) {
    const rotulos: Record<StatusPublicacaoHistoria, string> = {
      COMPLETA: 'completa',
      PARCIAL: 'parcial',
      CORTADA: 'cortada',
      ADAPTADA: 'adaptada',
      DESCONHECIDA: 'desconhecida',
    };
    return rotulos[status];
  }

  private buscarEdicoes(
    termo: string,
    carregando: ReturnType<typeof signal<boolean>>,
    destino: ReturnType<typeof signal<Edicao[]>>,
  ) {
    if (!termo.trim()) {
      this.mensagem.set('Informe um termo para buscar edições cadastradas no HQ-HUB.');
      return;
    }

    carregando.set(true);
    this.mensagem.set('');
    this.api.listarEdicoes(termo.trim(), 0, 12).subscribe({
      next: (resposta) => {
        destino.set(resposta.itens);
        carregando.set(false);
        if (!resposta.itens.length) {
          this.mensagem.set('Nenhuma edição interna encontrada. Cadastre a edição pelo catálogo/estante antes de criar vínculos.');
        }
      },
      error: (erro: unknown) => {
        carregando.set(false);
        this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível buscar edições.'));
      },
    });
  }

  private carregarConteudos() {
    const edicao = this.edicaoOriginal();
    if (!edicao) {
      return;
    }

    this.api.listarConteudosPorEdicao(edicao.id).subscribe({
      next: (conteudos) => {
        this.conteudosOriginais.set(conteudos);
        this.carregarPublicacoesHistorias();
      },
      error: (erro: unknown) => this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível carregar os conteúdos da edição.')),
    });
  }

  private carregarLinkAmazonOriginal(edicao: Edicao) {
    this.urlCompraAmazonOriginal = '';
    this.api.listarLinksPorEdicao(edicao.id).subscribe({
      next: (links) => {
        const amazon = links.find((link) => link.tipo === 'AMAZON');
        this.urlCompraAmazonOriginal = amazon?.url || '';
      },
      error: () => {
        this.urlCompraAmazonOriginal = '';
      },
    });
  }

  private salvarDadosManuaisOriginal(edicao: Edicao): Observable<unknown> | null {
    const urlCapa = this.urlCapaOriginal.trim();
    const urlAmazon = this.urlCompraAmazonOriginal.trim();
    const tarefas: Observable<unknown>[] = [];

    if (urlCapa && urlCapa !== edicao.urlCapa) {
      tarefas.push(
        this.api.atualizarEdicao(edicao.id, {
          numero: edicao.numero,
          titulo: edicao.titulo,
          descricao: edicao.descricao,
          dataPublicacao: edicao.dataPublicacao,
          urlCapa,
          codigoBarras: edicao.codigoBarras,
          quantidadePaginas: edicao.quantidadePaginas,
          precoCapa: edicao.precoCapa,
          formato: edicao.formato,
          fonteExterna: edicao.fonteExterna,
          idExterno: edicao.idExterno,
          urlOrigem: edicao.urlOrigem,
          serieId: edicao.serie?.id || 0,
        }).pipe(
          switchMap((edicaoAtualizada) => {
            this.edicaoOriginal.set(edicaoAtualizada);
            return of(edicaoAtualizada);
          }),
        ),
      );
    }

    if (urlAmazon) {
      tarefas.push(
        this.api.listarLinksPorEdicao(edicao.id).pipe(
          switchMap((links) => {
            const jaExiste = links.some((link) => link.url === urlAmazon);
            if (jaExiste) {
              return of(null);
            }
            return this.api.cadastrarLinkEdicao({
              edicaoId: edicao.id,
              tipo: 'AMAZON',
              titulo: 'Comprar na Amazon',
              url: urlAmazon,
              observacoes: 'Link de compra informado na tela de conteudos.',
            });
          }),
        ),
      );
    }

    return tarefas.length ? forkJoin(tarefas) : of(null);
  }

  private carregarPublicacoesHistorias() {
    const conteudos = this.conteudosOriginais();
    if (!conteudos.length) {
      this.publicacoesPorHistoria.set({});
      return;
    }

    const requisicoes = conteudos.map((conteudo) => this.api.listarPublicacoesPorHistoria(conteudo.historia.id));
    forkJoin(requisicoes).subscribe({
      next: (respostas) => {
        const mapa: Record<number, PublicacaoHistoria[]> = {};
        respostas.forEach((publicacoes, indice) => {
          mapa[conteudos[indice].historia.id] = publicacoes;
        });
        this.publicacoesPorHistoria.set(mapa);
      },
      error: () => this.publicacoesPorHistoria.set({}),
    });
  }

  private limparFormularioHistoria() {
    this.tituloHistoria = '';
    this.tituloOriginal = '';
    this.ordemConteudo = this.conteudosOriginais().length + 1;
    this.quantidadePaginas = null;
    this.tipoConteudo = 'HISTORIA';
    this.urlOrigemHistoria = '';
    this.observacoesConteudo = '';
  }

  private extrairMensagemErro(erro: unknown, mensagemPadrao: string) {
    const resposta = erro as { error?: { mensagem?: string } };
    return resposta.error?.mensagem ?? mensagemPadrao;
  }
}
