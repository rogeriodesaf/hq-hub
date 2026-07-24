import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { EstanteCompartilhada } from '../../core/modelos';

@Component({
  selector: 'app-estante-publica-page',
  imports: [CommonModule, RouterLink],
  template: `
    <main class="pagina-compartilhada">
      <header class="hero-estante">
        <a class="marca" routerLink="/entrar">HQ-HUB</a>
        @if (estante()) {
          <div>
            <p class="rotulo">Coleção virtual de</p>
            <h1>{{ estante()!.nome }}</h1>
            <p>{{ totalEdicoes() }} revistas · {{ totalSeries() }} séries</p>
          </div>
          <div class="acoes">
            <button class="botao secundario" type="button" (click)="copiarLink()">Copiar link</button>
            <a class="botao primario" routerLink="/entrar">Monte sua estante</a>
          </div>
        }
      </header>

      @if (mensagem()) {
        <p class="mensagem">{{ mensagem() }}</p>
      }

      @if (carregando()) {
        <section class="estado"><h2>Carregando estante...</h2></section>
      } @else if (!estante()) {
        <section class="estado">
          <h2>Estante indisponível</h2>
          <p>Ela não existe ou não está configurada como pública.</p>
          <a class="botao primario" routerLink="/entrar">Conhecer o HQ-HUB</a>
        </section>
      } @else {
        <section class="estante">
          @for (editora of estante()!.editoras; track editora.nome) {
            <article class="prateleira">
              <h2>{{ editora.nome }}</h2>
              @for (serie of editora.series; track serie.titulo + '-' + serie.volume) {
                <section class="serie">
                  <div class="titulo-serie">
                    <h3>{{ serie.titulo }} <small>V{{ serie.volume || 1 }}</small></h3>
                    <span>{{ serie.edicoes.length }} edições</span>
                  </div>
                  <div class="capas">
                    @for (edicao of serie.edicoes; track edicao.id) {
                      <div class="capa">
                        <img [src]="edicao.urlCapa || capaReserva" [alt]="edicao.titulo || 'Edição ' + edicao.numero" loading="lazy" (error)="usarReserva($event)" />
                        <strong>#{{ edicao.numero }}</strong>
                        <small [class.lido]="edicao.statusLeitura === 'LIDO'">
                          {{ edicao.statusLeitura === 'LIDO' ? 'Lido' : 'Não lido' }}
                        </small>
                      </div>
                    }
                  </div>
                </section>
              }
            </article>
          }
        </section>

        <section class="convite">
          <h2>Sua coleção também merece uma estante assim.</h2>
          <p>Organize suas revistas, leituras e edições faltantes gratuitamente no HQ-HUB.</p>
          <a class="botao primario" routerLink="/entrar">Criar minha conta</a>
        </section>
      }
    </main>
  `,
  styles: [`
    :host { display: block; min-height: 100vh; background: var(--fundo); color: var(--texto); }
    .pagina-compartilhada { width: min(1240px, calc(100% - 28px)); margin: auto; padding: 24px 0 56px; }
    .hero-estante { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 24px; padding: 28px; border-radius: 18px; background: linear-gradient(135deg, #111827, #26334a); color: white; }
    .hero-estante h1 { margin: 4px 0; font-size: clamp(2rem, 5vw, 3.8rem); }
    .hero-estante p { margin: 0; color: #dbe4f0; }
    .marca { color: #ff871f; font-size: 1.1rem; font-weight: 950; text-decoration: none; }
    .acoes { display: flex; flex-wrap: wrap; gap: 10px; }
    .estante { display: grid; gap: 22px; margin-top: 24px; }
    .prateleira { padding: 20px; border: 1px solid var(--borda); border-radius: 14px; background: var(--superficie); }
    .prateleira > h2 { margin: 0 0 18px; color: #ff871f; }
    .serie + .serie { margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--borda); }
    .titulo-serie { display: flex; justify-content: space-between; gap: 12px; align-items: baseline; }
    .titulo-serie h3 { margin: 0 0 12px; }
    .titulo-serie small { margin-left: 6px; color: var(--texto-suave); }
    .titulo-serie span { color: var(--texto-suave); white-space: nowrap; }
    .capas { display: flex; gap: 12px; overflow-x: auto; padding: 4px 2px 12px; }
    .capa { width: 112px; flex: 0 0 112px; display: grid; gap: 4px; }
    .capa img { width: 100%; aspect-ratio: 2 / 3; object-fit: cover; border-radius: 8px; box-shadow: 0 8px 20px rgba(0,0,0,.2); transition: transform .2s ease; }
    .capa:hover img { transform: translateY(-5px) scale(1.03); }
    .capa small { color: var(--texto-suave); }
    .capa small.lido { color: #16a34a; font-weight: 800; }
    .convite, .estado { margin-top: 28px; padding: 32px; border-radius: 16px; text-align: center; background: var(--superficie); border: 1px solid var(--borda); }
    .convite h2, .estado h2 { margin-top: 0; }
    .mensagem { padding: 10px 14px; border-radius: 8px; background: rgba(22,163,74,.12); color: #15803d; }
    @media (max-width: 600px) { .hero-estante { padding: 20px; } .acoes, .acoes .botao { width: 100%; } .titulo-serie { align-items: flex-start; } .capa { width: 96px; flex-basis: 96px; } }
  `],
})
export class EstantePublicaPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly rota = inject(ActivatedRoute);
  readonly estante = signal<EstanteCompartilhada | null>(null);
  readonly carregando = signal(true);
  readonly mensagem = signal('');
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly totalSeries = computed(() => this.estante()?.editoras.reduce((total, editora) => total + editora.series.length, 0) || 0);
  readonly totalEdicoes = computed(() => this.estante()?.editoras.reduce((total, editora) => total + editora.series.reduce((subtotal, serie) => subtotal + serie.edicoes.length, 0), 0) || 0);

  ngOnInit() {
    const id = Number(this.rota.snapshot.paramMap.get('id'));
    if (!id) {
      this.carregando.set(false);
      return;
    }
    this.api.obterEstanteCompartilhada(id).subscribe({
      next: (estante) => { this.estante.set(estante); this.carregando.set(false); },
      error: () => this.carregando.set(false),
    });
  }

  async copiarLink() {
    await navigator.clipboard.writeText(window.location.href);
    this.mensagem.set('Link copiado.');
  }

  usarReserva(evento: Event) {
    (evento.target as HTMLImageElement).src = this.capaReserva;
  }
}
