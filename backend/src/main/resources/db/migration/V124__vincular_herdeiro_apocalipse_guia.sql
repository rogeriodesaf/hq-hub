-- Vincula a edição Panini já cadastrada de X-Men: O Herdeiro de Apocalipse
-- à entrada canônica da ordem mutante e mantém a capa oficial como fallback.

WITH candidatos AS (
    SELECT
        edicao.id AS edicao_id,
        row_number() OVER (
            ORDER BY
                CASE WHEN edicao.id_externo = 'AHEAP001' THEN 0 ELSE 1 END,
                edicao.id
        ) AS prioridade
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND lower(trim(serie.titulo)) IN (
          lower('X-Men: O Herdeiro de Apocalipse'),
          lower('X-Men - O Herdeiro de Apocalipse')
      )
      AND coalesce(serie.volume, 1) = 1
      AND (
          edicao.id_externo = 'AHEAP001'
          OR ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '1'
      )
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rqaokb9ao11g3179ko9meved12/-S265-FWEBP'
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 587
  AND candidato.prioridade = 1;

-- Garante a exibição da capa mesmo se o cadastro estiver temporariamente em revisão.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rqaokb9ao11g3179ko9meved12/-S265-FWEBP'
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao = 587;

-- Atualiza a capa da edição correspondente no catálogo quando necessário.
UPDATE edicoes edicao
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rqaokb9ao11g3179ko9meved12/-S265-FWEBP',
    fonte_externa = 'PANINI',
    id_externo = 'AHEAP001',
    url_origem = 'https://panini.com.br/x-men-o-herdeiro-de-apocalipse',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND lower(trim(editora.nome)) = lower('Panini')
  AND lower(trim(serie.titulo)) IN (
      lower('X-Men: O Herdeiro de Apocalipse'),
      lower('X-Men - O Herdeiro de Apocalipse')
  )
  AND coalesce(serie.volume, 1) = 1
  AND (
      edicao.id_externo = 'AHEAP001'
      OR ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '1'
  );
