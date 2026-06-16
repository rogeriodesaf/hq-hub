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
  readonly autenticado = computed(() => !!this.usuarioAtual()?.token);

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
    return this.usuarioAtual()?.token ?? null;
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
