import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { AutenticacaoService } from './autenticacao.service';

export const revisorCatalogoGuard: CanActivateFn = () => {
  const autenticacao = inject(AutenticacaoService);
  const roteador = inject(Router);

  if (autenticacao.podeRevisarCatalogo()) {
    return true;
  }

  return roteador.parseUrl('/painel');
};
