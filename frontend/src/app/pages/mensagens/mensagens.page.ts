import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { resolverUrlMidia } from '../../core/midia-url';
import { Amizade, ConversaDireta, MensagemDireta, Usuario } from '../../core/modelos';

@Component({
  selector: 'app-mensagens-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Direct</p>
        <h1>Mensagens diretas entre pessoas.</h1>
      </div>
    </section>

    <section class="mensagens-layout">
      <aside class="bloco conversas-coluna">
        <div class="secao-titulo">
          <div>
            <p class="rotulo">Conversas</p>
            <h2>Caixa de entrada</h2>
          </div>
        </div>

        <div class="barra-busca interna">
          <input [(ngModel)]="busca" placeholder="Buscar pessoa ou conversa" />
        </div>

        <div class="lista-conversas">
          @for (conversa of conversasFiltradas(); track conversa.usuario.id) {
            <button type="button" [class.ativo]="destinatarioSelecionado()?.id === conversa.usuario.id" (click)="selecionarUsuario(conversa.usuario)">
              <span class="avatar-chat">
                @if (conversa.usuario.fotoPerfilThumbnailUrl) {
                  <img [src]="resolverUrlMidia(conversa.usuario.fotoPerfilThumbnailUrl)" alt="" />
                } @else {
                  {{ conversa.usuario.nome.slice(0, 1) }}
                }
              </span>
              <span>
                <strong>{{ conversa.usuario.nome }}</strong>
                <small>{{ conversa.ultimaMensagem.texto }}</small>
              </span>
              @if (conversa.naoLidas > 0) {
                <em>{{ conversa.naoLidas > 9 ? '9+' : conversa.naoLidas }}</em>
              }
            </button>
          } @empty {
            <p class="texto-suave">Nenhuma conversa ainda.</p>
          }
        </div>

        @if (pessoasDisponiveis().length) {
          <div class="lista-amigos-chat">
            <p class="rotulo">Comecar conversa</p>
            @for (pessoa of pessoasDisponiveis(); track pessoa.id) {
              <button type="button" (click)="selecionarUsuario(pessoa)">
                <span class="avatar-chat mini">
                  @if (pessoa.fotoPerfilThumbnailUrl) {
                    <img [src]="resolverUrlMidia(pessoa.fotoPerfilThumbnailUrl)" alt="" />
                  } @else {
                    {{ pessoa.nome.slice(0, 1) }}
                  }
                </span>
                <span>{{ pessoa.nome }}</span>
              </button>
            }
          </div>
        }
      </aside>

      <article class="bloco chat-coluna">
        @if (destinatarioSelecionado(); as destinatario) {
          <header class="chat-topo">
            <span class="avatar-chat grande">
              @if (destinatario.fotoPerfilThumbnailUrl) {
                <img [src]="resolverUrlMidia(destinatario.fotoPerfilThumbnailUrl)" alt="" />
              } @else {
                {{ destinatario.nome.slice(0, 1) }}
              }
            </span>
            <div>
              <h2>{{ destinatario.nome }}</h2>
              <p>{{ destinatario.bio || destinatario.email }}</p>
            </div>
          </header>

          <div class="janela-chat">
            @for (mensagem of mensagens(); track mensagem.id) {
              <div class="bolha-mensagem" [class.minha]="mensagem.remetente.id === usuarioAtualId()">
                <p>{{ mensagem.texto }}</p>
                <small>{{ mensagem.dataCriacao | date:'dd/MM HH:mm' }}</small>
              </div>
            } @empty {
              <p class="texto-suave">Envie a primeira mensagem para abrir este direct.</p>
            }
          </div>

          <form class="composer-chat" (ngSubmit)="enviarMensagem()">
            <textarea [(ngModel)]="textoMensagem" name="textoMensagem" rows="2" maxlength="2000" placeholder="Escreva uma mensagem"></textarea>
            <button class="botao primario" type="submit" [disabled]="enviando()">
              {{ enviando() ? 'Enviando...' : 'Enviar' }}
            </button>
          </form>
        } @else {
          <div class="estado-vazio-chat">
            <h2>Escolha alguém para conversar</h2>
            <p>Os directs aparecem aqui, com contador de mensagens nao lidas e acesso a qualquer pessoa.</p>
          </div>
        }

        @if (mensagemErro()) {
          <p class="mensagem-erro">{{ mensagemErro() }}</p>
        }
      </article>
    </section>
  `,
})
export class MensagensPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);
  private readonly rota = inject(ActivatedRoute);
  readonly resolverUrlMidia = resolverUrlMidia;

  readonly conversas = signal<ConversaDireta[]>([]);
  readonly amigos = signal<Usuario[]>([]);
  readonly usuarios = signal<Usuario[]>([]);
  readonly mensagens = signal<MensagemDireta[]>([]);
  readonly destinatarioSelecionado = signal<Usuario | null>(null);
  readonly enviando = signal(false);
  readonly mensagemErro = signal('');
  readonly usuarioAtualId = computed(() => this.autenticacao.usuario()?.id);

  busca = '';
  textoMensagem = '';

  readonly conversasFiltradas = computed(() => {
    const termo = this.busca.trim().toLowerCase();
    return this.conversas().filter((conversa) => {
      const texto = `${conversa.usuario.nome} ${conversa.usuario.email} ${conversa.ultimaMensagem.texto}`.toLowerCase();
      return !termo || texto.includes(termo);
    });
  });

  readonly pessoasDisponiveis = computed(() => {
    const idsComConversa = new Set(this.conversas().map((conversa) => conversa.usuario.id));
    const termo = this.busca.trim().toLowerCase();
    const usuarioAtualId = this.usuarioAtualId();
    return this.usuarios()
      .filter((usuario) => usuario.id !== usuarioAtualId)
      .filter((usuario) => !idsComConversa.has(usuario.id))
      .filter((usuario) => !termo || `${usuario.nome} ${usuario.email}`.toLowerCase().includes(termo))
      .slice(0, 12);
  });

  ngOnInit() {
    this.carregarBase();
  }

  selecionarUsuario(usuario: Usuario) {
    this.destinatarioSelecionado.set(usuario);
    this.mensagemErro.set('');
    this.api.listarMensagensDiretas(usuario.id).subscribe({
      next: (mensagens) => {
        this.mensagens.set(mensagens);
        this.carregarConversas();
      },
      error: () => this.mensagemErro.set('Nao foi possivel carregar esta conversa.'),
    });
  }

  enviarMensagem() {
    const texto = this.textoMensagem.trim();
    const destinatario = this.destinatarioSelecionado();

    if (!texto || !destinatario) {
      return;
    }

    this.enviando.set(true);
    this.api.enviarMensagemDireta(destinatario.id, texto).subscribe({
      next: (mensagem) => {
        this.enviando.set(false);
        this.textoMensagem = '';
        this.mensagens.update((mensagens) => [...mensagens, mensagem]);
        this.carregarConversas();
      },
      error: () => {
        this.enviando.set(false);
        this.mensagemErro.set('Nao foi possivel enviar a mensagem.');
      },
    });
  }

  private carregarBase() {
    this.carregarConversas();
    this.api.listarAmigos().subscribe({
      next: (amizades) => {
        const amigos = amizades.map((amizade) => this.outroUsuario(amizade));
        this.amigos.set(amigos);
      },
      error: () => this.amigos.set([]),
    });
    this.api.listarUsuarios().subscribe({
      next: (usuarios) => {
        this.usuarios.set(usuarios);
        this.abrirUsuarioDaRota(usuarios);
      },
      error: () => this.usuarios.set([]),
    });
  }

  private carregarConversas() {
    this.api.listarConversasDiretas().subscribe({
      next: (conversas) => {
        this.conversas.set(conversas);
        const selecionado = this.destinatarioSelecionado();
        if (!selecionado && conversas.length) {
          this.selecionarUsuario(conversas[0].usuario);
        }
      },
      error: () => this.conversas.set([]),
    });
  }

  private abrirUsuarioDaRota(usuarios: Usuario[]) {
    const usuarioId = Number(this.rota.snapshot.queryParamMap.get('usuarioId') || '0');
    if (!usuarioId) {
      return;
    }

    const usuario = usuarios.find((item) => item.id === usuarioId);
    if (usuario) {
      this.selecionarUsuario(usuario);
    }
  }

  private outroUsuario(amizade: Amizade) {
    const usuarioAtualId = this.usuarioAtualId();
    return amizade.solicitante.id === usuarioAtualId ? amizade.solicitado : amizade.solicitante;
  }
}
