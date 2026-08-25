-- Atualiza Biblioteca Will Eisner com as capas da 2a edicao publicadas pela Devir.

UPDATE series serie
SET descricao = 'Colecao em dois volumes que reune graphic novels de Will Eisner.',
    ano_inicio = 2019,
    ano_fim = 2020,
    fonte_externa = 'DEVIR',
    id_externo = 'DEV111639-DEV111640',
    url_origem = 'https://lojaeditora.devir.com.br/index.php?route=product/search&search=Biblioteca%20Eisner',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Biblioteca Will Eisner');

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Biblioteca Will Eisner')
    ORDER BY serie.id LIMIT 1
), capas(numero, titulo, data_publicacao, url_capa, sku, url_origem) AS (
    VALUES
        ('1', 'Biblioteca Will Eisner: Um Contrato com Deus',
         DATE '2019-10-01',
         'https://lojaeditora.devir.com.br/image/cache/catalog/produtos/DEV111639-400x600.jpg',
         'DEV111639',
         'https://lojaeditora.devir.com.br/DEV111639'),
        ('2', 'Biblioteca Will Eisner: O Milagre da Vida',
         DATE '2020-06-01',
         'https://lojaeditora.devir.com.br/image/cache/catalog/produtos/DEV111640-400x600.jpg',
         'DEV111640',
         'https://lojaeditora.devir.com.br/quadrinhos/DEV111640')
)
INSERT INTO edicoes (numero, titulo, descricao, data_publicacao, url_capa, formato,
                     fonte_externa, id_externo, url_origem, serie_id,
                     data_criacao, data_atualizacao)
SELECT capa.numero, capa.titulo,
       'Edicao brasileira da Biblioteca Will Eisner publicada pela Devir.',
       capa.data_publicacao, capa.url_capa,
       '19 x 26 cm, preto e branco, 2a edicao',
       'DEVIR', capa.sku, capa.url_origem,
       serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
