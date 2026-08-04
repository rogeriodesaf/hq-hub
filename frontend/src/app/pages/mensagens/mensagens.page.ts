import { CommonModule } from '@angular/common';
import { Component, ElementRef, HostListener, OnInit, ViewChild, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { resolverUrlMidia } from '../../core/midia-url';
import { Amizade, ConversaDireta, MensagemDireta, Usuario } from '../../core/modelos';

@Component({
  selector: 'app-mensagens-page',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <section class="cabecalho-pagina cabecalho-direct">
      <div>
        <p class="rotulo">Direct</p>
        <h1>Mensagens</h1>
      </div>
    </section>

    <section class="mensagens-layout" [class.chat-aberto]="!!destinatarioSelecionado()">
      <aside class="bloco conversas-coluna">
        <div class="secao-titulo titulo-conversas">
          <div>
            <h2>Conversas</h2>
            <small>{{ conversas().length }} {{ conversas().length === 1 ? 'conversa' : 'conversas' }}</small>
          </div>
        </div>

        <div class="barra-busca interna busca-conversas-fixa">
          <input
            [(ngModel)]="busca"
            (ngModelChange)="buscarPessoas()"
            placeholder="Buscar pessoa ou conversa"
          />
        </div>

        <div class="lista-conversas">
          @for (conversa of conversasOrdenadas(); track conversa.usuario.id) {
            <button type="button" [class.ativo]="destinatarioSelecionado()?.id === conversa.usuario.id" (click)="selecionarUsuario(conversa.usuario)">
              <span class="avatar-chat">
                @if (conversa.usuario.fotoPerfilThumbnailUrl) {
                  <img [src]="resolverUrlMidia(conversa.usuario.fotoPerfilThumbnailUrl)" alt="" />
                } @else {
                  {{ conversa.usuario.nome.slice(0, 1) }}
                }
              </span>
              <span class="resumo-conversa">
                <strong>{{ conversa.usuario.nome }}</strong>
                <small>{{ conversa.ultimaMensagem.texto }}</small>
              </span>
              <span class="meta-conversa">
                <time>{{ dataLista(conversa.dataUltimaMensagem) }}</time>
                @if (conversa.naoLidas > 0) {
                  <em>{{ conversa.naoLidas > 9 ? '9+' : conversa.naoLidas }}</em>
                }
                <span
                  class="fixar-conversa"
                  [class.ativo]="conversaFixada(conversa.usuario.id)"
                  role="button"
                  tabindex="0"
                  [attr.aria-label]="conversaFixada(conversa.usuario.id) ? 'Desafixar conversa' : 'Fixar conversa'"
                  (click)="alternarFixada(conversa.usuario.id, $event)"
                  (keydown.enter)="alternarFixada(conversa.usuario.id, $event)"
                >&#128204;</span>
              </span>
            </button>
          } @empty {
            <div class="vazio-conversas">
              <strong>Converse com outros leitores</strong>
              <p class="texto-suave">Escolha uma pessoa para iniciar um direct.</p>
              @for (pessoa of sugestoesConversa(); track pessoa.id) {
                <button type="button" (click)="selecionarUsuario(pessoa)">
                  <span class="avatar-chat mini">{{ pessoa.nome.slice(0, 1) }}</span>
                  <span>{{ pessoa.nome }}</span>
                </button>
              }
            </div>
          }
        </div>

        @if (busca.trim().length >= 2 && pessoasDisponiveis().length) {
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
            <button class="voltar-conversas" type="button" (click)="voltarParaConversas()" aria-label="Voltar para conversas">&larr;</button>
            <span class="avatar-chat">
              @if (destinatario.fotoPerfilThumbnailUrl) {
                <img [src]="resolverUrlMidia(destinatario.fotoPerfilThumbnailUrl)" alt="" />
              } @else {
                {{ destinatario.nome.slice(0, 1) }}
              }
            </span>
            <div>
              <h2>{{ destinatario.nome }}</h2>
              <p>{{ destinatario.bio || 'Leitor no HQ-HUB' }}</p>
              <small>Direct privado</small>
            </div>
            <nav class="acoes-chat" aria-label="Ações da conversa">
              <a [routerLink]="['/usuario', destinatario.id]">Ver perfil</a>
              <a [routerLink]="['/usuario', destinatario.id]" fragment="estante">Coleção</a>
            </nav>
          </header>

          <div class="janela-chat" #janelaChat>
            @for (mensagem of mensagens(); track mensagem.id) {
              @if (mostrarSeparadorData($index)) {
                <div class="separador-data"><span>{{ dataSeparador(mensagem.dataCriacao) }}</span></div>
              }
              <div class="bolha-mensagem" [class.minha]="mensagem.remetente.id === usuarioAtualId()">
                <p>{{ mensagem.texto }}</p>
                <small>
                  {{ horaMensagem(mensagem.dataCriacao) }}
                  @if (mensagem.remetente.id === usuarioAtualId()) {
                    <span class="status-mensagem" [class.lida]="mensagem.lida" [attr.aria-label]="mensagem.lida ? 'Mensagem lida' : 'Mensagem enviada'">
                      {{ mensagem.lida ? '\u2713\u2713' : '\u2713' }}
                    </span>
                  }
                </small>
              </div>
            } @empty {
              <p class="texto-suave">Envie a primeira mensagem para abrir este direct.</p>
            }
          </div>

          <form class="composer-chat" (ngSubmit)="enviarMensagem()">
            <div class="composer-recursos">
              <button type="button" (click)="inserirEmoji()" aria-label="Adicionar emoji">&#128522;</button>
              <button type="button" disabled title="Envio de arquivos em breve" aria-label="Anexar arquivo em breve">&#128206;</button>
              <button type="button" disabled title="Envio de imagens em breve" aria-label="Enviar imagem em breve">&#128247;</button>
            </div>
            <textarea
              [(ngModel)]="textoMensagem"
              name="textoMensagem"
              rows="1"
              maxlength="2000"
              placeholder="Escreva uma mensagem..."
              (keydown.enter)="aoPressionarEnter($event)"
            ></textarea>
            <button class="enviar-chat" type="submit" [disabled]="enviando() || !textoMensagem.trim()" [attr.aria-label]="enviando() ? 'Enviando mensagem' : 'Enviar mensagem'">
              {{ enviando() ? '...' : '\u27a4' }}
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
  readonly buscandoPessoas = signal(false);
  readonly mensagemErro = signal('');
  readonly usuarioAtualId = computed(() => this.autenticacao.usuario()?.id);
  readonly modoCompacto = signal(typeof window !== 'undefined' && window.matchMedia('(max-width: 760px)').matches);
  readonly conversasFixadas = signal<Set<number>>(new Set());
  @ViewChild('janelaChat') janelaChat?: ElementRef<HTMLElement>;

  busca = '';
  textoMensagem = '';

  readonly conversasFiltradas = computed(() => {
    const termo = this.busca.trim().toLowerCase();
    return this.conversas().filter((conversa) => {
      const texto = `${conversa.usuario.nome} ${conversa.usuario.email} ${conversa.ultimaMensagem.texto}`.toLowerCase();
      return !termo || texto.includes(termo);
    });
  });

  readonly conversasOrdenadas = computed(() => {
    const fixadas = this.conversasFixadas();
    return [...this.conversasFiltradas()].sort((a, b) => {
      const aFixada = fixadas.has(a.usuario.id) ? 1 : 0;
      const bFixada = fixadas.has(b.usuario.id) ? 1 : 0;
      return bFixada - aFixada || new Date(b.dataUltimaMensagem).getTime() - new Date(a.dataUltimaMensagem).getTime();
    });
  });

  readonly sugestoesConversa = computed(() => {
    const ids = new Set(this.conversas().map((conversa) => conversa.usuario.id));
    return this.amigos().filter((amigo) => !ids.has(amigo.id)).slice(0, 4);
  });

  readonly pessoasDisponiveis = computed(() => {
    const idsComConversa = new Set(this.conversas().map((conversa) => conversa.usuario.id));
    const termo = this.busca.trim().toLowerCase();
    if (termo.length < 2) {
      return [];
    }

    const usuarioAtualId = this.usuarioAtualId();
    return this.usuarios()
      .filter((usuario) => usuario.id !== usuarioAtualId)
      .filter((usuario) => !idsComConversa.has(usuario.id))
      .filter((usuario) => !termo || `${usuario.nome} ${usuario.email}`.toLowerCase().includes(termo))
      .slice(0, 12);
  });

  ngOnInit() {
    this.carregarFixadas();
    this.carregarBase();
  }

  @HostListener('window:resize')
  aoRedimensionar() {
    this.modoCompacto.set(window.matchMedia('(max-width: 760px)').matches);
  }

  selecionarUsuario(usuario: Usuario) {
    this.destinatarioSelecionado.set(usuario);
    this.mensagemErro.set('');
    this.api.listarMensagensDiretas(usuario.id).subscribe({
      next: (mensagens) => {
        this.mensagens.set(mensagens);
        this.carregarConversas();
        this.rolarParaFinal();
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
        this.rolarParaFinal();
      },
      error: () => {
        this.enviando.set(false);
        this.mensagemErro.set('Nao foi possivel enviar a mensagem.');
      },
    });
  }

  buscarPessoas() {
    const termo = this.busca.trim();
    if (termo.length < 2) {
      this.usuarios.set([]);
      return;
    }

    this.buscandoPessoas.set(true);
    this.api.listarUsuarios(termo).subscribe({
      next: (usuarios) => {
        this.usuarios.set(usuarios);
        this.buscandoPessoas.set(false);
      },
      error: () => {
        this.usuarios.set([]);
        this.buscandoPessoas.set(false);
      },
    });
  }

  voltarParaConversas() {
    this.destinatarioSelecionado.set(null);
    this.mensagens.set([]);
    this.mensagemErro.set('');
  }

  conversaFixada(usuarioId: number) {
    return this.conversasFixadas().has(usuarioId);
  }

  alternarFixada(usuarioId: number, evento: Event) {
    evento.preventDefault();
    evento.stopPropagation();
    const fixadas = new Set(this.conversasFixadas());
    fixadas.has(usuarioId) ? fixadas.delete(usuarioId) : fixadas.add(usuarioId);
    this.conversasFixadas.set(fixadas);
    this.salvarFixadas();
  }

  inserirEmoji() {
    this.textoMensagem += '\u{1F60A}';
  }

  aoPressionarEnter(evento: Event) {
    if ((evento as KeyboardEvent).shiftKey) {
      return;
    }
    evento.preventDefault();
    this.enviarMensagem();
  }

  mostrarSeparadorData(indice: number) {
    if (indice === 0) {
      return true;
    }
    const atual = new Date(this.mensagens()[indice].dataCriacao);
    const anterior = new Date(this.mensagens()[indice - 1].dataCriacao);
    return atual.toDateString() !== anterior.toDateString();
  }

  horaMensagem(data: string) {
    return new Intl.DateTimeFormat('pt-BR', { hour: '2-digit', minute: '2-digit' }).format(new Date(data));
  }

  dataLista(data: string) {
    const valor = new Date(data);
    const dias = this.diferencaEmDias(valor);
    if (dias === 0) {
      return this.horaMensagem(data);
    }
    if (dias === 1) {
      return 'Ontem';
    }
    if (dias < 7) {
      return new Intl.DateTimeFormat('pt-BR', { weekday: 'short' }).format(valor).replace('.', '');
    }
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short' }).format(valor).replace('.', '');
  }

  dataSeparador(data: string) {
    const valor = new Date(data);
    const dias = this.diferencaEmDias(valor);
    if (dias === 0) {
      return 'Hoje';
    }
    if (dias === 1) {
      return 'Ontem';
    }
    if (dias < 7) {
      return new Intl.DateTimeFormat('pt-BR', { weekday: 'long' }).format(valor);
    }
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(valor);
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
    this.abrirUsuarioDaRota();
  }

  private carregarConversas() {
    this.api.listarConversasDiretas().subscribe({
      next: (conversas) => {
        this.conversas.set(conversas);
        const selecionado = this.destinatarioSelecionado();
        if (!selecionado && conversas.length && !this.modoCompacto()) {
          this.selecionarUsuario(conversas[0].usuario);
        }
      },
      error: () => this.conversas.set([]),
    });
  }

  private abrirUsuarioDaRota() {
    const usuarioId = Number(this.rota.snapshot.queryParamMap.get('usuarioId') || '0');
    if (!usuarioId) {
      return;
    }

    this.api.obterPerfilUsuario(usuarioId).subscribe({
      next: (usuario) => this.selecionarUsuario(usuario),
      error: () => undefined,
    });
  }

  private outroUsuario(amizade: Amizade) {
    const usuarioAtualId = this.usuarioAtualId();
    return amizade.solicitante.id === usuarioAtualId ? amizade.solicitado : amizade.solicitante;
  }

  private carregarFixadas() {
    if (typeof localStorage === 'undefined') {
      return;
    }
    try {
      const ids = JSON.parse(localStorage.getItem(this.chaveFixadas()) || '[]') as number[];
      this.conversasFixadas.set(new Set(ids.filter((id) => Number.isInteger(id))));
    } catch {
      this.conversasFixadas.set(new Set());
    }
  }

  private salvarFixadas() {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem(this.chaveFixadas(), JSON.stringify([...this.conversasFixadas()]));
    }
  }

  private chaveFixadas() {
    return `hqhub.direct.fixadas.${this.usuarioAtualId() ?? 'anonimo'}`;
  }

  private diferencaEmDias(data: Date) {
    const hoje = new Date();
    const inicioHoje = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate()).getTime();
    const inicioData = new Date(data.getFullYear(), data.getMonth(), data.getDate()).getTime();
    return Math.max(0, Math.floor((inicioHoje - inicioData) / 86_400_000));
  }

  private rolarParaFinal() {
    requestAnimationFrame(() => {
      const janela = this.janelaChat?.nativeElement;
      if (janela) {
        janela.scrollTop = janela.scrollHeight;
      }
    });
  }
}
