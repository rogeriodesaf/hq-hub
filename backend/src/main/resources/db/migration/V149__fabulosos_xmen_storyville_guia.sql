-- Cadastra Fabulosos X-Men: Storyville (Panini, 2019), adiciona sua capa
-- e vincula a edicao unica ao guia mutante.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Fabulosos X-Men: Storyville',
    'Encadernado Panini com Uncanny X-Men 32 a 35 e Uncanny X-Men 600.',
    2019,
    2019,
    1,
    'COMIX',
    'COMIX-FABULOSOS-X-MEN-STORYVILLE',
    'https://www.comix.com.br/fabulosos-x-men-storyville-capa-dura.html',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Fabulosos X-Men: Storyville')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Fabulosos X-Men: Storyville',
    'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/1/0/1000x1000-comix_capa-fabulosos-x-men-storyville.jpg',
    'COMIX',
    'ISBN-9788542619539',
    'https://www.comix.com.br/fabulosos-x-men-storyville-capa-dura.html',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH candidato AS (
    SELECT edicao.id AS edicao_id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Fabulosos X-Men: Storyville')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY
        CASE WHEN lower(trim(edicao.numero)) IN ('única', 'unica', '1') THEN 0 ELSE 1 END,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa,
    detalhe_referencia = 'V1 #UNICA'
FROM candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 282;
