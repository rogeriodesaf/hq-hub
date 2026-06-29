import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { PerfilFeedComponent } from '../../shared/perfil-feed.component';
import { Usuario, UsuarioAutenticado } from '../../core/modelos';

@Component({
  selector: 'app-perfil-page',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, PerfilFeedComponent],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Perfil</p>
        <h1>{{ modo() === 'edicao' ? 'Foto, nome e bio ficam aqui.' : usuarioVisualizacao()?.nome }}</h1>
      </div>
      <a class="botao secundario" routerLink="/painel">Voltar ao feed</a>
    </section>

    <section class="perfil-layout">
      <article class="bloco">
        <app-perfil-feed
          [usuario]="usuarioVisualizacao()"
          [nome]="perfilNome"
          [bio]="perfilBio"
          [salvando]="salvandoPerfil()"
          [modo]="modo()"
          (nomeChange)="perfilNome = $event"
          (bioChange)="perfilBio = $event"
          (fotoSelecionada)="selecionarFotoPerfil($event)"
          (salvar)="salvarPerfil()"
        ></app-perfil-feed>

        @if (mensagem()) {
          <p class="mensagem-erro">{{ mensagem() }}</p>
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
      grid-template-columns: minmax(0, 1fr) 280px;
      gap: 18px;
      align-items: start;
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
  readonly salvandoSenha = signal(false);
  readonly mensagem = signal('');
  readonly mensagemSenha = signal('');
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

    this.salvandoPerfil.set(true);
    this.api.atualizarFotoPerfil(arquivo).subscribe({
      next: (usuario) => {
        this.autenticacao.atualizarPerfilLocal(usuario);
        this.usuarioVisualizacao.set(usuario);
        this.salvandoPerfil.set(false);
        this.mensagem.set('Foto de perfil atualizada.');
      },
      error: (erroResposta) => {
        this.salvandoPerfil.set(false);
        this.mensagem.set(erroResposta?.error?.mensagem || 'Nao foi possivel atualizar a foto.');
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

  private carregarPerfilPropio() {
    this.api.obterMeuPerfil().subscribe({
      next: (usuario) => {
        this.autenticacao.atualizarPerfilLocal(usuario);
        this.usuarioVisualizacao.set(usuario);
        this.perfilNome = usuario.nome;
        this.perfilBio = usuario.bio || '';
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
      },
      error: () => {
        this.mensagem.set('Perfil não encontrado.');
      },
    });
  }
}
