import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { Edicao, EstanteEditora } from '../../core/modelos';

@Component({
  selector: 'app-colecao-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Estante</p>
        <h1>Suas HQs agrupadas por editora e série.</h1>
      </div>
    </section>

    <section class="painel-formulario">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Adicionar ao perfil</p>
          <h2>Cadastrar edição na sua coleção</h2>
        </div>
      </div>

      <div class="barra-busca">
        <input [(ngModel)]="buscaEdicao" placeholder="Busque por título, número ou série" (keyup.enter)="buscarEdicoes()" />
        <button class="botao primario" type="button" (click)="buscarEdicoes()" [disabled]="carregandoEdicoes()">
          {{ carregandoEdicoes() ? 'Buscando...' : 'Buscar edição' }}
        </button>
      </div>

      @if (edicoesEncontradas().length) {
        <div class="lista-escolha">
          @for (edicao of edicoesEncontradas(); track edicao.id) {
            <button type="button" [class.ativo]="edicaoSelecionada()?.id === edicao.id" (click)="selecionarEdicao(edicao)">
              <strong>{{ tituloEdicao(edicao) }}</strong>
              <span>{{ edicao.serie?.titulo || 'Série não informada' }}</span>
            </button>
          }
        </div>
      }

      <form class="grade-formulario colecao-formulario" (ngSubmit)="cadastrarNaColecao()">
        <label>
          Edição escolhida
          <input [value]="edicaoSelecionada() ? tituloEdicao(edicaoSelecionada()!) : 'Nenhuma edição selecionada'" disabled />
        </label>

        <label>
          Conservação
          <select [(ngModel)]="estadoConservacao" name="estadoConservacao">
            <option value="NOVO">Novo</option>
            <option value="EXCELENTE">Excelente</option>
            <option value="MUITO_BOM">Muito bom</option>
            <option value="BOM">Bom</option>
            <option value="REGULAR">Regular</option>
            <option value="RUIM">Ruim</option>
          </select>
        </label>

        <label>
          Data da compra
          <input type="date" [(ngModel)]="dataAquisicao" name="dataAquisicao" />
        </label>

        <label>
          Preço pago
          <input type="number" min="0" step="0.01" [(ngModel)]="precoPago" name="precoPago" placeholder="0,00" />
        </label>

        <label>
          Leitura
          <select [(ngModel)]="statusLeitura" name="statusLeitura">
            <option value="NAO_LIDO">Não lido</option>
            <option value="LIDO">Lido</option>
          </select>
        </label>

        <label class="campo-largo">
          Observações
          <input [(ngModel)]="observacoes" name="observacoes" placeholder="Ex.: comprado em promoção, capa variante..." />
        </label>

        <button class="botao primario" type="submit" [disabled]="salvandoItem() || !edicaoSelecionada()">
          {{ salvandoItem() ? 'Salvando...' : 'Adicionar à estante' }}
        </button>
      </form>

      @if (mensagem()) {
        <p class="mensagem-erro">{{ mensagem() }}</p>
      }
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
  readonly edicoesEncontradas = signal<Edicao[]>([]);
  readonly edicaoSelecionada = signal<Edicao | null>(null);
  readonly carregandoEdicoes = signal(false);
  readonly salvandoItem = signal(false);
  readonly mensagem = signal('');
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

  buscaEdicao = '';
  estadoConservacao = 'MUITO_BOM';
  dataAquisicao = '';
  precoPago: number | null = null;
  statusLeitura = 'NAO_LIDO';
  observacoes = '';

  ngOnInit() {
    this.carregarEstante();
  }

  buscarEdicoes() {
    if (!this.buscaEdicao.trim()) {
      this.mensagem.set('Informe um termo para buscar a edição.');
      return;
    }

    this.mensagem.set('');
    this.carregandoEdicoes.set(true);
    this.api.listarEdicoes(this.buscaEdicao, 0, 8).subscribe({
      next: (resposta) => {
        this.edicoesEncontradas.set(resposta.itens);
        this.carregandoEdicoes.set(false);
        if (!resposta.itens.length) {
          this.mensagem.set('Nenhuma edição encontrada no catálogo interno.');
        }
      },
      error: () => {
        this.edicoesEncontradas.set([]);
        this.carregandoEdicoes.set(false);
        this.mensagem.set('Não foi possível buscar edições agora.');
      },
    });
  }

  selecionarEdicao(edicao: Edicao) {
    this.edicaoSelecionada.set(edicao);
    this.mensagem.set('');
  }

  cadastrarNaColecao() {
    const edicao = this.edicaoSelecionada();
    if (!edicao) {
      this.mensagem.set('Escolha uma edição antes de cadastrar.');
      return;
    }

    this.salvandoItem.set(true);
    this.mensagem.set('');
    this.api
      .cadastrarItemColecao({
        edicaoId: edicao.id,
        estadoConservacao: this.estadoConservacao,
        dataAquisicao: this.dataAquisicao || null,
        precoPago: this.precoPago,
        statusLeitura: this.statusLeitura,
        observacoes: this.observacoes || null,
      })
      .subscribe({
        next: () => {
          this.salvandoItem.set(false);
          this.mensagem.set('Edição adicionada à sua estante.');
          this.limparFormulario();
          this.carregarEstante();
        },
        error: () => {
          this.salvandoItem.set(false);
          this.mensagem.set('Não foi possível adicionar a edição. Verifique se ela já está na sua coleção.');
        },
      });
  }

  tituloEdicao(edicao: Edicao) {
    return `#${edicao.numero}${edicao.titulo ? ' - ' + edicao.titulo : ''}`;
  }

  rotuloLeitura(status: string) {
    return status === 'LIDO' ? 'Lido' : 'Não lido';
  }

  formatarData(data: string) {
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(
      new Date(`${data}T00:00:00`),
    );
  }

  private carregarEstante() {
    this.api.obterEstante().subscribe({
      next: (resposta) => this.estante.set(resposta),
      error: () => this.estante.set([]),
    });
  }

  private limparFormulario() {
    this.edicoesEncontradas.set([]);
    this.edicaoSelecionada.set(null);
    this.buscaEdicao = '';
    this.estadoConservacao = 'MUITO_BOM';
    this.dataAquisicao = '';
    this.precoPago = null;
    this.statusLeitura = 'NAO_LIDO';
    this.observacoes = '';
  }
}
