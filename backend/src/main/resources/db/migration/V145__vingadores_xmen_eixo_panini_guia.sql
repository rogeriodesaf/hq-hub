-- Cadastra a minisserie Vingadores & X-Men: Eixo (Panini, 2015-2016),
-- adiciona as tres capas brasileiras e vincula as edicoes ao guia mutante.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Vingadores & X-Men: Eixo',
    'Minisserie brasileira da Panini que publicou Avengers & X-Men: Axis em tres edicoes.',
    2015,
    2016,
    1,
    'COMIC_VINE',
    '160036',
    'https://comicvine.gamespot.com/vingadores-and-x-men-eixo/4050-160036/',
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

WITH capas(numero, url_capa, url_origem) AS (VALUES
    (1, 'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/p/a/panini_vingaseixoo.jpg', 'https://www.comix.com.br/vingadores-e-x-men-eixo-n-01.html'),
    (2, 'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/p/a/panini_xmeneixo2.jpg', 'https://www.comix.com.br/vingadores-e-x-men-eixo-n-02.html'),
    (3, 'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/p/a/panini_eixovingasxmen3.jpg', 'https://www.comix.com.br/vingadores-e-x-men-eixo-n-03.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Vingadores & X-Men: Eixo')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero::text,
    'Vingadores & X-Men: Eixo Vol. ' || capa.numero::text,
    capa.url_capa,
    'COMIX',
    'COMIX-VINGADORES-X-MEN-EIXO-' || lpad(capa.numero::text, 2, '0'),
    capa.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH vinculos(posicao, numero) AS (VALUES
    (272, '1'), (273, '2'), (277, '3')
), candidatos AS (
    SELECT vinculo.posicao, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON trim(edicao.numero) = vinculo.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Vingadores & X-Men: Eixo')
      AND coalesce(serie.volume, 0) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
