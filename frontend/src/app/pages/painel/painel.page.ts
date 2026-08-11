import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { resolverUrlMidia as resolverUrlMidiaCore } from '../../core/midia-url';
import { Anuncio, ColecaoResumo, ImagemFeed, PartnerChannel, PostagemFeed, RelatedVideoInput, Usuario } from '../../core/modelos';
import { PerfilFeedComponent } from '../../shared/perfil-feed.component';
import { RelatedContentComponent } from '../../shared/related-content.component';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-painel-page',
  imports: [CommonModule, FormsModule, RouterLink, PerfilFeedComponent, RelatedContentComponent],
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

    <nav class="atalhos-feed" aria-label="Atalhos do colecionador">
      <a routerLink="/colecao"><span>📚</span><strong>Minha Estante</strong></a>
      <a routerLink="/anuncios"><span>📢</span><strong>Meus anúncios</strong></a>
      <a routerLink="/compras"><span>🛒</span><strong>Compras e desejos</strong></a>
      <a routerLink="/catalogo"><span>🔎</span><strong>Buscar HQ</strong></a>
    </nav>

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

        <article class="bloco compositor-feed" id="publicar">
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
              placeholder="Compartilhe uma leitura ou cole aqui um link do YouTube..."
            ></textarea>
          </div>

          @if (linksYoutubeNoConteudo().length) {
            <div class="youtube-detectado" role="status">
              <span aria-hidden="true">▶</span>
              <div>
                <strong>{{ linksYoutubeNoConteudo().length === 1 ? 'Link do YouTube detectado' : linksYoutubeNoConteudo().length + ' links do YouTube detectados' }}</strong>
                <small>O HQ-HUB criará automaticamente {{ linksYoutubeNoConteudo().length === 1 ? 'um card para o vídeo' : 'cards para os vídeos' }}.</small>
              </div>
            </div>
          }

          @if (videosRelacionadosFormulario.length) {
            <div class="videos-compositor">
              <strong>Vídeos relacionados</strong>
              @for (video of videosRelacionadosFormulario; track $index) {
                <div class="linha-video-compositor">
                  <input
                    [(ngModel)]="video.title"
                    [name]="'tituloVideo' + $index"
                    maxlength="200"
                    placeholder="Título do vídeo"
                  />
                  <input
                    [(ngModel)]="video.url"
                    [name]="'urlVideo' + $index"
                    type="url"
                    placeholder="https://www.youtube.com/watch?v=..."
                  />
                  <button type="button" class="botao compacto perigo" (click)="removerVideoRelacionado($index)">Remover</button>
                </div>
              }
            </div>
          }
          @if (canalParceiroFormulario) {
            <div class="videos-compositor canal-parceiro-compositor">
              <strong>Canal parceiro em destaque</strong>
              <div class="linha-video-compositor">
                <input
                  [(ngModel)]="canalParceiroFormulario.name"
                  name="nomeCanalParceiro"
                  maxlength="200"
                  placeholder="Nome do canal (opcional)"
                />
                <input
                  [(ngModel)]="canalParceiroFormulario.url"
                  name="urlCanalParceiro"
                  type="url"
                  placeholder="Link do canal parceiro"
                />
                <button type="button" class="botao compacto perigo" (click)="removerCanalParceiroDoFormulario()">Remover</button>
              </div>
            </div>
          }
          <div class="compositor-rodape">
            <div class="compositor-acoes-midia">
              <label class="acao-upload-feed seletor-feed">
                <span>Adicionar fotos</span>
                <input type="file" accept="image/jpeg,image/png,image/webp" multiple (change)="selecionarImagens($event)" />
              </label>
              <button
                class="acao-upload-feed"
                type="button"
                (click)="adicionarVideoRelacionado()"
                [disabled]="videosRelacionadosFormulario.length >= 3"
              >
                Adicionar vídeo
              </button>
              <button
                class="acao-upload-feed"
                type="button"
                (click)="adicionarCanalParceiroAoFormulario()"
                [disabled]="!!canalParceiroFormulario"
              >
                Destacar canal parceiro
              </button>
            </div>
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
            <article class="bloco postagem-card" [id]="idPostagem(postagem)" [class.postagem-fixada]="postagem.fixada">
              <header class="cabecalho-postagem">
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
                  @if (postagem.usuario.bio) {
                    <span class="bio-autor">{{ postagem.usuario.bio }}</span>
                  }
                  <small class="metadados-postagem">
                    {{ dataRelativa(postagem.dataCriacao) }} <span aria-hidden="true">•</span> Público
                    @if (postagem.fixada) { <span class="selo-fixada">• Fixada</span> }
                  </small>
                </div>
                <details class="menu-postagem">
                  <summary aria-label="Abrir opções da publicação" title="Opções">•••</summary>
                  <div class="menu-postagem-popover">
                    @if (podeEditarCanal(postagem)) {
                      <button type="button" (click)="iniciarEdicaoPostagem(postagem, $event)">Editar postagem</button>
                      <button class="perigo" type="button" (click)="removerPeloMenu(postagem, $event)" [disabled]="interagindoId() === postagem.id">
                        Remover postagem
                      </button>
                      <button type="button" (click)="alternarFixacao(postagem, $event)" [disabled]="interagindoId() === postagem.id">
                        {{ postagem.fixada ? 'Desafixar publicação' : 'Fixar publicação' }}
                      </button>
                    }
                    <button type="button" (click)="compartilharPeloMenu(postagem, $event)">Compartilhar</button>
                  </div>
                </details>
              </header>

              @if (editandoPostagemId() === postagem.id) {
                <div class="editor-postagem">
                  <textarea [(ngModel)]="conteudosEdicao[postagem.id]" [name]="'conteudoEdicao' + postagem.id" maxlength="2000" rows="4"></textarea>
                  <div>
                    <button class="botao compacto primario" type="button" (click)="salvarEdicaoPostagem(postagem)" [disabled]="interagindoId() === postagem.id">Salvar</button>
                    <button class="botao compacto" type="button" (click)="cancelarEdicaoPostagem()">Cancelar</button>
                  </div>
                </div>
              } @else if (conteudoVisivel(postagem)) {
                <p class="texto-postagem">{{ conteudoVisivel(postagem) }}</p>
              }

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
                    <a class="botao compacto" [routerLink]="['/usuario', postagem.usuario.id]" fragment="estante">Ver colecao</a>
                  </div>
                </article>
              }

              @if (postagem.catalogoDestaque) {
                <article class="cartao-colecao-feed cartao-catalogo-feed" [class.sem-capa]="!capaCatalogoExibivel(postagem)">
                  @if (capaCatalogoExibivel(postagem); as urlCapa) {
                    <img [src]="urlCapa" [alt]="postagem.catalogoDestaque.titulo" loading="lazy" />
                  }
                  <div>
                    <p class="rotulo">Catalogo</p>
                    <h3>{{ postagem.catalogoDestaque.titulo }}</h3>
                    <span>{{ postagem.catalogoDestaque.quantidadeEdicoes }} edicoes - {{ postagem.catalogoDestaque.editora }}</span>
                    <strong class="status-colecao">Atualizado no acervo</strong>
                    <a class="botao compacto" routerLink="/catalogo" [queryParams]="{ serieId: postagem.catalogoDestaque.serieId }">
                      Ver no catalogo
                    </a>
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

              @if (postagem.catalogoDestaque || postagem.colecaoDestaque) {
                <section class="contexto-hq" aria-label="Relacionado a esta HQ">
                  <strong><span aria-hidden="true">▤</span> Relacionado a esta HQ</strong>
                  <div>
                    <span>✓ HQ</span>
                    @if (postagem.relatedVideos.length) { <span>✓ Vídeo</span> }
                    @if (editoraRelacionada(postagem)) { <span>✓ {{ editoraRelacionada(postagem) }}</span> }
                  </div>
                </section>
              }

              <app-related-content
                [videos]="postagem.relatedVideos"
                [partnerChannel]="postagem.partnerChannel"
                [referenceTitle]="postagem.catalogoDestaque?.titulo || postagem.colecaoDestaque?.titulo || ''"
              ></app-related-content>

              @if (podeEditarCanal(postagem)) {
                <div class="gestao-canal-parceiro">
                  <button class="botao-texto" type="button" (click)="alternarEditorCanal(postagem)">
                    {{ postagem.partnerChannel ? 'Editar canal parceiro' : 'Destacar canal parceiro' }}
                  </button>
                  @if (editandoCanalId() === postagem.id) {
                    <div class="editor-canal-parceiro">
                      <input
                        [(ngModel)]="canaisParceirosEdicao[postagem.id].name"
                        [name]="'nomeCanalParceiroPostagem' + postagem.id"
                        maxlength="200"
                        placeholder="Nome do canal (opcional)"
                      />
                      <input
                        [(ngModel)]="canaisParceirosEdicao[postagem.id].url"
                        [name]="'urlCanalParceiroPostagem' + postagem.id"
                        type="url"
                        placeholder="Link do canal parceiro"
                      />
                      <div>
                        <button class="botao compacto primario" type="button" (click)="salvarCanalParceiro(postagem)" [disabled]="salvandoCanalId() === postagem.id">
                          {{ salvandoCanalId() === postagem.id ? 'Salvando...' : 'Salvar destaque' }}
                        </button>
                        @if (postagem.partnerChannel) {
                          <button class="botao compacto perigo" type="button" (click)="removerCanalParceiro(postagem)" [disabled]="salvandoCanalId() === postagem.id">Remover destaque</button>
                        }
                        <button class="botao compacto" type="button" (click)="fecharEditorCanal()">Cancelar</button>
                      </div>
                    </div>
                  }
                </div>
              }

              <div class="contadores-postagem" [class.zerados]="postagem.totalCurtidas === 0 && postagem.comentarios.length === 0">
                <span>♥ {{ postagem.totalCurtidas }}</span>
                <span>💬 {{ postagem.comentarios.length }} {{ postagem.comentarios.length === 1 ? 'comentário' : 'comentários' }}</span>
              </div>

              <div class="barra-postagem">
                <button
                  class="acao-social"
                  type="button"
                  [class.ativo]="postagem.curtidaPeloUsuario"
                  (click)="curtir(postagem)"
                  [disabled]="interagindoId() === postagem.id"
                >
                  <span>{{ postagem.curtidaPeloUsuario ? '♥' : '♡' }}</span>
                  {{ postagem.curtidaPeloUsuario ? 'Curtido' : 'Curtir' }}
                </button>
                <button class="acao-social" type="button" (click)="focarComentario(postagem)">
                  <span class="icone-acao neutro">💬</span> Comentar
                </button>
                <button
                  class="acao-social compartilhar"
                  type="button"
                  (click)="compartilhar(postagem)"
                  [disabled]="compartilhandoId() === postagem.id"
                >
                  <span class="icone-acao neutro">↗</span>
                  {{ compartilhandoId() === postagem.id ? 'Compartilhando...' : 'Compartilhar' }}
                </button>
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
                      <div class="acoes-comentario">
                        <span class="tempo-comentario">{{ dataRelativa(comentario.dataCriacao) }}</span>
                        <button
                          class="curtir-comentario"
                          type="button"
                          [class.ativo]="comentario.curtidaPeloUsuario"
                          [attr.aria-label]="comentario.curtidaPeloUsuario ? 'Remover curtida do comentario' : 'Curtir comentario'"
                          [attr.aria-pressed]="comentario.curtidaPeloUsuario"
                          (click)="curtirComentario(postagem, comentario.id)"
                          [disabled]="interagindoId() === postagem.id"
                        >
                          {{ comentario.curtidaPeloUsuario ? '♥' : '♡' }}
                          @if (comentario.totalCurtidas > 0) {
                            <span>{{ comentario.totalCurtidas }}</span>
                          }
                        </button>
                      </div>
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
                  [id]="'comentario-postagem-' + postagem.id"
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
          <a routerLink="/titulos-estrangeiros">Títulos estrangeiros</a>
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

    .videos-compositor { display: grid; gap: 10px; margin: 12px 16px 0; padding: 12px; border: 1px solid var(--borda); border-radius: 12px; background: var(--superficie-2); }
    .linha-video-compositor { display: grid; grid-template-columns: minmax(140px, .8fr) minmax(220px, 1.4fr) auto; gap: 8px; align-items: center; }
    .compositor-acoes-midia { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
    .canal-parceiro-compositor { border-color: rgba(255, 135, 31, .35); }
    .gestao-canal-parceiro { display: grid; gap: 8px; justify-items: start; }
    .editor-canal-parceiro { display: grid; width: 100%; gap: 8px; padding: 12px; border: 1px solid var(--borda); border-radius: 12px; background: var(--superficie-2); }
    .editor-canal-parceiro > div { display: flex; flex-wrap: wrap; gap: 8px; }

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

    .cartao-colecao-feed.sem-capa {
      grid-template-columns: 1fr;
    }

    .cartao-colecao-feed.sem-capa > div {
      padding: 14px;
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
      color: var(--texto-suave);
      font-size: 0.78rem;
    }

    .acoes-comentario {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-top: 6px;
    }

    .curtir-comentario {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      min-width: 28px;
      padding: 2px 6px;
      border: 0;
      border-radius: 999px;
      background: transparent;
      color: var(--texto-suave);
      cursor: pointer;
      font-size: 0.85rem;
      font-weight: 850;
    }

    .curtir-comentario:hover {
      background: rgba(255, 135, 31, 0.12);
      color: #d75f00;
    }

    .curtir-comentario.ativo {
      color: #e5484d;
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

    /* Design system do feed */
    :host {
      --feed-raio-card: 16px;
      --feed-raio-interno: 12px;
      --feed-espaco: 12px;
      --feed-sombra: 0 10px 32px rgba(15, 23, 42, 0.07);
    }

    .lista-feed { gap: 16px; }

    .postagem-card {
      gap: var(--feed-espaco);
      padding: 16px;
      border-radius: var(--feed-raio-card);
      box-shadow: var(--feed-sombra);
      transition: border-color .2s ease, box-shadow .2s ease;
    }

    .postagem-card.postagem-fixada {
      border-color: color-mix(in srgb, var(--borda) 62%, var(--marca) 38%);
    }

    .cabecalho-postagem {
      display: grid;
      grid-template-columns: 44px minmax(0, 1fr) auto;
      gap: 11px;
      align-items: start;
    }

    .autor-postagem { gap: 2px; padding-top: 1px; }
    .autor-postagem strong { font-size: 1rem; line-height: 1.2; }

    .bio-autor {
      overflow: hidden;
      color: var(--texto-suave);
      font-size: .82rem;
      line-height: 1.3;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .metadados-postagem {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
      align-items: center;
      color: color-mix(in srgb, var(--texto-suave) 86%, transparent);
      font-size: .75rem !important;
    }

    .selo-fixada { color: var(--marca); font-weight: 800; }

    .menu-postagem { position: relative; margin-left: auto; }
    .menu-postagem summary {
      display: grid;
      width: 36px;
      height: 36px;
      place-items: center;
      border-radius: 50%;
      color: var(--texto-suave);
      cursor: pointer;
      font-size: 1rem;
      font-weight: 900;
      letter-spacing: 1px;
      list-style: none;
      transition: color .18s ease, background .18s ease;
    }
    .menu-postagem summary::-webkit-details-marker { display: none; }
    .menu-postagem summary:hover,
    .menu-postagem[open] summary { color: var(--texto); background: var(--superficie-2); }
    .menu-postagem-popover {
      position: absolute;
      top: 42px;
      right: 0;
      z-index: 12;
      display: grid;
      width: min(220px, calc(100vw - 42px));
      overflow: hidden;
      padding: 6px;
      border: 1px solid var(--borda);
      border-radius: 12px;
      background: var(--superficie);
      box-shadow: 0 18px 48px rgba(15, 23, 42, .18);
      animation: abrir-menu .16s ease-out both;
    }
    .menu-postagem-popover button {
      min-height: 40px;
      padding: 0 10px;
      border: 0;
      border-radius: 8px;
      color: var(--texto);
      background: transparent;
      cursor: pointer;
      font: inherit;
      font-size: .84rem;
      font-weight: 750;
      text-align: left;
    }
    .menu-postagem-popover button:hover { background: var(--superficie-2); }
    .menu-postagem-popover button.perigo { color: #b42318; }

    .texto-postagem {
      padding-bottom: 2px;
      color: var(--texto);
      font-size: .98rem;
      line-height: 1.55;
    }

    .editor-postagem { display: grid; gap: 8px; }
    .editor-postagem textarea { resize: vertical; min-height: 96px; background: var(--superficie-2); }
    .editor-postagem > div { display: flex; gap: 8px; justify-content: flex-end; }

    .cartao-colecao-feed,
    .grade-imagens-feed div,
    .grade-imagens-feed a,
    .comentarios-feed article,
    .novo-comentario input { border-radius: var(--feed-raio-interno); }

    .imagem-postagem { animation: revelar-imagem .28s ease-out both; }

    .contexto-hq {
      display: grid;
      gap: 7px;
      padding: 10px 12px;
      border: 1px solid var(--borda);
      border-radius: var(--feed-raio-interno);
      background: var(--superficie-2);
    }
    .contexto-hq strong { display: flex; gap: 7px; align-items: center; font-size: .83rem; }
    .contexto-hq strong span { color: var(--marca); }
    .contexto-hq div { display: flex; flex-wrap: wrap; gap: 6px; }
    .contexto-hq div span {
      padding: 4px 7px;
      border-radius: 999px;
      color: var(--texto-suave);
      background: var(--superficie);
      font-size: .72rem;
      font-weight: 750;
    }

    .gestao-canal-parceiro { margin-top: -4px; }

    .contadores-postagem {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      padding-top: 2px;
      color: var(--texto-suave);
      font-size: .78rem;
      font-weight: 700;
    }
    .contadores-postagem.zerados { opacity: .62; }

    .barra-postagem {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 4px;
      padding-top: 7px;
    }
    .acao-social {
      justify-content: center;
      min-width: 0;
      min-height: 40px;
      padding: 0 8px;
      border-radius: 9px;
      font-size: .82rem;
      transition: color .18s ease, background .18s ease, transform .12s ease;
    }
    .acao-social:hover { color: var(--texto); background: var(--superficie-2); }
    .acao-social:active { transform: scale(.97); }
    .acao-social span { font-size: 1.15rem; }
    .acao-social .icone-acao.neutro { color: currentColor; font-size: 1rem; }
    .acao-social.ativo span { animation: curtir-pop .28s ease-out; }

    .comentarios-feed article { padding: 9px 10px; background: var(--superficie-2); }
    .novo-comentario input { min-height: 42px; }

    @keyframes abrir-menu { from { opacity: 0; transform: translateY(-5px) scale(.98); } to { opacity: 1; transform: none; } }
    @keyframes curtir-pop { 50% { transform: scale(1.3); } }
    @keyframes revelar-imagem { from { opacity: 0; } to { opacity: 1; } }

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

      .linha-video-compositor { grid-template-columns: 1fr; }

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

    @media (max-width: 600px) {
      :host { --feed-raio-card: 14px; --feed-espaco: 11px; }
      .feed-cabecalho { align-items: start; gap: 10px; }
      .feed-cabecalho h1 { font-size: clamp(1.35rem, 7vw, 1.75rem); }
      .feed-metricas { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .postagem-card { padding: 14px 12px; }
      .cabecalho-postagem { grid-template-columns: 40px minmax(0, 1fr) 36px; gap: 9px; }
      .cabecalho-postagem .avatar-feed { width: 40px; height: 40px; }
      .bio-autor { max-width: 100%; }
      .cartao-colecao-feed { grid-template-columns: 92px minmax(0, 1fr); gap: 11px; }
      .cartao-colecao-feed > img { min-height: 148px; }
      .cartao-colecao-feed > div { gap: 6px; padding: 10px 10px 10px 0; }
      .cartao-colecao-feed h3 { font-size: 1rem; }
      .acao-social { padding: 0 4px; font-size: .76rem; }
      .novo-comentario { grid-template-columns: minmax(0, 1fr) auto; }
      .novo-comentario .botao { padding-inline: 10px; }
    }

    @media (max-width: 360px) {
      .acao-social { gap: 4px; font-size: .7rem; }
      .acao-social span { font-size: 1rem; }
      .contexto-hq { padding: 9px; }
    }

    @media (prefers-reduced-motion: reduce) {
      .menu-postagem-popover,
      .acao-social.ativo span,
      .imagem-postagem { animation: none; }
      .postagem-card,
      .acao-social { transition: none; }
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
  readonly compartilhandoId = signal<number | null>(null);
  readonly editandoPostagemId = signal<number | null>(null);
  readonly editandoCanalId = signal<number | null>(null);
  readonly salvandoCanalId = signal<number | null>(null);
  readonly mensagem = signal('');
  novoConteudo = '';
  imagensSelecionadas: File[] = [];
  previsualizacoes: Array<{ url: string; nome: string }> = [];
  videosRelacionadosFormulario: Array<{ title: string; url: string }> = [];
  canalParceiroFormulario: { name: string; url: string } | null = null;
  canaisParceirosEdicao: Record<number, { name: string; url: string }> = {};
  conteudosEdicao: Record<number, string> = {};
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

    const videosManuais: RelatedVideoInput[] = this.videosRelacionadosFormulario.map((video) => ({
      title: video.title.trim(),
      url: video.url.trim(),
    }));
    if (videosManuais.some((video) => !video.title || !video.url)) {
      this.mensagem.set('Informe o título e a URL de cada vídeo relacionado.');
      return;
    }
    const videosRelacionados = this.mesclarVideosYoutube(conteudo, videosManuais);
    const partnerChannel = this.canalParceiroFormulario
      ? { name: this.canalParceiroFormulario.name.trim() || null, url: this.canalParceiroFormulario.url.trim() }
      : null;
    if (partnerChannel && !partnerChannel.url) {
      this.mensagem.set('Informe o link do canal parceiro.');
      return;
    }

    this.publicando.set(true);
    this.mensagem.set('');
    this.enviarImagensSelecionadas()
      .then((imagens) => this.criarPostagem(conteudo, imagens, videosRelacionados, partnerChannel))
      .catch((mensagem) => {
        this.publicando.set(false);
        this.mensagem.set(String(mensagem));
      });
  }

  adicionarVideoRelacionado() {
    if (this.videosRelacionadosFormulario.length < 3) {
      this.videosRelacionadosFormulario.push({ title: '', url: '' });
    }
  }

  linksYoutubeNoConteudo() {
    return this.extrairLinksYoutube(this.novoConteudo).slice(0, Math.max(0, 3 - this.videosRelacionadosFormulario.length));
  }

  removerVideoRelacionado(indice: number) {
    this.videosRelacionadosFormulario.splice(indice, 1);
  }

  adicionarCanalParceiroAoFormulario() {
    this.canalParceiroFormulario = { name: '', url: '' };
  }

  removerCanalParceiroDoFormulario() {
    this.canalParceiroFormulario = null;
  }

  podeEditarCanal(postagem: PostagemFeed) {
    return postagem.usuario.id === this.usuario()?.id || this.usuario()?.perfil === 'ADMINISTRADOR';
  }

  iniciarEdicaoPostagem(postagem: PostagemFeed, evento?: Event) {
    this.fecharMenuPostagem(evento);
    this.conteudosEdicao[postagem.id] = postagem.conteudo;
    this.editandoPostagemId.set(postagem.id);
  }

  cancelarEdicaoPostagem() {
    this.editandoPostagemId.set(null);
  }

  salvarEdicaoPostagem(postagem: PostagemFeed) {
    const conteudo = this.conteudosEdicao[postagem.id]?.trim();
    if (!conteudo) {
      this.mensagem.set('A postagem não pode ficar vazia.');
      return;
    }
    this.interagindoId.set(postagem.id);
    this.api.atualizarPostagemFeed(postagem.id, conteudo).subscribe({
      next: (atualizada) => {
        this.substituirPostagem(atualizada);
        this.editandoPostagemId.set(null);
      },
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Não foi possível editar esta postagem.'),
      complete: () => this.interagindoId.set(null),
    });
  }

  alternarFixacao(postagem: PostagemFeed, evento?: Event) {
    this.fecharMenuPostagem(evento);
    this.interagindoId.set(postagem.id);
    this.api.alternarFixacaoPostagem(postagem.id).subscribe({
      next: (atualizada) => {
        this.substituirPostagem(atualizada);
        this.feed.update((itens) => [...itens].sort((a, b) => Number(b.fixada) - Number(a.fixada)
          || new Date(b.dataCriacao).getTime() - new Date(a.dataCriacao).getTime()));
      },
      error: (erro) => this.mensagem.set(erro?.error?.mensagem || 'Não foi possível alterar a fixação.'),
      complete: () => this.interagindoId.set(null),
    });
  }

  compartilharPeloMenu(postagem: PostagemFeed, evento: Event) {
    this.fecharMenuPostagem(evento);
    void this.compartilhar(postagem);
  }

  removerPeloMenu(postagem: PostagemFeed, evento: Event) {
    this.fecharMenuPostagem(evento);
    this.removerPostagem(postagem);
  }

  focarComentario(postagem: PostagemFeed) {
    document.getElementById(`comentario-postagem-${postagem.id}`)?.focus();
  }

  conteudoVisivel(postagem: PostagemFeed) {
    if (!postagem.relatedVideos?.length) {
      return postagem.conteudo.trim();
    }
    return postagem.conteudo
      .replace(/https?:\/\/(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?[^\s<]*v=|shorts\/|live\/|embed\/)|youtu\.be\/)[^\s<]+/gi, '')
      .replace(/[ \t]+\n/g, '\n')
      .replace(/\n{3,}/g, '\n\n')
      .trim();
  }

  editoraRelacionada(postagem: PostagemFeed) {
    return postagem.catalogoDestaque?.editora || postagem.colecaoDestaque?.editora || '';
  }

  private fecharMenuPostagem(evento?: Event) {
    const detalhes = (evento?.currentTarget as HTMLElement | null)?.closest('details');
    if (detalhes) {
      detalhes.removeAttribute('open');
    }
  }

  alternarEditorCanal(postagem: PostagemFeed) {
    if (this.editandoCanalId() === postagem.id) {
      this.fecharEditorCanal();
      return;
    }
    this.canaisParceirosEdicao[postagem.id] = {
      name: postagem.partnerChannel?.name || '',
      url: postagem.partnerChannel?.url || '',
    };
    this.editandoCanalId.set(postagem.id);
  }

  fecharEditorCanal() {
    this.editandoCanalId.set(null);
  }

  salvarCanalParceiro(postagem: PostagemFeed) {
    const formulario = this.canaisParceirosEdicao[postagem.id];
    const url = formulario?.url.trim();
    if (!url) {
      this.mensagem.set('Informe o link do canal parceiro.');
      return;
    }
    this.salvandoCanalId.set(postagem.id);
    this.mensagem.set('');
    this.api.atualizarCanalParceiro(postagem.id, { name: formulario.name.trim() || null, url }).subscribe({
      next: (atualizada) => {
        this.substituirPostagem(atualizada);
        this.salvandoCanalId.set(null);
        this.fecharEditorCanal();
      },
      error: (erro) => {
        this.salvandoCanalId.set(null);
        this.mensagem.set(erro?.error?.mensagem || 'Não foi possível salvar o canal parceiro.');
      },
    });
  }

  removerCanalParceiro(postagem: PostagemFeed) {
    this.salvandoCanalId.set(postagem.id);
    this.api.removerCanalParceiro(postagem.id).subscribe({
      next: (atualizada) => {
        this.substituirPostagem(atualizada);
        this.salvandoCanalId.set(null);
        this.fecharEditorCanal();
      },
      error: (erro) => {
        this.salvandoCanalId.set(null);
        this.mensagem.set(erro?.error?.mensagem || 'Não foi possível remover o canal parceiro.');
      },
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
    if (postagem.colecaoDestaque || postagem.catalogoDestaque) {
      return [];
    }

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

  private criarPostagem(
    conteudo: string,
    imagens: ImagemFeed[],
    relatedVideos: RelatedVideoInput[],
    partnerChannel: PartnerChannel | null,
  ) {
    this.api.publicarNoFeed({ conteudo, urlImagem: imagens[0]?.urlImagem || null, imagens, relatedVideos, partnerChannel }).subscribe({
      next: (postagem) => {
        this.feed.update((feed) => [postagem, ...feed]);
        this.novoConteudo = '';
        this.imagensSelecionadas = [];
        this.videosRelacionadosFormulario = [];
        this.canalParceiroFormulario = null;
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

  private mesclarVideosYoutube(conteudo: string, videosManuais: RelatedVideoInput[]) {
    const urlsExistentes = new Set(videosManuais.map((video) => this.normalizarUrlYoutube(video.url)));
    const automaticos: RelatedVideoInput[] = [];

    for (const url of this.extrairLinksYoutube(conteudo)) {
      const normalizada = this.normalizarUrlYoutube(url);
      if (!normalizada || urlsExistentes.has(normalizada)) {
        continue;
      }
      urlsExistentes.add(normalizada);
      const videoId = this.extrairIdYoutube(url);
      automaticos.push({
        title: 'Vídeo compartilhado no YouTube',
        url,
        thumbnail: videoId ? `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg` : null,
      });
      if (videosManuais.length + automaticos.length >= 3) {
        break;
      }
    }

    return [...videosManuais, ...automaticos].slice(0, 3);
  }

  private extrairLinksYoutube(texto: string) {
    const padrao = /https?:\/\/(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?[^\s<]*v=|shorts\/|live\/|embed\/)|youtu\.be\/)[^\s<]+/gi;
    return [...texto.matchAll(padrao)]
      .map((resultado) => resultado[0].replace(/[),.;!?]+$/g, ''))
      .filter((url, indice, urls) => urls.indexOf(url) === indice);
  }

  private extrairIdYoutube(url: string) {
    try {
      const endereco = new URL(url);
      const host = endereco.hostname.replace(/^www\.|^m\./, '');
      let videoId = '';
      if (host === 'youtu.be') {
        videoId = endereco.pathname.split('/').filter(Boolean)[0] || '';
      } else if (host === 'youtube.com') {
        videoId = endereco.searchParams.get('v') || endereco.pathname.split('/').filter(Boolean)[1] || '';
      }
      return /^[A-Za-z0-9_-]{6,}$/.test(videoId) ? videoId : '';
    } catch {
      return '';
    }
  }

  private normalizarUrlYoutube(url: string) {
    const videoId = this.extrairIdYoutube(url);
    return videoId ? `youtube:${videoId}` : url.trim().toLowerCase();
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

  curtirComentario(postagem: PostagemFeed, comentarioId: number) {
    this.interagindoId.set(postagem.id);
    this.api.alternarCurtidaComentario(postagem.id, comentarioId).subscribe({
      next: (atualizada) => this.substituirPostagem(atualizada),
      error: (erro) => {
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel curtir este comentario.');
        this.interagindoId.set(null);
      },
      complete: () => this.interagindoId.set(null),
    });
  }

  async compartilhar(postagem: PostagemFeed) {
    this.compartilhandoId.set(postagem.id);
    const url = this.urlPostagem(postagem);
    const titulo = postagem.colecaoDestaque?.titulo
      || postagem.catalogoDestaque?.titulo
      || 'HQ-HUB';

    try {
      if (navigator.share) {
        await navigator.share({ title: titulo, url });
        return;
      }

      await this.copiarTexto(url);
      this.mensagem.set('Link da postagem copiado. Agora e so colar no WhatsApp ou onde quiser.');
    } catch (erro) {
      if (erro instanceof DOMException && erro.name === 'AbortError') {
        return;
      }
      this.mensagem.set('Nao foi possivel compartilhar agora. Tente copiar o link manualmente.');
    } finally {
      this.compartilhandoId.set(null);
    }
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

  capaCatalogoExibivel(postagem: PostagemFeed): string | null {
    const url = postagem.catalogoDestaque?.urlCapa?.trim();
    if (!url || url.toLowerCase().includes('guiadosquadrinhos.com')) {
      return null;
    }
    return this.resolverUrlMidia(url) || null;
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

  idPostagem(postagem: PostagemFeed) {
    return `postagem-${postagem.id}`;
  }

  private urlPostagem(postagem: PostagemFeed) {
    const base = environment.apiUrl || window.location.origin;
    const url = new URL(`/api/compartilhar/postagens/${postagem.id}`, base);
    const versaoPostagem = new Date(postagem.dataAtualizacao || postagem.dataCriacao).getTime() || postagem.id;
    url.searchParams.set('v', `11-${versaoPostagem}`);
    return url.toString();
  }

  private async copiarTexto(texto: string) {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(texto);
      return;
    }

    const area = document.createElement('textarea');
    area.value = texto;
    area.setAttribute('readonly', '');
    area.style.position = 'fixed';
    area.style.left = '-9999px';
    document.body.appendChild(area);
    area.select();
    document.execCommand('copy');
    document.body.removeChild(area);
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
