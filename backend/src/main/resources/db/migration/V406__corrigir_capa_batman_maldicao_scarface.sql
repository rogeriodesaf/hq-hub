-- Substitui a URL do Guia, que bloqueia hotlink, por uma capa publica estavel.
WITH edicoes_alvo AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Batman: A Maldição de Scarface')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%mythos%'
)
UPDATE edicoes edicao
SET url_capa = 'https://rika.vtexassets.com/arquivos/ids/240342/-herois_abril_etc-batman-maldicao-scarface.jpg?v=635316706727700000',
    fonte_externa = 'RIKA',
    id_externo = coalesce(edicao.id_externo, '21983'),
    url_origem = 'https://www.rika.com.br/batman---a-maldicao-de-scarface16000069/p',
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
  AND edicao.url_capa IS NOT NULL;
