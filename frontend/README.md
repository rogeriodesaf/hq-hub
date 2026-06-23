# HQ-HUB Frontend

Aplicação Angular standalone para o HQ-HUB, com layout responsivo e suporte a PWA.

## Requisitos

- Node.js 24 ou superior
- Backend rodando em `http://localhost:8080`

## Rodar em desenvolvimento

```bash
npm install
npm start
```

Acesse:

```text
http://localhost:4200
```

O frontend usa `proxy.conf.json` para encaminhar `/api` para o backend Quarkus.

## Build de produção

```bash
npm run build
```

Os arquivos ficam em:

```text
dist/frontend/browser
```

## Deploy no Render

Para funcionar como SPA Angular (rotas diretas como /painel), use Render Static Site com fallback para /index.html.

Arquivos de deploy usados no projeto:

- ../../render.yaml (blueprint na raiz do repositório)
- render.yaml (configuração equivalente para uso local da pasta frontend)
- public/_redirects (fallback complementar de rota)

Pontos obrigatórios:

- Build Command: npm install && npm run build
- Publish Directory: dist/frontend/browser
- Rewrite de SPA: /* -> /index.html

## PWA

O PWA é habilitado no build de produção. Para testar instalação no celular, publique ou sirva o conteúdo de `dist/frontend/browser` por HTTPS. Em ambiente local, navegadores também aceitam PWA em `localhost`.

Arquivos principais:

- `public/manifest.webmanifest`
- `ngsw-config.json`
- `public/assets/icone-hqhub.svg`

## Telas implementadas

- Login e cadastro
- Painel da coleção
- Busca externa ComicVine por volumes
- Listagem de edições de um volume em ordem cronológica
- Catálogo interno
- Estante da coleção
- Compras planejadas
- Assistente
