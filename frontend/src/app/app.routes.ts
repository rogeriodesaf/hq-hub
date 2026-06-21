import { Routes } from '@angular/router';

import { autenticadoGuard } from './core/autenticado.guard';
import { revisorCatalogoGuard } from './core/perfil.guard';

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
        path: 'perfil',
        loadComponent: () => import('./pages/perfil/perfil.page').then((m) => m.PerfilPage),
      },
      {
        path: 'perfil/:id',
        loadComponent: () => import('./pages/perfil/perfil.page').then((m) => m.PerfilPage),
      },
      {
        path: 'usuario/:id',
        loadComponent: () => import('./pages/perfil-publico/perfil-publico.page').then((m) => m.PerfilPublicoPage),
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
        canActivate: [revisorCatalogoGuard],
        loadComponent: () => import('./pages/conteudos/conteudos.page').then((m) => m.ConteudosPage),
      },
      {
        path: 'importacao',
        canActivate: [revisorCatalogoGuard],
        loadComponent: () => import('./pages/importacao/importacao.page').then((m) => m.ImportacaoPage),
      },
      {
        path: 'revisao',
        canActivate: [revisorCatalogoGuard],
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
        path: 'mensagens',
        loadComponent: () => import('./pages/mensagens/mensagens.page').then((m) => m.MensagensPage),
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
