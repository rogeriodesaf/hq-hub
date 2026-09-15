-- Capa do encadernado Panini de 2019, sem confundir com a edicao Abril de 1989.
WITH edicao_alvo AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND coalesce(serie.volume, 1) = 1
      AND coalesce(serie.ano_inicio, 2019) = 2019
      AND (
          hqhub_normalizar_titulo_serie(serie.titulo) =
              hqhub_normalizar_titulo_serie('Batman: As Dez Noites da Besta e Outras Historias')
          OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) =
              hqhub_normalizar_titulo_serie('Batman: As Dez Noites da Besta e Outras Historias')
      )
      AND hqhub_normalizar_identidade(edicao.numero) IN (
          hqhub_normalizar_identidade('1'),
          hqhub_normalizar_identidade('UNICA')
      )
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE edicoes edicao
SET url_capa = 'https://rika.vteximg.com.br/arquivos/ids/345846/Batman-As-Dez-Noites-da-Besta-e-Outras-Historias.jpg?v=637235313677370000',
    fonte_externa = 'RIKA',
    id_externo = coalesce(edicao.id_externo, '9788583684039'),
    url_origem = 'https://www.rika.com.br/batman---as-dez-noites-da-besta-e-outras-historias-15007390/p',
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicao_alvo alvo
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Batman: As Dez Noites da Besta e Outras Historias')
  AND edicao.url_capa IS NOT NULL;
