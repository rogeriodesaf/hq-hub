-- Aplica a capa de Batman: A Maldicao de Scarface, edicao unica da Mythos.
WITH edicoes_alvo AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Batman: A Maldição de Scarface')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%mythos%'
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_identidade(edicao.numero) IN (
          hqhub_normalizar_identidade('UNICA'),
          hqhub_normalizar_identidade('ÚNICA'),
          hqhub_normalizar_identidade('1')
      )
)
UPDATE edicoes edicao
SET url_capa = 'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?id=21983&path=mythos/b/ba06210000.jpg',
    fonte_externa = 'GUIA_DOS_QUADRINHOS',
    id_externo = '21983',
    url_origem = 'https://www.guiadosquadrinhos.com/edicao/batman-a-maldicao-de-scarface/ba062100/21983',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE edicao.id IN (SELECT id FROM edicoes_alvo);

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Batman: A Maldição de Scarface')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%mythos%'
  AND coalesce(serie.volume, 1) = 1
  AND edicao.url_capa IS NOT NULL;
