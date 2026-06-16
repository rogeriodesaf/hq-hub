import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { PaginaResposta, ResultadoPesquisaCatalogo, Serie } from '../../core/modelos';

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
      <input [(ngModel)]="busca" placeholder="Buscar HQ no catálogo ou na Comic Vine" (keyup.enter)="carregar()" />
      <button class="botao primario" type="button" (click)="carregar()" [disabled]="carregandoResultados()">
        {{ carregandoResultados() ? 'Buscando...' : 'Buscar' }}
      </button>
    </section>

    @if (mensagem()) {
      <p class="mensagem-erro">{{ mensagem() }}</p>
    }

    <section class="catalogo-layout">
      <article class="bloco">
        <div class="secao-titulo">
          <h2>Séries internas</h2>
          <span>{{ series().totalItens }} itens</span>
        </div>
        <div class="lista-linhas">
          @for (serie of series().itens; track serie.id) {
            <button type="button" [class.ativo]="serieSelecionada()?.id === serie.id" (click)="selecionarSerie(serie)">
              <strong>{{ serie.titulo }}</strong>
              <span>{{ serie.editora?.nome || 'Sem editora' }} · V{{ serie.volume || '-' }}</span>
            </button>
          } @empty {
            <p class="texto-suave">Nenhuma série interna encontrada.</p>
          }
        </div>
      </article>

      <article class="bloco">
        <div class="secao-titulo">
          <h2>Edições</h2>
          <span>{{ resultadosCatalogo().length }} itens</span>
        </div>
        <div class="grade-mini-capas">
          @for (resultado of resultadosCatalogo(); track chaveResultado(resultado)) {
            <article class="mini-capa resultado-catalogo" [class.externo]="resultado.fonte === 'COMIC_VINE'">
              <img [src]="resultado.urlCapa || capaReserva" [alt]="resultado.titulo || resultado.numero || 'Edição'" loading="lazy" />
              <strong>#{{ resultado.numero || '-' }}</strong>
              <span>{{ resultado.titulo || resultado.nomeVolume || 'Sem título' }}</span>
              <small>{{ resultado.nomeVolume || 'Volume não informado' }}</small>
              <em>{{ rotuloFonte(resultado) }}</em>
              @if (resultado.jaCadastrada && resultado.id) {
                <button class="botao compacto" type="button" (click)="abrirInterna(resultado)">
                  Ver interna
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
      </article>
    </section>
  `,
})
export class CatalogoPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly series = signal<PaginaResposta<Serie>>({ itens: [], pagina: 0, tamanho: 12, totalItens: 0, totalPaginas: 0 });
  readonly resultadosCatalogo = signal<ResultadoPesquisaCatalogo[]>([]);
  readonly serieSelecionada = signal<Serie | null>(null);
  readonly carregandoResultados = signal(false);
  readonly mensagem = signal('');
  busca = '';

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.mensagem.set('');
    this.api.listarSeries(this.busca, 0, 12).subscribe((resposta) => this.series.set(resposta));

    if (!this.busca.trim() && !this.serieSelecionada()) {
      this.resultadosCatalogo.set([]);
      return;
    }

    this.carregandoResultados.set(true);
    const termo = this.serieSelecionada()?.titulo || this.busca;
    this.api.pesquisarCatalogo(termo).subscribe({
      next: (resposta) => {
        this.resultadosCatalogo.set(this.filtrarPorSerieSelecionada(resposta));
        this.carregandoResultados.set(false);
      },
      error: () => {
        this.resultadosCatalogo.set([]);
        this.carregandoResultados.set(false);
        this.mensagem.set('Não foi possível pesquisar no catálogo agora.');
      },
    });
  }

  selecionarSerie(serie: Serie) {
    this.serieSelecionada.set(serie);
    this.busca = serie.titulo;
    this.carregar();
  }

  rotuloFonte(resultado: ResultadoPesquisaCatalogo) {
    return resultado.fonte === 'HQ_HUB' ? 'Catálogo HQ-HUB' : 'Comic Vine';
  }

  chaveResultado(resultado: ResultadoPesquisaCatalogo) {
    return `${resultado.fonte}-${resultado.id || resultado.idExterno || resultado.numero}`;
  }

  abrirInterna(resultado: ResultadoPesquisaCatalogo) {
    this.mensagem.set(`Edição interna #${resultado.numero || resultado.id} selecionada.`);
  }

  private filtrarPorSerieSelecionada(resultados: ResultadoPesquisaCatalogo[]) {
    const serie = this.serieSelecionada();
    if (!serie) {
      return resultados;
    }

    const titulo = serie.titulo.toLowerCase();
    return resultados.filter((resultado) => (resultado.nomeVolume || resultado.titulo || '').toLowerCase().includes(titulo));
  }

  // TODO: implementar importação de edição externa para o catálogo interno ao selecionar resultado da Comic Vine.
}
