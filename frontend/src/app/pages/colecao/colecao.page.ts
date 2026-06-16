import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';

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

    <section class="abas-filtro">
      <button type="button" [class.ativo]="filtroLeitura() === 'TODAS'" (click)="filtroLeitura.set('TODAS')">
        Todas
      </button>
      <button type="button" [class.ativo]="filtroLeitura() === 'LIDO'" (click)="filtroLeitura.set('LIDO')">
        Lidas
      </button>
      <button type="button" [class.ativo]="filtroLeitura() === 'NAO_LIDO'" (click)="filtroLeitura.set('NAO_LIDO')">
        Não lidas
      </button>
    </section>

    @if (!estanteFiltrada().length) {
      <section class="estado-vazio">
        <h2>Nenhuma edição encontrada</h2>
        <p>Cadastre edições na coleção ou ajuste o filtro de leitura.</p>
      </section>
    }

    <section class="estante">
      @for (editora of estanteFiltrada(); track editora.editoraId) {
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
                    <small [class.lido]="edicao.statusLeitura === 'LIDO'">{{ rotuloLeitura(edicao.statusLeitura) }}</small>
                    @if (edicao.dataAquisicao) {
                      <em>Comprado em {{ formatarData(edicao.dataAquisicao) }}</em>
                    }
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
  readonly filtroLeitura = signal<'TODAS' | 'LIDO' | 'NAO_LIDO'>('TODAS');
  readonly estanteFiltrada = computed(() => {
    const filtro = this.filtroLeitura();

    if (filtro === 'TODAS') {
      return this.estante();
    }

    return this.estante()
      .map((editora) => ({
        ...editora,
        series: editora.series
          .map((serie) => ({
            ...serie,
            edicoes: serie.edicoes.filter((edicao) => edicao.statusLeitura === filtro),
          }))
          .filter((serie) => serie.edicoes.length > 0),
      }))
      .filter((editora) => editora.series.length > 0);
  });

  ngOnInit() {
    this.api.obterEstante().subscribe({
      next: (resposta) => this.estante.set(resposta),
      error: () => this.estante.set([]),
    });
  }

  rotuloLeitura(status: string) {
    return status === 'LIDO' ? 'Lido' : 'Não lido';
  }

  formatarData(data: string) {
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(
      new Date(`${data}T00:00:00`),
    );
  }
}
