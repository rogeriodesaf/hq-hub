import { Component, HostListener, OnInit, computed, inject, signal } from '@angular/core';
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
  LucidePlus,
  LucideSearch,
  LucideShoppingBag,
  LucideSun,
  LucideUserRound,
  LucideUsers,
  LucideTv,
} from '@lucide/angular';
import { filter, forkJoin } from 'rxjs';

import { AutenticacaoService } from './core/autenticacao.service';
import { ApiService } from './core/api.service';
import { AtualizacaoAppService } from './core/atualizacao-app.service';
import { resolverUrlMidia } from './core/midia-url';
import { Amizade, ContribuicaoCatalogo, ConversaDireta, NotificacaoSocial, Usuario } from './core/modelos';
import { SeoService } from './core/seo.service';

type PeriodoNotificacao = 'Hoje' | 'Ontem' | 'Últimos 7 dias' | 'Anteriores';
interface ItemNotificacao {
  chave: string;
  usuario: Usuario;
  descricao: string;
  data: string;
  destino: string;
  parametros?: Record<string, number | string>;
  imagem?: string | null;
  socialId?: number;
  lida: boolean;
}

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
    LucidePlus,
    LucideSearch,
    LucideShoppingBag,
    LucideSun,
    LucideUserRound,
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
  private readonly seo = inject(SeoService);
  private readonly api = inject(ApiService);
  readonly atualizacaoApp = inject(AtualizacaoAppService);
  readonly autenticacaoService = inject(AutenticacaoService);
  readonly usuario = this.autenticacaoService.usuario;
  readonly mostrarShell = computed(() => this.autenticacaoService.autenticado());
  readonly podeRevisarCatalogo = this.autenticacaoService.podeRevisarCatalogo;
  readonly pendenciasCatalogo = signal(0);
  readonly novidadesFeed = signal(0);
  readonly mensagensNaoLidas = signal(0);
  readonly solicitacoesAmizadePendentes = signal(0);
  readonly alteracoesEstanteAmigos = signal(0);
  readonly notificacoesSociaisNaoLidas = signal(0);
  readonly notificacoesAbertas = signal(false);
  readonly publicarAberto = signal(false);
  readonly urlAtual = signal('');
  readonly modoEscuro = signal(false);
  readonly carregandoNotificacoes = signal(false);
  readonly erroNotificacoes = signal(false);
  readonly marcandoNotificacoes = signal(false);
  readonly solicitacoesRecebidas = signal<Amizade[]>([]);
  readonly conversasComNaoLidas = signal<ConversaDireta[]>([]);
  readonly alteracoesEstanteRecentes = signal<ContribuicaoCatalogo[]>([]);
  readonly notificacoesSociais = signal<NotificacaoSocial[]>([]);
  readonly periodosNotificacoes: PeriodoNotificacao[] = ['Hoje', 'Ontem', 'Últimos 7 dias', 'Anteriores'];
  readonly itensNotificacoes = computed<ItemNotificacao[]>(() => [
    ...this.notificacoesSociais().map((item) => ({
      chave: `social-${item.id}`, usuario: item.autor,
      descricao: item.mensagem.startsWith(`${item.autor.nome} `)
        ? item.mensagem.slice(item.autor.nome.length + 1) : item.mensagem,
      data: item.dataCriacao, destino: item.postagemId ? `/postagem/${item.postagemId}` : '/painel',
      socialId: item.id, lida: item.lida,
    })),
    ...this.solicitacoesRecebidas().map((item) => ({
      chave: `amizade-${item.id}`, usuario: item.solicitante, descricao: 'enviou uma solicitação de amizade',
      data: item.dataSolicitacao, destino: '/amigos', parametros: { aba: 'recebidas' }, lida: false,
    })),
    ...this.conversasComNaoLidas().map((item) => ({
      chave: `mensagem-${item.usuario.id}`, usuario: item.usuario, descricao: 'enviou uma mensagem',
      data: item.dataUltimaMensagem, destino: '/mensagens', parametros: { usuarioId: item.usuario.id }, lida: false,
    })),
    ...this.alteracoesEstanteRecentes().map((item) => ({
      chave: `estante-${item.id}`, usuario: item.usuario,
      descricao: `atualizou ${item.edicao.serie?.titulo || 'uma HQ'} ${item.edicao.numero || ''}`.trim(),
      data: item.dataCriacao, destino: '/catalogo', parametros: { edicaoId: item.edicao.id },
      imagem: item.edicao.urlCapa, lida: true,
    })),
  ].sort((a, b) => new Date(b.data).getTime() - new Date(a.data).getTime()));
  readonly resolverUrlMidia = resolverUrlMidia;
  readonly totalNotificacoes = computed(() =>
    Math.min(
      9,
      this.novidadesFeed() +
        this.notificacoesSociaisNaoLidas() +
        this.mensagensNaoLidas() +
        this.solicitacoesAmizadePendentes() +
        this.alteracoesEstanteAmigos(),
    ),
  );
  readonly catalogoAtivo = computed(() => this.rotaEm('/catalogo', '/titulos-estrangeiros'));
  readonly socialAtivo = computed(() => this.rotaEm('/social', '/mensagens', '/amigos', '/canais', '/colaboradores'));
  readonly perfilAtivo = computed(() => this.rotaEm('/perfil', '/colecao', '/compras', '/anuncios', '/assistente', '/conteudos', '/importacao', '/revisao'));
  private intervaloNotificacoes: number | null = null;

  ngOnInit() {
    this.urlAtual.set(this.roteador.url);
    this.seo.atualizar(this.roteador.url);
    this.carregarTema();
    this.carregarPendenciasCatalogo();
    this.carregarNovidadesFeed();
    this.carregarMensagensNaoLidas();
    this.carregarSolicitacoesAmizadePendentes();
    this.carregarAlteracoesEstanteAmigos();
    this.carregarContagemNotificacoesSociais();
    window.addEventListener('hqhub-amizades-atualizadas', () => {
      this.carregarSolicitacoesAmizadePendentes();
      if (this.notificacoesAbertas()) {
        this.carregarNotificacoes();
      }
    });
    window.addEventListener('hqhub-alternar-tema', () => this.alternarTema());
    window.addEventListener('hqhub-abrir-notificacoes', () => {
      if (!this.notificacoesAbertas()) {
        this.abrirNotificacoes();
      }
    });
    this.intervaloNotificacoes = window.setInterval(() => {
      if (this.autenticacaoService.autenticado()) {
        this.carregarMensagensNaoLidas();
        this.carregarSolicitacoesAmizadePendentes();
        this.carregarAlteracoesEstanteAmigos();
        this.carregarNovidadesFeed();
        this.carregarContagemNotificacoesSociais();
      }
    }, 30000);
    this.roteador.events
      .pipe(filter((evento): evento is NavigationEnd => evento instanceof NavigationEnd))
      .subscribe((evento) => {
        this.urlAtual.set(evento.urlAfterRedirects);
        this.seo.atualizar(evento.urlAfterRedirects);
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
        this.fecharPublicar();
      });
  }

  private rotaEm(...prefixos: string[]) {
    return prefixos.some((prefixo) => this.urlAtual().startsWith(prefixo));
  }

  abrirPublicar() {
    this.publicarAberto.set(true);
    document.body.classList.add('bottom-sheet-aberto');
  }

  fecharPublicar() {
    this.publicarAberto.set(false);
    document.body.classList.remove('bottom-sheet-aberto');
  }

  @HostListener('document:keydown.escape')
  aoPressionarEscape() {
    if (this.notificacoesAbertas()) this.fecharNotificacoes();
    if (this.publicarAberto()) {
      this.fecharPublicar();
    }
  }

  abrirNotificacoes() {
    if (this.notificacoesAbertas()) {
      this.fecharNotificacoes();
      return;
    }

    this.notificacoesAbertas.set(true);
    this.carregarNotificacoes();
  }

  notificacoesDoPeriodo(periodo: PeriodoNotificacao) {
    return this.itensNotificacoes().filter((item) => this.periodoNotificacao(item.data) === periodo);
  }

  private periodoNotificacao(data: string): PeriodoNotificacao {
    const dia = new Date(data);
    if (Number.isNaN(dia.getTime())) return 'Anteriores';
    const inicioHoje = new Date();
    inicioHoje.setHours(0, 0, 0, 0);
    const dias = Math.floor((inicioHoje.getTime() - new Date(dia.getFullYear(), dia.getMonth(), dia.getDate()).getTime()) / 86400000);
    return dias <= 0 ? 'Hoje' : dias === 1 ? 'Ontem' : dias < 7 ? 'Últimos 7 dias' : 'Anteriores';
  }

  tempoNotificacao(data: string) {
    const minutos = Math.max(0, Math.floor((Date.now() - new Date(data).getTime()) / 60000));
    if (!Number.isFinite(minutos)) return '';
    if (minutos < 1) return 'agora';
    if (minutos < 60) return `há ${minutos} min`;
    if (minutos < 1440) return `há ${Math.floor(minutos / 60)} h`;
    return `há ${Math.floor(minutos / 1440)} d`;
  }

  abrirItemNotificacao(item: ItemNotificacao) {
    if (item.socialId && !item.lida) {
      this.api.marcarNotificacaoSocialComoLida(item.socialId).subscribe({
        next: () => {
          this.notificacoesSociais.update((itens) => itens.map((social) => social.id === item.socialId ? { ...social, lida: true } : social));
          this.carregarContagemNotificacoesSociais();
          this.navegarNotificacao(item);
        },
        error: () => this.erroNotificacoes.set(true),
      });
      return;
    }
    this.navegarNotificacao(item);
  }

  private navegarNotificacao(item: ItemNotificacao) {
    this.fecharNotificacoes();
    void this.roteador.navigate([item.destino], { queryParams: item.parametros });
  }

  marcarTodasNotificacoesComoLidas() {
    if (this.marcandoNotificacoes()) return;
    this.marcandoNotificacoes.set(true);
    this.api.marcarNotificacoesSociaisComoLidas().subscribe({
      next: () => {
        this.notificacoesSociais.update((itens) => itens.map((item) => ({ ...item, lida: true })));
        this.notificacoesSociaisNaoLidas.set(0);
        this.marcandoNotificacoes.set(false);
      },
      error: () => { this.erroNotificacoes.set(true); this.marcandoNotificacoes.set(false); },
    });
  }

  fecharNotificacoes() {
    this.notificacoesAbertas.set(false);
  }

  baixarInstalador() {
    this.api.baixarInstalador().subscribe({
      next: (arquivo) => {
        const url = URL.createObjectURL(arquivo);
        const ancora = document.createElement('a');
        ancora.href = url;
        ancora.download = 'Coleciona-HQ-Agente-Setup.exe';
        ancora.click();
        URL.revokeObjectURL(url);
      },
      error: () => alert('Não foi possível baixar o instalador do Coleciona HQ.'),
    });
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

  private carregarContagemNotificacoesSociais() {
    if (!this.autenticacaoService.autenticado()) {
      this.notificacoesSociaisNaoLidas.set(0);
      return;
    }
    this.api.contarNotificacoesSociaisNaoLidas().subscribe({
      next: (resposta) => this.notificacoesSociaisNaoLidas.set(Math.min(resposta.total, 9)),
      error: () => { if (this.notificacoesAbertas()) this.erroNotificacoes.set(true); },
    });
  }

  carregarNotificacoes() {
    if (!this.autenticacaoService.autenticado()) {
      this.solicitacoesRecebidas.set([]);
      this.conversasComNaoLidas.set([]);
      this.alteracoesEstanteRecentes.set([]);
      this.notificacoesSociais.set([]);
      return;
    }

    const vistoEm = Number(localStorage.getItem(App.CHAVE_FEED_VISTO) || '0');
    this.carregandoNotificacoes.set(true);
    this.erroNotificacoes.set(false);
    forkJoin({
      solicitacoes: this.api.listarSolicitacoesRecebidas(),
      conversas: this.api.listarConversasDiretas(),
      alteracoes: this.api.listarAlteracoesEstanteAmigos(vistoEm),
      sociais: this.api.listarNotificacoesSociais(),
    }).subscribe({
      next: ({ solicitacoes, conversas, alteracoes, sociais }) => {
        this.solicitacoesRecebidas.set(solicitacoes);
        this.conversasComNaoLidas.set(conversas.filter((conversa) => conversa.naoLidas > 0));
        this.alteracoesEstanteRecentes.set(alteracoes);
        this.notificacoesSociais.set(sociais);
        this.carregandoNotificacoes.set(false);
      },
      error: () => {
        this.erroNotificacoes.set(true);
        this.carregandoNotificacoes.set(false);
      },
    });
  }
}
