# Capas do guia cronológico do Batman — 2026-09-05

Levantamento da API pública: 120 posições, 32 com capa e 88 sem capa.
A migração V357 preenche 80 referências sem alterar títulos, posições, vínculos
com o catálogo, status de identificação ou capas existentes.

Fontes e URLs individuais: `capas-revisadas.json`. Cada imagem foi baixada e
validada como imagem HTTP 200. URLs de placeholder foram rejeitadas. As imagens
JPEG também foram conferidas visualmente em folhas de contato locais.

Critério: publicação correspondente à história. Para sagas divididas, a primeira
parte serve como referência visual, sem afirmar que contém a saga completa.
Batman: Padrões Sombrios e Batman & Robin: Ano Um usam capas oficiais de pré-venda.
Espantalho: Ano Um e Duas-Caras: Ano Um compartilham a capa do encadernado que
reúne as duas histórias. O Último Arkham usa A Saga do Batman V1 #30, conforme
a escolha anterior do usuário (a referência está atualmente na posição 58).

## Oito pendências preservadas

| Posição | Título | Pendência |
| --- | --- | --- |
| 19 | Batman: Contos | Distinguir Contos por Tim Sale de outras coletâneas. |
| 68 | Batman: Caminho para a Terra de Ninguém | Confirmar publicação brasileira que representa o prelúdio, não a saga principal. |
| 71 | Batman: Nova Gotham | Definir volume/publicação brasileira da fase. |
| 78 | Batman: Consequências | Título sem edição identificada com segurança. |
| 84 | Batwoman | O próprio guia indica que falta definir volume/fase. |
| 95 | Robin Vermelho | Confirmar publicação brasileira e volume da fase indicada. |
| 97 | Batman & Robin | O próprio guia indica que falta definir edição brasileira. |
| 116 | Batman — Cavaleiro das Trevas, volume 1 | Distinguir série dos Novos 52 da obra de Frank Miller. |

## Verificação

`testar_migracao_capas_batman.cjs` executa o SQL real em PostgreSQL/PGlite, usando
a função de normalização da V55 e os dados do snapshot `antes.json`. Confere 80
alterações, idempotência e preservação de posições, títulos, vínculos e imagens
anteriores. Também testa proteções contra outro guia, título divergente, edição
vinculada e capa já cadastrada. Não se trata de execução contra o banco de produção.

As folhas de contato são artefatos locais de conferência, não imagens do catálogo.
