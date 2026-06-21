import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { tap } from 'rxjs';

import { Usuario, UsuarioAutenticado } from './modelos';

const CHAVE_USUARIO = 'hqhub.usuario';

@Injectable({ providedIn: 'root' })
export class AutenticacaoService {
  private readonly http = injectHttpClient();
  private readonly usuarioAtual = signal<UsuarioAutenticado | null>(this.lerUsuarioSalvo());

  readonly usuario = this.usuarioAtual.asReadonly();
  readonly autenticado = computed(() => this.sessaoValida());
  readonly podeRevisarCatalogo = computed(() => {
    const perfil = this.usuarioAtual()?.perfil;
    return perfil === 'COLABORADOR' || perfil === 'ADMINISTRADOR';
  });

  entrar(email: string, senha: string) {
    return this.http.post<UsuarioAutenticado>('/api/auth/login', { email, senha }).pipe(
      tap((usuario) => {
        localStorage.setItem(CHAVE_USUARIO, JSON.stringify(usuario));
        this.usuarioAtual.set(usuario);
      }),
    );
  }

  cadastrar(nome: string, email: string, senha: string) {
    return this.http.post('/api/usuarios', { nome, email, senha });
  }

  solicitarRedefinicaoSenha(email: string) {
    return this.http.post('/api/auth/redefinir-senha/solicitar', { email });
  }

  redefinirSenha(token: string, novaSenha: string) {
    return this.http.post('/api/auth/redefinir-senha/confirmar', { token, novaSenha });
  }

  atualizarPerfilLocal(usuario: Usuario) {
    const atual = this.usuarioAtual();
    if (!atual) {
      return;
    }

    const atualizado: UsuarioAutenticado = {
      ...atual,
      nome: usuario.nome,
      email: usuario.email,
      perfil: usuario.perfil,
      bio: usuario.bio,
      fotoPerfilUrl: usuario.fotoPerfilUrl,
      fotoPerfilThumbnailUrl: usuario.fotoPerfilThumbnailUrl,
    };
    localStorage.setItem(CHAVE_USUARIO, JSON.stringify(atualizado));
    this.usuarioAtual.set(atualizado);
  }

  sair() {
    localStorage.removeItem(CHAVE_USUARIO);
    this.usuarioAtual.set(null);
  }

  obterToken() {
    if (!this.sessaoValida()) {
      this.sair();
      return null;
    }

    return this.usuarioAtual()?.token ?? null;
  }

  private sessaoValida() {
    const usuario = this.usuarioAtual();
    if (!usuario?.token) {
      return false;
    }

    const payload = this.lerPayloadToken(usuario.token);
    if (!payload?.exp) {
      return true;
    }

    const agoraEmSegundos = Math.floor(Date.now() / 1000);
    return payload.exp > agoraEmSegundos;
  }

  private lerPayloadToken(token: string): { exp?: number } | null {
    const partes = token.split('.');
    if (partes.length < 2) {
      return null;
    }

    try {
      const base64 = partes[1].replace(/-/g, '+').replace(/_/g, '/');
      const conteudo = atob(base64);
      return JSON.parse(conteudo) as { exp?: number };
    } catch {
      return null;
    }
  }

  private lerUsuarioSalvo(): UsuarioAutenticado | null {
    const salvo = localStorage.getItem(CHAVE_USUARIO);
    if (!salvo) {
      return null;
    }

    try {
      return JSON.parse(salvo) as UsuarioAutenticado;
    } catch {
      localStorage.removeItem(CHAVE_USUARIO);
      return null;
    }
  }
}

function injectHttpClient() {
  return inject(HttpClient);
}
