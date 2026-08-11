import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { resolverUrlMidia } from '../../core/midia-url';
import { PostagemPublica } from '../../core/modelos';
import { RelatedContentComponent } from '../../shared/related-content.component';

@Component({
  selector: 'app-postagem-publica-page',
  imports: [CommonModule, RouterLink, RelatedContentComponent],
  template: `
    <main class="pagina-publica">
      <header class="topo">
        <a class="marca" routerLink="/entrar">HQ-HUB</a>
        <a class="botao secundario compacto" routerLink="/entrar">Entrar ou criar conta</a>
      </header>

      @if (carregando()) {
        <section class="estado"><h1>Carregando postagem...</h1></section>
      } @else if (!postagem()) {
        <section class="estado">
          <h1>Postagem indisponivel</h1>
          <p>Este conteudo nao existe mais ou nao esta disponivel.</p>
          <a class="botao primario" routerLink="/entrar">Conhecer o HQ-HUB</a>
        </section>
      } @else {
        <article class="postagem">
          <header class="autor">
            <div class="avatar">
              @if (postagem()!.autor.fotoPerfilThumbnailUrl) {
                <img [src]="midia(postagem()!.autor.fotoPerfilThumbnailUrl)" alt="" />
              } @else {
                {{ iniciais(postagem()!.autor.nome) }}
              }
            </div>
            <div>
              <strong>{{ postagem()!.autor.nome }}</strong>
              <span>{{ dataFormatada(postagem()!.dataCriacao) }} · Publico</span>
            </div>
          </header>

          <p class="conteudo">{{ postagem()!.conteudo }}</p>

          @if (postagem()!.colecaoDestaque; as colecao) {
            <section class="destaque">
              <img [src]="midia(colecao.urlCapa) || capaReserva" [alt]="colecao.titulo" />
              <div>
                <span class="rotulo">Colecao</span>
                <h2>{{ colecao.titulo }}</h2>
                <p>{{ colecao.quantidadeEdicoes }} edicoes · {{ colecao.editora }}</p>
                <a class="botao compacto secundario" [routerLink]="['/colecao-compartilhada', postagem()!.id]">Ver colecao</a>
              </div>
            </section>
          }

          @if (postagem()!.catalogoDestaque; as catalogo) {
            <section class="destaque" [class.sem-capa]="!capaExibivel(catalogo.urlCapa)">
              @if (capaExibivel(catalogo.urlCapa); as urlCapa) {
                <img [src]="urlCapa" [alt]="catalogo.titulo" />
              }
              <div>
                <span class="rotulo">Catalogo</span>
                <h2>{{ catalogo.titulo }}</h2>
                <p>{{ catalogo.quantidadeEdicoes }} edicoes · {{ catalogo.editora }}</p>
              </div>
            </section>
          }

          @if (imagens().length) {
            <div class="imagens" [class.multipla]="imagens().length > 1">
              @for (imagem of imagens(); track imagem.urlImagem) {
                <a [href]="midia(imagem.urlImagem)" target="_blank" rel="noopener noreferrer">
                  <img [src]="midia(imagem.urlThumbnail || imagem.urlImagem)" [alt]="'Imagem publicada por ' + postagem()!.autor.nome" />
                </a>
              }
            </div>
          }

          <app-related-content
            [videos]="postagem()!.relatedVideos"
            [partnerChannel]="postagem()!.partnerChannel"
            [referenceTitle]="postagem()!.catalogoDestaque?.titulo || postagem()!.colecaoDestaque?.titulo || ''"
          ></app-related-content>

          <div class="resumo">
            <span>♡ {{ postagem()!.totalCurtidas }}</span>
            <span>{{ postagem()!.comentarios.length }} comentarios</span>
            <button type="button" (click)="copiarLink()">{{ linkCopiado() ? 'Link copiado' : 'Copiar link' }}</button>
          </div>

          @if (postagem()!.comentarios.length) {
            <section class="comentarios" aria-label="Comentarios">
              @for (comentario of postagem()!.comentarios; track comentario.id) {
                <article>
                  <strong>{{ comentario.autor.nome }}</strong>
                  <p>{{ comentario.texto }}</p>
                  <small>
                    {{ dataFormatada(comentario.dataCriacao) }}
                    @if (comentario.totalCurtidas > 0) {
                      · ♥ {{ comentario.totalCurtidas }}
                    }
                  </small>
                </article>
              }
            </section>
          }
        </article>

        <section class="convite">
          <h2>Participe da comunidade HQ-HUB</h2>
          <p>Crie sua conta para curtir, comentar e compartilhar suas leituras.</p>
          <a class="botao primario" routerLink="/entrar">Entrar ou criar conta</a>
        </section>
      }
    </main>
  `,
  styles: [`
    :host { display: block; min-height: 100vh; background: var(--fundo); color: var(--texto); }
    .pagina-publica { width: min(820px, calc(100% - 28px)); margin: auto; padding: 18px 0 56px; }
    .topo { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 18px; }
    .marca { color: #ff871f; font-size: 1.25rem; font-weight: 950; text-decoration: none; }
    .postagem, .estado, .convite { border: 1px solid var(--borda); border-radius: 18px; background: var(--superficie); box-shadow: 0 12px 36px rgba(15, 23, 42, .08); }
    .postagem { padding: clamp(18px, 4vw, 32px); }
    .autor { display: flex; align-items: center; gap: 12px; }
    .autor > div:last-child { display: grid; gap: 2px; }
    .autor span, .destaque p, .resumo, small { color: var(--texto-suave); }
    .avatar { display: grid; width: 48px; height: 48px; place-items: center; overflow: hidden; border-radius: 50%; background: var(--azul); color: white; font-weight: 900; }
    .avatar img { width: 100%; height: 100%; object-fit: cover; }
    .conteudo { margin: 22px 0; font-size: 1.08rem; line-height: 1.65; white-space: pre-wrap; overflow-wrap: anywhere; }
    .destaque { display: grid; grid-template-columns: 116px 1fr; gap: 20px; align-items: center; margin: 20px 0; padding: 16px; border-radius: 14px; background: var(--fundo); }
    .destaque.sem-capa { grid-template-columns: 1fr; }
    .destaque img { width: 116px; aspect-ratio: 2 / 3; object-fit: cover; border-radius: 8px; }
    .destaque h2 { margin: 4px 0; }
    .rotulo { color: #ff871f; font-size: .78rem; font-weight: 900; letter-spacing: .08em; text-transform: uppercase; }
    .imagens { display: grid; gap: 8px; margin-top: 20px; overflow: hidden; border-radius: 14px; }
    .imagens.multipla { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .imagens a:last-child:nth-child(3) { grid-column: 1 / -1; }
    .imagens img { display: block; width: 100%; max-height: 620px; object-fit: cover; }
    .imagens:not(.multipla) img { width: auto; max-width: 100%; height: auto; max-height: 720px; margin: 0 auto; object-fit: contain; }
    .resumo { display: flex; gap: 20px; align-items: center; padding: 18px 0 4px; border-top: 1px solid var(--borda); margin-top: 20px; }
    .resumo button { margin-left: auto; border: 0; background: transparent; color: #ff871f; font: inherit; font-weight: 800; cursor: pointer; }
    .comentarios { display: grid; gap: 12px; margin-top: 18px; padding-top: 18px; border-top: 1px solid var(--borda); }
    .comentarios article { padding: 12px 14px; border-radius: 12px; background: var(--fundo); }
    .comentarios p { margin: 5px 0; white-space: pre-wrap; }
    .estado, .convite { padding: 36px 24px; text-align: center; }
    .convite { margin-top: 24px; }
    .estado h1, .convite h2 { margin-top: 0; }
    @media (max-width: 540px) {
      .destaque { grid-template-columns: 86px 1fr; gap: 14px; }
      .destaque img { width: 86px; }
      .imagens.multipla { grid-template-columns: 1fr; }
      .imagens a:last-child:nth-child(3) { grid-column: auto; }
    }
  `],
})
export class PostagemPublicaPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly rota = inject(ActivatedRoute);

  readonly postagem = signal<PostagemPublica | null>(null);
  readonly carregando = signal(true);
  readonly linkCopiado = signal(false);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly midia = resolverUrlMidia;

  ngOnInit() {
    const postagemId = Number(this.rota.snapshot.paramMap.get('id'));
    if (!postagemId) {
      this.carregando.set(false);
      return;
    }
    this.api.obterPostagemPublica(postagemId).subscribe({
      next: (postagem) => {
        this.postagem.set(postagem);
        this.carregando.set(false);
      },
      error: () => this.carregando.set(false),
    });
  }

  imagens() {
    const postagem = this.postagem();
    if (!postagem) return [];
    if (postagem.imagens.length) return postagem.imagens;
    return postagem.urlImagem ? [{ urlImagem: postagem.urlImagem, urlThumbnail: postagem.urlImagem }] : [];
  }

  capaExibivel(url: string | null | undefined): string | null {
    const valor = url?.trim();
    if (!valor || valor.toLowerCase().includes('guiadosquadrinhos.com')) {
      return null;
    }
    return this.midia(valor) || null;
  }

  iniciais(nome: string) {
    return nome.split(' ').filter(Boolean).slice(0, 2).map((parte) => parte[0]?.toUpperCase()).join('') || 'HQ';
  }

  dataFormatada(data: string) {
    return new Intl.DateTimeFormat('pt-BR', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(data));
  }

  async copiarLink() {
    try {
      await navigator.clipboard.writeText(window.location.href);
      this.linkCopiado.set(true);
    } catch {
      this.linkCopiado.set(false);
    }
  }
}
