import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { ContribuicaoCatalogo } from '../../core/modelos';

@Component({
  selector: 'app-revisao-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Revisao</p>
        <h1>Pendencias enviadas por usuarios para checagem do catalogo.</h1>
      </div>
      <button class="botao compacto" type="button" (click)="carregar()" [disabled]="carregando()">
        {{ carregando() ? 'Atualizando...' : 'Atualizar' }}
      </button>
    </section>

    @if (mensagem()) {
      <p class="mensagem-erro">{{ mensagem() }}</p>
    }

    <section class="metricas-revisao">
      <article>
        <span>Pendentes</span>
        <strong>{{ pendentes().length }}</strong>
      </article>
      <article>
        <span>Novas edicoes</span>
        <strong>{{ pendentesCadastroManual().length }}</strong>
      </article>
    </section>

    <section class="lista-revisao">
      @for (contribuicao of pendentes(); track contribuicao.id) {
        <article class="bloco revisao-card">
          <div class="secao-titulo">
            <div>
              <p class="rotulo">{{ rotuloTipo(contribuicao) }}</p>
              <h2>{{ tituloEdicao(contribuicao) }}</h2>
            </div>
            <span>{{ contribuicao.usuario.nome }}</span>
          </div>

          <div class="grade-revisao">
            <div>
              <strong>Serie</strong>
              <span>{{ contribuicao.edicao.serie?.titulo || 'Nao informada' }}</span>
            </div>
            <div>
              <strong>Editora</strong>
              <span>{{ contribuicao.edicao.serie?.editora?.nome || 'Nao informada' }}</span>
            </div>
            <div>
              <strong>Capa</strong>
              <span>{{ contribuicao.edicao.urlCapa ? 'Informada' : 'Pendente' }}</span>
            </div>
            <div>
              <strong>Fonte</strong>
              <span>{{ contribuicao.urlFonte || contribuicao.edicao.urlOrigem || 'Pendente' }}</span>
            </div>
          </div>

          @if (contribuicao.observacoes) {
            <p class="texto-suave">{{ contribuicao.observacoes }}</p>
          }

          @if (contribuicao.dadosSugeridosJson) {
            <details>
              <summary>Dados enviados</summary>
              <pre>{{ formatarDados(contribuicao.dadosSugeridosJson) }}</pre>
            </details>
          }

          <label class="campo-revisao">
            Mensagem da revisao
            <input
              [(ngModel)]="mensagensRevisao[contribuicao.id]"
              [name]="'mensagemRevisao' + contribuicao.id"
              placeholder="Ex.: conferido no catalogo, falta completar historias..."
            />
          </label>

          <div class="acoes-revisao">
            <button class="botao primario compacto" type="button" (click)="aprovar(contribuicao)" [disabled]="revisandoId() === contribuicao.id">
              Marcar como checado
            </button>
            <button class="botao compacto" type="button" (click)="recusar(contribuicao)" [disabled]="revisandoId() === contribuicao.id">
              Recusar
            </button>
          </div>
        </article>
      } @empty {
        <section class="estado-vazio">
          <h2>Nenhuma pendencia de catalogo</h2>
          <p>Quando alguem criar uma edicao pela estante ou sugerir dados, ela aparece aqui para revisao.</p>
        </section>
      }
    </section>
  `,
  styles: `
    .metricas-revisao {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 180px));
      gap: 12px;
      margin-bottom: 18px;
    }

    .metricas-revisao article,
    .grade-revisao div {
      display: grid;
      gap: 4px;
      padding: 12px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
    }

    .metricas-revisao span,
    .grade-revisao span {
      color: var(--texto-suave);
      font-size: 0.86rem;
      overflow-wrap: anywhere;
    }

    .metricas-revisao strong {
      font-size: 1.5rem;
    }

    .lista-revisao,
    .revisao-card {
      display: grid;
      gap: 14px;
    }

    .grade-revisao {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 10px;
    }

    .campo-revisao {
      display: grid;
      gap: 6px;
      font-size: 0.88rem;
      color: var(--texto-suave);
    }

    .acoes-revisao {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    details {
      border: 1px solid var(--borda);
      border-radius: 8px;
      padding: 10px 12px;
      background: var(--superficie-suave);
    }

    summary {
      cursor: pointer;
      font-weight: 700;
    }

    pre {
      margin: 10px 0 0;
      white-space: pre-wrap;
      overflow-wrap: anywhere;
      font-size: 0.82rem;
      color: var(--texto-suave);
    }

    @media (max-width: 900px) {
      .metricas-revisao,
      .grade-revisao {
        grid-template-columns: 1fr;
      }
    }
  `,
})
export class RevisaoPage implements OnInit {
  private readonly api = inject(ApiService);

  readonly pendentes = signal<ContribuicaoCatalogo[]>([]);
  readonly carregando = signal(false);
  readonly revisandoId = signal<number | null>(null);
  readonly mensagem = signal('');
  readonly pendentesCadastroManual = computed(() =>
    this.pendentes().filter((contribuicao) => contribuicao.fonteExterna === 'CADASTRO_USUARIO'),
  );
  mensagensRevisao: Record<number, string> = {};

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.carregando.set(true);
    this.mensagem.set('');
    this.api.listarContribuicoesPendentes().subscribe({
      next: (pendentes) => {
        this.pendentes.set(pendentes);
        this.carregando.set(false);
      },
      error: (erro) => {
        this.carregando.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel carregar as pendencias.');
      },
    });
  }

  aprovar(contribuicao: ContribuicaoCatalogo) {
    this.revisar(contribuicao, 'aprovar');
  }

  recusar(contribuicao: ContribuicaoCatalogo) {
    this.revisar(contribuicao, 'recusar');
  }

  tituloEdicao(contribuicao: ContribuicaoCatalogo) {
    const serie = contribuicao.edicao.serie?.titulo || 'Edicao';
    const numero = contribuicao.edicao.numero ? ` #${contribuicao.edicao.numero}` : '';
    const titulo = contribuicao.edicao.titulo ? ` - ${contribuicao.edicao.titulo}` : '';
    return `${serie}${numero}${titulo}`;
  }

  rotuloTipo(contribuicao: ContribuicaoCatalogo) {
    if (contribuicao.fonteExterna === 'CADASTRO_USUARIO') {
      return 'Nova edicao criada na estante';
    }

    const rotulos: Record<string, string> = {
      CAPA_EDICAO: 'Sugestao de capa',
      DADOS_EDICAO: 'Dados da edicao',
      PUBLICACAO_BRASILEIRA: 'Publicacao brasileira',
      LINK_GUIA_DOS_QUADRINHOS: 'Link do Guia dos Quadrinhos',
      OUTRA_INFORMACAO: 'Outra informacao',
    };
    return rotulos[contribuicao.tipo] || contribuicao.tipo;
  }

  formatarDados(valor: string) {
    try {
      return JSON.stringify(JSON.parse(valor), null, 2);
    } catch {
      return valor;
    }
  }

  private revisar(contribuicao: ContribuicaoCatalogo, acao: 'aprovar' | 'recusar') {
    this.revisandoId.set(contribuicao.id);
    this.mensagem.set('');
    const mensagemRevisao = this.mensagensRevisao[contribuicao.id]?.trim() || null;
    const requisicao =
      acao === 'aprovar'
        ? this.api.aprovarContribuicaoCatalogo(contribuicao.id, mensagemRevisao)
        : this.api.recusarContribuicaoCatalogo(contribuicao.id, mensagemRevisao);

    requisicao.subscribe({
      next: () => {
        this.revisandoId.set(null);
        this.pendentes.update((pendentes) => pendentes.filter((item) => item.id !== contribuicao.id));
        this.mensagem.set(acao === 'aprovar' ? 'Pendencia marcada como checada.' : 'Pendencia recusada.');
      },
      error: (erro) => {
        this.revisandoId.set(null);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel revisar esta pendencia.');
      },
    });
  }
}
