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
        path: 'conteudos',
        loadComponent: () => import('./pages/conteudos/conteudos.page').then((m) => m.ConteudosPage),
      },
      {
        path: 'importacao',
        loadComponent: () => import('./pages/importacao/importacao.page').then((m) => m.ImportacaoPage),
      },
      {
        path: 'revisao',
        loadComponent: () => import('./pages/revisao/revisao.page').then((m) => m.RevisaoPage),
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
        path: 'anuncios',
        loadComponent: () => import('./pages/anuncios/anuncios.page').then((m) => m.AnunciosPage),
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
