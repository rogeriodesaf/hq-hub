import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, switchMap, throwError } from 'rxjs';

import { environment } from '../../environments/environment';
import { AutenticacaoService } from './autenticacao.service';

export const autenticacaoInterceptor: HttpInterceptorFn = (requisicao, proximo) => {
  const autenticacao = inject(AutenticacaoService);
  const urlOriginal = requisicao.url;
  if (environment.apiUrl && urlOriginal.startsWith('/api')) {
    requisicao = requisicao.clone({ url: `${environment.apiUrl}${urlOriginal}` });
  }

  const ehApi = urlOriginal.startsWith('/api/') ||
    (environment.apiUrl && urlOriginal.startsWith(`${environment.apiUrl}/api/`));
  const ehAuth = /\/api\/auth\/(login|renovar|sair|redefinir-senha\/)/.test(requisicao.url);
  if (!ehApi || ehAuth || !autenticacao.autenticado()) return proximo(requisicao);

  return autenticacao.garantirToken().pipe(
    switchMap((token) => {
      const autenticada = token
        ? requisicao.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
        : requisicao;
      return proximo(autenticada).pipe(
        catchError((erro: unknown) => {
          if (!(erro instanceof HttpErrorResponse) || erro.status !== 401 || !token) {
            return throwError(() => erro);
          }
          return autenticacao.garantirToken(true).pipe(
            switchMap((novoToken) => novoToken
              ? proximo(requisicao.clone({ setHeaders: { Authorization: `Bearer ${novoToken}` } }))
              : throwError(() => erro)),
          );
        }),
      );
    }),
  );
};
