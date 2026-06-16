import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { AutenticacaoService } from '../../core/autenticacao.service';
import { ApiService } from '../../core/api.service';
import { Amizade, Usuario } from '../../core/modelos';

@Component({
  selector: 'app-amigos-page',
  imports: [CommonModule, FormsModule],
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

      <form class="formulario-inline" (ngSubmit)="enviarConvite()">
        <label>
          ID do usuário
          <input type="number" min="1" [(ngModel)]="usuarioSolicitadoId" name="usuarioSolicitadoId" />
        </label>
        <button class="botao primario" type="submit" [disabled]="enviandoConvite()">
          {{ enviandoConvite() ? 'Enviando...' : 'Enviar convite' }}
        </button>
      </form>

      @if (usuariosFiltrados().length) {
        <div class="lista-escolha usuarios-escolha">
          @for (usuario of usuariosFiltrados(); track usuario.id) {
            <button type="button" (click)="selecionarUsuario(usuario)">
              <strong>{{ usuario.nome }}</strong>
              <span>#{{ usuario.id }} · {{ usuario.email }}</span>
            </button>
          }
        </div>
      }

      @if (mensagem()) {
        <p class="mensagem-erro">{{ mensagem() }}</p>
      }
    </section>

    <section class="amizades-layout">
      <article class="bloco">
        <div class="secao-titulo">
          <h2>Solicitações recebidas</h2>
          <span>{{ recebidas().length }}</span>
        </div>
        <div class="lista-amizades">
          @for (amizade of recebidas(); track amizade.id) {
            <div>
              <strong>{{ amizade.solicitante.nome }}</strong>
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
              <strong>{{ outroUsuario(amizade).nome }}</strong>
              <span>{{ outroUsuario(amizade).email }}</span>
              <button class="botao compacto" type="button" (click)="remover(amizade)">Remover</button>
            </div>
          } @empty {
            <p class="texto-suave">Você ainda não adicionou amigos.</p>
          }
        </div>
      </article>
    </section>
  `,
})
export class AmigosPage implements OnInit {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);

  readonly usuarios = signal<Usuario[]>([]);
  readonly usuariosFiltrados = signal<Usuario[]>([]);
  readonly amigos = signal<Amizade[]>([]);
  readonly recebidas = signal<Amizade[]>([]);
  readonly enviadas = signal<Amizade[]>([]);
  readonly mensagem = signal('');
  readonly enviandoConvite = signal(false);

  buscaUsuario = '';
  usuarioSolicitadoId: number | null = null;

  ngOnInit() {
    this.carregarTudo();
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

  selecionarUsuario(usuario: Usuario) {
    this.usuarioSolicitadoId = usuario.id;
    this.mensagem.set(`Usuário selecionado: ${usuario.nome}.`);
  }

  enviarConvite() {
    if (!this.usuarioSolicitadoId) {
      this.mensagem.set('Informe ou escolha o ID do usuário.');
      return;
    }

    this.enviandoConvite.set(true);
    this.api.enviarSolicitacaoAmizade(this.usuarioSolicitadoId).subscribe({
      next: () => {
        this.enviandoConvite.set(false);
        this.usuarioSolicitadoId = null;
        this.buscaUsuario = '';
        this.usuariosFiltrados.set([]);
        this.mensagem.set('Convite enviado.');
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
      next: () => this.carregarTudo(),
      error: () => this.mensagem.set('Não foi possível aceitar a solicitação.'),
    });
  }

  recusar(id: number) {
    this.api.recusarSolicitacaoAmizade(id).subscribe({
      next: () => this.carregarTudo(),
      error: () => this.mensagem.set('Não foi possível recusar a solicitação.'),
    });
  }

  remover(amizade: Amizade) {
    this.api.removerAmigo(this.outroUsuario(amizade).id).subscribe({
      next: () => this.carregarTudo(),
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
}
