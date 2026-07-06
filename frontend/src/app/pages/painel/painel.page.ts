import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { resolverUrlMidia as resolverUrlMidiaCore } from '../../core/midia-url';
import { Anuncio, ColecaoResumo, ImagemFeed, PostagemFeed, Usuario } from '../../core/modelos';
import { PerfilFeedComponent } from '../../shared/perfil-feed.component';

@Component({
  selector: 'app-painel-page',
  imports: [CommonModule, FormsModule, RouterLink, PerfilFeedComponent],
  template: `
    <section class="cabecalho-pagina feed-cabecalho">
      <div>
        <p class="rotulo">Feed principal</p>
        <h1>No que a comunidade esta lendo hoje?</h1>
      </div>
      <a class="botao primario" routerLink="/amigos">Encontrar amigos</a>
    </section>

    <section class="metricas feed-metricas">
      <article>
        <span>{{ resumo()?.totalItens ?? 0 }}</span>
        <p>Edicoes na colecao</p>
      </article>
      <article>
        <span>{{ resumo()?.totalSeries ?? 0 }}</span>
        <p>Series acompanhadas</p>
      </article>
      <article>
        <span>{{ resumo()?.totalEditoras ?? 0 }}</span>
        <p>Editoras na estante</p>
      </article>
      <article>
        <span>{{ formatarMoeda(resumo()?.valorTotalPago ?? 0) }}</span>
        <p>Investido na colecao</p>
      </article>
    </section>

    <section class="feed-layout">
      <div class="feed-coluna">
        <a
          class="banner-feed banner-evolukit"
          href="https://link.amazon/B09ZELm0N"
          target="_blank"
          rel="noreferrer"
          aria-label="Adquira sua evolukit"
        >
          <img
            src="https://acdn-us.mitiendanube.com/stores/005/843/311/themes/common/logo-1653308187-1764589351-c5659b892bb2b592b88048f01fe6900f1764589351.png?0"
            alt=""
            loading="lazy"
          />
          <span>Adquira sua evolukit</span>
        </a>

        <a class="banner-feed banner-apoio" routerLink="/apoie">
          <strong>Torne-se apoiador desse projeto</strong>
          <span>Ajude o HQ-HUB a crescer como um acervo livre, colaborativo e feito por colecionadores.</span>
        </a>

        <app-perfil-feed
          [usuario]="usuario()"
          modo="resumo"
        ></app-perfil-feed>

        <div class="acoes-perfil-feed">
          <a class="botao compacto secundario" routerLink="/perfil">Editar perfil</a>
        </div>

        @if (sugestaoAmigo()) {
          <article class="bloco sugestao-amigo-card">
            <div class="avatar-feed">
              @if (sugestaoAmigo()!.fotoPerfilThumbnailUrl) {
                <img [src]="resolverUrlMidia(sugestaoAmigo()!.fotoPerfilThumbnailUrl)" alt="" />
              } @else {
                {{ iniciais(sugestaoAmigo()!.nome) }}
              }
            </div>
            <div>
              <p class="rotulo">Sugestao de amigo</p>
              <strong>{{ sugestaoAmigo()!.nome }}</strong>
              <span>{{ sugestaoAmigo()!.email }}</span>
              @if (mensagemSugestaoAmigo()) {
                <small>{{ mensagemSugestaoAmigo() }}</small>
              }
            </div>
            <button
              class="botao compacto primario"
              type="button"
              (click)="adicionarSugestaoAmigo()"
              [disabled]="enviandoSugestaoAmigo()"
            >
              {{ enviandoSugestaoAmigo() ? 'Enviando...' : 'Adicionar amigo' }}
            </button>
          </article>
        }

        <article class="bloco compositor-feed">
          <div class="compositor-topo">
            <div class="avatar-feed">
              @if (usuario()?.fotoPerfilThumbnailUrl) {
                <img [src]="resolverUrlMidia(usuario()?.fotoPerfilThumbnailUrl)" alt="" />
              } @else {
                {{ iniciais(usuario()?.nome || 'HQ') }}
              }
            </div>
            <label>No que voce esta pensando?</label>
          </div>
          <div class="compositor-corpo">
            <textarea
              [(ngModel)]="novoConteudo"
              name="novoConteudo"
              rows="4"
              maxlength="2000"
              placeholder="Compartilhe uma leitura, uma capa bonita ou uma descoberta da sua estante..."
            ></textarea>
          </div>
          <div class="compositor-rodape">
            <label class="acao-upload-feed seletor-feed">
              <span>Adicionar fotos</span>
              <input type="file" accept="image/jpeg,image/png,image/webp" multiple (change)="selecionarImagens($event)" />
            </label>
            <button class="botao primario" type="button" (click)="publicar()" [disabled]="publicando() || !novoConteudo.trim()">
              {{ publicando() ? 'Publicando...' : 'Publicar' }}
            </button>
          </div>

          @if (previsualizacoes.length) {
            <div class="grade-imagens-feed previa-feed">
              @for (imagem of previsualizacoes; track imagem.url) {
                <div>
                  <img [src]="imagem.url" alt="Previa da imagem da postagem" />
                  <button type="button" aria-label="Remover imagem" (click)="removerImagem($index)">x</button>
                </div>
              }
            </div>
          }

          @if (mensagem()) {
            <p class="mensagem-erro">{{ mensagem() }}</p>
          }

        </article>

        <section class="lista-feed">
          @for (postagem of feed(); track postagem.id) {
            <article class="bloco postagem-card">
              <header>
                <div class="avatar-feed">
                  <a [routerLink]="['/usuario', postagem.usuario.id]" class="link-perfil">
                    @if (postagem.usuario.fotoPerfilThumbnailUrl) {
                      <img [src]="resolverUrlMidia(postagem.usuario.fotoPerfilThumbnailUrl)" alt="" />
                    } @else {
                      {{ iniciais(postagem.usuario.nome) }}
                    }
                  </a>
                </div>
                <div class="autor-postagem">
                  <a [routerLink]="['/usuario', postagem.usuario.id]" class="link-nome-amigo">
                    <strong>{{ postagem.usuario.nome }}</strong>
                  </a>
                  <small>
                    @if (postagem.usuario.bio) {
                      {{ postagem.usuario.bio }} ·
                    }
                    {{ dataRelativa(postagem.dataCriacao) }} - Publico
                  </small>
                </div>
                @if (postagem.usuario.id === usuario()?.id) {
                  <button
                    class="botao compacto perigo acao-postagem"
                    type="button"
                    (click)="removerPostagem(postagem)"
                    [disabled]="interagindoId() === postagem.id"
                  >
                    Remover
                  </button>
                }
              </header>

              <p class="texto-postagem">{{ postagem.conteudo }}</p>

              @if (postagem.colecaoDestaque) {
                <article class="cartao-colecao-feed">
                  <img
                    [src]="postagem.colecaoDestaque.urlCapa || 'assets/capa-reserva.svg'"
                    [alt]="postagem.colecaoDestaque.titulo"
                    loading="lazy"
                  />
                  <div>
                    <p class="rotulo">Colecao</p>
                    <h3>{{ postagem.colecaoDestaque.titulo }}</h3>
                    <span>{{ postagem.colecaoDestaque.quantidadeEdicoes }} edicoes - {{ postagem.colecaoDestaque.editora }}</span>
                    @if (postagem.colecaoDestaque.concluida) {
                      <strong class="status-colecao concluida">Colecao completa</strong>
                    } @else {
                      <strong class="status-colecao">Na estante</strong>
                    }
                    <a class="botao compacto" routerLink="/colecao">Ver colecao</a>
                  </div>
                </article>
              }

              @if (imagensPostagem(postagem).length) {
                <div class="grade-imagens-feed imagens-postagem" [class.multipla]="imagensPostagem(postagem).length > 1">
                  @for (imagem of imagensPostagem(postagem); track imagem.urlImagem) {
                    <a [href]="resolverUrlMidia(imagem.urlImagem)" target="_blank" rel="noreferrer">
                      <img
                        class="imagem-postagem"
                        [src]="resolverUrlMidia(imagem.urlThumbnail)"
                        alt="Imagem publicada por {{ postagem.usuario.nome }}"
                        loading="lazy"
                      />
                    </a>
                  }
                </div>
              }

              <div class="barra-postagem">
                <button
                  class="acao-social"
                  type="button"
                  [class.ativo]="postagem.curtidaPeloUsuario"
                  (click)="curtir(postagem)"
                  [disabled]="interagindoId() === postagem.id"
                >
                  <span>{{ postagem.curtidaPeloUsuario ? '♥' : '♡' }}</span>
                  {{ postagem.totalCurtidas }}
                </button>
                <span class="contador-social">{{ postagem.comentarios.length }} comentarios</span>
                <span class="contador-social">Compartilhar</span>
              </div>

              <section class="comentarios-feed">
                @for (comentario of postagem.comentarios; track comentario.id) {
                  <article>
                    <div class="avatar-feed mini">
                      <a [routerLink]="['/usuario', comentario.usuario.id]" class="link-perfil">
                        @if (comentario.usuario.fotoPerfilThumbnailUrl) {
                          <img [src]="resolverUrlMidia(comentario.usuario.fotoPerfilThumbnailUrl)" alt="" />
                        } @else {
                          {{ iniciais(comentario.usuario.nome) }}
                        }
                      </a>
                    </div>
                    <div>
                      <a [routerLink]="['/usuario', comentario.usuario.id]" class="link-nome-amigo">
                        <strong>{{ comentario.usuario.nome }}</strong>
                      </a>
                      <p>{{ comentario.texto }}</p>
                      <span class="tempo-comentario">{{ dataRelativa(comentario.dataCriacao) }}</span>
                      @if (comentario.usuario.id === usuario()?.id) {
                        <button
                          class="botao-texto perigo"
                          type="button"
                          (click)="removerComentario(postagem, comentario.id)"
                          [disabled]="interagindoId() === postagem.id"
                        >
                          Excluir
                        </button>
                      }
                    </div>
                  </article>
                }
              </section>

              <div class="novo-comentario">
                <input
                  [(ngModel)]="comentarios[postagem.id]"
                  [name]="'comentario' + postagem.id"
                  placeholder="Comente com a comunidade"
                  (keyup.enter)="comentar(postagem)"
                />
                <button
                  class="botao compacto"
                  type="button"
                  (click)="comentar(postagem)"
                  [disabled]="interagindoId() === postagem.id || !comentarios[postagem.id]?.trim()"
                >
                  Comentar
                </button>
              </div>
            </article>
          } @empty {
            <section class="estado-vazio">
              <h2>Seu feed ainda esta quieto</h2>
              <p>Publique algo ou adicione amigos para acompanhar o que eles estao lendo.</p>
            </section>
          }
        </section>
      </div>

      <aside class="bloco feed-lateral">
        @if (anuncios().length) {
          <section class="anuncios-feed-card">
            <div>
              <p class="rotulo">Classificados</p>
              <h2>Revistas anunciadas</h2>
            </div>
            @for (anuncio of anuncios().slice(0, 3); track anuncio.id) {
              <article>
                <img [src]="anuncio.itemColecao.edicao.urlCapa || 'assets/capa-reserva.svg'" [alt]="anuncio.tituloEdicao" loading="lazy" />
                <div>
                  <strong>{{ anuncio.tituloEdicao }}</strong>
                  <span>{{ anuncio.nomeAnunciante }}</span>
                  <small>{{ anuncio.preco ? formatarMoeda(anuncio.preco) : 'Valor a combinar' }}</small>
                </div>
              </article>
            }
            <a class="botao compacto primario" routerLink="/anuncios">Ver anuncios</a>
          </section>
        }

        <p class="rotulo">Atalhos</p>
        <div class="lista-acoes">
          <a routerLink="/perfil">Meu perfil</a>
          <a routerLink="/colecao">Ver estante</a>
          <a routerLink="/catalogo">Catalogo interno</a>
          <a routerLink="/descobrir">Pesquisar HQs</a>
          <a routerLink="/compras">Planejar compras</a>
        </div>
      </aside>
    </section>
  `,
  styles: `
    .feed-cabecalho {
      align-items: end;
    }

    .feed-cabecalho h1 {
      max-width: 640px;
    }

    .feed-metricas {
      margin-bottom: 18px;
    }

    .feed-layout {
      display: grid;
      grid-template-columns: minmax(0, 680px) 300px;
      gap: 22px;
      align-items: start;
      justify-content: center;
    }

    .feed-coluna,
    .lista-feed,
    .compositor-feed,
    .postagem-card {
      display: grid;
      gap: 14px;
    }

    .acoes-perfil-feed {
      display: flex;
      justify-content: flex-start;
      margin-top: -4px;
    }

    .compositor-feed {
      padding: 0;
      overflow: hidden;
    }

    .compositor-topo {
      display: grid;
      grid-template-columns: 44px minmax(0, 1fr);
      gap: 12px;
      align-items: center;
      padding: 16px 16px 10px;
    }

    .compositor-feed label {
      display: grid;
      gap: 8px;
      color: var(--texto);
      font-size: 0.95rem;
      font-weight: 850;
    }

    .compositor-corpo {
      padding: 0 16px;
    }

    .compositor-feed textarea {
      resize: vertical;
      min-height: 110px;
      border-color: rgba(101, 113, 125, 0.24);
      background: var(--superficie-2);
      line-height: 1.55;
    }

    .compositor-rodape {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      align-items: center;
      margin-top: 12px;
      padding: 12px 16px 16px;
      border-top: 1px solid var(--borda);
    }

    .acao-upload-feed {
      display: inline-flex;
      align-items: center;
      min-height: 38px;
      padding: 0 10px;
      border: 1px solid transparent;
      border-radius: 8px;
      color: var(--texto-suave);
      background: transparent;
      cursor: pointer;
      font-size: 0.9rem;
      font-weight: 800;
    }

    .acao-upload-feed:hover {
      border-color: var(--borda);
      color: var(--azul);
      background: var(--superficie-2);
    }

    .sugestao-amigo-card {
      display: grid;
      grid-template-columns: 44px minmax(0, 1fr) auto;
      gap: 12px;
      align-items: center;
      border-color: rgba(22, 78, 99, 0.24);
      background: linear-gradient(135deg, rgba(22, 78, 99, 0.08), rgba(245, 158, 11, 0.08));
    }

    .sugestao-amigo-card div:nth-child(2) {
      display: grid;
      gap: 2px;
      min-width: 0;
    }

    .sugestao-amigo-card strong,
    .sugestao-amigo-card span,
    .sugestao-amigo-card small {
      overflow-wrap: anywhere;
    }

    .sugestao-amigo-card span,
    .sugestao-amigo-card small {
      color: var(--texto-suave);
      font-size: 0.86rem;
    }

    .seletor-feed input {
      display: none;
    }

    .grade-imagens-feed {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 8px;
    }

    .grade-imagens-feed div,
    .grade-imagens-feed a {
      position: relative;
      display: block;
      overflow: hidden;
      border-radius: 8px;
      border: 1px solid var(--borda);
      background: var(--superficie-suave);
    }

    .grade-imagens-feed button {
      position: absolute;
      top: 6px;
      right: 6px;
      width: 28px;
      height: 28px;
      border: 0;
      border-radius: 999px;
      background: rgba(21, 25, 31, 0.78);
      color: #fff;
      cursor: pointer;
      font-weight: 900;
    }

    .previa-feed img,
    .imagem-postagem {
      width: 100%;
      height: 100%;
      max-height: 520px;
      aspect-ratio: 4 / 3;
      object-fit: cover;
      display: block;
    }

    .imagens-postagem:not(.multipla) {
      grid-template-columns: 1fr;
    }

    .imagens-postagem:not(.multipla) .imagem-postagem {
      aspect-ratio: 16 / 10;
    }

    .postagem-card header {
      display: flex;
      gap: 12px;
      align-items: center;
    }

    .postagem-card {
      padding: 16px;
    }

    .autor-postagem {
      display: grid;
      gap: 4px;
      min-width: 0;
    }

    .acao-postagem {
      margin-left: auto;
    }

    .autor-postagem small {
      color: var(--texto-suave);
      font-size: 0.82rem;
      overflow-wrap: anywhere;
    }

    .barra-postagem,
    .comentarios-feed article p {
      color: var(--texto-suave);
      font-size: 0.88rem;
    }

    .avatar-feed {
      display: grid;
      width: 44px;
      height: 44px;
      place-items: center;
      border-radius: 999px;
      background: var(--azul);
      color: #fff;
      font-weight: 900;
      overflow: hidden;
      flex: 0 0 auto;
    }

    .avatar-feed.mini {
      width: 30px;
      height: 30px;
      font-size: 0.72rem;
    }

    .avatar-feed img,
    .foto-perfil-feed img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }

    .texto-postagem {
      margin: 0;
      line-height: 1.6;
      white-space: pre-wrap;
      font-size: 0.98rem;
    }

    .cartao-colecao-feed {
      display: grid;
      grid-template-columns: minmax(110px, 0.42fr) minmax(0, 1fr);
      gap: 14px;
      overflow: hidden;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie-2);
    }

    .cartao-colecao-feed > img {
      width: 100%;
      height: 100%;
      min-height: 190px;
      object-fit: cover;
      background: var(--superficie-suave);
    }

    .cartao-colecao-feed > div {
      display: grid;
      align-content: center;
      gap: 8px;
      min-width: 0;
      padding: 14px 14px 14px 0;
    }

    .cartao-colecao-feed h3,
    .cartao-colecao-feed span {
      margin: 0;
      overflow-wrap: anywhere;
    }

    .cartao-colecao-feed h3 {
      font-size: 1.15rem;
      line-height: 1.12;
    }

    .cartao-colecao-feed span {
      color: var(--texto-suave);
      font-size: 0.88rem;
    }

    .status-colecao {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      width: fit-content;
      color: var(--texto-suave);
      font-size: 0.86rem;
    }

    .status-colecao.concluida {
      color: var(--verde);
    }

    .status-colecao.concluida::after {
      content: "✓";
      display: inline-grid;
      width: 18px;
      height: 18px;
      place-items: center;
      border-radius: 999px;
      background: rgba(47, 143, 107, 0.14);
      color: var(--verde);
      font-size: 0.72rem;
      font-weight: 900;
    }

    .barra-postagem {
      display: flex;
      flex-wrap: wrap;
      gap: 14px;
      align-items: center;
      padding-top: 10px;
      border-top: 1px solid var(--borda);
    }

    .acao-social {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      min-height: 34px;
      padding: 0;
      border: 0;
      color: var(--texto-suave);
      background: transparent;
      cursor: pointer;
      font-weight: 850;
    }

    .acao-social span {
      color: #e11d48;
      font-size: 1.35rem;
      line-height: 1;
    }

    .acao-social.ativo {
      color: var(--texto);
    }

    .contador-social {
      color: var(--texto-suave);
      font-size: 0.88rem;
      font-weight: 750;
    }

    .comentarios-feed {
      display: grid;
      gap: 8px;
    }

    .comentarios-feed article {
      display: grid;
      grid-template-columns: 30px minmax(0, 1fr);
      gap: 8px;
      padding: 10px 12px;
      border-radius: 8px;
      background: var(--superficie-suave);
    }

    .comentarios-feed article p {
      margin: 4px 0 0;
      color: var(--texto);
      line-height: 1.45;
    }

    .tempo-comentario {
      display: inline-block;
      margin-top: 4px;
      color: var(--texto-suave);
      font-size: 0.78rem;
    }

    .botao-texto {
      width: fit-content;
      margin-top: 6px;
      padding: 0;
      border: 0;
      background: transparent;
      color: var(--texto-suave);
      cursor: pointer;
      font-size: 0.8rem;
      font-weight: 850;
    }

    .botao-texto.perigo,
    .botao.perigo {
      color: #b42318;
    }

    .botao.perigo {
      border-color: rgba(180, 35, 24, 0.24);
      background: rgba(180, 35, 24, 0.08);
    }

    .novo-comentario {
      display: grid;
      grid-template-columns: minmax(0, 1fr) auto;
      gap: 8px;
    }

    .novo-comentario input {
      min-height: 40px;
      border-radius: 8px;
      background: var(--superficie-2);
    }

    .feed-lateral {
      position: sticky;
      top: 88px;
      display: grid;
      gap: 16px;
    }

    .anuncios-feed-card {
      display: grid;
      gap: 12px;
      padding-bottom: 14px;
      border-bottom: 1px solid var(--borda);
    }

    .anuncios-feed-card h2 {
      margin: 0;
      font-size: 1rem;
    }

    .anuncios-feed-card article {
      display: grid;
      grid-template-columns: 52px minmax(0, 1fr);
      gap: 10px;
      align-items: center;
    }

    .anuncios-feed-card img {
      width: 52px;
      aspect-ratio: 2 / 3;
      object-fit: cover;
      border-radius: 6px;
      background: var(--superficie-suave);
    }

    .anuncios-feed-card article div {
      display: grid;
      gap: 2px;
      min-width: 0;
    }

    .anuncios-feed-card strong,
    .anuncios-feed-card span,
    .anuncios-feed-card small {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .anuncios-feed-card span,
    .anuncios-feed-card small {
      color: var(--texto-suave);
      font-size: 0.82rem;
    }

    .link-perfil {
      display: block;
      cursor: pointer;
      transition: opacity 0.2s ease;
    }

    .link-perfil:hover {
      opacity: 0.7;
    }

    .link-nome-amigo {
      color: inherit;
      text-decoration: none;
      cursor: pointer;
      transition: color 0.2s ease;
    }

    .link-nome-amigo:hover {
      color: var(--azul);
    }

    @media (max-width: 900px) {
      .feed-layout {
        grid-template-columns: 1fr;
      }

      .feed-lateral {
        position: static;
      }

      .novo-comentario {
        grid-template-columns: 1fr;
      }

      .cartao-colecao-feed {
        grid-template-columns: 104px minmax(0, 1fr);
      }

      .cartao-colecao-feed > img {
        min-height: 170px;
      }

      .sugestao-amigo-card {
        grid-template-columns: 44px minmax(0, 1fr);
      }

      .sugestao-amigo-card button {
        grid-column: 1 / -1;
        width: 100%;
      }
    }
  `,
})
export class PainelPage implements OnInit {
  private static readonly EMAIL_SUGESTAO_AMIGO = 'rogeriodesaf@gmail.com';

  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);

  readonly usuario = this.autenticacao.usuario;
  readonly resumo = signal<ColecaoResumo | null>(null);
  readonly feed = signal<PostagemFeed[]>([]);
  readonly anuncios = signal<Anuncio[]>([]);
  readonly sugestaoAmigo = signal<Usuario | null>(null);
  readonly enviandoSugestaoAmigo = signal(false);
  readonly mensagemSugestaoAmigo = signal('');
  readonly publicando = signal(false);
  readonly interagindoId = signal<number | null>(null);
  readonly mensagem = signal('');
  novoConteudo = '';
  imagensSelecionadas: File[] = [];
  previsualizacoes: Array<{ url: string; nome: string }> = [];
  comentarios: Record<number, string> = {};

  ngOnInit() {
    this.carregarResumo();
    this.carregarFeed();
    this.carregarAnuncios();
    this.carregarSugestaoAmigo();
  }

  publicar() {
    const conteudo = this.novoConteudo.trim();
    if (!conteudo) {
      return;
    }

    this.publicando.set(true);
    this.mensagem.set('');
    this.enviarImagensSelecionadas()
      .then((imagens) => this.criarPostagem(conteudo, imagens))
      .catch((mensagem) => {
        this.publicando.set(false);
        this.mensagem.set(String(mensagem));
      });
  }

  selecionarImagens(evento: Event) {
    const input = evento.target as HTMLInputElement;
    const arquivos = Array.from(input.files || []);
    input.value = '';
    this.mensagem.set('');

    if (!arquivos.length) {
      return;
    }

    const selecionadas = [...this.imagensSelecionadas, ...arquivos].slice(0, 3);
    const erro = this.validarImagens(selecionadas, arquivos.length + this.imagensSelecionadas.length > 3);
    if (erro) {
      this.mensagem.set(erro);
      return;
    }

    this.limparPrevisualizacoes();
    this.imagensSelecionadas = selecionadas;
    this.previsualizacoes = this.imagensSelecionadas.map((arquivo) => ({
      nome: arquivo.name,
      url: URL.createObjectURL(arquivo),
    }));
  }

  removerImagem(indice: number) {
    this.imagensSelecionadas.splice(indice, 1);
    this.limparPrevisualizacoes();
    this.previsualizacoes = this.imagensSelecionadas.map((arquivo) => ({
      nome: arquivo.name,
      url: URL.createObjectURL(arquivo),
    }));
  }

  imagensPostagem(postagem: PostagemFeed): ImagemFeed[] {
    if (postagem.imagens?.length) {
      return postagem.imagens;
    }

    return postagem.urlImagem
      ? [{
          urlImagem: postagem.urlImagem,
          urlThumbnail: postagem.urlImagem,
          nomeArquivo: '',
          tipoMime: '',
          tamanhoBytes: 0,
          largura: null,
          altura: null,
          ordem: 0,
        }]
      : [];
  }

  private criarPostagem(conteudo: string, imagens: ImagemFeed[]) {
    this.api.publicarNoFeed({ conteudo, urlImagem: imagens[0]?.urlImagem || null, imagens }).subscribe({
      next: (postagem) => {
        this.feed.update((feed) => [postagem, ...feed]);
        this.novoConteudo = '';
        this.imagensSelecionadas = [];
        this.limparPrevisualizacoes();
        this.previsualizacoes = [];
        this.publicando.set(false);
      },
      error: (erro) => {
        this.publicando.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel publicar agora.');
      },
    });
  }

  curtir(postagem: PostagemFeed) {
    this.interagindoId.set(postagem.id);
    this.api.alternarCurtidaPostagem(postagem.id).subscribe({
      next: (atualizada) => this.substituirPostagem(atualizada),
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel curtir esta postagem.'),
      complete: () => this.interagindoId.set(null),
    });
  }

  comentar(postagem: PostagemFeed) {
    const texto = this.comentarios[postagem.id]?.trim();
    if (!texto) {
      return;
    }

    this.interagindoId.set(postagem.id);
    this.api.comentarPostagem(postagem.id, texto).subscribe({
      next: (atualizada) => {
        this.comentarios[postagem.id] = '';
        this.substituirPostagem(atualizada);
      },
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel comentar esta postagem.'),
      complete: () => this.interagindoId.set(null),
    });
  }

  adicionarSugestaoAmigo() {
    const usuario = this.sugestaoAmigo();
    if (!usuario) {
      return;
    }

    this.enviandoSugestaoAmigo.set(true);
    this.mensagemSugestaoAmigo.set('');
    this.api.enviarSolicitacaoAmizade(usuario.id).subscribe({
      next: () => {
        this.mensagemSugestaoAmigo.set('Solicitacao enviada.');
        this.sugestaoAmigo.set(null);
        window.dispatchEvent(new Event('hqhub-amizades-atualizadas'));
      },
      error: (erro) => {
        this.mensagemSugestaoAmigo.set(erro?.error?.mensagem || 'Nao foi possivel enviar a solicitacao.');
      },
      complete: () => this.enviandoSugestaoAmigo.set(false),
    });
  }

  resolverUrlMidia(url: string | null | undefined): string {
    return resolverUrlMidiaCore(url, '');
  }

  iniciais(nome: string) {
    return nome
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((parte) => parte[0]?.toUpperCase())
      .join('') || 'HQ';
  }

  dataRelativa(data: string) {
    const timestamp = new Date(data).getTime();
    const diferenca = Date.now() - timestamp;
    const minutos = Math.max(1, Math.floor(diferenca / 60000));
    if (minutos < 60) {
      return `${minutos} min`;
    }

    const horas = Math.floor(minutos / 60);
    if (horas < 24) {
      return `${horas} h`;
    }

    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(new Date(data));
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  private carregarResumo() {
    this.api.obterResumoColecao().subscribe({
      next: (resumo) => this.resumo.set(resumo),
      error: () => this.resumo.set({ totalItens: 0, totalSeries: 0, totalEditoras: 0, valorTotalPago: 0 }),
    });
  }

  private carregarFeed() {
    this.api.listarFeed().subscribe({
      next: (feed) => this.feed.set(feed),
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel carregar o feed.'),
    });
  }

  private carregarSugestaoAmigo() {
    const usuarioAtual = this.usuario();
    this.api.listarUsuarios(PainelPage.EMAIL_SUGESTAO_AMIGO).subscribe({
      next: (usuarios) => {
        const sugestao = usuarios.find((usuario) => usuario.email.toLowerCase() === PainelPage.EMAIL_SUGESTAO_AMIGO);
        if (!sugestao || sugestao.id === usuarioAtual?.id) {
          this.sugestaoAmigo.set(null);
          return;
        }

        this.api.obterRelacionamentoAmizade(sugestao.id).subscribe({
          next: (amizade) => this.sugestaoAmigo.set(amizade ? null : sugestao),
          error: () => this.sugestaoAmigo.set(sugestao),
        });
      },
      error: () => this.sugestaoAmigo.set(null),
    });
  }

  removerPostagem(postagem: PostagemFeed) {
    if (!confirm('Apagar esta postagem?')) {
      return;
    }

    this.interagindoId.set(postagem.id);
    this.api.removerPostagemFeed(postagem.id).subscribe({
      next: () => this.feed.update((feed) => feed.filter((item) => item.id !== postagem.id)),
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel apagar esta postagem.'),
      complete: () => this.interagindoId.set(null),
    });
  }

  removerComentario(postagem: PostagemFeed, comentarioId: number) {
    this.interagindoId.set(postagem.id);
    this.api.removerComentarioFeed(postagem.id, comentarioId).subscribe({
      next: (atualizada) => this.substituirPostagem(atualizada),
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel apagar este comentario.'),
      complete: () => this.interagindoId.set(null),
    });
  }

  private carregarAnuncios() {
    this.api.listarAnuncios().subscribe({
      next: (anuncios) => this.anuncios.set(anuncios.slice(0, 3)),
      error: () => this.anuncios.set([]),
    });
  }

  private substituirPostagem(postagem: PostagemFeed) {
    this.feed.update((feed) => feed.map((item) => item.id === postagem.id ? postagem : item));
  }

  private enviarImagensSelecionadas(): Promise<ImagemFeed[]> {
    if (!this.imagensSelecionadas.length) {
      return Promise.resolve([]);
    }

    return new Promise((resolve, reject) => {
      this.api.enviarImagensFeed(this.imagensSelecionadas).subscribe({
        next: (imagens) => resolve(imagens),
        error: (erro) => reject(erro?.error?.mensagem || 'Nao foi possivel enviar as imagens.'),
      });
    });
  }

  private validarImagens(arquivos: File[], excedeuQuantidade: boolean) {
    if (excedeuQuantidade || arquivos.length > 3) {
      return 'A postagem pode ter no maximo 3 imagens.';
    }

    const tiposPermitidos = ['image/jpeg', 'image/png', 'image/webp'];
    const invalida = arquivos.find((arquivo) => !tiposPermitidos.includes(arquivo.type));
    if (invalida) {
      return 'Use apenas imagens JPG, PNG ou WEBP.';
    }

    const grande = arquivos.find((arquivo) => arquivo.size > 2 * 1024 * 1024);
    if (grande) {
      return 'Cada imagem deve ter no maximo 2 MB.';
    }

    return '';
  }

  private limparPrevisualizacoes() {
    this.previsualizacoes.forEach((imagem) => URL.revokeObjectURL(imagem.url));
  }
}
