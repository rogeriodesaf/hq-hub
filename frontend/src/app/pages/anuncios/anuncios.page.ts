import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { Anuncio, EstadoConservacao, ItemColecao, TipoAnuncio } from '../../core/modelos';

@Component({
  selector: 'app-anuncios-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Classificados</p>
        <h1>Venda, troca e procura entre colecionadores.</h1>
      </div>
    </section>

    <section class="anuncios-layout">
      <article class="bloco">
        <div class="secao-titulo">
          <div>
            <h2>Anunciar item da minha estante</h2>
            <p class="texto-suave">Escolha uma HQ que voce possui e publique como venda ou troca.</p>
          </div>
        </div>

        <form class="grade-formulario anuncio-formulario" (ngSubmit)="cadastrarAnuncio()">
          <label class="campo-largo">
            Buscar na minha estante
            <input
              [(ngModel)]="buscaItem"
              name="buscaItem"
              placeholder="Digite titulo, serie ou numero"
              (ngModelChange)="filtrarItensColecao()"
            />
          </label>

          @if (itensFiltrados().length) {
            <div class="lista-escolha campo-largo">
              @for (item of itensFiltrados(); track item.id) {
                <button type="button" [class.ativo]="itemSelecionado()?.id === item.id" (click)="selecionarItem(item)">
                  <strong>{{ tituloItem(item) }}</strong>
                  <span>{{ item.estadoConservacao }} · {{ item.statusLeitura === 'LIDO' ? 'Lido' : 'Nao lido' }}</span>
                </button>
              }
            </div>
          }

          <label class="campo-largo">
            Item escolhido
            <input [value]="itemSelecionado() ? tituloItem(itemSelecionado()!) : 'Nenhum item escolhido'" disabled />
          </label>

          <label>
            Tipo de anuncio
            <select [(ngModel)]="formulario.tipoAnuncio" name="tipoAnuncio">
              <option value="VENDA">Venda</option>
              <option value="TROCA">Troca</option>
              <option value="VENDA_E_TROCA">Venda ou troca</option>
            </select>
          </label>

          <label>
            Preco
            <input type="number" min="0" step="0.01" [(ngModel)]="formulario.preco" name="preco" placeholder="Opcional para troca" />
          </label>

          <label>
            Conservacao
            <select [(ngModel)]="formulario.estadoConservacao" name="estadoConservacao">
              <option value="NOVO">Novo</option>
              <option value="EXCELENTE">Excelente</option>
              <option value="MUITO_BOM">Muito bom</option>
              <option value="BOM">Bom</option>
              <option value="REGULAR">Regular</option>
              <option value="RUIM">Ruim</option>
            </select>
          </label>

          <label>
            Cidade
            <input [(ngModel)]="formulario.cidade" name="cidade" placeholder="Ex.: Joao Pessoa" />
          </label>

          <label>
            UF
            <input [(ngModel)]="formulario.estado" name="estado" maxlength="2" placeholder="PB" />
          </label>

          <label>
            WhatsApp
            <input [(ngModel)]="formulario.contatoWhatsapp" name="contatoWhatsapp" placeholder="DDD + numero" />
          </label>

          <label>
            Mostrar WhatsApp
            <select [(ngModel)]="formulario.exibirWhatsapp" name="exibirWhatsapp">
              <option [ngValue]="true">Sim</option>
              <option [ngValue]="false">Nao</option>
            </select>
          </label>

          <label class="campo-largo">
            Descricao
            <textarea [(ngModel)]="formulario.descricao" name="descricao" rows="3" placeholder="Estado, detalhes, o que aceita em troca..."></textarea>
          </label>

          <button class="botao primario" type="submit" [disabled]="salvando() || !itemSelecionado()">
            {{ salvando() ? 'Publicando...' : 'Publicar anuncio' }}
          </button>
        </form>

        @if (mensagemFormulario()) {
          <p class="mensagem-erro compacto">{{ mensagemFormulario() }}</p>
        }
      </article>

      <article class="bloco">
        <div class="secao-titulo">
          <div>
            <h2>Meus anuncios</h2>
            <p class="texto-suave">Controle o que voce esta oferecendo.</p>
          </div>
        </div>

        <div class="lista-anuncios compacta">
          @for (anuncio of meusAnuncios(); track anuncio.id) {
            <article>
              <strong>{{ anuncio.tituloEdicao }}</strong>
              <span>{{ rotuloTipo(anuncio.tipoAnuncio) }} · {{ anuncio.status }}</span>
              <div class="acoes-linha">
                @if (anuncio.status === 'ATIVO') {
                  <button class="botao compacto" type="button" (click)="pausar(anuncio)">Pausar</button>
                } @else if (anuncio.status === 'PAUSADO') {
                  <button class="botao compacto" type="button" (click)="reativar(anuncio)">Reativar</button>
                }
                @if (anuncio.status !== 'ENCERRADO') {
                  <button class="botao compacto" type="button" (click)="encerrar(anuncio)">Encerrar</button>
                }
              </div>
            </article>
          } @empty {
            <section class="estado-vazio compacto">
              <h2>Nenhum anuncio seu</h2>
              <p>Os itens anunciados aparecem aqui.</p>
            </section>
          }
        </div>
      </article>
    </section>

    <section class="bloco">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Mercado de colecionadores</p>
          <h2>Anuncios ativos</h2>
        </div>
        <button class="botao compacto" type="button" (click)="carregar()">Atualizar</button>
      </div>

      <section class="grade-anuncios">
        @for (anuncio of anunciosFiltrados(); track anuncio.id) {
          <article class="anuncio-card">
            <img [src]="anuncio.itemColecao.edicao.urlCapa || capaReserva" [alt]="anuncio.tituloEdicao" loading="lazy" />
            <div>
              <p class="rotulo">{{ rotuloTipo(anuncio.tipoAnuncio) }}</p>
              <h3>{{ anuncio.tituloEdicao }}</h3>
              <p>{{ anuncio.descricao || 'Sem descricao.' }}</p>
              <span>{{ anuncio.nomeAnunciante }} · {{ anuncio.cidade || 'Cidade nao informada' }}{{ anuncio.estado ? '/' + anuncio.estado : '' }}</span>
              <strong>{{ anuncio.preco ? formatarMoeda(anuncio.preco) : 'Valor a combinar' }}</strong>
              <div class="acoes-linha">
                @if (anuncio.linkContatoWhatsapp) {
                  <a class="botao compacto primario" [href]="anuncio.linkContatoWhatsapp" target="_blank" rel="noreferrer">
                    Chamar no WhatsApp
                  </a>
                } @else {
                  <button class="botao compacto" type="button" (click)="obterContato(anuncio)">Ver contato</button>
                }
              </div>
            </div>
          </article>
        } @empty {
          <section class="estado-vazio">
            <h2>Nenhum anuncio ativo</h2>
            <p>Quando colecionadores publicarem vendas ou trocas, elas aparecem aqui.</p>
          </section>
        }
      </section>
    </section>
  `,
})
export class AnunciosPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly itensColecao = signal<ItemColecao[]>([]);
  readonly itensFiltrados = signal<ItemColecao[]>([]);
  readonly itemSelecionado = signal<ItemColecao | null>(null);
  readonly anuncios = signal<Anuncio[]>([]);
  readonly meusAnuncios = signal<Anuncio[]>([]);
  readonly salvando = signal(false);
  readonly mensagemFormulario = signal('');
  buscaItem = '';
  formulario = {
    tipoAnuncio: 'VENDA' as TipoAnuncio,
    preco: null as number | null,
    estadoConservacao: 'MUITO_BOM' as EstadoConservacao,
    descricao: '',
    cidade: '',
    estado: '',
    contatoWhatsapp: '',
    exibirWhatsapp: true,
  };

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.api.listarItensColecao().subscribe({
      next: (itens) => {
        this.itensColecao.set(itens);
        this.itensFiltrados.set(itens.slice(0, 8));
      },
      error: () => {
        this.itensColecao.set([]);
        this.itensFiltrados.set([]);
      },
    });

    this.api.listarAnuncios().subscribe({
      next: (anuncios) => this.anuncios.set(anuncios),
      error: () => this.anuncios.set([]),
    });

    this.api.listarMeusAnuncios().subscribe({
      next: (anuncios) => this.meusAnuncios.set(anuncios),
      error: () => this.meusAnuncios.set([]),
    });
  }

  anunciosFiltrados() {
    return this.anuncios();
  }

  filtrarItensColecao() {
    const termo = this.normalizar(this.buscaItem);
    const itens = this.itensColecao();

    if (!termo) {
      this.itensFiltrados.set(itens.slice(0, 8));
      return;
    }

    this.itensFiltrados.set(
      itens
        .filter((item) => this.normalizar(this.tituloItem(item)).includes(termo))
        .slice(0, 8),
    );
  }

  selecionarItem(item: ItemColecao) {
    this.itemSelecionado.set(item);
    this.formulario.estadoConservacao = item.estadoConservacao as EstadoConservacao;
    this.mensagemFormulario.set('');
  }

  cadastrarAnuncio() {
    const item = this.itemSelecionado();
    if (!item) {
      this.mensagemFormulario.set('Escolha um item da sua estante para anunciar.');
      return;
    }

    this.salvando.set(true);
    this.mensagemFormulario.set('');
    this.api
      .cadastrarAnuncio({
        itemColecaoId: item.id,
        tipoAnuncio: this.formulario.tipoAnuncio,
        preco: this.formulario.preco,
        estadoConservacao: this.formulario.estadoConservacao,
        descricao: this.formulario.descricao || null,
        cidade: this.formulario.cidade || null,
        estado: this.formulario.estado || null,
        contatoWhatsapp: this.formulario.contatoWhatsapp || null,
        exibirWhatsapp: this.formulario.exibirWhatsapp,
      })
      .subscribe({
        next: () => {
          this.salvando.set(false);
          this.mensagemFormulario.set('Anuncio publicado.');
          this.limparFormulario();
          this.carregar();
        },
        error: (erro) => {
          const resposta = erro as { error?: { mensagem?: string } };
          this.salvando.set(false);
          this.mensagemFormulario.set(resposta.error?.mensagem ?? 'Nao foi possivel publicar o anuncio.');
        },
      });
  }

  pausar(anuncio: Anuncio) {
    this.api.pausarAnuncio(anuncio.id).subscribe({ next: () => this.carregar() });
  }

  reativar(anuncio: Anuncio) {
    this.api.reativarAnuncio(anuncio.id).subscribe({ next: () => this.carregar() });
  }

  encerrar(anuncio: Anuncio) {
    this.api.encerrarAnuncio(anuncio.id).subscribe({ next: () => this.carregar() });
  }

  obterContato(anuncio: Anuncio) {
    this.api.obterContatoAnuncio(anuncio.id).subscribe({
      next: (contato) => window.open(contato.linkWhatsapp, '_blank', 'noreferrer'),
      error: () => this.mensagemFormulario.set('Este anunciante nao disponibilizou contato pelo WhatsApp.'),
    });
  }

  tituloItem(item: ItemColecao) {
    return `${item.edicao.serie?.titulo || 'Serie nao informada'} #${item.edicao.numero}${item.edicao.titulo ? ' - ' + item.edicao.titulo : ''}`;
  }

  rotuloTipo(tipo: TipoAnuncio) {
    if (tipo === 'VENDA') {
      return 'Venda';
    }
    if (tipo === 'TROCA') {
      return 'Troca';
    }
    return 'Venda ou troca';
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  private limparFormulario() {
    this.itemSelecionado.set(null);
    this.buscaItem = '';
    this.formulario = {
      tipoAnuncio: 'VENDA',
      preco: null,
      estadoConservacao: 'MUITO_BOM',
      descricao: '',
      cidade: '',
      estado: '',
      contatoWhatsapp: '',
      exibirWhatsapp: true,
    };
  }

  private normalizar(valor: string) {
    return valor.trim().toLocaleLowerCase('pt-BR');
  }
}

