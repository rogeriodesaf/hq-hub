-- Cadastra O Espetacular Homem-Aranha, 3a serie (Panini, 2016-2019), com 29 edicoes.
-- As capas disponiveis foram obtidas no catalogo da Rika Comic Shop.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
                    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao)
SELECT 'O Espetacular Homem-Aranha, 3ª Série',
       'Serie mensal da Panini publicada de novembro de 2016 a marco de 2019.',
       2016, 2019, 3, 'RIKA', 'ESPETACULAR-3S',
       'https://www.rika.com.br/', editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1 FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 3ª Série')
  )
ORDER BY editora.id LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo)) DO NOTHING;

WITH serie_alvo AS (
    SELECT serie.id FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 3ª Série')
    ORDER BY serie.id LIMIT 1
), capas(numero, data_publicacao, asset_id, url_capa_alternativa) AS (
    VALUES
      ('1',  DATE '2016-11-01', 304545, NULL), ('2',  DATE '2016-12-01', 304546, NULL),
      ('3',  DATE '2017-01-01', 304547, NULL), ('4',  DATE '2017-02-01', 304548, NULL),
      ('5',  DATE '2017-03-01', 304549, NULL), ('6',  DATE '2017-04-01', 304550, NULL),
      ('7',  DATE '2017-05-01', 304551, NULL), ('8',  DATE '2017-06-01', 304552, NULL),
      ('9',  DATE '2017-07-01', 304553, NULL), ('10', DATE '2017-08-01', 304554, NULL),
      ('11', DATE '2017-09-01', 321133, NULL), ('12', DATE '2017-10-01', 304556, NULL),
      ('13', DATE '2017-11-01', 321135, NULL), ('14', DATE '2017-12-01', 304558, NULL),
      ('15', DATE '2018-01-01', 304559, NULL), ('16', DATE '2018-02-01', 304560, NULL),
      ('17', DATE '2018-03-01', 304561, NULL), ('18', DATE '2018-04-01', 332985, NULL),
      ('19', DATE '2018-05-01', 332986, NULL), ('20', DATE '2018-06-01', 332987, NULL),
      ('21', DATE '2018-07-01', NULL, 'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?path=panini/e/es01120021.jpg&w=400'),
      ('22', DATE '2018-08-01', NULL, 'https://www.guiadosquadrinhos.com/edicao/ShowImage.aspx?path=panini/e/es01120022.jpg&w=400'),
      ('23', DATE '2018-09-01', 304567, NULL), ('24', DATE '2018-10-01', 320935, NULL),
      ('25', DATE '2018-11-01', 320936, NULL), ('26', DATE '2018-12-01', 332988, NULL),
      ('27', DATE '2019-01-01', 304571, NULL), ('28', DATE '2019-02-01', 304572, NULL),
      ('29', DATE '2019-03-01', 304573, NULL)
)
INSERT INTO edicoes (numero, titulo, descricao, data_publicacao, url_capa, quantidade_paginas,
                     formato, fonte_externa, id_externo, url_origem, serie_id,
                     data_criacao, data_atualizacao)
SELECT capa.numero,
       'O Espetacular Homem-Aranha #' || capa.numero,
       'Edicao brasileira da terceira serie de O Espetacular Homem-Aranha publicada pela Panini.',
       capa.data_publicacao,
       coalesce('https://rika.vtexassets.com/arquivos/ids/' || capa.asset_id || '/capa.jpg', capa.url_capa_alternativa),
       CASE WHEN capa.numero = '26' THEN 92 ELSE 76 END,
       '17 x 26 cm, colorido, lombada canoa',
       CASE WHEN capa.asset_id IS NULL THEN 'GUIA_DOS_QUADRINHOS' ELSE 'RIKA' END,
       'ESPETACULAR-3S-' || lpad(capa.numero, 2, '0'),
       CASE WHEN capa.asset_id IS NULL
            THEN 'https://www.guiadosquadrinhos.com/capas/espetacular-homem-aranha-o-3-serie/es011200'
            ELSE 'https://www.rika.com.br/' END,
       serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM serie_alvo serie CROSS JOIN capas capa
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = EXCLUDED.titulo, descricao = EXCLUDED.descricao,
    data_publicacao = EXCLUDED.data_publicacao, url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas, formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa, id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem, data_atualizacao = CURRENT_TIMESTAMP;
