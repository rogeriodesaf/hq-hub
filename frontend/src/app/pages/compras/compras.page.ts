import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { CompraPlanejada } from '../../core/modelos';

@Component({
  selector: 'app-compras-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Planejamento</p>
        <h1>Compras do mês, prioridades e links de venda.</h1>
      </div>
    </section>

    <section class="filtros-mes">
      <select [(ngModel)]="mes" (change)="carregar()">
        @for (nome of meses; track nome; let indice = $index) {
          <option [ngValue]="indice + 1">{{ nome }}</option>
        }
      </select>
      <input type="number" [(ngModel)]="ano" (change)="carregar()" />
    </section>

    <section class="compras-lista">
      @for (compra of compras(); track compra.id) {
        <article class="compra-card">
          <img [src]="compra.edicao.urlCapa || capaReserva" [alt]="compra.edicao.titulo || compra.edicao.numero" loading="lazy" />
          <div>
            <p class="rotulo">{{ compra.prioridade }} · {{ compra.status }}</p>
            <h2>{{ compra.edicao.serie?.titulo }} #{{ compra.edicao.numero }}</h2>
            <p>{{ compra.observacoes || 'Sem observações.' }}</p>
            @if (compra.linkCompra) {
              <a class="botao compacto" [href]="compra.linkCompra" target="_blank" rel="noreferrer">Abrir loja</a>
            }
          </div>
          <strong>{{ formatarMoeda(compra.precoEstimado || 0) }}</strong>
        </article>
      } @empty {
        <section class="estado-vazio">
          <h2>Nenhuma compra para este mês</h2>
          <p>Quando você cadastrar próximas compras, elas aparecem aqui por mês e prioridade.</p>
        </section>
      }
    </section>
  `,
})
export class ComprasPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  readonly compras = signal<CompraPlanejada[]>([]);
  mes = new Date().getMonth() + 1;
  ano = new Date().getFullYear();

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.api.listarComprasPlanejadas(this.mes, this.ano).subscribe({
      next: (resposta) => this.compras.set(resposta),
      error: () => this.compras.set([]),
    });
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }
}
