import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

import { environment } from '../../environments/environment';
import { AutenticacaoService } from './autenticacao.service';

export const autenticacaoInterceptor: HttpInterceptorFn = (requisicao, proximo) => {
  const autenticacaoService = inject(AutenticacaoService);
  const roteador = inject(Router);

  if (environment.apiUrl && requisicao.url.startsWith('/api')) {
    requisicao = requisicao.clone({ url: `${environment.apiUrl}${requisicao.url}` });
  }

  const token = autenticacaoService.obterToken();
  console.log('[INTERCEPTOR]', requisicao.url, '- token:', !!token ? token.substring(0, 20) + '...' : 'nenhum');

  const requisicaoAutenticada = token
    ? requisicao.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`,
        },
      })
    : requisicao;

  return proximo(requisicaoAutenticada).pipe(
    catchError((erro) => {
      if (erro instanceof HttpErrorResponse && erro.status === 401 && !requisicao.url.includes('/auth/login')) {
        console.log('[INTERCEPTOR] 401 recebido, fazendo logout');
        autenticacaoService.sair();
        roteador.navigateByUrl('/entrar');
      }

      return throwError(() => erro);
    }),
  );
};
