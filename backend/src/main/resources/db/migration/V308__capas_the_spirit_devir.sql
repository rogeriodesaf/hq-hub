-- Cadastra a serie brasileira The Spirit (Acme/Devir, 1994-1995) e suas oito edicoes.
-- As capas foram conferidas em exemplares brasileiros, sem uso do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Devir', 'Editora brasileira de quadrinhos e jogos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
                    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao)
SELECT 'The Spirit',
       'Serie brasileira de historias classicas de The Spirit, publicada em coedicao pela Acme e Devir.',
       1994, 1995, 1, 'ACME_DEVIR', 'THE-SPIRIT-ACME-DEVIR-1994',
       'https://www.comix.com.br/colec-o-general-the-spirit-will-eisner-devir-acme.html',
       editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
  AND NOT EXISTS (
      SELECT 1 FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'devir%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) = hqhub_normalizar_titulo_serie('The Spirit')
        AND COALESCE(existente.volume, 0) = 1
  )
ORDER BY editora.id LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo)) DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('The Spirit')
      AND COALESCE(serie.volume, 0) = 1
    ORDER BY serie.id LIMIT 1
), capas(numero, data_publicacao, url_capa, id_externo, url_origem) AS (
    VALUES
        ('1', DATE '1994-11-01',
         'https://bdportugal.com/Comics/bazar/image_leaf/2016/03/2016031515405300001.jpeg',
         'THE-SPIRIT-ACME-DEVIR-01', 'https://bdportugal.com/Comics/bazar/_S.html'),
        ('2', DATE '1994-12-01',
         'https://static.estantevirtual.com.br/book/00/J49-6955-000/J49-6955-000_detail1.jpg',
         'THE-SPIRIT-ACME-DEVIR-02', 'https://www.estantevirtual.com.br/busca?q=Revista%20General%20Apresenta%20The%20Spirit%20N%C2%BA%202'),
        ('3', DATE '1995-01-01',
         'https://hqhub-backend.onrender.com/capas/the-spirit-devir/the-spirit-3.jpg',
         'THE-SPIRIT-ACME-DEVIR-03', 'https://rutube.ru/video/3778639f009f684639369c5d0b79abe2/'),
        ('4', DATE '1995-02-01',
         'https://hqhub-backend.onrender.com/capas/the-spirit-devir/the-spirit-4.jpg',
         'THE-SPIRIT-ACME-DEVIR-04', 'https://rutube.ru/video/3778639f009f684639369c5d0b79abe2/'),
        ('5', DATE '1995-03-01',
         'https://hqhub-backend.onrender.com/capas/the-spirit-devir/the-spirit-5.jpg',
         'THE-SPIRIT-ACME-DEVIR-05', 'https://rutube.ru/video/3778639f009f684639369c5d0b79abe2/'),
        ('6', DATE '1995-04-01',
         'https://hqhub-backend.onrender.com/capas/the-spirit-devir/the-spirit-6.jpg',
         'THE-SPIRIT-ACME-DEVIR-06', 'https://rutube.ru/video/3778639f009f684639369c5d0b79abe2/'),
        ('7', DATE '1995-05-01',
         'https://bdportugal.com/Comics/bazar/image_leaf/2016/03/2016031515313200001.jpeg',
         'THE-SPIRIT-ACME-DEVIR-07', 'https://bdportugal.com/Comics/bazar/_S.html'),
        ('8', DATE '1995-06-01',
         'https://hqhub-backend.onrender.com/capas/the-spirit-devir/the-spirit-8.jpg',
         'THE-SPIRIT-ACME-DEVIR-08', 'https://rutube.ru/video/3778639f009f684639369c5d0b79abe2/')
)
INSERT INTO edicoes (numero, titulo, descricao, data_publicacao, url_capa, formato,
                     fonte_externa, id_externo, url_origem, serie_id,
                     data_criacao, data_atualizacao)
SELECT capa.numero, 'The Spirit #' || capa.numero,
       'Edicao brasileira publicada em coedicao pela Acme e Devir.',
       capa.data_publicacao, capa.url_capa, '28 paginas, colorido e preto e branco, brochura',
       'ACME_DEVIR', capa.id_externo, capa.url_origem,
       serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
