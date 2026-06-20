import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { CompraPlanejada, Edicao } from '../../core/modelos';

@Component({
  selector: 'app-compras-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Planejamento</p>
        <h1>Compras do mes, prioridades e links de venda.</h1>
      </div>
    </section>

    <section class="painel-formulario">
      <div>
        <p class="rotulo">Nova compra do mes</p>
        <h2>Escolha a edicao pelo catalogo e organize suas proximas compras.</h2>
      </div>

      <form class="grade-formulario" (ngSubmit)="cadastrarCompra()">
        <label class="campo-largo">
          Buscar edicao
          <input
            name="buscaEdicao"
            [(ngModel)]="buscaEdicao"
            placeholder="Digite titulo, serie ou numero da HQ"
            (keyup.enter)="buscarEdicoes()"
          />
        </label>

        <button class="botao" type="button" (click)="buscarEdicoes()" [disabled]="buscandoEdicoes()">
          {{ buscandoEdicoes() ? 'Buscando...' : 'Buscar edicao' }}
        </button>

        <div class="acoes-linha campo-largo acoes-busca-externa">
          <button class="botao compacto" type="button" (click)="abrirBuscaPanini()" [disabled]="!buscaEdicao.trim()">
            Panini
          </button>
          <button class="botao compacto" type="button" (click)="abrirBuscaAmazon()" [disabled]="!buscaEdicao.trim()">
            Amazon
          </button>
        </div>

        @if (edicoesEncontradas().length) {
          <div class="lista-escolha campo-largo">
            @for (edicao of edicoesEncontradas(); track edicao.id) {
              <button type="button" [class.ativo]="edicaoSelecionada()?.id === edicao.id" (click)="selecionarEdicao(edicao)">
                <strong>{{ tituloEdicao(edicao) }}</strong>
                <span>{{ edicao.serie?.editora?.nome || 'Editora nao informada' }}</span>
              </button>
            }
          </div>
        }

        <label class="campo-largo">
          Edicao escolhida
          <input [value]="edicaoSelecionada() ? tituloEdicao(edicaoSelecionada()!) : 'Nenhuma edicao escolhida'" disabled />
        </label>

        <label>
          Mes
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
            <option value="MEDIA">Media</option>
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
          Observacoes
          <textarea name="observacoes" rows="3" [(ngModel)]="formulario.observacoes"></textarea>
        </label>

        <button class="botao primario" type="submit" [disabled]="salvando() || !edicaoSelecionada()">
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
            <p>{{ compra.observacoes || 'Sem observacoes.' }}</p>
            @if (compra.linkCompra) {
              <a class="botao compacto" [href]="compra.linkCompra" target="_blank" rel="noreferrer">Abrir loja</a>
            }
          </div>
          <strong>{{ formatarMoeda(compra.precoEstimado || 0) }}</strong>
        </article>
      } @empty {
        <section class="estado-vazio">
          <h2>Nenhuma compra para este mes</h2>
          <p>Quando voce cadastrar proximas compras, elas aparecem aqui por mes e prioridade.</p>
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
  readonly edicoesEncontradas = signal<Edicao[]>([]);
  readonly edicaoSelecionada = signal<Edicao | null>(null);
  readonly buscandoEdicoes = signal(false);
  readonly salvando = signal(false);
  readonly mensagem = signal('');
  mes = new Date().getMonth() + 1;
  ano = new Date().getFullYear();
  buscaEdicao = '';
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

  buscarEdicoes() {
    if (!this.buscaEdicao.trim()) {
      this.mensagem.set('Digite um titulo, serie ou numero para buscar a edicao.');
      return;
    }

    this.buscandoEdicoes.set(true);
    this.mensagem.set('');
    this.api.listarEdicoes(this.buscaEdicao, 0, 12).subscribe({
      next: (resposta) => {
        this.edicoesEncontradas.set(resposta.itens);
        this.buscandoEdicoes.set(false);
        if (!resposta.itens.length) {
          this.mensagem.set('Nao achei essa edicao no catalogo interno. Tente Panini ou Amazon abaixo.');
        }
      },
      error: () => {
        this.edicoesEncontradas.set([]);
        this.buscandoEdicoes.set(false);
        this.mensagem.set('Nao foi possivel buscar edicoes agora.');
      },
    });
  }

  selecionarEdicao(edicao: Edicao) {
    this.edicaoSelecionada.set(edicao);
    this.formulario.edicaoId = edicao.id;
    this.mensagem.set('');
  }

  cadastrarCompra() {
    if (!this.formulario.edicaoId) {
      this.mensagem.set('Escolha uma edicao antes de cadastrar a compra.');
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
          this.buscaEdicao = '';
          this.edicoesEncontradas.set([]);
          this.edicaoSelecionada.set(null);
          this.carregar();
        },
        error: () => {
          this.salvando.set(false);
          this.mensagem.set('Nao foi possivel cadastrar a compra.');
        },
      });
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  abrirBuscaPanini() {
    const termo = encodeURIComponent(this.buscaEdicao.trim());
    window.open(`https://venda.panini.com.br/catalogsearch/result/?q=${termo}`, '_blank', 'noreferrer');
  }

  abrirBuscaAmazon() {
    const termo = encodeURIComponent(this.buscaEdicao.trim());
    window.open(`https://www.amazon.com.br/s?k=${termo}`, '_blank', 'noreferrer');
  }

  tituloEdicao(edicao: Edicao) {
    return `${edicao.serie?.titulo || 'Serie nao informada'} #${edicao.numero}${edicao.titulo ? ' - ' + edicao.titulo : ''}`;
  }
}

