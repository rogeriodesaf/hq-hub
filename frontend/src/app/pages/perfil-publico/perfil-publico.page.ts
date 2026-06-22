import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { environment } from '../../../environments/environment';
import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { Amizade, Anuncio, EstanteEditora, EstatisticasPublicasColecao, PaginaResposta, PostagemFeed, Usuario } from '../../core/modelos';

@Component({
  selector: 'app-perfil-publico-page',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    @if (carregando()) {
      <div class="estado-carregando">
        <p>Carregando perfil...</p>
      </div>
    } @else if (!usuario()) {
      <div class="estado-vazio">
        <h2>Usuário não encontrado</h2>
        <p>Este perfil não existe ou foi removido.</p>
        <a class="botao secundario" routerLink="/painel">Voltar ao feed</a>
      </div>
    } @else {
      <section class="cabecalho-pagina perfil-publico-cabecalho">
        <div class="perfil-publico-identidade">
          <div class="avatar-publico">
            @if (usuario()!.fotoPerfilUrl) {
              <img [src]="resolverUrlMidia(usuario()!.fotoPerfilUrl)" [alt]="'Foto de ' + usuario()!.nome" />
            } @else {
              {{ iniciais(usuario()!.nome) }}
            }
          </div>
          <div>
            <h1>{{ usuario()!.nome }}</h1>
            @if (usuario()!.bio) {
              <p class="bio-publica">{{ usuario()!.bio }}</p>
            }
          </div>
        </div>

        @if (!ehMeuPerfil()) {
          <div class="acoes-perfil-publico">
            @if (amizade() === undefined) {
              <span class="texto-suave">Carregando...</span>
            } @else if (amizade() === null) {
              <button class="botao primario" type="button" (click)="enviarConvite()" [disabled]="processando()">
                {{ processando() ? 'Enviando...' : 'Adicionar amigo' }}
              </button>
            } @else if (amizade()!.status === 'PENDENTE' && amizade()!.solicitante.id === usuarioAtual()?.id) {
              <span class="texto-suave">Convite enviado</span>
              <button class="botao compacto" type="button" (click)="cancelarConvite()" [disabled]="processando()">Cancelar</button>
            } @else if (amizade()!.status === 'PENDENTE' && amizade()!.solicitado.id === usuarioAtual()?.id) {
              <button class="botao primario" type="button" (click)="aceitarConvite()" [disabled]="processando()">Aceitar convite</button>
              <button class="botao compacto" type="button" (click)="recusarConvite()" [disabled]="processando()">Recusar</button>
            } @else if (amizade()!.status === 'ACEITA') {
              <a class="botao secundario compacto" routerLink="/mensagens" [queryParams]="{ usuarioId: usuario()!.id }">Enviar mensagem</a>
              <button class="botao compacto" type="button" (click)="removerAmigo()" [disabled]="processando()">Remover amigo</button>
            }

            @if (mensagem()) {
              <p class="mensagem-erro">{{ mensagem() }}</p>
            }
          </div>
        }
      </section>

      <!-- Stats da coleção -->
      @if (stats()) {
        <section class="metricas perfil-stats">
          <article>
            <span>{{ stats()!.totalItens }}</span>
            <p>HQs na estante</p>
          </article>
          <article>
            <span>{{ stats()!.totalSeries }}</span>
            <p>Séries</p>
          </article>
          <article>
            <span>{{ stats()!.totalLidos }}</span>
            <p>Lidas</p>
          </article>
          <article>
            <span>{{ stats()!.totalNaoLidos }}</span>
            <p>Não lidas</p>
          </article>
          <article>
            <span>{{ formatarMoeda(stats()!.valorTotalPago) }}</span>
            <p>Investido</p>
          </article>
        </section>
      }

      <div class="perfil-publico-layout">

        <!-- Postagens -->
        <section class="bloco perfil-secao">
          <div class="secao-titulo">
            <h2>Postagens</h2>
            <span>{{ postagens().length }}</span>
          </div>

          @if (postagens().length) {
            <div class="lista-postagens-publico">
              @for (postagem of postagens(); track postagem.id) {
                <article class="bloco postagem-card">
                  <header>
                    <div class="avatar-feed">
                      @if (usuario()!.fotoPerfilThumbnailUrl) {
                        <img [src]="resolverUrlMidia(usuario()!.fotoPerfilThumbnailUrl)" alt="" />
                      } @else {
                        {{ iniciais(usuario()!.nome) }}
                      }
                    </div>
                    <div>
                      <strong>{{ usuario()!.nome }}</strong>
                      @if (usuario()!.bio) {
                        <small>{{ usuario()!.bio }}</small>
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
                            [alt]="'Imagem de ' + usuario()!.nome"
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
                    <span>{{ postagem.comentarios.length }} comentários</span>
                  </div>

                  <section class="comentarios-feed">
                    @for (comentario of postagem.comentarios; track comentario.id) {
                      <article>
                        <div class="avatar-feed mini">
                          <a [routerLink]="['/usuario', comentario.usuario.id]" class="link-perfil">
                            @if (comentario.usuario.fotoPerfilThumbnailUrl) {
                              <img [src]="comentario.usuario.fotoPerfilThumbnailUrl" alt="" />
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
                      placeholder="Escreva um comentário"
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
              }
            </div>
          } @else {
            <p class="texto-suave">Nenhuma postagem ainda.</p>
          }
        </section>

        <div class="perfil-publico-lateral">

          <!-- Anúncios -->
          <section class="bloco perfil-secao">
            <div class="secao-titulo">
              <h2>Anúncios</h2>
              <span>{{ anuncios().length }}</span>
            </div>

            @if (anuncios().length) {
              <div class="lista-anuncios-publico">
                @for (anuncio of anuncios(); track anuncio.id) {
                  <article class="anuncio-publico">
                    @if (anuncio.itemColecao.edicao.urlCapa) {
                      <img [src]="anuncio.itemColecao.edicao.urlCapa" [alt]="anuncio.tituloEdicao" loading="lazy" class="capa-anuncio" />
                    }
                    <div>
                      <strong>{{ anuncio.tituloEdicao }}</strong>
                      <span class="rotulo-tipo">{{ labelTipoAnuncio(anuncio.tipoAnuncio) }}</span>
                      @if (anuncio.preco) {
                        <span>{{ formatarMoeda(anuncio.preco) }}</span>
                      }
                      <a class="botao compacto" routerLink="/anuncios">Ver anúncio</a>
                    </div>
                  </article>
                }
              </div>
            } @else {
              <p class="texto-suave">Nenhum anúncio ativo.</p>
            }
          </section>

          <!-- Estante -->
          <section class="bloco perfil-secao">
            <div class="secao-titulo">
              <h2>Estante</h2>
              @if (estantePagina()) {
                <span>{{ estantePagina()!.totalItens }} edições</span>
              }
            </div>

            <div class="estante-busca">
              <input
                [(ngModel)]="buscaEstante"
                placeholder="Buscar série ou edição..."
                (keyup.enter)="buscarEstante()"
              />
              <button class="botao compacto secundario" type="button" (click)="buscarEstante()">Buscar</button>
              @if (buscaEstante) {
                <button class="botao compacto" type="button" (click)="limparBusca()">Limpar</button>
              }
            </div>

            @if (carregandoEstante()) {
              <p class="texto-suave">Carregando estante...</p>
            } @else if (estante().length) {
              <div class="estante-publica">
                @for (editora of estante(); track editora.editoraId) {
                  <article class="prateleira">
                    <h3>{{ editora.nome }}</h3>
                    @for (serie of editora.series; track serie.serieId) {
                      <div class="serie-estante">
                        <div class="secao-titulo">
                          <strong>{{ serie.titulo }}</strong>
                          <span>{{ serie.edicoes.length }} edições</span>
                        </div>
                        <div class="linha-capas">
                          @for (edicao of serie.edicoes; track edicao.edicaoId) {
                            <div class="lombada" [title]="(edicao.titulo || ('#' + edicao.numero)) + ' — ' + labelStatusLeitura(edicao.statusLeitura)">
                              <img
                                [src]="edicao.urlCapa || capaReserva"
                                [alt]="edicao.titulo || edicao.numero"
                                loading="lazy"
                                (error)="usarCapaReserva($event)"
                              />
                              <span>#{{ edicao.numero }}</span>
                              <small [class.lido]="edicao.statusLeitura === 'LIDO'">{{ labelStatusLeitura(edicao.statusLeitura) }}</small>
                            </div>
                          }
                        </div>
                      </div>
                    }
                  </article>
                }
              </div>

              <!-- Paginação -->
              @if (estantePagina() && estantePagina()!.totalPaginas > 1) {
                <div class="paginacao-estante">
                  <button
                    class="botao compacto secundario"
                    type="button"
                    [disabled]="paginaEstante() === 0"
                    (click)="irParaPagina(paginaEstante() - 1)"
                  >← Anterior</button>

                  <span>{{ paginaEstante() + 1 }} / {{ estantePagina()!.totalPaginas }}</span>

                  <button
                    class="botao compacto secundario"
                    type="button"
                    [disabled]="paginaEstante() >= estantePagina()!.totalPaginas - 1"
                    (click)="irParaPagina(paginaEstante() + 1)"
                  >Próxima →</button>
                </div>
              }
            } @else {
              <p class="texto-suave">Estante não disponível.</p>
            }
          </section>

        </div>
      </div>
    }
  `,
  styles: `
    .estado-carregando,
    .estado-vazio {
      display: grid;
      place-items: center;
      min-height: 240px;
      gap: 12px;
      text-align: center;
    }

    .perfil-publico-cabecalho {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      flex-wrap: wrap;
      gap: 16px;
    }

    .perfil-publico-identidade {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .avatar-publico {
      display: grid;
      width: 80px;
      height: 80px;
      place-items: center;
      border-radius: 12px;
      overflow: hidden;
      background: var(--azul);
      color: #fff;
      font-size: 1.8rem;
      font-weight: 900;
      flex: 0 0 auto;
    }

    .avatar-publico img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .bio-publica {
      color: var(--texto-suave);
      font-size: 0.9rem;
      margin-top: 4px;
      max-width: 480px;
    }

    .acoes-perfil-publico {
      display: flex;
      gap: 10px;
      align-items: center;
      flex-wrap: wrap;
    }

    .perfil-publico-layout {
      display: grid;
      gap: 18px;
      grid-template-columns: minmax(0, 1fr) 300px;
      align-items: start;
      margin-top: 18px;
    }

    .perfil-stats {
      grid-template-columns: repeat(5, minmax(0, 1fr));
      margin-top: 10px;
      margin-bottom: 18px;
    }

    @media (max-width: 980px) {
      .perfil-publico-layout {
        grid-template-columns: 1fr;
      }

      .perfil-stats {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
    }

    @media (max-width: 600px) {
      .perfil-publico-cabecalho {
        flex-direction: column;
        align-items: stretch;
      }

      .perfil-stats {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .grade-imagens-feed {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .estante-busca {
        flex-wrap: wrap;
      }

      .estante-busca input {
        width: 100%;
      }

      .novo-comentario {
        grid-template-columns: 1fr;
      }

      .paginacao-estante {
        font-size: 0.82rem;
      }
    }

    .perfil-secao {
      display: grid;
      gap: 14px;
    }

    .lista-postagens-publico {
      display: grid;
      gap: 14px;
    }

    .postagem-card {
      display: grid;
      gap: 14px;
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

    .postagem-card header span {
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

    .avatar-feed img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }

    .texto-postagem {
      margin: 0;
      line-height: 1.6;
      white-space: pre-wrap;
      overflow-wrap: anywhere;
    }

    .grade-imagens-feed {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 8px;
    }

    .grade-imagens-feed a {
      position: relative;
      display: block;
      overflow: hidden;
      border-radius: 8px;
      border: 1px solid var(--borda);
      background: var(--superficie-suave);
    }

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

    .barra-postagem {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      align-items: center;
      padding-top: 4px;
      border-top: 1px solid var(--borda);
      color: var(--texto-suave);
      font-size: 0.88rem;
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
      color: var(--texto-suave);
      font-size: 0.88rem;
    }

    .novo-comentario {
      display: grid;
      grid-template-columns: minmax(0, 1fr) auto;
      gap: 8px;
    }

    .perfil-publico-lateral {
      display: grid;
      gap: 18px;
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

    .lista-anuncios-publico {
      display: grid;
      gap: 10px;
    }

    .anuncio-publico {
      display: flex;
      gap: 12px;
      align-items: flex-start;
    }

    .capa-anuncio {
      width: 52px;
      height: 72px;
      object-fit: cover;
      border-radius: 4px;
      flex: 0 0 auto;
    }

    .anuncio-publico div {
      display: grid;
      gap: 4px;
    }

    .rotulo-tipo {
      font-size: 0.8rem;
      color: var(--texto-suave);
    }

    .estante-publica {
      display: grid;
      gap: 20px;
    }

    .serie-estante {
      display: grid;
      gap: 6px;
    }

    .paginacao-estante {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      padding-top: 8px;
      font-size: 0.9rem;
      color: var(--texto-suave);
    }

    .estante-busca {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .estante-busca input {
      flex: 1;
      min-width: 0;
    }

    .texto-suave {
      color: var(--texto-suave);
      font-size: 0.9rem;
    }
  `,
})
export class PerfilPublicoPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly autenticacao = inject(AutenticacaoService);
  private readonly route = inject(ActivatedRoute);

  readonly carregando = signal(true);
  readonly carregandoEstante = signal(false);
  readonly usuario = signal<Usuario | null>(null);
  readonly amizade = signal<Amizade | null | undefined>(undefined);
  readonly postagens = signal<PostagemFeed[]>([]);
  readonly anuncios = signal<Anuncio[]>([]);
  readonly estante = signal<EstanteEditora[]>([]);
  readonly estantePagina = signal<PaginaResposta<EstanteEditora> | null>(null);
  readonly paginaEstante = signal(0);
  readonly stats = signal<EstatisticasPublicasColecao | null>(null);
  readonly mensagem = signal('');
  readonly processando = signal(false);
  readonly interagindoId = signal<number | null>(null);
  readonly usuarioAtual = this.autenticacao.usuario;

  readonly capaReserva = 'assets/capa-reserva.svg';

  buscaEstante = '';
  comentarios: Record<number, string> = {};

  ehMeuPerfil() {
    return this.usuario()?.id === this.usuarioAtual()?.id;
  }

  totalEstante() {
    return this.estantePagina()?.totalItens ?? 0;
  }

  ngOnInit() {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    if (!id) return;

    this.api.obterPerfilUsuario(id).subscribe({
      next: (usuario) => {
        this.usuario.set(usuario);
        this.carregando.set(false);
        this.carregarDados(id);
      },
      error: () => {
        this.usuario.set(null);
        this.carregando.set(false);
      },
    });
  }

  private carregarDados(usuarioId: number) {
    this.api.obterRelacionamentoAmizade(usuarioId).subscribe({
      next: (amizade) => this.amizade.set(amizade),
      error: () => this.amizade.set(null),
    });

    this.api.obterFeedUsuario(usuarioId).subscribe({
      next: (postagens) => this.postagens.set(postagens),
      error: () => this.postagens.set([]),
    });

    this.api.listarAnunciosPorUsuario(usuarioId).subscribe({
      next: (anuncios) => this.anuncios.set(anuncios),
      error: () => this.anuncios.set([]),
    });

    this.api.obterEstatisticasPublicasColecao(usuarioId).subscribe({
      next: (stats) => this.stats.set(stats),
      error: () => this.stats.set(null),
    });

    this.carregarEstante(usuarioId, 0);
  }

  private carregarEstante(usuarioId: number, pagina: number) {
    this.carregandoEstante.set(true);
    this.api.obterEstantePublicaPaginada(usuarioId, pagina, 5, this.buscaEstante).subscribe({
      next: (resposta) => {
        this.estantePagina.set(resposta);
        this.estante.set(resposta.itens);
        this.paginaEstante.set(pagina);
        this.carregandoEstante.set(false);
      },
      error: () => {
        this.estante.set([]);
        this.carregandoEstante.set(false);
      },
    });
  }

  irParaPagina(pagina: number) {
    const id = this.usuario()?.id;
    if (!id) return;
    this.carregarEstante(id, pagina);
  }

  buscarEstante() {
    const id = this.usuario()?.id;
    if (!id) return;
    this.carregarEstante(id, 0);
  }

  limparBusca() {
    this.buscaEstante = '';
    this.buscarEstante();
  }

  enviarConvite() {
    const usuario = this.usuario();
    if (!usuario) return;
    this.processando.set(true);
    this.api.enviarSolicitacaoAmizade(usuario.id).subscribe({
      next: (amizade) => {
        this.amizade.set(amizade);
        this.processando.set(false);
        this.mensagem.set('');
      },
      error: () => {
        this.processando.set(false);
        this.mensagem.set('Não foi possível enviar o convite.');
      },
    });
  }

  aceitarConvite() {
    const id = this.amizade()?.id;
    if (!id) return;
    this.processando.set(true);
    this.api.aceitarSolicitacaoAmizade(id).subscribe({
      next: (amizade) => {
        this.amizade.set(amizade);
        this.processando.set(false);
      },
      error: () => {
        this.processando.set(false);
        this.mensagem.set('Não foi possível aceitar o convite.');
      },
    });
  }

  recusarConvite() {
    const id = this.amizade()?.id;
    if (!id) return;
    this.processando.set(true);
    this.api.recusarSolicitacaoAmizade(id).subscribe({
      next: () => {
        this.amizade.set(null);
        this.processando.set(false);
      },
      error: () => {
        this.processando.set(false);
        this.mensagem.set('Não foi possível recusar o convite.');
      },
    });
  }

  cancelarConvite() {
    const amizadeId = this.amizade()?.id;
    const usuarioId = this.usuario()?.id;
    if (!amizadeId || !usuarioId) return;
    this.processando.set(true);
    this.api.removerAmigo(usuarioId).subscribe({
      next: () => {
        this.amizade.set(null);
        this.processando.set(false);
      },
      error: () => {
        this.processando.set(false);
        this.mensagem.set('Não foi possível cancelar o convite.');
      },
    });
  }

  removerAmigo() {
    const usuarioId = this.usuario()?.id;
    if (!usuarioId) return;
    this.processando.set(true);
    this.api.removerAmigo(usuarioId).subscribe({
      next: () => {
        this.amizade.set(null);
        this.processando.set(false);
      },
      error: () => {
        this.processando.set(false);
        this.mensagem.set('Não foi possível remover o amigo.');
      },
    });
  }

  curtir(postagem: PostagemFeed) {
    this.interagindoId.set(postagem.id);
    this.api.alternarCurtidaPostagem(postagem.id).subscribe({
      next: (atualizada) => {
        this.postagens.update((lista) => lista.map((p) => (p.id === atualizada.id ? atualizada : p)));
      },
      complete: () => this.interagindoId.set(null),
    });
  }

  comentar(postagem: PostagemFeed) {
    const texto = this.comentarios[postagem.id]?.trim();
    if (!texto) return;
    this.interagindoId.set(postagem.id);
    this.api.comentarPostagem(postagem.id, texto).subscribe({
      next: (atualizada) => {
        this.comentarios[postagem.id] = '';
        this.postagens.update((lista) => lista.map((p) => (p.id === atualizada.id ? atualizada : p)));
      },
      complete: () => this.interagindoId.set(null),
    });
  }


  resolverUrlMidia(url: string | null | undefined): string {
    if (!url) {
      return this.capaReserva;
    }

    if (url.startsWith('http://')) {
      url = url.replace('http://', 'https://');
    }

    if (url.startsWith('https://')) {
      return url;
    }

    return `${environment.apiUrl}${url}`;
  }

  imagensPostagem(postagem: PostagemFeed) {
    return postagem.imagens?.length ? postagem.imagens : [];
  }

  iniciais(nome: string) {
    return nome
      .split(' ')
      .slice(0, 2)
      .map((p) => p[0])
      .join('')
      .toUpperCase();
  }

  dataRelativa(data: string) {
    const diff = Date.now() - new Date(data).getTime();
    const minutos = Math.floor(diff / 60000);
    if (minutos < 1) return 'agora';
    if (minutos < 60) return `${minutos}min`;
    const horas = Math.floor(minutos / 60);
    if (horas < 24) return `${horas}h`;
    const dias = Math.floor(horas / 24);
    if (dias < 7) return `${dias}d`;
    return new Date(data).toLocaleDateString('pt-BR');
  }

  formatarMoeda(valor: number) {
    return valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  }

  labelTipoAnuncio(tipo: string) {
    const tipos: Record<string, string> = {
      VENDA: 'Venda',
      TROCA: 'Troca',
      VENDA_E_TROCA: 'Venda / Troca',
    };
    return tipos[tipo] ?? tipo;
  }

  usarCapaReserva(evento: Event) {
    const imagem = evento.target as HTMLImageElement;
    if (!imagem.src.endsWith(this.capaReserva)) {
      imagem.src = this.capaReserva;
    }
  }

  labelStatusLeitura(status: string) {
    const labels: Record<string, string> = {
      LIDO: 'Lido',
      NAO_LIDO: 'Não lido',
    };
    return labels[status] ?? status;
  }
}
