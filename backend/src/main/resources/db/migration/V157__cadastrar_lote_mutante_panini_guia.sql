-- Cadastra o lote Panini ausente e vincula as 26 referências ao guia mutante.
-- Os registros usam somente identidades confirmadas pelo próprio guia; capas
-- não verificadas permanecem nulas para evitar associar imagens incorretas.

CREATE TEMP TABLE hqhub_lote_mutante_panini (
    posicao INTEGER NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    volume INTEGER NOT NULL,
    numero VARCHAR(50) NOT NULL,
    ano INTEGER NOT NULL
) ON COMMIT DROP;

INSERT INTO hqhub_lote_mutante_panini (posicao, titulo, volume, numero, ano) VALUES
    (387, 'Os Novos Mutantes: Almas Mortas', 1, 'UNICA', 2019),
    (388, 'Os Novos Mutantes: Filhos da Guerra', 1, 'UNICA', 2020),
    (392, 'Império Secreto', 1, 'UNICA', 2023),
    (393, 'X-Men: Império Secreto', 1, 'UNICA', 2018),
    (401, 'Jean Grey', 1, '1', 2018),
    (402, 'Jean Grey', 1, '2', 2019),
    (405, 'Surpreendentes X-Men: A Vida de X', 1, 'UNICA', 2018),
    (406, 'Surpreendentes X-Men: Um Homem Chamado X', 1, 'UNICA', 2019),
    (415, 'Surpreendentes X-Men: Até que Nossos Medos nos Separem', 1, 'UNICA', 2020),
    (426, 'Fabulosos X-Men: A Queda', 1, '1', 2020),
    (427, 'Fabulosos X-Men: A Queda', 1, '2', 2020),
    (434, 'Fabulosos X-Men: Isto é para sempre', 1, 'UNICA', 2020),
    (435, 'Fabulosos X-Men: Sempre fomos', 1, 'UNICA', 2020),
    (436, 'Sr. & Sra. X', 1, 'UNICA', 2020),
    (456, 'Império', 1, '1', 2021),
    (457, 'Império', 1, '2', 2021),
    (459, 'Império', 1, '3', 2021),
    (476, 'A Maldição do Homem-Coisa', 1, 'UNICA', 2022),
    (484, 'Aniquilação Final', 1, 'UNICA', 2022),
    (495, 'Wolverine', 1, '1', 2022),
    (522, 'O Espetacular Homem-Aranha', 1, '13', 2023),
    (523, 'Teia Sombria Especial', 1, 'UNICA', 2023),
    (527, 'Novos Mutantes: A Saga de Sublime', 1, 'UNICA', 2023),
    (529, 'Legião de X', 1, 'UNICA', 2023),
    (556, 'Vozes da Marvel', 1, '4', 2024),
    (588, 'Tempestade', 1, '1', 2025);

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT DISTINCT
    lote.titulo,
    'Publicação brasileira da Panini vinculada ao guia de leitura mutante.',
    min(lote.ano) OVER (PARTITION BY lote.titulo, lote.volume),
    max(lote.ano) OVER (PARTITION BY lote.titulo, lote.volume),
    lote.volume,
    'PANINI',
    'PANINI-GUIA-MUTANTE-' || min(lote.posicao) OVER (PARTITION BY lote.titulo, lote.volume),
    'https://panini.com.br/catalogsearch/result/?q=' || replace(lote.titulo, ' ', '+'),
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM hqhub_lote_mutante_panini lote
CROSS JOIN editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    ano_inicio = LEAST(series.ano_inicio, EXCLUDED.ano_inicio),
    ano_fim = GREATEST(series.ano_fim, EXCLUDED.ano_fim),
    data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO edicoes (
    numero, titulo, nome_volume, data_publicacao, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    lote.numero,
    CASE WHEN lote.numero = 'UNICA' THEN lote.titulo ELSE lote.titulo || ' #' || lote.numero END,
    lote.titulo,
    make_date(lote.ano, 1, 1),
    'PANINI',
    'PANINI-GUIA-MUTANTE-' || lote.posicao,
    'https://panini.com.br/catalogsearch/result/?q=' || replace(lote.titulo, ' ', '+'),
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM hqhub_lote_mutante_panini lote
JOIN editoras editora ON lower(trim(editora.nome)) = 'panini'
JOIN series serie
  ON serie.editora_id = editora.id
 AND serie.volume = lote.volume
 AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(lote.titulo)
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH candidatos AS (
    SELECT lote.posicao, edicao.id AS edicao_id, edicao.url_capa
    FROM hqhub_lote_mutante_panini lote
    JOIN editoras editora ON lower(trim(editora.nome)) = 'panini'
    JOIN series serie
      ON serie.editora_id = editora.id
     AND serie.volume = lote.volume
     AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(lote.titulo)
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(lote.numero)
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(candidato.url_capa, item.url_capa_referencia)
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao;
