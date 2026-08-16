-- Substitui a capa bloqueada de Fabulosos X-Men Vs. Shield e adiciona as
-- capas Panini Brasil de Vingadores & X-Men: Eixo Especial #1 e #2.
-- Nenhuma imagem desta migração vem do Guia dos Quadrinhos.

UPDATE edicoes
SET url_capa = 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/9/1/91569_900x900540900939001.jpg',
    url_origem = 'https://www.comix.com.br/fabulosos-x-men-vs-shield-capa-dura.html',
    fonte_externa = 'COMIX',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE id = 14369;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 246
  AND edicao.id = 14369
  AND item.edicao_id = edicao.id;

WITH capas(numero, id_comic_vine, url_capa) AS (VALUES
    ('1', '1071451', 'https://comicvine.gamespot.com/a/uploads/scale_large/11/110017/9489673-wwww.jpg'),
    ('2', '1071452', 'https://comicvine.gamespot.com/a/uploads/scale_large/11/110017/9489674-wwww.jpg')
), edicoes_alvo AS (
    SELECT edicao.id, capas.id_comic_vine, capas.url_capa
    FROM capas
    JOIN edicoes edicao ON trim(edicao.numero) = capas.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(serie.titulo) LIKE '%vingadores%'
      AND lower(serie.titulo) LIKE '%x-men%'
      AND lower(serie.titulo) LIKE '%eixo especial%'
      AND serie.volume = 1
      AND lower(trim(editora.nome)) = 'panini'
)
UPDATE edicoes edicao
SET url_capa = alvo.url_capa,
    id_comic_vine = alvo.id_comic_vine,
    url_comic_vine = 'https://comicvine.gamespot.com/vingadores-and-x-men-eixo-especial-'
        || trim(edicao.numero) || '/4000-' || alvo.id_comic_vine || '/',
    fonte_externa = 'COMIC_VINE',
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
WHERE edicao.id = alvo.id;

WITH vinculos(posicao, numero) AS (VALUES
    (275, '1'),
    (276, '2')
), candidatos AS (
    SELECT
        vinculo.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON trim(edicao.numero) = vinculo.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(serie.titulo) LIKE '%vingadores%'
      AND lower(serie.titulo) LIKE '%x-men%'
      AND lower(serie.titulo) LIKE '%eixo especial%'
      AND serie.volume = 1
      AND lower(trim(editora.nome)) = 'panini'
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
