# Base Editorial + Web Scraping (RAG Híbrido) - HQ-HUB Assistente

## Visão Geral

O assistente agora suporta **RAG (Retrieval-Augmented Generation) híbrido**: além de responder sobre sua coleção pessoal (sistema HQ-HUB), ele também consulta uma **base editorial de conhecimento** sobre quadrinhos que pode ser alimentada manualmente ou via scraping de Comic Vine.

## Arquitetura

```
Pergunta do Usuário
        ↓
[Classificação de Intenção]
        ├→ Sistema HQ-HUB (faltantes, completude, compras, etc.)
        │   └→ Consultar banco local
        └→ Conhecimento Editorial (arcos, autores, curiosidades, etc.)
            └→ Buscar em Base Editorial + Web Scraping
        ↓
[Ordenar por Relevância]
        ↓
Resposta com Fonte
```

## Como Alimentar a Base Editorial

### Opção 1: Manual (via API)

Cadastre conhecimentos manualmente:

```bash
curl -X POST http://localhost:8080/api/conhecimentos-editoriais \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "SAGA",
    "titulo": "Saga do Batman - Asilo de Arkham",
    "conteudo": "Clássica trilogia que inclui os arcos mais famosos do Batman.",
    "fonte": "DC Comics Oficial",
    "urlFonte": "https://www.dccomics.com/batman",
    "confianca": "OFICIAL",
    "origemDados": "MANUAL",
    "tags": "batman,saga,clássico"
  }'
```

### Opção 2: Web Scraping do Comic Vine

Importe automaticamente do Comic Vine:

```bash
# Importar série
curl -X POST http://localhost:8080/api/conhecimentos-editoriais/scraping/serie/Batman \
  -H "Authorization: Bearer $TOKEN"

# Importar personagem
curl -X POST http://localhost:8080/api/conhecimentos-editoriais/scraping/personagem/Batman \
  -H "Authorization: Bearer $TOKEN"

# Importar criador
curl -X POST http://localhost:8080/api/conhecimentos-editoriais/scraping/criador/Frank%20Miller \
  -H "Authorization: Bearer $TOKEN"
```

**Pré-requisito:** Configurar a chave de API do Comic Vine como variável de ambiente:
```bash
export COMIC_VINE_API_KEY=sua_chave_aqui
```

## Tipos de Conhecimento Suportados

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| **SAGA** | Coleção de arcos relacionados | Saga do Batman, X-Men |
| **HEROI** | Personagem protagonista | Batman, Superman |
| **AUTOR** | Roteirista, desenhista ou criador | Frank Miller, Alan Moore |
| **ARCO** | Storyline específica | A Morte do Superman |
| **CURIOSIDADE** | Fato interessante | Primeira aparição, prêmios |

## Níveis de Confiança

| Nível | Descrição | Multiplicador de Relevância |
|-------|-----------|---------------------------|
| **VERIFICADA** | Revisado e validado | x1.5 |
| **OFICIAL** | Fonte oficial (DC, Marvel, etc.) | x1.3 |
| **COMUNITARIA** | Comunidade ou wiki | x0.8 |

A relevância também sofre penalidade se a origem for SCRAPING (-10%).

## Exemplos de Perguntas

### Pergunta sobre Curosidade
```
"Qual é a história por trás do Batman?"
→ Busca na base editorial por conteúdo relevante
→ Retorna com fonte + nível de confiança
```

### Pergunta sobre Arcos
```
"Quantos arcos famosos tem a Saga do Batman?"
→ Busca por titulo ou tags contendo "batman"
→ Conta arcos cadastrados
→ Responde com fontes
```

### Pergunta sobre Autor
```
"Quem é Frank Miller e quais suas obras?"
→ Busca tipo AUTOR
→ Retorna biografia e obras
→ Cita Comic Vine como fonte
```

### Pergunta Sistema + Conhecimento
```
"A Saga do Batman que tenho está completa?"
→ Primeiro tenta interpretar como pergunta do sistema
→ Se não encontrar na coleção, consulta base editorial
→ Responde com contexto híbrido
```

## Algoritmo de Relevância

```
Score = 0

if (titulo contains pergunta) Score += 10
if (conteudo contains pergunta) Score += 5
if (tags contains pergunta) Score += 5

switch (confianca):
  case "VERIFICADA": Score *= 1.5
  case "OFICIAL": Score *= 1.3
  case "COMUNITARIA": Score *= 0.8

if (origem == "SCRAPING") Score *= 0.9

// Ordena descendente, retorna top 5
```

## Fluxo da Resposta

1. **Pergunta chega ao backend**
2. **ClassificadorIntencao** detecta se é sistema ou conhecimento
3. **Se sistema:** consulta banco local (faltantes, compras, etc.)
4. **Se conhecimento:** busca na base editorial com RAG
5. **Calcula relevância** de cada resultado
6. **Retorna resposta** com:
   - Conteúdo principal
   - Fonte (URL + nome)
   - Nível de confiança (emoji)
   - Lista completa de resultados (para UI mostrar alternativas)

## Exemplo de Resposta

```json
{
  "resposta": "A Saga do Batman é uma coleção épica de graphic novels que inclui os arcos mais memoráveis do personagem.\n\n📌 Fonte: DC Comics Oficial - https://www.dccomics.com/batman\n🎯 Confiança: OFICIAL",
  "origem": "CONHECIMENTO_EDITORIAL",
  "dados": [
    {
      "id": 1,
      "tipo": "SAGA",
      "titulo": "Saga do Batman - Asilo de Arkham",
      "conteudo": "...",
      "fonte": "DC Comics Oficial",
      "urlFonte": "https://www.dccomics.com/batman",
      "confianca": "OFICIAL",
      "relevancia": 10.2
    }
  ]
}
```

## Configuração Comic Vine API

### Obter API Key

1. Acesse https://comicvine.gamespot.com/api/
2. Faça login ou crie conta
3. Copie sua API Key

### Variável de Ambiente

```bash
# Linux/Mac
export COMIC_VINE_API_KEY=sua_chave_aqui

# Windows
set COMIC_VINE_API_KEY=sua_chave_aqui

# Docker Compose
environment:
  - COMIC_VINE_API_KEY=sua_chave_aqui
```

## Endpoints da API

### Criar Conhecimento
```
POST /api/conhecimentos-editoriais
```

### Buscar por Pergunta
```
GET /api/conhecimentos-editoriais/buscar?q=texto
```

### Buscar por Tipo
```
GET /api/conhecimentos-editoriais/tipo/{tipo}
```

### Scraping (Manual Trigger)
```
POST /api/conhecimentos-editoriais/scraping/serie/{nome}
POST /api/conhecimentos-editoriais/scraping/personagem/{nome}
POST /api/conhecimentos-editoriais/scraping/criador/{nome}
```

## Boas Práticas

1. **Começar manual:** Cadastre conhecimentos que você realmente domina
2. **Adicionar fonte:** Sempre preencha fonte e URL origem
3. **Revisão antes de scraping:** Valide dados importados do Comic Vine
4. **Atualizar regularmente:** Mantenha base editorial atualizada
5. **Usar tags:** Facilita busca semântica posterior

## Próximos Passos

- [ ] Integração com Elasticsearch para busca mais rápida
- [ ] Import automático agendado (cron job)
- [ ] Validação de duplicatas antes de inserir
- [ ] UI de admin para gerenciar base editorial
- [ ] Métricas: quais perguntas mais procuram
- [ ] Feedback do usuário: avaliação de respostas
