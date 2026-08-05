import { CommonModule } from '@angular/common';
import { Component, Input, signal } from '@angular/core';

import { PartnerChannel, RelatedVideo } from '../core/modelos';

@Component({
  selector: 'app-related-content',
  imports: [CommonModule],
  template: `
    @if (partnerChannel?.url) {
      <aside class="canal-parceiro" aria-label="Canal parceiro em destaque">
        <div class="avatar-canal">
          @if (partnerChannel?.thumbnail) {
            <img [src]="partnerChannel!.thumbnail" [alt]="partnerChannel!.name || 'Canal parceiro'" loading="lazy" decoding="async" />
          } @else {
            <span aria-hidden="true">★</span>
          }
        </div>
        <div class="informacoes-canal">
          <small>Canal parceiro</small>
          <strong>{{ partnerChannel!.name || 'Conteúdo recomendado pelo HQ-HUB' }}</strong>
        </div>
        <a class="visitar-canal ripple" [href]="partnerChannel!.url" target="_blank" rel="noopener noreferrer">
          Conhecer canal <span aria-hidden="true">↗</span>
        </a>
      </aside>
    }

    @if (videosExibidos.length) {
      <section class="conteudo-relacionado" aria-label="Conteúdo relacionado">
        <div class="cabecalho-relacionado">
          <span class="icone-secao" aria-hidden="true">▻</span>
          <div>
            <strong>Conteúdo relacionado</strong>
            <small>Vídeos selecionados para esta publicação</small>
          </div>
          @if (videosExibidos.length > 1) {
            <button class="alternador" type="button" (click)="alternarExpansao()" [attr.aria-expanded]="expandido()">
              {{ expandido() ? 'Ocultar' : 'Ver ' + videosExibidos.length + ' vídeos' }}
            </button>
          }
        </div>

        @if (expandido()) {
          <div class="grade-videos">
            @for (video of videosExibidos; track video.id || video.url) {
              <article class="video-card">
                <a class="thumbnail-video" [href]="video.url" target="_blank" rel="noopener noreferrer">
                  <img
                    [src]="video.thumbnail || thumbnailPadrao"
                    [alt]="'Thumbnail de ' + video.title"
                    loading="lazy"
                    decoding="async"
                    (error)="usarThumbnailPadrao($event)"
                  />
                  <span class="selo-youtube" aria-hidden="true">▶</span>
                </a>
                <div class="video-informacoes">
                  <h4>{{ video.title }}</h4>
                  @if (video.channelName) { <span>{{ video.channelName }}</span> }
                  <div class="metadados-video">
                    @if (video.durationSeconds) { <small>{{ formatarDuracao(video.durationSeconds) }}</small> }
                    @if (video.viewCount !== null && video.viewCount !== undefined) {
                      <small>{{ formatarVisualizacoes(video.viewCount) }} visualizações</small>
                    }
                  </div>
                  <a class="botao-assistir ripple" [href]="video.url" target="_blank" rel="noopener noreferrer">
                    <span aria-hidden="true">▶</span> Assistir no YouTube
                  </a>
                </div>
              </article>
            }
          </div>
        }
      </section>
    } @else if (referenceTitle.trim()) {
      <section class="conteudo-relacionado fallback-youtube" aria-label="Conteúdo relacionado">
        <div><span class="icone-youtube" aria-hidden="true">▶</span><strong>Conteúdo relacionado</strong></div>
        <a class="buscar-youtube ripple" [href]="urlPesquisa" target="_blank" rel="noopener noreferrer">
          ▶ Buscar vídeos no YouTube
        </a>
      </section>
    }
  `,
  styles: [`
    :host { display: block; }
    .conteudo-relacionado { display: grid; gap: 12px; margin-top: 2px; padding-top: 14px; border-top: 1px solid var(--borda); }
    .cabecalho-relacionado { display: flex; width: 100%; align-items: center; gap: 9px; color: var(--texto); }
    .cabecalho-relacionado > div { display: grid; gap: 1px; min-width: 0; }
    .cabecalho-relacionado strong { font-size: .9rem; }
    .cabecalho-relacionado small { color: var(--texto-suave); font-size: .74rem; }
    .icone-secao { display: inline-grid; width: 28px; height: 28px; place-items: center; border-radius: 9px; color: #fff; background: #e52d27; font-size: .78rem; }
    .alternador { margin-left: auto; padding: 6px 8px; border: 0; border-radius: 8px; color: var(--texto-suave); background: var(--superficie-2); cursor: pointer; font-size: .74rem; font-weight: 750; }
    .grade-videos { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; animation: revelar-videos .2s ease-out both; transform-origin: top; }
    .video-card { min-width: 0; overflow: hidden; border: 1px solid var(--borda); border-radius: 12px; background: var(--superficie-2); box-shadow: 0 5px 16px rgba(15, 23, 42, .06); transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease; }
    .video-card:hover { transform: translateY(-2px); border-color: color-mix(in srgb, var(--borda) 60%, #e52d27 40%); box-shadow: 0 10px 24px rgba(15, 23, 42, .11); }
    .thumbnail-video { position: relative; display: block; overflow: hidden; aspect-ratio: 16 / 9; background: #171717; }
    .thumbnail-video img { display: block; width: 100%; height: 100%; object-fit: cover; transition: transform .25s ease; }
    .thumbnail-video:hover img { transform: scale(1.035); }
    .selo-youtube { position: absolute; inset: 50% auto auto 50%; width: 46px; height: 32px; border-radius: 9px; transform: translate(-50%, -50%); box-shadow: 0 5px 14px rgba(0, 0, 0, .3); }
    .video-informacoes { display: grid; gap: 6px; padding: 11px; }
    .video-informacoes h4 { display: -webkit-box; margin: 0; overflow: hidden; font-size: .92rem; line-height: 1.35; -webkit-box-orient: vertical; -webkit-line-clamp: 2; }
    .video-informacoes > span, .metadados-video { color: var(--texto-suave); font-size: .76rem; }
    .metadados-video { display: flex; flex-wrap: wrap; gap: 8px; }
    .botao-assistir, .buscar-youtube { position: relative; display: inline-flex; width: fit-content; align-items: center; gap: 6px; overflow: hidden; border-radius: 8px; color: #fff; background: #202124; font-size: .78rem; font-weight: 800; text-decoration: none; transition: background .2s ease, transform .2s ease; }
    .botao-assistir { padding: 8px 10px; }
    .buscar-youtube { padding: 10px 13px; }
    .botao-assistir:hover, .buscar-youtube:hover { background: #e52d27; transform: translateY(-1px); }
    .ripple::after { content: ''; position: absolute; inset: 50%; border-radius: 50%; background: rgba(255,255,255,.35); transform: translate(-50%,-50%) scale(0); opacity: 0; }
    .ripple:active::after { animation: ripple .42s ease-out; }
    .fallback-youtube { padding: 12px; border: 1px solid var(--borda); border-radius: 12px; background: var(--superficie-2); }
    .fallback-youtube > div { display: flex; align-items: center; gap: 9px; }
    .icone-youtube, .selo-youtube { display: inline-grid; place-items: center; color: #fff; background: #e52d27; }
    .icone-youtube { width: 28px; height: 22px; border-radius: 7px; font-size: .72rem; }
    @keyframes revelar-videos { from { opacity: 0; transform: translateY(-8px) scaleY(.97); } to { opacity: 1; transform: none; } }
    @keyframes ripple { 0% { opacity: .7; transform: translate(-50%,-50%) scale(0); } 100% { opacity: 0; transform: translate(-50%,-50%) scale(8); } }
    @media (max-width: 820px) { .grade-videos { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
    @media (max-width: 520px) { .grade-videos { grid-template-columns: 1fr; } .cabecalho-relacionado small { display: none; } .alternador { max-width: 128px; } }
    @media (prefers-reduced-motion: reduce) { .grade-videos, .ripple:active::after { animation: none; } .video-card, .thumbnail-video img { transition: none; } }
  `],
})
export class RelatedContentComponent {
  @Input() videos: RelatedVideo[] | null | undefined = [];
  @Input() partnerChannel: PartnerChannel | null | undefined = null;
  @Input() referenceTitle = '';

  readonly expandido = signal(true);
  readonly thumbnailPadrao = 'assets/youtube-placeholder.svg';

  get videosExibidos() { return (this.videos || []).slice(0, 3); }
  get urlPesquisa() { return `https://www.youtube.com/results?search_query=${encodeURIComponent(`${this.referenceTitle.trim()} review`)}`; }
  alternarExpansao() { this.expandido.update((valor) => !valor); }

  usarThumbnailPadrao(evento: Event) {
    const imagem = evento.target as HTMLImageElement;
    if (!imagem.src.includes('youtube-placeholder.svg')) imagem.src = this.thumbnailPadrao;
  }

  formatarDuracao(segundos: number) {
    const minutos = Math.floor(segundos / 60);
    return `${minutos}:${(segundos % 60).toString().padStart(2, '0')}`;
  }

  formatarVisualizacoes(total: number) {
    return new Intl.NumberFormat('pt-BR', { notation: 'compact', maximumFractionDigits: 1 }).format(total);
  }
}
