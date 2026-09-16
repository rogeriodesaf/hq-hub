import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { CompartilhamentoService } from '../../core/compartilhamento.service';
import { AnuncioPublico, TipoAnuncio } from '../../core/modelos';

@Component({
  selector: 'app-classificados-publicos-page',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <main class="pagina-classificados">
      <header class="hero">
        <a class="marca" routerLink="/entrar">HQ-HUB</a>
        <div>
          <p class="rotulo">Mercado de colecionadores</p>
          <h1>Anúncios ativos</h1>
          <p>HQs à venda e para troca, oferecidas diretamente por colecionadores.</p>
        </div>
        <a class="botao primario" routerLink="/entrar">Entrar ou criar conta</a>
      </header>

      @if (idSelecionado()) {
        @if (carregandoDetalhe()) {
          <section class="estado" role="status">Carregando anúncio...</section>
        } @else if (anuncioSelecionado(); as anuncio) {
          <article class="detalhe-anuncio-publico" id="anuncio-selecionado">
            <img [src]="anuncio.urlFotoExemplar || anuncio.urlCapa || capaReserva" [alt]="'Foto de ' + anuncio.tituloEdicao" (error)="usarReserva($event)" />
            <div>
              <p class="rotulo">{{ rotuloTipo(anuncio.tipoAnuncio) }}</p>
              <h1>{{ anuncio.tituloEdicao }}</h1>
              @if (anuncio.preco !== null) { <strong>{{ formatarMoeda(anuncio.preco) }}</strong> }
              @if (anuncio.estadoConservacao) { <p>Conservação: {{ rotuloConservacao(anuncio.estadoConservacao) }}</p> }
              @if (anuncio.nomeAnunciante) { <p>Anunciante: {{ anuncio.nomeAnunciante }}</p> }
              @if (anuncio.descricao) { <p>{{ anuncio.descricao }}</p> }
              <div class="acoes-anuncio-publico">
                @if (anuncio.linkContatoWhatsapp) { <a class="botao primario compacto" [href]="anuncio.linkContatoWhatsapp" target="_blank" rel="noopener noreferrer">Perguntar no WhatsApp</a> }
                <button class="botao compacto" type="button" (click)="compartilharAnuncio(anuncio)">Compartilhar anúncio</button>
                <a class="botao compacto" routerLink="/classificados" [queryParams]="{}">Ver todos</a>
              </div>
              @if (mensagemCompartilhamento()) { <p role="status">{{ mensagemCompartilhamento() }}</p> }
            </div>
          </article>
        } @else {
          <section class="estado"><h2>Anúncio indisponível</h2><p>Este anúncio não está mais ativo.</p><a routerLink="/classificados">Ver classificados</a></section>
        }
      }

      @if (carregando()) {
        <section class="estado"><h2>Carregando anúncios...</h2></section>
      } @else {
        <section class="grade">
          @for (anuncio of anuncios(); track anuncio.id) {
            <article class="card">
              <img [src]="anuncio.urlFotoExemplar || anuncio.urlCapa || capaReserva" [alt]="anuncio.tituloEdicao" loading="lazy" (error)="usarReserva($event)" />
              <div>
                <p class="rotulo">{{ rotuloTipo(anuncio.tipoAnuncio) }}</p>
                <h2>{{ anuncio.tituloEdicao }}</h2>
                <p class="descricao">{{ anuncio.descricao || 'Edição anunciada por um colecionador do HQ-HUB.' }}</p>
                <span>{{ anuncio.nomeAnunciante }} · {{ anuncio.cidade || 'Local não informado' }}{{ anuncio.estado ? '/' + anuncio.estado : '' }}</span>
                <strong>{{ anuncio.preco ? formatarMoeda(anuncio.preco) : 'Valor a combinar' }}</strong>
                <a class="botao compacto" routerLink="/classificados" [queryParams]="{ anuncioId: anuncio.id }">Ver anúncio</a>
                @if (anuncio.linkContatoWhatsapp) {
                  <a class="botao primario compacto" [href]="anuncio.linkContatoWhatsapp" target="_blank" rel="noopener noreferrer">Perguntar no WhatsApp</a>
                } @else {
                  <a class="botao compacto" routerLink="/entrar">Entrar para saber mais</a>
                }
              </div>
            </article>
          } @empty {
            <section class="estado"><h2>Nenhum anúncio ativo agora.</h2><p>Volte em breve para conferir novas edições.</p></section>
          }
        </section>
      }

      <footer class="convite">
        <h2>Tem quadrinhos para vender ou trocar?</h2>
        <p>Crie sua estante no HQ-HUB e publique seus anúncios.</p>
        <a class="botao primario" routerLink="/entrar">Participar do HQ-HUB</a>
      </footer>
    </main>
  `,
  styles: [`
    :host { display: block; min-height: 100vh; background: var(--fundo); }
    .pagina-classificados { width: min(1180px, calc(100% - 32px)); margin: 0 auto; padding: 28px 0 48px; }
    .hero { display: grid; grid-template-columns: auto 1fr auto; gap: 24px; align-items: center; padding: 28px; border-radius: 18px; background: linear-gradient(135deg,#101722,#31200f 60%,#9c4300); color: #fff; box-shadow: var(--sombra); }
    .marca { color: #ff8a1f; font-size: 1.5rem; font-weight: 950; text-decoration: none; }
    .hero h1, .hero p { margin: 0; } .hero h1 { margin: 4px 0 8px; font-size: clamp(1.7rem,4vw,2.7rem); }
    .grade { display: grid; grid-template-columns: repeat(auto-fill,minmax(245px,1fr)); gap: 18px; margin-top: 24px; }
    .card { overflow: hidden; border: 1px solid var(--borda); border-radius: 14px; background: var(--superficie); box-shadow: 0 10px 30px rgba(21,25,31,.08); }
    .card > img { width: 100%; aspect-ratio: 3/4; object-fit: contain; padding: 14px; background: var(--superficie-suave); transition: transform .2s ease; }
    .card:hover > img { transform: scale(1.035); }
    .card > div { display: grid; gap: 9px; padding: 16px; }
    .card h2, .card p { margin: 0; } .card h2 { font-size: 1.05rem; } .card span, .descricao { color: var(--texto-suave); line-height: 1.45; }
    .card strong { color: var(--marca-escura); font-size: 1.12rem; }
    .estado, .convite { margin-top: 24px; padding: 32px; border: 1px solid var(--borda); border-radius: 14px; background: var(--superficie); text-align: center; }
    .convite h2, .convite p { margin: 0 0 10px; }
    .detalhe-anuncio-publico { display: grid; grid-template-columns: minmax(160px, 260px) minmax(0, 1fr); gap: 22px; margin-top: 24px; padding: 20px; border-radius: 14px; background: var(--superficie); color: var(--texto); }
    .detalhe-anuncio-publico > img { width: 100%; max-height: 390px; object-fit: contain; background: var(--superficie-2); }
    .detalhe-anuncio-publico h1 { margin: 0 0 12px; font-size: clamp(1.4rem, 3vw, 2rem); }
    .detalhe-anuncio-publico p { margin: 8px 0; }
    .detalhe-anuncio-publico strong { font-size: 1.3rem; }
    .acoes-anuncio-publico { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 16px; }
    @media (max-width: 620px) { .detalhe-anuncio-publico { grid-template-columns: 1fr; } }
    @media (max-width: 720px) { .hero { grid-template-columns: 1fr; } .hero .botao { width: 100%; } }
  `],
})
export class ClassificadosPublicosPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly rota = inject(ActivatedRoute);
  private readonly compartilhamento = inject(CompartilhamentoService);
  readonly anuncios = signal<AnuncioPublico[]>([]);
  readonly carregando = signal(true);
  readonly idSelecionado = signal<number | null>(null);
  readonly anuncioSelecionado = signal<AnuncioPublico | null>(null);
  readonly carregandoDetalhe = signal(false);
  readonly mensagemCompartilhamento = signal('');
  readonly capaReserva = 'assets/capa-reserva.svg';

  ngOnInit() {
    this.rota.queryParamMap.subscribe((parametros) => {
      const id = Number(parametros.get('anuncioId'));
      this.idSelecionado.set(Number.isInteger(id) && id > 0 ? id : null);
      this.anuncioSelecionado.set(null);
      if (!this.idSelecionado()) return;
      this.carregandoDetalhe.set(true);
      this.api.buscarAnuncioPublico(id).subscribe({
        next: (anuncio) => {
          if (this.idSelecionado() !== id) return;
          this.anuncioSelecionado.set(anuncio);
          this.carregandoDetalhe.set(false);
        },
        error: () => { if (this.idSelecionado() === id) this.carregandoDetalhe.set(false); },
      });
    });
    this.api.listarAnunciosPublicos().subscribe({
      next: (anuncios) => { this.anuncios.set(anuncios); this.carregando.set(false); },
      error: () => this.carregando.set(false),
    });
  }

  rotuloTipo(tipo: TipoAnuncio) {
    return tipo === 'VENDA' ? 'Venda' : tipo === 'TROCA' ? 'Troca' : 'Venda ou troca';
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  rotuloConservacao(valor: string) {
    return valor.replaceAll('_', ' ').toLowerCase();
  }

  async compartilharAnuncio(anuncio: AnuncioPublico) {
    const url = `https://hqhub.space/classificados/anuncio/${anuncio.id}?v=${Date.now()}`;
    const preco = anuncio.preco != null ? ` por ${this.formatarMoeda(anuncio.preco)}` : '';
    try {
      const resultado = await this.compartilhamento.compartilhar({ title: `${anuncio.tituloEdicao} | HQ-HUB`, text: `Estou vendendo esta HQ${preco}. Veja o anúncio no HQ-HUB:`, url });
      if (resultado === 'copiado') this.mensagemCompartilhamento.set('Link do anúncio copiado.');
    } catch {
      this.mensagemCompartilhamento.set('Não foi possível compartilhar este anúncio.');
    }
  }

  usarReserva(evento: Event) {
    (evento.target as HTMLImageElement).src = this.capaReserva;
  }
}
