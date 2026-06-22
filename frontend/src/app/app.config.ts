import { provideHttpClient, withInterceptors } from '@angular/common/http';
import {
  APP_INITIALIZER,
  ApplicationConfig,
  provideBrowserGlobalErrorListeners,
  provideZoneChangeDetection,
} from '@angular/core';
import { provideRouter } from '@angular/router';

import { autenticacaoInterceptor } from './core/autenticacao.interceptor';
import { routes } from './app.routes';

function limparServiceWorkersLegados() {
  return async () => {
    if (!('serviceWorker' in navigator)) {
      return;
    }

    const registros = await navigator.serviceWorker.getRegistrations();
    await Promise.all(registros.map((registro) => registro.unregister()));

    if ('caches' in window) {
      const chaves = await caches.keys();
      await Promise.all(chaves.map((chave) => caches.delete(chave)));
    }
  };
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([autenticacaoInterceptor])),
    {
      provide: APP_INITIALIZER,
      useFactory: limparServiceWorkersLegados,
      multi: true,
    },
  ]
};
