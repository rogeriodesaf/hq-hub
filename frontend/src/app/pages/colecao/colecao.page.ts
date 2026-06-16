import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';

import { ApiService } from '../../core/api.service';
import { EstanteEditora } from '../../core/modelos';

@Component({
  selector: 'app-colecao-page',
  imports: [CommonModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Estante</p>
        <h1>Suas HQs agrupadas por editora e série.</h1>
      </div>
    </section>

    @if (!estante().length) {
      <section class="estado-vazio">
        <h2>Nenhuma edição na estante ainda</h2>
        <p>Cadastre edições e adicione itens à coleção para ver sua estante ganhar forma.</p>
      </section>
    }

    <section class="estante">
      @for (editora of estante(); track editora.editoraId) {
        <article class="prateleira">
          <h2>{{ editora.nome }}</h2>
          @for (serie of editora.series; track serie.serieId) {
            <div class="serie-estante">
              <div class="secao-titulo">
                <h3>{{ serie.titulo }}</h3>
                <span>{{ serie.edicoes.length }} edições</span>
              </div>
              <div class="linha-capas">
                @for (edicao of serie.edicoes; track edicao.itemColecaoId) {
                  <div class="lombada">
                    <img [src]="edicao.urlCapa || capaReserva" [alt]="edicao.titulo || edicao.numero" loading="lazy" />
                    <span>#{{ edicao.numero }}</span>
                  </div>
                }
              </div>
            </div>
          }
        </article>
      }
    </section>
  `,
})
export class ColecaoPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly estante = signal<EstanteEditora[]>([]);

  ngOnInit() {
    this.api.obterEstante().subscribe({
      next: (resposta) => this.estante.set(resposta),
      error: () => this.estante.set([]),
    });
  }
}
