import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import {
  LucideBookOpen,
  LucideBot,
  LucideCalendarDays,
  LucideClipboardCheck,
  LucideGitCompare,
  LucideUpload,
  LucideLibrary,
  LucideLogOut,
  LucideMessageCircle,
  LucideMoon,
  LucideNewspaper,
  LucideSearch,
  LucideShoppingBag,
  LucideSun,
  LucideUsers,
  LucideTv,
} from '@lucide/angular';
import { filter, forkJoin } from 'rxjs';

import { AutenticacaoService } from './core/autenticacao.service';
import { ApiService } from './core/api.service';
import { resolverUrlMidia } from './core/midia-url';
import { Amizade, ContribuicaoCatalogo, ConversaDireta } from './core/modelos';

@Component({
  selector: 'app-root',
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    LucideBookOpen,
    LucideBot,
    LucideCalendarDays,
    LucideClipboardCheck,
    LucideGitCompare,
    LucideUpload,
    LucideLibrary,
    LucideLogOut,
    LucideMessageCircle,
    LucideMoon,
    LucideNewspaper,
    LucideSearch,
    LucideShoppingBag,
    LucideSun,
    LucideUsers,
    LucideTv,
  ],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit {
  private static readonly CHAVE_FEED_VISTO = 'hqhub.feed.vistoEm';
  private static readonly CHAVE_TEMA = 'hqhub.tema';
  private readonly roteador = inject(Router);
  private readonly api = inject(ApiService);
  readonly autenticacaoService = inject(AutenticacaoService);
  readonly usuario = this.autenticacaoService.usuario;
  readonly mostrarShell = computed(() => this.autenticacaoService.autenticado());
  readonly podeRevisarCatalogo = this.autenticacaoService.podeRevisarCatalogo;
  readonly pendenciasCatalogo = signal(0);
  readonly novidadesFeed = signal(0);
  readonly mensagensNaoLidas = signal(0);
  readonly solicitacoesAmizadePendentes = signal(0);
  readonly alteracoesEstanteAmigos = signal(0);
  readonly notificacoesAbertas = signal(false);
  readonly modoEscuro = signal(false);
  readonly carregandoNotificacoes = signal(false);
  readonly solicitacoesRecebidas = signal<Amizade[]>([]);
  readonly conversasComNaoLidas = signal<ConversaDireta[]>([]);
  readonly alteracoesEstanteRecentes = signal<ContribuicaoCatalogo[]>([]);
  readonly resolverUrlMidia = resolverUrlMidia;
  readonly totalNotificacoes = computed(() =>
    Math.min(
      9,
      this.novidadesFeed() +
        this.mensagensNaoLidas() +
        this.solicitacoesAmizadePendentes() +
        this.alteracoesEstanteAmigos(),
    ),
  );
  private intervaloNotificacoes: number | null = null;

  ngOnInit() {
    this.carregarTema();
    this.carregarPendenciasCatalogo();
    this.carregarNovidadesFeed();
    this.carregarMensagensNaoLidas();
    this.carregarSolicitacoesAmizadePendentes();
    this.carregarAlteracoesEstanteAmigos();
    window.addEventListener('hqhub-amizades-atualizadas', () => {
      this.carregarSolicitacoesAmizadePendentes();
      if (this.notificacoesAbertas()) {
        this.carregarNotificacoes();
      }
    });
    this.intervaloNotificacoes = window.setInterval(() => {
      if (this.autenticacaoService.autenticado()) {
        this.carregarMensagensNaoLidas();
        this.carregarSolicitacoesAmizadePendentes();
        this.carregarAlteracoesEstanteAmigos();
        this.carregarNovidadesFeed();
      }
    }, 30000);
    this.roteador.events
      .pipe(filter((evento): evento is NavigationEnd => evento instanceof NavigationEnd))
      .subscribe((evento) => {
        if (evento.urlAfterRedirects.startsWith('/painel')) {
          this.marcarNotificacoesComoVistas();
        }
        if (evento.urlAfterRedirects.startsWith('/mensagens')) {
          this.carregarMensagensNaoLidas();
        }
        if (evento.urlAfterRedirects.startsWith('/amigos')) {
          this.carregarSolicitacoesAmizadePendentes();
        }
        if (this.notificacoesAbertas()) {
          this.fecharNotificacoes();
        }
      });
  }

  abrirNotificacoes() {
    if (this.notificacoesAbertas()) {
      this.fecharNotificacoes();
      return;
    }

    this.notificacoesAbertas.set(true);
    this.carregarNotificacoes();
  }

  fecharNotificacoes() {
    this.notificacoesAbertas.set(false);
  }

  sair() {
    this.autenticacaoService.sair();
    this.roteador.navigateByUrl('/entrar');
  }

  alternarTema() {
    this.aplicarTema(!this.modoEscuro());
  }

  private carregarTema() {
    this.aplicarTema(localStorage.getItem(App.CHAVE_TEMA) === 'escuro');
  }

  private aplicarTema(escuro: boolean) {
    this.modoEscuro.set(escuro);
    document.body.classList.toggle('tema-escuro', escuro);
    localStorage.setItem(App.CHAVE_TEMA, escuro ? 'escuro' : 'claro');
  }

  private carregarPendenciasCatalogo() {
    if (!this.podeRevisarCatalogo()) {
      this.pendenciasCatalogo.set(0);
      return;
    }

    this.api.contarContribuicoesPendentes().subscribe({
      next: (resposta) => this.pendenciasCatalogo.set(resposta.total),
      error: () => this.pendenciasCatalogo.set(0),
    });
  }

  private carregarNovidadesFeed() {
    if (!this.autenticacaoService.autenticado()) {
      this.novidadesFeed.set(0);
      return;
    }

    const vistoEm = Number(localStorage.getItem(App.CHAVE_FEED_VISTO) || '0');
    this.api.listarFeed(0, 20).subscribe({
      next: (feed) => {
        if (!vistoEm) {
          this.novidadesFeed.set(Math.min(feed.length, 9));
          return;
        }

        const total = feed.filter((postagem) => new Date(postagem.dataCriacao).getTime() > vistoEm).length;
        this.novidadesFeed.set(Math.min(total, 9));
      },
      error: () => this.novidadesFeed.set(0),
    });
  }

  private marcarNotificacoesComoVistas() {
    localStorage.setItem(App.CHAVE_FEED_VISTO, String(Date.now()));
    this.novidadesFeed.set(0);
    this.alteracoesEstanteAmigos.set(0);
  }

  private carregarMensagensNaoLidas() {
    if (!this.autenticacaoService.autenticado()) {
      this.mensagensNaoLidas.set(0);
      return;
    }

    this.api.contarMensagensNaoLidas().subscribe({
      next: (resposta) => this.mensagensNaoLidas.set(Math.min(resposta.total, 9)),
      error: () => this.mensagensNaoLidas.set(0),
    });
  }

  private carregarSolicitacoesAmizadePendentes() {
    if (!this.autenticacaoService.autenticado()) {
      this.solicitacoesAmizadePendentes.set(0);
      return;
    }

    this.api.contarSolicitacoesRecebidas().subscribe({
      next: (resposta) => this.solicitacoesAmizadePendentes.set(Math.min(resposta.total, 9)),
      error: () => this.solicitacoesAmizadePendentes.set(0),
    });
  }

  private carregarAlteracoesEstanteAmigos() {
    if (!this.autenticacaoService.autenticado()) {
      this.alteracoesEstanteAmigos.set(0);
      return;
    }

    const vistoEm = Number(localStorage.getItem(App.CHAVE_FEED_VISTO) || '0');
    this.api.contarAlteracoesEstanteAmigos(vistoEm).subscribe({
      next: (resposta) => this.alteracoesEstanteAmigos.set(Math.min(resposta.total, 9)),
      error: () => this.alteracoesEstanteAmigos.set(0),
    });
  }

  private carregarNotificacoes() {
    if (!this.autenticacaoService.autenticado()) {
      this.solicitacoesRecebidas.set([]);
      this.conversasComNaoLidas.set([]);
      this.alteracoesEstanteRecentes.set([]);
      return;
    }

    const vistoEm = Number(localStorage.getItem(App.CHAVE_FEED_VISTO) || '0');
    this.carregandoNotificacoes.set(true);
    forkJoin({
      solicitacoes: this.api.listarSolicitacoesRecebidas(),
      conversas: this.api.listarConversasDiretas(),
      alteracoes: this.api.listarAlteracoesEstanteAmigos(vistoEm),
    }).subscribe({
      next: ({ solicitacoes, conversas, alteracoes }) => {
        this.solicitacoesRecebidas.set(solicitacoes);
        this.conversasComNaoLidas.set(conversas.filter((conversa) => conversa.naoLidas > 0));
        this.alteracoesEstanteRecentes.set(alteracoes);
        this.carregandoNotificacoes.set(false);
      },
      error: () => {
        this.solicitacoesRecebidas.set([]);
        this.conversasComNaoLidas.set([]);
        this.alteracoesEstanteRecentes.set([]);
        this.carregandoNotificacoes.set(false);
      },
    });
  }
}
