import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { resolverUrlMidia as resolverUrlMidiaCore } from '../../core/midia-url';
import { Amizade, ColecaoResumo, EstatisticasPublicasColecao, ItemColecao, Usuario, UsuarioAutenticado } from '../../core/modelos';

@Component({
  selector: 'app-perfil-page',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <section class="perfil-layout">
      <article class="perfil-principal">
        <section class="perfil-hero">
          <div
            class="perfil-capa"
            [class.com-imagem]="usuarioVisualizacao()?.capaPerfilUrl"
            [style.background-image]="usuarioVisualizacao()?.capaPerfilUrl ? 'linear-gradient(180deg, rgba(10, 14, 20, .08), rgba(10, 14, 20, .3)), url(' + resolverUrlMidia(usuarioVisualizacao()?.capaPerfilUrl) + ')' : null"
          >
            @if (modo() === 'edicao') {
              <label class="trocar-capa" [class.carregando]="salvandoCapa()">
                {{ salvandoCapa() ? 'Enviando...' : 'Alterar imagem de capa' }}
                <input type="file" accept="image/jpeg,image/png,image/webp" (change)="selecionarCapaPerfil($event)" />
              </label>
            }
          </div>
          <div class="perfil-identidade">
            @if (modo() === 'edicao') {
              <label class="avatar-editor" [class.carregando]="salvandoFoto()">
                <span class="avatar-perfil">
                  @if (usuarioVisualizacao()?.fotoPerfilThumbnailUrl) {
                    <img [src]="resolverUrlMidia(usuarioVisualizacao()?.fotoPerfilThumbnailUrl)" alt="Foto de perfil" />
                  } @else {
                    {{ iniciais(usuarioVisualizacao()?.nome || perfilNome || 'HQ') }}
                  }
                </span>
                <span class="trocar-foto">{{ salvandoFoto() ? 'Enviando...' : 'Trocar foto' }}</span>
                <input type="file" accept="image/jpeg,image/png,image/webp" (change)="selecionarFotoPerfil($event)" />
              </label>
            } @else {
              <div class="avatar-perfil">
                @if (usuarioVisualizacao()?.fotoPerfilThumbnailUrl) {
                  <img [src]="resolverUrlMidia(usuarioVisualizacao()?.fotoPerfilThumbnailUrl)" alt="Foto de perfil" />
                } @else {
                  {{ iniciais(usuarioVisualizacao()?.nome || perfilNome || 'HQ') }}
                }
              </div>
            }
            <div>
              <p class="rotulo">Perfil</p>
              <h1>{{ usuarioVisualizacao()?.nome || perfilNome || 'Seu perfil' }}</h1>
              <p>{{ usuarioVisualizacao()?.bio || perfilBio || 'Leio livros e HQs interessantes e sou parte da comunidade HQ-HUB.' }}</p>
            </div>
          </div>

          <div class="perfil-estatisticas">
            <article>
              <strong>{{ totalPostagens() }}</strong>
              <span>Atividades</span>
            </article>
            <article>
              <strong>{{ totalItensPerfil() }}</strong>
              <span>HQs na estante</span>
            </article>
            <article>
              <strong>{{ totalAmigos() }}</strong>
              <span>Amigos</span>
            </article>
          </div>

          <div class="perfil-acoes">
            <a class="botao compacto" routerLink="/painel">Voltar ao feed</a>
          </div>
        </section>

        @if (modo() === 'edicao') {
          <section class="bloco perfil-editor">
            <div>
              <p class="rotulo">Editar dados</p>
              <h2>Deixe seu perfil com cara de colecionador.</h2>
            </div>
            <label>
              Nome
              <input [(ngModel)]="perfilNome" name="perfilNome" />
            </label>
            <label>
              Bio
              <textarea
                [(ngModel)]="perfilBio"
                name="perfilBio"
                rows="4"
                maxlength="500"
                placeholder="O que voce le, coleciona ou procura?"
              ></textarea>
            </label>
            <button class="botao primario compacto" type="button" (click)="salvarPerfil()" [disabled]="salvandoPerfil() || !perfilNome.trim()">
              {{ salvandoPerfil() ? 'Salvando...' : 'Salvar perfil' }}
            </button>
          </section>
        }

        @if (mensagem()) {
          <p class="mensagem-erro">{{ mensagem() }}</p>
        }

        <section class="perfil-grade">
          <article class="bloco perfil-secao">
            <p class="rotulo">Sobre mim</p>
            <p>{{ usuarioVisualizacao()?.bio || perfilBio || 'Esse colecionador ainda nao escreveu uma bio.' }}</p>
          </article>

          <article class="bloco perfil-secao">
            <p class="rotulo">Estatisticas</p>
            <div class="lista-estatisticas">
              <span>HQs lidas <strong>{{ totalLidosPerfil() }}</strong></span>
              <span>Series acompanhadas <strong>{{ totalSeriesPerfil() }}</strong></span>
              <span>Editoras na estante <strong>{{ totalEditorasPerfil() }}</strong></span>
            </div>
          </article>
        </section>

        @if (itensColecao().length) {
          <section class="bloco perfil-secao">
            <div class="perfil-secao-topo">
              <div>
                <p class="rotulo">Colecao em destaque</p>
                <h2>Capas da estante</h2>
              </div>
              <a routerLink="/colecao">Ver todas</a>
            </div>
            <div class="capas-perfil">
              @for (item of itensColecao().slice(0, 6); track item.id) {
                <article>
                  <img [src]="item.edicao.urlCapa || 'assets/capa-reserva.svg'" [alt]="tituloItemColecao(item)" loading="lazy" />
                  <strong>{{ tituloItemColecao(item) }}</strong>
                  <span>{{ item.edicao.serie?.titulo || 'HQ-HUB' }}</span>
                </article>
              }
            </div>
          </section>
        }
      </article>

      <aside class="bloco painel-ajuda-perfil">
        <p class="rotulo">{{ modo() === 'edicao' ? 'Resumo' : 'Informacoes' }}</p>
        @if (modo() === 'edicao') {
          <p>A imagem e a bio atualizadas aqui aparecem no topo do feed e nas interações do sistema.</p>
          <a class="botao compacto" routerLink="/amigos">Ver amigos</a>
          <form class="form-senha" (ngSubmit)="alterarSenha()">
            <label>
              Senha atual
              <input [(ngModel)]="senhaAtual" name="senhaAtual" type="password" autocomplete="current-password" />
            </label>
            <label>
              Nova senha
              <input [(ngModel)]="novaSenha" name="novaSenha" type="password" autocomplete="new-password" />
            </label>
            <label>
              Confirmar nova senha
              <input [(ngModel)]="confirmacaoSenha" name="confirmacaoSenha" type="password" autocomplete="new-password" />
            </label>
            @if (mensagemSenha()) {
              <p class="mensagem-senha">{{ mensagemSenha() }}</p>
            }
            <button class="botao compacto primario" type="submit" [disabled]="salvandoSenha()">
              {{ salvandoSenha() ? 'Salvando...' : 'Alterar senha' }}
            </button>
          </form>
        } @else {
          <p>Perfil de {{ usuarioVisualizacao()?.nome }}</p>
          <button class="botao compacto" (click)="enviarMensagem()" *ngIf="usuarioVisualizacao()?.id !== usuarioAtual()?.id">
            Enviar Mensagem
          </button>
        }
      </aside>
    </section>
  `,
  styles: `
    .perfil-layout {
      display: grid;
      grid-template-columns: minmax(0, 760px) 300px;
      gap: 22px;
      align-items: start;
      justify-content: center;
    }

    .perfil-principal {
      display: grid;
      gap: 16px;
      min-width: 0;
    }

    .perfil-hero {
      overflow: hidden;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
      box-shadow: var(--sombra);
    }

    .perfil-capa {
      position: relative;
      min-height: 190px;
      background:
        linear-gradient(135deg, rgba(21, 25, 31, 0.18), rgba(255, 122, 0, 0.3)),
        radial-gradient(circle at 20% 25%, rgba(255, 255, 255, 0.46), transparent 18%),
        linear-gradient(135deg, #15191f 0%, #64320d 52%, #ff7a00 100%);
    }

    .perfil-capa.com-imagem {
      background-position: center;
      background-size: cover;
    }

    .trocar-capa {
      position: absolute;
      right: 14px;
      top: 14px;
      padding: 9px 12px;
      border-radius: 999px;
      background: rgba(15, 18, 24, 0.78);
      color: #fff;
      cursor: pointer;
      font-size: 0.78rem;
      font-weight: 850;
      backdrop-filter: blur(8px);
    }

    .trocar-capa input,
    .avatar-editor input {
      display: none;
    }

    .trocar-capa.carregando,
    .avatar-editor.carregando {
      pointer-events: none;
      opacity: 0.72;
    }

    :host-context(body.tema-escuro) .perfil-capa {
      background:
        linear-gradient(135deg, rgba(0, 0, 0, 0.1), rgba(255, 138, 31, 0.22)),
        radial-gradient(circle at 24% 24%, rgba(255, 255, 255, 0.14), transparent 18%),
        linear-gradient(135deg, #0d1117 0%, #2b1d15 52%, #a04400 100%);
    }

    .perfil-identidade {
      position: relative;
      z-index: 1;
      display: grid;
      grid-template-columns: 116px minmax(0, 1fr);
      gap: 18px;
      align-items: start;
      padding: 0 20px 16px;
    }

    .perfil-identidade > .avatar-perfil,
    .perfil-identidade > .avatar-editor {
      margin-top: -54px;
    }

    .avatar-perfil {
      position: relative;
      display: grid;
      width: 116px;
      height: 116px;
      place-items: center;
      overflow: hidden;
      border: 4px solid var(--superficie);
      border-radius: 50%;
      background: var(--marca);
      color: #15191f;
      font-size: 2rem;
      font-weight: 900;
      box-shadow: 0 12px 32px rgba(21, 25, 31, 0.22);
    }

    .avatar-editor {
      display: grid;
      gap: 5px;
      justify-items: center;
      cursor: pointer;
    }

    .trocar-foto {
      color: var(--azul);
      font-size: 0.72rem;
      font-weight: 850;
      text-align: center;
    }

    .avatar-editor:hover .trocar-foto {
      text-decoration: underline;
    }

    .avatar-perfil img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .perfil-identidade h1,
    .perfil-identidade p {
      margin: 0;
    }

    .perfil-identidade h1 {
      font-size: clamp(1.75rem, 4vw, 2.5rem);
      line-height: 1;
    }

    .perfil-identidade > div:last-child {
      display: grid;
      gap: 6px;
      min-width: 0;
      padding-top: 14px;
    }

    .perfil-identidade > div:last-child p:last-child {
      color: var(--texto-suave);
      line-height: 1.45;
    }

    .perfil-estatisticas {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 8px;
      padding: 0 20px 16px;
    }

    .perfil-estatisticas article {
      display: grid;
      justify-items: center;
      gap: 4px;
      padding: 10px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie-2);
    }

    .perfil-estatisticas strong {
      color: var(--marca);
      font-size: 1.2rem;
      font-weight: 900;
    }

    .perfil-estatisticas span {
      color: var(--texto-suave);
      font-size: 0.82rem;
      font-weight: 750;
      text-align: center;
    }

    .perfil-acoes {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      padding: 0 20px 20px;
    }

    .seletor-foto input {
      display: none;
    }

    .perfil-editor,
    .perfil-secao {
      display: grid;
      gap: 12px;
    }

    .perfil-editor h2,
    .perfil-secao h2 {
      margin: 0;
      font-size: 1.12rem;
    }

    .perfil-editor label {
      display: grid;
      gap: 6px;
      color: var(--texto);
      font-size: 0.88rem;
      font-weight: 800;
    }

    .perfil-grade {
      display: grid;
      grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
      gap: 16px;
    }

    .perfil-secao > p:not(.rotulo) {
      margin: 0;
      color: var(--texto-suave);
      line-height: 1.6;
    }

    .lista-estatisticas {
      display: grid;
      gap: 10px;
    }

    .lista-estatisticas span {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      color: var(--texto-suave);
    }

    .lista-estatisticas strong {
      color: var(--texto);
    }

    .perfil-secao-topo {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .perfil-secao-topo a {
      color: var(--azul);
      font-weight: 850;
    }

    .capas-perfil {
      display: grid;
      grid-template-columns: repeat(6, minmax(0, 1fr));
      gap: 10px;
    }

    .capas-perfil article {
      display: grid;
      gap: 6px;
      min-width: 0;
    }

    .capas-perfil img {
      width: 100%;
      aspect-ratio: 2 / 3;
      border-radius: 6px;
      object-fit: cover;
      background: var(--superficie-suave);
    }

    .capas-perfil strong,
    .capas-perfil span {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .capas-perfil strong {
      font-size: 0.82rem;
    }

    .capas-perfil span {
      color: var(--texto-suave);
      font-size: 0.76rem;
    }

    .painel-ajuda-perfil {
      display: grid;
      gap: 12px;
      position: sticky;
      top: 88px;
    }

    .painel-ajuda-perfil p {
      margin: 0;
      color: var(--texto-suave);
      line-height: 1.55;
    }

    .form-senha {
      display: grid;
      gap: 10px;
      padding-top: 12px;
      border-top: 1px solid var(--borda);
    }

    .form-senha label {
      display: grid;
      gap: 6px;
      color: var(--texto);
      font-weight: 750;
      font-size: 0.86rem;
    }

    .form-senha input {
      min-height: 40px;
      border: 1px solid var(--borda);
      border-radius: 6px;
      padding: 0 10px;
      background: var(--superficie);
      color: var(--texto);
    }

    .mensagem-senha {
      font-weight: 750;
      font-size: 0.86rem;
    }

    @media (max-width: 900px) {
      .perfil-layout {
        grid-template-columns: 1fr;
      }

      .perfil-identidade {
        grid-template-columns: 88px minmax(0, 1fr);
        gap: 14px;
      }

      .perfil-identidade > .avatar-perfil,
      .perfil-identidade > .avatar-editor {
        margin-top: -42px;
      }

      .avatar-perfil {
        width: 88px;
        height: 88px;
        font-size: 1.45rem;
      }

      .perfil-grade,
      .capas-perfil {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .painel-ajuda-perfil {
        position: static;
      }
    }
  `,
})
export class PerfilPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);
  private readonly route = inject(ActivatedRoute);
  
  readonly usuarioAtual = this.autenticacao.usuario;
  readonly usuarioVisualizacao = signal<(Usuario | UsuarioAutenticado) | null>(null);
  readonly modo = signal<'edicao' | 'visualizacao'>('edicao');
  readonly salvandoPerfil = signal(false);
  readonly salvandoFoto = signal(false);
  readonly salvandoCapa = signal(false);
  readonly salvandoSenha = signal(false);
  readonly mensagem = signal('');
  readonly mensagemSenha = signal('');
  readonly resumo = signal<ColecaoResumo | null>(null);
  readonly estatisticasPublicas = signal<EstatisticasPublicasColecao | null>(null);
  readonly amigos = signal<Amizade[]>([]);
  readonly itensColecao = signal<ItemColecao[]>([]);
  readonly totalPostagens = signal(0);
  perfilNome = '';
  perfilBio = '';
  senhaAtual = '';
  novaSenha = '';
  confirmacaoSenha = '';

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.modo.set('visualizacao');
      this.carregarPerfilOutroUsuario(parseInt(id, 10));
    } else {
      this.modo.set('edicao');
      this.carregarPerfilPropio();
      this.carregarResumoProprio();
      this.carregarAmigos();
      this.carregarItensColecao();
    }
  }

  salvarPerfil() {
    const nome = this.perfilNome.trim();
    if (!nome) {
      return;
    }

    this.salvandoPerfil.set(true);
    this.api.atualizarMeuPerfil({ nome, bio: this.perfilBio.trim() || null }).subscribe({
      next: (usuario) => {
        this.autenticacao.atualizarPerfilLocal(usuario);
        this.usuarioVisualizacao.set(usuario);
        this.perfilNome = usuario.nome;
        this.perfilBio = usuario.bio || '';
        this.salvandoPerfil.set(false);
        this.mensagem.set('Perfil atualizado.');
      },
      error: (erro) => {
        this.salvandoPerfil.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel atualizar o perfil.');
      },
    });
  }

  selecionarFotoPerfil(evento: Event) {
    const input = evento.target as HTMLInputElement;
    const arquivo = input.files?.[0];
    input.value = '';
    if (!arquivo) {
      return;
    }

    this.salvandoFoto.set(true);
    this.api.atualizarFotoPerfil(arquivo).subscribe({
      next: (usuario) => {
        this.autenticacao.atualizarPerfilLocal(usuario);
        this.usuarioVisualizacao.set(usuario);
        this.salvandoFoto.set(false);
        this.mensagem.set('Foto de perfil atualizada.');
      },
      error: (erroResposta) => {
        this.salvandoFoto.set(false);
        this.mensagem.set(erroResposta?.error?.mensagem || 'Nao foi possivel atualizar a foto.');
      },
    });
  }

  selecionarCapaPerfil(evento: Event) {
    const input = evento.target as HTMLInputElement;
    const arquivo = input.files?.[0];
    input.value = '';
    if (!arquivo) {
      return;
    }

    this.salvandoCapa.set(true);
    this.api.atualizarCapaPerfil(arquivo).subscribe({
      next: (usuario) => {
        this.autenticacao.atualizarPerfilLocal(usuario);
        this.usuarioVisualizacao.set(usuario);
        this.salvandoCapa.set(false);
        this.mensagem.set('Imagem de capa atualizada.');
      },
      error: (erroResposta) => {
        this.salvandoCapa.set(false);
        this.mensagem.set(erroResposta?.error?.mensagem || 'Nao foi possivel atualizar a capa.');
      },
    });
  }

  alterarSenha() {
    this.mensagemSenha.set('');
    const senhaAtual = this.senhaAtual.trim();
    const novaSenha = this.novaSenha.trim();
    const confirmacaoSenha = this.confirmacaoSenha.trim();

    if (!senhaAtual || novaSenha.length < 6) {
      this.mensagemSenha.set('Informe a senha atual e uma nova senha com pelo menos 6 caracteres.');
      return;
    }

    if (novaSenha !== confirmacaoSenha) {
      this.mensagemSenha.set('A confirmacao da senha nao confere.');
      return;
    }

    this.salvandoSenha.set(true);
    this.api.atualizarMinhaSenha({ senhaAtual, novaSenha }).subscribe({
      next: () => {
        this.senhaAtual = '';
        this.novaSenha = '';
        this.confirmacaoSenha = '';
        this.salvandoSenha.set(false);
        this.mensagemSenha.set('Senha alterada com sucesso.');
      },
      error: (erro) => {
        this.salvandoSenha.set(false);
        this.mensagemSenha.set(erro?.error?.mensagem || 'Nao foi possivel alterar a senha.');
      },
    });
  }

  enviarMensagem() {
    const usuarioId = this.usuarioVisualizacao()?.id;
    if (usuarioId) {
      // TODO: Navegar para página de mensagens com o usuário
    }
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

  totalItensPerfil() {
    return this.estatisticasPublicas()?.totalItens ?? this.resumo()?.totalItens ?? this.itensColecao().length;
  }

  totalSeriesPerfil() {
    return this.estatisticasPublicas()?.totalSeries ?? this.resumo()?.totalSeries ?? 0;
  }

  totalEditorasPerfil() {
    return this.estatisticasPublicas()?.totalEditoras ?? this.resumo()?.totalEditoras ?? 0;
  }

  totalLidosPerfil() {
    return this.estatisticasPublicas()?.totalLidos ?? this.itensColecao().filter((item) => item.statusLeitura === 'LIDO').length;
  }

  totalAmigos() {
    return this.amigos().length;
  }

  tituloItemColecao(item: ItemColecao) {
    const serie = item.edicao.serie?.titulo;
    const numero = item.edicao.numero ? ` #${item.edicao.numero}` : '';
    return item.edicao.titulo || `${serie || 'Edicao'}${numero}`;
  }

  private carregarPerfilPropio() {
    this.api.obterMeuPerfil().subscribe({
      next: (usuario) => {
        this.autenticacao.atualizarPerfilLocal(usuario);
        this.usuarioVisualizacao.set(usuario);
        this.perfilNome = usuario.nome;
        this.perfilBio = usuario.bio || '';
        this.carregarEstatisticasPublicas(usuario.id);
        this.carregarFeedUsuario(usuario.id);
      },
      error: () => {
        const usuario = this.usuarioAtual();
        this.usuarioVisualizacao.set(usuario);
        this.perfilNome = usuario?.nome || '';
        this.perfilBio = usuario?.bio || '';
      },
    });
  }

  private carregarPerfilOutroUsuario(id: number) {
    this.api.obterPerfilUsuario(id).subscribe({
      next: (usuario) => {
        this.usuarioVisualizacao.set(usuario);
        this.perfilNome = usuario.nome;
        this.perfilBio = usuario.bio || '';
        this.carregarEstatisticasPublicas(usuario.id);
        this.carregarFeedUsuario(usuario.id);
      },
      error: () => {
        this.mensagem.set('Perfil não encontrado.');
      },
    });
  }

  private carregarResumoProprio() {
    this.api.obterResumoColecao().subscribe({
      next: (resumo) => this.resumo.set(resumo),
      error: () => this.resumo.set(null),
    });
  }

  private carregarEstatisticasPublicas(usuarioId: number) {
    this.api.obterEstatisticasPublicasColecao(usuarioId).subscribe({
      next: (estatisticas) => this.estatisticasPublicas.set(estatisticas),
      error: () => this.estatisticasPublicas.set(null),
    });
  }

  private carregarAmigos() {
    this.api.listarAmigos().subscribe({
      next: (amigos) => this.amigos.set(amigos),
      error: () => this.amigos.set([]),
    });
  }

  private carregarItensColecao() {
    this.api.listarItensColecao().subscribe({
      next: (itens) => this.itensColecao.set(itens.slice(0, 12)),
      error: () => this.itensColecao.set([]),
    });
  }

  private carregarFeedUsuario(usuarioId: number) {
    this.api.obterFeedUsuario(usuarioId, 0, 20).subscribe({
      next: (postagens) => this.totalPostagens.set(postagens.length),
      error: () => this.totalPostagens.set(0),
    });
  }
}
