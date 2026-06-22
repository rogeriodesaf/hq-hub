import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

import { environment } from '../../environments/environment';
import { AutenticacaoService } from './autenticacao.service';

export const autenticacaoInterceptor: HttpInterceptorFn = (requisicao, proximo) => {
  const autenticacaoService = inject(AutenticacaoService);
  const roteador = inject(Router);

  console.warn('🔗 INTERCEPTOR:', requisicao.method, requisicao.url);

  if (environment.apiUrl && requisicao.url.startsWith('/api')) {
    const novaUrl = `${environment.apiUrl}${requisicao.url}`;
    console.warn('🔗 URL reescrita:', novaUrl);
    requisicao = requisicao.clone({ url: novaUrl });
  }

  const token = autenticacaoService.obterToken();
  console.warn('🔗 Token obtido?', !!token ? 'SIM: ' + token.substring(0, 20) + '...' : 'NÃO');

  const requisicaoAutenticada = token
    ? requisicao.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`,
        },
      })
    : requisicao;

  console.warn('🔗 Headers da requisição:', requisicaoAutenticada.headers.keys());

  return proximo(requisicaoAutenticada).pipe(
    catchError((erro) => {
      console.error('🔗 ERRO:', requisicao.url, erro.status, erro.message);
      if (erro instanceof HttpErrorResponse && erro.status === 401 && !requisicao.url.includes('/auth/login')) {
        console.error('🔗 401 recebido, fazendo logout');
        autenticacaoService.sair();
        roteador.navigateByUrl('/entrar');
      }

      return throwError(() => erro);
    }),
  );
};
