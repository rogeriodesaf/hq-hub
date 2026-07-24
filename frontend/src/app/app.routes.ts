import { Routes } from '@angular/router';

import { autenticadoGuard } from './core/autenticado.guard';
import { revisorCatalogoGuard } from './core/perfil.guard';

export const routes: Routes = [
  {
    path: 'entrar',
    loadComponent: () => import('./pages/autenticacao/autenticacao.page').then((m) => m.AutenticacaoPage),
  },
  {
    path: 'estante-publica/:id',
    loadComponent: () => import('./pages/estante-publica/estante-publica.page').then((m) => m.EstantePublicaPage),
  },
  {
    path: 'compartilhar-estante/:id',
    loadComponent: () => import('./pages/estante-publica/estante-publica.page').then((m) => m.EstantePublicaPage),
  },
  {
    path: 'classificados',
    loadComponent: () => import('./pages/classificados-publicos/classificados-publicos.page').then((m) => m.ClassificadosPublicosPage),
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
        path: 'canais',
        loadComponent: () => import('./pages/canais/canais.page').then((m) => m.CanaisPage),
      },
      {
        path: 'colaboradores',
        loadComponent: () => import('./pages/colaboradores/colaboradores.page').then((m) => m.ColaboradoresPage),
      },
      {
        path: 'apoie',
        loadComponent: () => import('./pages/apoie/apoie.page').then((m) => m.ApoiePage),
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
