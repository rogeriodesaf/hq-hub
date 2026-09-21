import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { map } from 'rxjs';

import { AutenticacaoService } from './autenticacao.service';

export const autenticadoGuard: CanActivateFn = () => {
  const autenticacaoService = inject(AutenticacaoService);
  const roteador = inject(Router);

  return autenticacaoService.garantirToken().pipe(
    map((token) => token ? true : roteador.createUrlTree(['/entrar'])),
  );
};
