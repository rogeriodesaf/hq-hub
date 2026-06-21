import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { PerfilFeedComponent } from '../../shared/perfil-feed.component';
import { Usuario, UsuarioAutenticado } from '../../core/modelos';

@Component({
  selector: 'app-perfil-page',
  standalone: true,
  imports: [CommonModule, RouterLink, PerfilFeedComponent],
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
  readonly mensagem = signal('');
  perfilNome = '';
  perfilBio = '';

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
