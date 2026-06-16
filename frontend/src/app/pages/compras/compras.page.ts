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

    <section class="painel-formulario">
      <div>
        <p class="rotulo">Nova compra do mês</p>
        <h2>Cadastre uma edição para não comprar repetido.</h2>
      </div>

      <form class="grade-formulario" (ngSubmit)="cadastrarCompra()">
        <label>
          ID da edição
          <input type="number" min="1" name="edicaoId" [(ngModel)]="formulario.edicaoId" required />
        </label>
        <label>
          Mês
          <select name="mesFormulario" [(ngModel)]="formulario.mes">
            @for (nome of meses; track nome; let indice = $index) {
              <option [ngValue]="indice + 1">{{ nome }}</option>
            }
          </select>
        </label>
        <label>
          Ano
          <input type="number" name="anoFormulario" [(ngModel)]="formulario.ano" required />
        </label>
        <label>
          Prioridade
          <select name="prioridade" [(ngModel)]="formulario.prioridade">
            <option value="ALTA">Alta</option>
            <option value="MEDIA">Média</option>
            <option value="BAIXA">Baixa</option>
          </select>
        </label>
        <label>
          Valor estimado
          <input type="number" min="0" step="0.01" name="precoEstimado" [(ngModel)]="formulario.precoEstimado" />
        </label>
        <label class="campo-largo">
          Link de compra
          <input type="url" name="linkCompra" [(ngModel)]="formulario.linkCompra" placeholder="https://..." />
        </label>
        <label class="campo-largo">
          Observações
          <textarea name="observacoes" rows="3" [(ngModel)]="formulario.observacoes"></textarea>
        </label>
        <button class="botao primario" type="submit" [disabled]="salvando()">
          {{ salvando() ? 'Salvando...' : 'Cadastrar compra' }}
        </button>
      </form>

      @if (mensagem()) {
        <p class="mensagem-erro compacto">{{ mensagem() }}</p>
      }
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
  readonly salvando = signal(false);
  readonly mensagem = signal('');
  mes = new Date().getMonth() + 1;
  ano = new Date().getFullYear();
  formulario = {
    edicaoId: null as number | null,
    mes: this.mes,
    ano: this.ano,
    prioridade: 'MEDIA',
    status: 'PLANEJADA',
    precoEstimado: null as number | null,
    linkCompra: '',
    observacoes: '',
  };

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.api.listarComprasPlanejadas(this.mes, this.ano).subscribe({
      next: (resposta) => this.compras.set(resposta),
      error: () => this.compras.set([]),
    });
  }

  cadastrarCompra() {
    if (!this.formulario.edicaoId) {
      this.mensagem.set('Informe o ID da edição.');
      return;
    }

    this.salvando.set(true);
    this.mensagem.set('');
    this.api
      .cadastrarCompraPlanejada({
        edicaoId: this.formulario.edicaoId,
        mes: this.formulario.mes,
        ano: this.formulario.ano,
        prioridade: this.formulario.prioridade,
        status: this.formulario.status,
        precoEstimado: this.formulario.precoEstimado,
        linkCompra: this.formulario.linkCompra || null,
        observacoes: this.formulario.observacoes || null,
      })
      .subscribe({
        next: () => {
          this.salvando.set(false);
          this.mes = this.formulario.mes;
          this.ano = this.formulario.ano;
          this.formulario = {
            ...this.formulario,
            edicaoId: null,
            precoEstimado: null,
            linkCompra: '',
            observacoes: '',
          };
          this.carregar();
        },
        error: () => {
          this.salvando.set(false);
          this.mensagem.set('Não foi possível cadastrar a compra.');
        },
      });
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }
}
