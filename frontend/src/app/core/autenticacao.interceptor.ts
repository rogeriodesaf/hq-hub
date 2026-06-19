import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

import { AutenticacaoService } from './autenticacao.service';

export const autenticacaoInterceptor: HttpInterceptorFn = (requisicao, proximo) => {
  const autenticacaoService = inject(AutenticacaoService);
  const roteador = inject(Router);
  const token = autenticacaoService.obterToken();

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
        autenticacaoService.sair();
        roteador.navigateByUrl('/entrar');
      }

      return throwError(() => erro);
    }),
  );
};
