import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { PostagemColecaoPublica } from '../../core/modelos';

@Component({
  selector: 'app-colecao-compartilhada-page',
  imports: [CommonModule, RouterLink],
  template: `
    <main class="pagina-publica">
      <header class="topo">
        <a class="marca" routerLink="/entrar">HQ-HUB</a>
        <a class="botao secundario compacto" routerLink="/entrar">Entrar ou criar conta</a>
      </header>

      @if (carregando()) {
        <section class="estado">
          <h1>Carregando coleção...</h1>
        </section>
      } @else if (!colecao()) {
        <section class="estado">
          <h1>Coleção indisponível</h1>
          <p>Esta postagem não existe mais ou não possui uma coleção compartilhada.</p>
          <a class="botao primario" routerLink="/entrar">Conhecer o HQ-HUB</a>
        </section>
      } @else {
        <section class="hero">
          <div>
            <p class="rotulo">Coleção compartilhada por {{ colecao()!.nomeUsuario }}</p>
            <h1>{{ colecao()!.titulo }}</h1>
            <p class="editora">{{ colecao()!.editora }} · {{ colecao()!.edicoes.length }} edições</p>
            @if (colecao()!.conteudo) {
              <blockquote>{{ colecao()!.conteudo }}</blockquote>
            }
          </div>
          <button class="botao secundario" type="button" (click)="copiarLink()">
            {{ linkCopiado() ? 'Link copiado' : 'Copiar link' }}
          </button>
        </section>

        <section class="colecao" aria-label="Edições da coleção">
          @for (edicao of colecao()!.edicoes; track edicao.id) {
            <article class="edicao">
              <img
                [src]="edicao.urlCapa || capaReserva"
                [alt]="edicao.titulo || 'Edição ' + edicao.numero"
                loading="lazy"
                (error)="usarReserva($event)"
              />
              <div>
                <strong>#{{ edicao.numero }}</strong>
                @if (edicao.titulo) {
                  <span>{{ edicao.titulo }}</span>
                }
                <small [class.lido]="edicao.statusLeitura === 'LIDO'">
                  {{ edicao.statusLeitura === 'LIDO' ? 'Lido' : 'Não lido' }}
                </small>
              </div>
            </article>
          }
        </section>

        <section class="convite">
          <h2>Organize também a sua coleção de quadrinhos</h2>
          <p>Cadastre suas HQs, acompanhe leituras e descubra o que falta na sua estante.</p>
          <a class="botao primario" routerLink="/entrar">Criar minha conta no HQ-HUB</a>
        </section>
      }
    </main>
  `,
  styles: [`
    :host { display: block; min-height: 100vh; background: var(--fundo); color: var(--texto); }
    .pagina-publica { width: min(1180px, calc(100% - 28px)); margin: auto; padding: 18px 0 56px; }
    .topo { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 18px; }
    .marca { color: #ff871f; font-size: 1.25rem; font-weight: 950; text-decoration: none; }
    .hero { display: flex; align-items: flex-end; justify-content: space-between; gap: 28px; padding: clamp(24px, 5vw, 48px); border-radius: 22px; background: linear-gradient(135deg, #111827, #26334a); color: white; box-shadow: 0 18px 45px rgba(15, 23, 42, .18); }
    .hero h1 { margin: 6px 0; max-width: 850px; font-size: clamp(2rem, 6vw, 4.6rem); line-height: 1; }
    .hero .editora { margin: 0; color: #dbe4f0; }
    .hero blockquote { max-width: 720px; margin: 22px 0 0; padding-left: 16px; border-left: 3px solid #ff871f; color: #f1f5f9; font-size: 1.05rem; }
    .colecao { display: grid; grid-template-columns: repeat(auto-fill, minmax(145px, 1fr)); gap: 20px; margin-top: 28px; }
    .edicao { min-width: 0; padding: 10px; border: 1px solid var(--borda); border-radius: 14px; background: var(--superficie); }
    .edicao img { width: 100%; aspect-ratio: 2 / 3; object-fit: cover; border-radius: 9px; box-shadow: 0 10px 24px rgba(0, 0, 0, .2); }
    .edicao div { display: grid; gap: 3px; padding: 10px 2px 2px; }
    .edicao span { overflow: hidden; color: var(--texto-suave); font-size: .88rem; text-overflow: ellipsis; white-space: nowrap; }
    .edicao small { color: var(--texto-suave); }
    .edicao small.lido { color: #16a34a; font-weight: 800; }
    .convite, .estado { margin-top: 30px; padding: 36px 24px; border: 1px solid var(--borda); border-radius: 18px; background: var(--superficie); text-align: center; }
    .convite h2, .estado h1 { margin-top: 0; }
    @media (max-width: 640px) {
      .topo .botao { padding-inline: 12px; }
      .hero { align-items: stretch; flex-direction: column; }
      .hero .botao { width: 100%; }
      .colecao { grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; }
    }
  `],
})
export class ColecaoCompartilhadaPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly rota = inject(ActivatedRoute);

  readonly colecao = signal<PostagemColecaoPublica | null>(null);
  readonly carregando = signal(true);
  readonly linkCopiado = signal(false);
  readonly capaReserva = 'assets/capa-reserva.svg';

  ngOnInit() {
    const postagemId = Number(this.rota.snapshot.paramMap.get('id'));
    if (!postagemId) {
      this.carregando.set(false);
      return;
    }

    this.api.obterColecaoPublicaDaPostagem(postagemId).subscribe({
      next: (colecao) => {
        this.colecao.set(colecao);
        this.carregando.set(false);
      },
      error: () => this.carregando.set(false),
    });
  }

  async copiarLink() {
    try {
      await navigator.clipboard.writeText(window.location.href);
      this.linkCopiado.set(true);
    } catch {
      this.linkCopiado.set(false);
    }
  }

  usarReserva(evento: Event) {
    (evento.target as HTMLImageElement).src = this.capaReserva;
  }
}
