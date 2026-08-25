-- Cria a edicao ausente numero 1 da DC Comics - Colecao de Graphic Novels
-- (Eaglemoss, volume 1): Batman: Silencio - Parte 1.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(serie.titulo) LIKE '%dc comics%'
      AND lower(serie.titulo) LIKE '%graphic novels%'
      AND lower(serie.titulo) NOT LIKE '%sagas definitivas%'
      AND lower(editora.nome) LIKE 'eaglemoss%'
      AND coalesce(serie.volume, 1) = 1
    ORDER BY
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    '1',
    'Batman: Silêncio - Parte 1',
    'Primeiro volume de DC Comics - Coleção de Graphic Novels, publicado pela Eaglemoss.',
    'Volume 1',
    DATE '2014-09-01',
    'https://spider145hqs.wordpress.com/wp-content/uploads/2022/09/dccomics_colecaodegraphicnovels_vol01_eaglemoss_17092022.jpg',
    'SPIDER145',
    'dc-graphic-novels-eaglemoss-1',
    'https://spider145hqs.com/2022/09/18/dc-comics-colecao-de-graphic-novels-volumes-1-a-10/',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
