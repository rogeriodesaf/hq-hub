import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { Edicao, PaginaResposta, Serie } from '../../core/modelos';

@Component({
  selector: 'app-catalogo-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Catálogo interno</p>
        <h1>Séries e edições já cadastradas no HQ-HUB.</h1>
      </div>
    </section>

    <section class="barra-busca">
      <input [(ngModel)]="busca" placeholder="Buscar no catálogo" (keyup.enter)="carregar()" />
      <button class="botao primario" type="button" (click)="carregar()">Buscar</button>
    </section>

    <section class="catalogo-layout">
      <article class="bloco">
        <div class="secao-titulo">
          <h2>Séries</h2>
          <span>{{ series().totalItens }} itens</span>
        </div>
        <div class="lista-linhas">
          @for (serie of series().itens; track serie.id) {
            <button type="button" [class.ativo]="serieSelecionada()?.id === serie.id" (click)="selecionarSerie(serie)">
              <strong>{{ serie.titulo }}</strong>
              <span>{{ serie.editora?.nome || 'Sem editora' }} · V{{ serie.volume || '-' }}</span>
            </button>
          }
        </div>
      </article>

      <article class="bloco">
        <div class="secao-titulo">
          <h2>Edições</h2>
          <span>{{ edicoes().totalItens }} itens</span>
        </div>
        <div class="grade-mini-capas">
          @for (edicao of edicoes().itens; track edicao.id) {
            <div class="mini-capa">
              <img [src]="edicao.urlCapa || capaReserva" [alt]="edicao.titulo || edicao.numero" loading="lazy" />
              <strong>#{{ edicao.numero }}</strong>
              <span>{{ edicao.titulo || edicao.serie?.titulo || 'Sem título' }}</span>
            </div>
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
  readonly edicoes = signal<PaginaResposta<Edicao>>({ itens: [], pagina: 0, tamanho: 24, totalItens: 0, totalPaginas: 0 });
  readonly serieSelecionada = signal<Serie | null>(null);
  busca = '';

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.api.listarSeries(this.busca, 0, 12).subscribe((resposta) => this.series.set(resposta));
    this.api.listarEdicoes(this.busca, 0, 24, this.serieSelecionada()?.id).subscribe((resposta) => this.edicoes.set(resposta));
  }

  selecionarSerie(serie: Serie) {
    this.serieSelecionada.set(serie);
    this.api.listarEdicoes('', 0, 24, serie.id).subscribe((resposta) => this.edicoes.set(resposta));
  }
}
