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
    path: 'guia-de-leitura/:slug',
    loadComponent: () => import('./pages/ordens-leitura/ordens-leitura.page').then((m) => m.OrdensLeituraPage),
  },
  {
    path: 'guia-de-leitura-app/:slug',
    loadComponent: () => import('./pages/ordens-leitura/ordens-leitura.page').then((m) => m.OrdensLeituraPage),
  },
  {
    path: 'colecao-compartilhada/:id',
    loadComponent: () => import('./pages/colecao-compartilhada/colecao-compartilhada.page').then((m) => m.ColecaoCompartilhadaPage),
  },
  {
    path: 'postagem/:id',
    loadComponent: () => import('./pages/postagem-publica/postagem-publica.page').then((m) => m.PostagemPublicaPage),
  },
  {
    path: 'catalogo',
    loadComponent: () => import('./pages/catalogo/catalogo.page').then((m) => m.CatalogoPage),
  },
  {
    path: 'edicoes/:id',
    loadComponent: () => import('./pages/catalogo/catalogo.page').then((m) => m.CatalogoPage),
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
        pathMatch: 'full',
        redirectTo: 'titulos-estrangeiros',
      },
      {
        path: 'titulos-estrangeiros',
        loadComponent: () => import('./pages/descobrir/descobrir.page').then((m) => m.DescobrirPage),
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
        path: 'ordens-leitura',
        loadComponent: () => import('./pages/ordens-leitura/ordens-leitura.page').then((m) => m.OrdensLeituraPage),
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
        path: 'social',
        loadComponent: () => import('./pages/social/social.page').then((m) => m.SocialPage),
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
