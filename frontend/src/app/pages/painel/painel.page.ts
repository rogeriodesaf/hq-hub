import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { ColecaoResumo, EdicaoComicVine, VolumeComicVine } from '../../core/modelos';

@Component({
  selector: 'app-painel-page',
  imports: [CommonModule, RouterLink],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Visão geral</p>
        <h1>Organize sua coleção sem perder o fio da cronologia.</h1>
      </div>
      <a class="botao primario" routerLink="/descobrir">Pesquisar HQs</a>
    </section>

    <section class="metricas">
      <article>
        <span>{{ resumo()?.totalItens ?? 0 }}</span>
        <p>Edições na coleção</p>
      </article>
      <article>
        <span>{{ resumo()?.totalSeries ?? 0 }}</span>
        <p>Séries acompanhadas</p>
      </article>
      <article>
        <span>{{ resumo()?.totalEditoras ?? 0 }}</span>
        <p>Editoras na estante</p>
      </article>
      <article>
        <span>{{ formatarMoeda(resumo()?.valorTotalPago ?? 0) }}</span>
        <p>Investido na coleção</p>
      </article>
    </section>

    <section class="painel-grade">
      <article class="bloco destaque-busca">
        <div>
          <p class="rotulo">ComicVine</p>
          <h2>Amazing Spider-Man em ordem cronológica</h2>
          <p>Use a busca externa para escolher o volume e carregar as edições por página.</p>
        </div>
        <a class="botao claro" routerLink="/descobrir">Abrir busca</a>
      </article>

      <article class="bloco">
        <p class="rotulo">Atalhos</p>
        <div class="lista-acoes">
          <a routerLink="/colecao">Ver estante</a>
          <a routerLink="/compras">Planejar compras</a>
          <a routerLink="/catalogo">Catálogo interno</a>
          <a routerLink="/assistente">Perguntar ao assistente</a>
        </div>
      </article>
    </section>
  `,
})
export class PainelPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly resumo = signal<ColecaoResumo | null>(null);
  readonly volumes = signal<VolumeComicVine[]>([]);
  readonly edicoes = signal<EdicaoComicVine[]>([]);

  ngOnInit() {
    this.api.obterResumoColecao().subscribe({
      next: (resumo) => this.resumo.set(resumo),
      error: () => this.resumo.set({ totalItens: 0, totalSeries: 0, totalEditoras: 0, valorTotalPago: 0 }),
    });
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }
}

