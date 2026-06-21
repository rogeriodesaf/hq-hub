import { CommonModule } from '@angular/common';
import { AfterViewInit, Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { AutenticacaoService } from '../../core/autenticacao.service';
import { ApiService } from '../../core/api.service';
import { Amizade, Usuario } from '../../core/modelos';

@Component({
  selector: 'app-amigos-page',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Amigos</p>
        <h1>Convites e conexões com outros colecionadores.</h1>
      </div>
    </section>

    <section class="painel-formulario">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Novo convite</p>
          <h2>Enviar solicitação de amizade</h2>
        </div>
      </div>

      <div class="barra-busca">
        <input [(ngModel)]="buscaUsuario" placeholder="Buscar por nome ou e-mail" (keyup.enter)="buscarUsuarios()" />
        <button class="botao primario" type="button" (click)="buscarUsuarios()">Buscar usuários</button>
      </div>

      @if (usuariosFiltrados().length) {
        <div class="lista-escolha usuarios-escolha">
          @for (usuario of usuariosFiltrados(); track usuario.id) {
            <button type="button" (click)="enviarConvite(usuario)" [disabled]="enviandoConvite()">
              <strong>{{ usuario.nome }}</strong>
              <span>{{ usuario.email }}</span>
              <small>{{ enviandoConvite() ? 'Enviando...' : 'Enviar convite' }}</small>
            </button>
          }
        </div>
      }

      @if (mensagem()) {
        <p class="mensagem-erro">{{ mensagem() }}</p>
      }
    </section>

    <section class="amizades-layout">
      <article class="bloco" id="solicitacoes-recebidas">
        <div class="secao-titulo">
          <h2>Solicitações recebidas</h2>
          <span>{{ recebidas().length }}</span>
        </div>
        <div class="lista-amizades">
          @for (amizade of recebidas(); track amizade.id) {
            <div>
              <a [routerLink]="['/usuario', amizade.solicitante.id]" class="link-nome-amigo">
                <strong>{{ amizade.solicitante.nome }}</strong>
              </a>
              <span>{{ amizade.solicitante.email }}</span>
              <div class="acoes-linha">
                <button class="botao compacto" type="button" (click)="aceitar(amizade.id)">Aceitar</button>
                <button class="botao compacto" type="button" (click)="recusar(amizade.id)">Recusar</button>
              </div>
            </div>
          } @empty {
            <p class="texto-suave">Nenhum convite recebido.</p>
          }
        </div>
      </article>

      <article class="bloco">
        <div class="secao-titulo">
          <h2>Solicitações enviadas</h2>
          <span>{{ enviadas().length }}</span>
        </div>
        <div class="lista-amizades">
          @for (amizade of enviadas(); track amizade.id) {
            <div>
              <strong>{{ amizade.solicitado.nome }}</strong>
              <span>{{ amizade.solicitado.email }}</span>
              <small>Aguardando resposta</small>
            </div>
          } @empty {
            <p class="texto-suave">Nenhum convite pendente enviado.</p>
          }
        </div>
      </article>

      <article class="bloco">
        <div class="secao-titulo">
          <h2>Meus amigos</h2>
          <span>{{ amigos().length }}</span>
        </div>
        <div class="lista-amizades">
          @for (amizade of amigos(); track amizade.id) {
            <div>
              <a [routerLink]="['/usuario', outroUsuario(amizade).id]" class="link-nome-amigo">
                <strong>{{ outroUsuario(amizade).nome }}</strong>
              </a>
              <span>{{ outroUsuario(amizade).email }}</span>
              <div class="acoes-linha">
                <a class="botao compacto secundario" [routerLink]="['/usuario', outroUsuario(amizade).id]">Ver perfil</a>
                <a class="botao compacto" routerLink="/mensagens" [queryParams]="{ usuarioId: outroUsuario(amizade).id }">Direct</a>
                <button class="botao compacto" type="button" (click)="remover(amizade)">Remover</button>
              </div>
            </div>
          } @empty {
            <p class="texto-suave">Você ainda não adicionou amigos.</p>
          }
        </div>
      </article>
    </section>
  `,
})
export class AmigosPage implements OnInit, AfterViewInit {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);
  private readonly rota = inject(ActivatedRoute);

  readonly usuarios = signal<Usuario[]>([]);
  readonly usuariosFiltrados = signal<Usuario[]>([]);
  readonly amigos = signal<Amizade[]>([]);
  readonly recebidas = signal<Amizade[]>([]);
  readonly enviadas = signal<Amizade[]>([]);
  readonly mensagem = signal('');
  readonly enviandoConvite = signal(false);

  buscaUsuario = '';
  private focoSolicitacoesRecebidas = false;

  ngOnInit() {
    this.focoSolicitacoesRecebidas = this.rota.snapshot.queryParamMap.get('aba') === 'recebidas';
    this.carregarTudo();
  }

  ngAfterViewInit() {
    if (this.focoSolicitacoesRecebidas) {
      queueMicrotask(() => {
        document.getElementById('solicitacoes-recebidas')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    }
  }

  buscarUsuarios() {
    const termo = this.buscaUsuario.trim().toLowerCase();
    this.api.listarUsuarios().subscribe({
      next: (usuarios) => {
        const usuarioAtualId = this.autenticacao.usuario()?.id;
        const filtrados = usuarios.filter((usuario) => {
          const texto = `${usuario.nome} ${usuario.email}`.toLowerCase();
          return usuario.id !== usuarioAtualId && (!termo || texto.includes(termo));
        });
        this.usuarios.set(usuarios);
        this.usuariosFiltrados.set(filtrados.slice(0, 12));
        if (!filtrados.length) {
          this.mensagem.set('Nenhum usuário encontrado para este termo.');
        } else {
          this.mensagem.set('');
        }
      },
      error: () => this.mensagem.set('Não foi possível buscar usuários agora.'),
    });
  }

  enviarConvite(usuario: Usuario) {
    this.enviandoConvite.set(true);
    this.api.enviarSolicitacaoAmizade(usuario.id).subscribe({
      next: () => {
        this.enviandoConvite.set(false);
        this.buscaUsuario = '';
        this.usuariosFiltrados.set([]);
        this.mensagem.set('Convite enviado.');
        this.notificarAtualizacaoAmizades();
        this.carregarTudo();
      },
      error: () => {
        this.enviandoConvite.set(false);
        this.mensagem.set('Não foi possível enviar o convite. Talvez já exista uma solicitação entre vocês.');
      },
    });
  }

  aceitar(id: number) {
    this.api.aceitarSolicitacaoAmizade(id).subscribe({
      next: () => {
        this.notificarAtualizacaoAmizades();
        this.carregarTudo();
      },
      error: () => this.mensagem.set('Não foi possível aceitar a solicitação.'),
    });
  }

  recusar(id: number) {
    this.api.recusarSolicitacaoAmizade(id).subscribe({
      next: () => {
        this.notificarAtualizacaoAmizades();
        this.carregarTudo();
      },
      error: () => this.mensagem.set('Não foi possível recusar a solicitação.'),
    });
  }

  remover(amizade: Amizade) {
    this.api.removerAmigo(this.outroUsuario(amizade).id).subscribe({
      next: () => {
        this.notificarAtualizacaoAmizades();
        this.carregarTudo();
      },
      error: () => this.mensagem.set('Não foi possível remover este amigo.'),
    });
  }

  outroUsuario(amizade: Amizade) {
    const usuarioAtualId = this.autenticacao.usuario()?.id;
    return amizade.solicitante.id === usuarioAtualId ? amizade.solicitado : amizade.solicitante;
  }

  private carregarTudo() {
    this.api.listarAmigos().subscribe({
      next: (resposta) => this.amigos.set(resposta),
      error: () => this.amigos.set([]),
    });
    this.api.listarSolicitacoesRecebidas().subscribe({
      next: (resposta) => this.recebidas.set(resposta),
      error: () => this.recebidas.set([]),
    });
    this.api.listarSolicitacoesEnviadas().subscribe({
      next: (resposta) => this.enviadas.set(resposta),
      error: () => this.enviadas.set([]),
    });
  }

  private notificarAtualizacaoAmizades() {
    window.dispatchEvent(new CustomEvent('hqhub-amizades-atualizadas'));
  }
}

