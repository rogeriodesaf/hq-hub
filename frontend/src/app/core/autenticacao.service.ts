import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { Observable, catchError, finalize, map, of, shareReplay, tap } from 'rxjs';

import { normalizarUrlMidia } from './midia-url';
import { Usuario, UsuarioAutenticado } from './modelos';

const CHAVE_USUARIO = 'hqhub.usuario';
const AUTH_BASE = '/api/auth';

@Injectable({ providedIn: 'root' })
export class AutenticacaoService {
  private readonly http = inject(HttpClient);
  private readonly usuarioAtual = signal<UsuarioAutenticado | null>(this.lerUsuarioSalvo());
  private renovacaoEmAndamento: Observable<string | null> | null = null;

  readonly usuario = this.usuarioAtual.asReadonly();
  readonly autenticado = computed(() => !!this.usuarioAtual());
  readonly podeRevisarCatalogo = computed(() => {
    const perfil = this.usuarioAtual()?.perfil;
    return perfil === 'COLABORADOR' || perfil === 'ADMINISTRADOR';
  });
  readonly ehAdministrador = computed(() => this.usuarioAtual()?.perfil === 'ADMINISTRADOR');

  constructor() {
    window.addEventListener('storage', (evento) => {
      if (evento.key === CHAVE_USUARIO) this.usuarioAtual.set(this.lerUsuarioSalvo());
    });
  }

  entrar(email: string, senha: string) {
    return this.http.post<UsuarioAutenticado>(`${AUTH_BASE}/login`, { email, senha }).pipe(
      tap((usuario) => this.salvarUsuario(usuario)),
    );
  }

  cadastrar(nome: string, email: string, senha: string) {
    return this.http.post('/api/usuarios', { nome, email, senha });
  }

  solicitarRedefinicaoSenha(email: string) {
    return this.http.post(`${AUTH_BASE}/redefinir-senha/solicitar`, { email });
  }

  redefinirSenha(token: string, novaSenha: string) {
    return this.http.post(`${AUTH_BASE}/redefinir-senha/confirmar`, { token, novaSenha });
  }

  atualizarPerfilLocal(usuario: Usuario) {
    const atual = this.usuarioAtual();
    if (!atual) return;
    this.salvarUsuario({
      ...atual,
      nome: usuario.nome,
      email: usuario.email,
      perfil: usuario.perfil,
      bio: usuario.bio,
      fotoPerfilUrl: usuario.fotoPerfilUrl,
      fotoPerfilThumbnailUrl: usuario.fotoPerfilThumbnailUrl,
      capaPerfilUrl: usuario.capaPerfilUrl,
    });
  }

  sair() {
    const refreshToken = this.usuarioAtual()?.refreshToken;
    this.limparSessao();
    if (refreshToken) {
      this.http.post(`${AUTH_BASE}/sair`, { refreshToken }).subscribe({ error: () => {} });
    }
  }

  obterToken(): string | null {
    const token = this.normalizarToken(this.usuarioAtual()?.token);
    return this.tokenValido(token) ? token : null;
  }

  garantirToken(forcarRenovacao = false): Observable<string | null> {
    const usuario = this.usuarioAtual();
    if (!usuario) return of(null);
    const token = this.normalizarToken(usuario.token);
    if (!forcarRenovacao && this.tokenValido(token, 60) && usuario.refreshToken) return of(token);
    if (this.renovacaoEmAndamento) return this.renovacaoEmAndamento;

    const refreshToken = usuario.refreshToken;
    if (!refreshToken) {
      this.limparSessao();
      return of(null);
    }
    const chamada = this.http.post<UsuarioAutenticado>(`${AUTH_BASE}/renovar`, { refreshToken });
    this.renovacaoEmAndamento = chamada.pipe(
      map((renovado) => {
        if (this.usuarioAtual()?.refreshToken !== refreshToken) return this.obterToken();
        this.salvarUsuario(renovado);
        return this.normalizarToken(renovado.token);
      }),
      catchError((erro: unknown) => {
        const salvo = this.lerUsuarioSalvo();
        if (salvo?.refreshToken && salvo.refreshToken !== refreshToken &&
            this.tokenValido(this.normalizarToken(salvo.token))) {
          this.usuarioAtual.set(salvo);
          return of(this.normalizarToken(salvo.token));
        }
        if (erro instanceof HttpErrorResponse && [400, 401, 403].includes(erro.status)) {
          this.limparSessao();
        }
        return of(null);
      }),
      finalize(() => { this.renovacaoEmAndamento = null; }),
      shareReplay(1),
    );
    return this.renovacaoEmAndamento;
  }

  private salvarUsuario(usuario: UsuarioAutenticado) {
    const normalizado: UsuarioAutenticado = {
      ...usuario,
      token: this.normalizarToken(usuario.token),
      fotoPerfilUrl: normalizarUrlMidia(usuario.fotoPerfilUrl),
      fotoPerfilThumbnailUrl: normalizarUrlMidia(usuario.fotoPerfilThumbnailUrl),
      capaPerfilUrl: normalizarUrlMidia(usuario.capaPerfilUrl),
    };
    localStorage.setItem(CHAVE_USUARIO, JSON.stringify(normalizado));
    this.usuarioAtual.set(normalizado);
  }

  private limparSessao() {
    localStorage.removeItem(CHAVE_USUARIO);
    this.usuarioAtual.set(null);
  }

  private tokenValido(token: string, margemSegundos = 0): boolean {
    if (!token) return false;
    try {
      const payload = token.split('.')[1];
      if (!payload) return false;
      const base64 = payload.replace(/-/g, '+').replace(/_/g, '/');
      const exp = Number(JSON.parse(atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, '='))).exp);
      return Number.isFinite(exp) && exp > Math.floor(Date.now() / 1000) + margemSegundos;
    } catch {
      return false;
    }
  }

  private normalizarToken(token: string | null | undefined): string {
    return token?.replace(/^Bearer\s+/i, '').trim() ?? '';
  }

  private lerUsuarioSalvo(): UsuarioAutenticado | null {
    try {
      const salvo = localStorage.getItem(CHAVE_USUARIO);
      if (!salvo) return null;
      const usuario = JSON.parse(salvo) as UsuarioAutenticado;
      if (usuario?.refreshToken) return usuario;
      localStorage.removeItem(CHAVE_USUARIO);
      return null;
    } catch {
      localStorage.removeItem(CHAVE_USUARIO);
      return null;
    }
  }
}
