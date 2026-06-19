import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { tap } from 'rxjs';

import { UsuarioAutenticado } from './modelos';

const CHAVE_USUARIO = 'hqhub.usuario';

@Injectable({ providedIn: 'root' })
export class AutenticacaoService {
  private readonly http = injectHttpClient();
  private readonly usuarioAtual = signal<UsuarioAutenticado | null>(this.lerUsuarioSalvo());

  readonly usuario = this.usuarioAtual.asReadonly();
  readonly autenticado = computed(() => this.sessaoValida());

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
