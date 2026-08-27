-- Corrige o link da capa da edição 1 de Druuna, que estava hospedado em fonte instável.

UPDATE edicoes edicao
SET url_capa = 'https://rika.vtexassets.com/arquivos/ids/346441/Druuna-Volume-1.jpg?v=637240514965030000',
    url_origem = 'https://www.rika.com.br/autor-paolo-eleuteri-serpieri',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('1')
  AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Druuna')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
  AND coalesce(serie.volume, 1) = 1;
