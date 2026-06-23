import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { resolverUrlMidia as resolverUrlMidiaCore } from '../../core/midia-url';
import { ColecaoResumo, ImagemFeed, PostagemFeed } from '../../core/modelos';
import { PerfilFeedComponent } from '../../shared/perfil-feed.component';

@Component({
  selector: 'app-painel-page',
  imports: [CommonModule, FormsModule, RouterLink, PerfilFeedComponent],
  template: `
    <section class="cabecalho-pagina feed-cabecalho">
      <div>
        <p class="rotulo">Feed</p>
        <h1>Compartilhe leituras, achados e fotos com seus amigos.</h1>
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
        <app-perfil-feed
          [usuario]="usuario()"
          modo="resumo"
        ></app-perfil-feed>

        <div class="acoes-perfil-feed">
          <a class="botao compacto secundario" routerLink="/perfil">Editar perfil</a>
        </div>

        <article class="bloco compositor-feed">
          <label>
            No que voce esta pensando?
            <textarea
              [(ngModel)]="novoConteudo"
              name="novoConteudo"
              rows="4"
              maxlength="2000"
              placeholder="Ex.: terminei A Saga do Homem-Aranha #12 hoje. Que final!"
            ></textarea>
          </label>
          <div class="upload-feed">
            <label class="botao secundario compacto seletor-feed">
              Escolher fotos
              <input type="file" accept="image/jpeg,image/png,image/webp" multiple (change)="selecionarImagens($event)" />
            </label>
            <span>JPG, PNG ou WEBP. Ate 3 imagens, 2 MB cada.</span>
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

          <div class="acoes-feed">
            <button class="botao primario" type="button" (click)="publicar()" [disabled]="publicando() || !novoConteudo.trim()">
              {{ publicando() ? 'Publicando...' : 'Publicar' }}
            </button>
          </div>
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
                <div>
                  <a [routerLink]="['/usuario', postagem.usuario.id]" class="link-nome-amigo">
                    <strong>{{ postagem.usuario.nome }}</strong>
                  </a>
                  @if (postagem.usuario.bio) {
                    <small>{{ postagem.usuario.bio }}</small>
                  }
                  <span>{{ dataRelativa(postagem.dataCriacao) }}</span>
                </div>
              </header>

              <p class="texto-postagem">{{ postagem.conteudo }}</p>

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
                  class="botao compacto"
                  type="button"
                  [class.primario]="postagem.curtidaPeloUsuario"
                  (click)="curtir(postagem)"
                  [disabled]="interagindoId() === postagem.id"
                >
                  {{ postagem.curtidaPeloUsuario ? 'Curtido' : 'Curtir' }}
                </button>
                <span>{{ postagem.totalCurtidas }} curtidas</span>
                <span>{{ postagem.comentarios.length }} comentarios</span>
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
                    </div>
                  </article>
                }
              </section>

              <div class="novo-comentario">
                <input
                  [(ngModel)]="comentarios[postagem.id]"
                  [name]="'comentario' + postagem.id"
                  placeholder="Escreva um comentario"
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

    .feed-metricas {
      margin-bottom: 18px;
    }

    .feed-layout {
      display: grid;
      grid-template-columns: minmax(0, 1fr) 280px;
      gap: 18px;
      align-items: start;
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

    .compositor-feed label {
      display: grid;
      gap: 8px;
      color: var(--texto-suave);
      font-size: 0.9rem;
      font-weight: 750;
    }

    .compositor-feed textarea {
      resize: vertical;
      min-height: 110px;
    }

    .acoes-feed {
      display: flex;
      justify-content: flex-end;
    }

    .upload-feed {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      align-items: center;
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

    .postagem-card header div:last-child {
      display: grid;
      gap: 2px;
    }

    .postagem-card header small {
      color: var(--texto-suave);
      font-size: 0.82rem;
      overflow-wrap: anywhere;
    }

    .postagem-card header span,
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
      border-radius: 8px;
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
    }

    .barra-postagem {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      align-items: center;
      padding-top: 4px;
      border-top: 1px solid var(--borda);
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
    }

    .novo-comentario {
      display: grid;
      grid-template-columns: minmax(0, 1fr) auto;
      gap: 8px;
    }

    .feed-lateral {
      position: sticky;
      top: 88px;
      display: grid;
      gap: 16px;
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
    }
  `,
})
export class PainelPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);

  readonly usuario = this.autenticacao.usuario;
  readonly resumo = signal<ColecaoResumo | null>(null);
  readonly feed = signal<PostagemFeed[]>([]);
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
