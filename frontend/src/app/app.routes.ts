import { Routes } from '@angular/router';

import { autenticadoGuard } from './core/autenticado.guard';

export const routes: Routes = [
  {
    path: 'entrar',
    loadComponent: () => import('./pages/autenticacao/autenticacao.page').then((m) => m.AutenticacaoPage),
  },
  {
    path: '',
    canActivate: [autenticadoGuard],
    children: [
      {
        path: 'painel',
        loadComponent: () => import('./pages/painel/painel.page').then((m) => m.PainelPage),
      },
      {
        path: 'descobrir',
        loadComponent: () => import('./pages/descobrir/descobrir.page').then((m) => m.DescobrirPage),
      },
      {
        path: 'catalogo',
        loadComponent: () => import('./pages/catalogo/catalogo.page').then((m) => m.CatalogoPage),
      },
      {
        path: 'colecao',
        loadComponent: () => import('./pages/colecao/colecao.page').then((m) => m.ColecaoPage),
      },
      {
        path: 'compras',
        loadComponent: () => import('./pages/compras/compras.page').then((m) => m.ComprasPage),
      },
      {
        path: 'amigos',
        loadComponent: () => import('./pages/amigos/amigos.page').then((m) => m.AmigosPage),
      },
      {
        path: 'assistente',
        loadComponent: () => import('./pages/assistente/assistente.page').then((m) => m.AssistentePage),
      },
      {
        path: '',
        pathMatch: 'full',
        redirectTo: 'painel',
      },
    ],
  },
  {
    path: '**',
    redirectTo: 'painel',
  },
];
