import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';

import { AutenticacaoService } from './autenticacao.service';

export const autenticadoGuard: CanActivateFn = () => {
  const autenticacaoService = inject(AutenticacaoService);
  const roteador = inject(Router);

  if (autenticacaoService.autenticado()) {
    return true;
  }

  return roteador.createUrlTree(['/entrar']);
};
