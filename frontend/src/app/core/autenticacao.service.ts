import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { tap } from 'rxjs';

import { environment } from '../../environments/environment';
import { normalizarUrlMidia } from './midia-url';

import { Usuario, UsuarioAutenticado } from './modelos';

const CHAVE_USUARIO = 'hqhub.usuario';
const AUTH_BASE = '/api/auth';

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
  readonly ehAdministrador = computed(() => this.usuarioAtual()?.perfil === 'ADMINISTRADOR');

  constructor() {
    console.warn('🔐 AutenticacaoService inicializado');
    console.warn('🔐 Usuário salvo no localStorage:', this.usuarioAtual());
    console.warn('🔐 Autenticado?', this.autenticado());
  }

entrar(email: string, senha: string) {
  return this.http.post<UsuarioAutenticado>(`${AUTH_BASE}/login`, { email, senha }).pipe(
    tap((usuario) => {
      console.log('[AUTH] Login recebido:', { email, perfil: usuario.perfil, expiraEm: usuario.expiraEm, tipoToken: usuario.tipoToken });
      console.log('[AUTH] Token completo:', usuario.token);
      const usuarioNormalizado: UsuarioAutenticado = {
        ...usuario,
        token: this.normalizarToken(usuario.token),
        fotoPerfilUrl: this.normalizarUrlMidia(usuario.fotoPerfilUrl),
        fotoPerfilThumbnailUrl: this.normalizarUrlMidia(usuario.fotoPerfilThumbnailUrl),
      };
      console.log('[AUTH] Token normalizado:', usuarioNormalizado.token);
      localStorage.setItem(CHAVE_USUARIO, JSON.stringify(usuarioNormalizado));
      this.usuarioAtual.set(usuarioNormalizado);
      console.log('[AUTH] Sessão válida após login?', this.sessaoValida());
    }),
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
    if (!atual) {
      return;
    }

    const atualizado: UsuarioAutenticado = {
      ...atual,
      nome: usuario.nome,
      email: usuario.email,
      perfil: usuario.perfil,
      bio: usuario.bio,
      fotoPerfilUrl: this.normalizarUrlMidia(usuario.fotoPerfilUrl),
      fotoPerfilThumbnailUrl: this.normalizarUrlMidia(usuario.fotoPerfilThumbnailUrl),
    };
    localStorage.setItem(CHAVE_USUARIO, JSON.stringify(atualizado));
    this.usuarioAtual.set(atualizado);
  }

  sair() {
    localStorage.removeItem(CHAVE_USUARIO);
    this.usuarioAtual.set(null);
  }

  obterToken() {
    const token = this.normalizarToken(this.usuarioAtual()?.token);
    const valida = this.sessaoValida();
    console.log('[AUTH] obterToken:', { temToken: !!token, sessaoValida: valida });
    if (!token || !valida) {
      console.log('[AUTH] Token ou sessão inválidos, fazendo logout');
      this.sair();
      return null;
    }

    return token;
  }

  private sessaoValida() {
    const token = this.normalizarToken(this.usuarioAtual()?.token);
    if (!token) {
      console.log('[AUTH] sessaoValida: token vazio');
      return false;
    }

    const payload = this.lerPayloadToken(token);
    console.log('[AUTH] sessaoValida - payload:', payload);
    const exp = payload?.exp ? Number(payload.exp) : NaN;
    const agora = Math.floor(Date.now() / 1000);
    console.log('[AUTH] sessaoValida - exp:', exp, 'agora:', agora, 'válido?', exp > agora);
    if (!Number.isFinite(exp)) {
      console.log('[AUTH] exp não é número válido');
      return false;
    }

    const agoraEmSegundos = Math.floor(Date.now() / 1000);
    return exp > agoraEmSegundos;
  }

  private lerPayloadToken(token: string): { exp?: number | string } | null {
    const partes = token.split('.');
    if (partes.length < 2) {
      return null;
    }

    try {
      const base64Url = partes[1].replace(/-/g, '+').replace(/_/g, '/');
      const paddingNecessario = (4 - (base64Url.length % 4)) % 4;
      const base64 = base64Url + '='.repeat(paddingNecessario);
      const conteudo = atob(base64);
      return JSON.parse(conteudo) as { exp?: number | string };
    } catch {
      return null;
    }
  }

  private normalizarToken(token: string | null | undefined): string {
    if (!token) {
      console.warn('🔐 normalizarToken: token vazio');
      return '';
    }

    const normalizado = token.replace(/^Bearer\s+/i, '').trim();
    console.warn('🔐 normalizarToken:', { original: token.substring(0, 30), normalizado: normalizado.substring(0, 30) });
    return normalizado;
  }

  private lerUsuarioSalvo(): UsuarioAutenticado | null {
    const salvo = localStorage.getItem(CHAVE_USUARIO);
    console.warn('🔐 lerUsuarioSalvo:', { chaveBuscada: CHAVE_USUARIO, encontrado: !!salvo, conteudo: salvo?.substring(0, 100) });
    if (!salvo) {
      console.warn('🔐 Nenhum usuário salvo no localStorage');
      return null;
    }

    try {
      const usuario = JSON.parse(salvo) as UsuarioAutenticado;
      const usuarioNormalizado: UsuarioAutenticado = {
        ...usuario,
        fotoPerfilUrl: this.normalizarUrlMidia(usuario.fotoPerfilUrl),
        fotoPerfilThumbnailUrl: this.normalizarUrlMidia(usuario.fotoPerfilThumbnailUrl),
      };
      localStorage.setItem(CHAVE_USUARIO, JSON.stringify(usuarioNormalizado));
      console.warn('🔐 Usuário recuperado:', { email: usuario.email, perfil: usuario.perfil, temToken: !!usuario.token });
      return usuarioNormalizado;
    } catch (erro) {
      console.error('🔐 Erro ao parsear usuário salvo:', erro);
      localStorage.removeItem(CHAVE_USUARIO);
      return null;
    }
  }

  private normalizarUrlMidia(url: string | null | undefined): string | null {
    return normalizarUrlMidia(url);
  }
}

function injectHttpClient() {
  return inject(HttpClient);
}
