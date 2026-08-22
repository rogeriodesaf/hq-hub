import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { PostagemFeed } from '../core/modelos';

@Component({
  selector: 'app-atividade-estante-card',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <article class="atividade" [attr.aria-label]="rotuloAtividade()">
      <header>
        <a class="avatar" [routerLink]="['/usuario', postagem.usuario.id]" [attr.aria-label]="'Ver perfil de ' + postagem.usuario.nome">
          @if (postagem.usuario.fotoPerfilThumbnailUrl) {
            <img [src]="postagem.usuario.fotoPerfilThumbnailUrl" [alt]="'Foto de ' + postagem.usuario.nome" />
          } @else {
            <span aria-hidden="true">{{ iniciais(postagem.usuario.nome) }}</span>
          }
        </a>
        <div>
          <p><a [routerLink]="['/usuario', postagem.usuario.id]">{{ postagem.usuario.nome }}</a> {{ rotuloAtividade() }}</p>
          <time [attr.datetime]="postagem.dataCriacao">{{ tempoRelativo() }}</time>
        </div>
      </header>

      @if (postagem.atividadeEstante?.edicoes?.length) {
        <section class="edicoes" [class.agrupada]="postagem.atividadeEstante!.quantidade > 1">
          @for (edicao of postagem.atividadeEstante!.edicoes; track edicao.edicaoId || edicao.titulo) {
            @if (edicao.edicaoId) {
              <a class="edicao" routerLink="/catalogo" [queryParams]="{ edicaoId: edicao.edicaoId }">
                <img [src]="edicao.urlCapa || capaReserva" [alt]="'Capa de ' + edicao.titulo" loading="lazy" />
                @if (postagem.atividadeEstante!.quantidade === 1) {
                  <span><strong>{{ edicao.titulo }}</strong><em>Ver edição</em></span>
                }
              </a>
            } @else {
              <div class="edicao sem-link">
                <img [src]="edicao.urlCapa || capaReserva" [alt]="'Capa de ' + edicao.titulo" loading="lazy" />
                @if (postagem.atividadeEstante!.quantidade === 1) { <span><strong>{{ edicao.titulo }}</strong></span> }
              </div>
            }
          }
          @if (postagem.atividadeEstante!.quantidade > 1) {
            <div class="resumo-grupo">
              <a [routerLink]="['/usuario', postagem.usuario.id]" fragment="estante">Ver todas</a>
            </div>
          }
        </section>
      } @else {
        <p class="fallback">{{ postagem.conteudo || 'Atividade da estante' }}</p>
      }

      <div class="contadores" aria-live="polite">
        @if (postagem.totalCurtidas) { <span>{{ postagem.totalCurtidas }} {{ postagem.totalCurtidas === 1 ? 'curtida' : 'curtidas' }}</span> }
        @if (postagem.comentarios.length) { <span>{{ postagem.comentarios.length }} {{ postagem.comentarios.length === 1 ? 'comentário' : 'comentários' }}</span> }
      </div>
      <div class="acoes">
        <button type="button" [class.ativo]="postagem.curtidaPeloUsuario" [attr.aria-pressed]="postagem.curtidaPeloUsuario" (click)="curtir.emit()" [disabled]="ocupado">
          <span aria-hidden="true">{{ postagem.curtidaPeloUsuario ? '♥' : '♡' }}</span> Curtir
        </button>
        <button type="button" [attr.aria-expanded]="comentariosAbertos" (click)="comentariosAbertos = !comentariosAbertos">
          <span aria-hidden="true">💬</span> Comentar
        </button>
      </div>

      @if (comentariosAbertos) {
        <section class="comentarios" aria-label="Comentários da atividade">
          @for (comentario of postagem.comentarios; track comentario.id) {
            <article>
              <strong>{{ comentario.usuario.nome }}</strong>
              <p>{{ comentario.texto }}</p>
              <button type="button" (click)="curtirComentario.emit(comentario.id)" [disabled]="ocupado">
                {{ comentario.curtidaPeloUsuario ? '♥' : '♡' }} Curtir @if (comentario.totalCurtidas) { ({{ comentario.totalCurtidas }}) }
              </button>
              @if (comentario.usuario.id === usuarioAtualId) {
                <button type="button" (click)="removerComentario.emit(comentario.id)" [disabled]="ocupado">Excluir</button>
              }
            </article>
          }
          <form (ngSubmit)="enviarComentario()">
            <label [for]="'comentario-atividade-' + postagem.id" class="sr-only">Escrever comentário</label>
            <input [id]="'comentario-atividade-' + postagem.id" [(ngModel)]="novoComentario" name="novoComentario" placeholder="Escreva um comentário" autocomplete="off" />
            <button type="submit" [disabled]="ocupado || !novoComentario.trim()">Comentar</button>
          </form>
        </section>
      }
    </article>
  `,
  styles: [`
    :host { display: block; }
    .atividade { display: grid; gap: 12px; color: var(--texto); }
    header { display: flex; align-items: center; gap: 10px; }
    header p { margin: 0; line-height: 1.35; }
    header a { color: inherit; text-decoration: none; }
    header a:hover, header a:focus-visible { text-decoration: underline; }
    time, .contadores { color: var(--texto-suave); font-size: .8rem; }
    .avatar { width: 42px; height: 42px; border-radius: 50%; overflow: hidden; flex: 0 0 42px; display: grid; place-items: center; background: var(--superficie-2); font-weight: 800; }
    .avatar img { width: 100%; height: 100%; object-fit: cover; }
    .edicoes { display: grid; gap: 10px; }
    .edicao { display: grid; grid-template-columns: 86px minmax(0, 1fr); gap: 14px; align-items: center; color: inherit; text-decoration: none; min-width: 0; }
    .edicao img { width: 86px; aspect-ratio: 2 / 3; border-radius: 8px; object-fit: cover; background: var(--superficie-2); }
    .edicao span { min-width: 0; display: grid; gap: 8px; }
    .edicao strong { overflow-wrap: anywhere; line-height: 1.35; }
    .edicao em, .resumo-grupo a { color: var(--primaria); font-style: normal; font-weight: 700; }
    .agrupada { grid-template-columns: repeat(3, minmax(58px, 86px)) minmax(0, 1fr); align-items: center; }
    .agrupada .edicao { display: block; }
    .agrupada .edicao img { width: 100%; }
    .resumo-grupo { display: grid; gap: 8px; min-width: 0; }
    .contadores { display: flex; justify-content: flex-end; gap: 14px; min-height: 18px; }
    .acoes { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); border-top: 1px solid var(--borda); }
    .acoes button, .comentarios button, .comentarios input { min-height: 44px; }
    button { border: 0; border-radius: 8px; background: transparent; color: inherit; cursor: pointer; font: inherit; }
    button:hover, button:focus-visible { background: var(--superficie-2); outline-offset: 2px; }
    button.ativo { color: var(--primaria); font-weight: 700; }
    button:disabled { opacity: .55; cursor: wait; }
    .comentarios { display: grid; gap: 10px; border-top: 1px solid var(--borda); padding-top: 10px; }
    .comentarios article { padding: 10px 12px; border-radius: 10px; background: var(--superficie-2); }
    .comentarios p { margin: 4px 0; overflow-wrap: anywhere; }
    .comentarios article button { min-height: 36px; padding: 0 10px; font-size: .82rem; }
    .comentarios form { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 8px; }
    .comentarios input { min-width: 0; border: 1px solid var(--borda); border-radius: 10px; background: var(--superficie); color: var(--texto); padding: 0 12px; }
    .comentarios form button { padding: 0 14px; background: var(--primaria); color: white; }
    .fallback { margin: 0; color: var(--texto-suave); }
    .sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0; }
    @media (max-width: 620px) {
      .agrupada { grid-template-columns: repeat(3, minmax(54px, 72px)); }
      .resumo-grupo { grid-column: 1 / -1; }
      .edicao { grid-template-columns: 76px minmax(0, 1fr); }
      .edicao img { width: 76px; }
    }
  `],
})
export class AtividadeEstanteCardComponent {
  @Input({ required: true }) postagem!: PostagemFeed;
  @Input() usuarioAtualId: number | null = null;
  @Input() ocupado = false;
  @Output() curtir = new EventEmitter<void>();
  @Output() comentar = new EventEmitter<string>();
  @Output() curtirComentario = new EventEmitter<number>();
  @Output() removerComentario = new EventEmitter<number>();

  readonly capaReserva = 'assets/capa-reserva.svg';
  comentariosAbertos = false;
  novoComentario = '';

  rotuloAtividade() {
    switch (this.postagem.atividadeEstante?.tipo) {
      case 'MARCOU_COMO_LIDA': return 'marcou como lida';
      case 'ADICIONOU_LISTA_DESEJOS': return 'adicionou à lista de desejos';
      default: return this.postagem.atividadeEstante?.quantidade === 1 ? 'adicionou à estante' : `adicionou ${this.postagem.atividadeEstante?.quantidade || 0} HQs à estante`;
    }
  }

  iniciais(nome: string) { return nome.split(/\s+/).slice(0, 2).map((parte) => parte[0]).join('').toUpperCase(); }

  tempoRelativo() {
    const segundos = Math.max(0, Math.floor((Date.now() - new Date(this.postagem.dataCriacao).getTime()) / 1000));
    if (segundos < 60) return 'agora';
    if (segundos < 3600) return `há ${Math.floor(segundos / 60)} min`;
    if (segundos < 86400) return `há ${Math.floor(segundos / 3600)} h`;
    return `há ${Math.floor(segundos / 86400)} d`;
  }

  enviarComentario() {
    const texto = this.novoComentario.trim();
    if (!texto) return;
    this.comentar.emit(texto);
    this.novoComentario = '';
  }
}
