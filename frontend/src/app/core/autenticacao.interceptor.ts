import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';

import { AutenticacaoService } from './autenticacao.service';

export const autenticacaoInterceptor: HttpInterceptorFn = (requisicao, proximo) => {
  const token = inject(AutenticacaoService).obterToken();

  if (!token) {
    return proximo(requisicao);
  }

  return proximo(
    requisicao.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
      },
    }),
  );
};
