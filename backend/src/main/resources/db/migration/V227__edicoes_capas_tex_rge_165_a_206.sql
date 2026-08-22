-- Cadastra a fase de Tex publicada pela RGE e suas capas, das edicoes 165 a 206.
-- Fonte das capas: catalogo publico da Rika (VTEX). Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'RGE / Rio Grafica',
    'Rio Grafica e Editora, editora brasileira que publicou esta fase de Tex.',
    'Brasil',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (nome) DO UPDATE SET
    data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Tex',
    'Serie brasileira de Tex publicada pela RGE, do numero 165 ao 206.',
    1983,
    1986,
    1,
    'RIKA',
    'tex-rge-volume-1',
    'https://www.rika.com.br/tex--16512000165/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
    hqhub_normalizar_titulo_serie('RGE'),
    hqhub_normalizar_titulo_serie('RGE / Rio Grafica'),
    hqhub_normalizar_titulo_serie('Rio Grafica e Editora')
)
ORDER BY CASE
    WHEN hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('RGE / Rio Grafica') THEN 0
    ELSE 1
END, editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, url_capa) AS (VALUES
    ('165', 'https://rika.vteximg.com.br/arquivos/ids/156949/-bonelli-tex-165.jpg?v=635312864173130000'),
    ('166', 'https://rika.vteximg.com.br/arquivos/ids/156950/-bonelli-tex-166.jpg?v=635312864191200000'),
    ('167', 'https://rika.vteximg.com.br/arquivos/ids/156951/-bonelli-tex-167.jpg?v=635312864209070000'),
    ('168', 'https://rika.vteximg.com.br/arquivos/ids/156952/-bonelli-tex-168.jpg?v=635312864227570000'),
    ('169', 'https://rika.vteximg.com.br/arquivos/ids/156953/-bonelli-tex-169.jpg?v=635312864245630000'),
    ('170', 'https://rika.vteximg.com.br/arquivos/ids/156954/-bonelli-tex-170.jpg?v=635312864265430000'),
    ('171', 'https://rika.vteximg.com.br/arquivos/ids/156955/-bonelli-tex-171.jpg?v=635312864285100000'),
    ('172', 'https://rika.vteximg.com.br/arquivos/ids/156956/-bonelli-tex-172.jpg?v=635312864302470000'),
    ('173', 'https://rika.vteximg.com.br/arquivos/ids/156957/-bonelli-tex-173.jpg?v=635312864371430000'),
    ('174', 'https://rika.vteximg.com.br/arquivos/ids/156958/-bonelli-tex-174.jpg?v=635312864390000000'),
    ('175', 'https://rika.vteximg.com.br/arquivos/ids/156959/-bonelli-tex-175.jpg?v=635312864420070000'),
    ('176', 'https://rika.vteximg.com.br/arquivos/ids/156960/-bonelli-tex-176.jpg?v=635312864437700000'),
    ('177', 'https://rika.vteximg.com.br/arquivos/ids/156961/-bonelli-tex-177.jpg?v=635312864456500000'),
    ('178', 'https://rika.vteximg.com.br/arquivos/ids/156962/-bonelli-tex-178.jpg?v=635312864470230000'),
    ('179', 'https://rika.vteximg.com.br/arquivos/ids/156963/-bonelli-tex-179.jpg?v=635312864490830000'),
    ('180', 'https://rika.vteximg.com.br/arquivos/ids/156964/-bonelli-tex-180.jpg?v=635312864512670000'),
    ('181', 'https://rika.vteximg.com.br/arquivos/ids/156965/-bonelli-tex-181.jpg?v=635312864528670000'),
    ('182', 'https://rika.vteximg.com.br/arquivos/ids/156966/-bonelli-tex-182.jpg?v=635312864547970000'),
    ('183', 'https://rika.vteximg.com.br/arquivos/ids/156967/-bonelli-tex-183.jpg?v=635312864565130000'),
    ('184', 'https://rika.vteximg.com.br/arquivos/ids/156968/-bonelli-tex-184.jpg?v=635312864583870000'),
    ('185', 'https://rika.vteximg.com.br/arquivos/ids/156969/-bonelli-tex-185.jpg?v=635312864602770000'),
    ('186', 'https://rika.vteximg.com.br/arquivos/ids/156970/-bonelli-tex-186.jpg?v=635312864620970000'),
    ('187', 'https://rika.vteximg.com.br/arquivos/ids/156971/-bonelli-tex-187.jpg?v=635312864639600000'),
    ('188', 'https://rika.vteximg.com.br/arquivos/ids/156972/-bonelli-tex-188.jpg?v=635312864656530000'),
    ('189', 'https://rika.vteximg.com.br/arquivos/ids/156973/-bonelli-tex-189.jpg?v=635312864674130000'),
    ('190', 'https://rika.vteximg.com.br/arquivos/ids/156974/-bonelli-tex-190.jpg?v=635312864690530000'),
    ('191', 'https://rika.vteximg.com.br/arquivos/ids/156975/-bonelli-tex-191.jpg?v=635312864711130000'),
    ('192', 'https://rika.vteximg.com.br/arquivos/ids/156976/-bonelli-tex-192.jpg?v=635312864729530000'),
    ('193', 'https://rika.vteximg.com.br/arquivos/ids/156977/-bonelli-tex-193.jpg?v=635312864746870000'),
    ('194', 'https://rika.vteximg.com.br/arquivos/ids/156978/-bonelli-tex-194.jpg?v=635312864767800000'),
    ('195', 'https://rika.vteximg.com.br/arquivos/ids/156979/-bonelli-tex-195.jpg?v=635312864783170000'),
    ('196', 'https://rika.vteximg.com.br/arquivos/ids/156980/-bonelli-tex-196.jpg?v=635312864804100000'),
    ('197', 'https://rika.vteximg.com.br/arquivos/ids/156981/-bonelli-tex-197.jpg?v=635312864863430000'),
    ('198', 'https://rika.vteximg.com.br/arquivos/ids/156982/-bonelli-tex-198.jpg?v=635312864882500000'),
    ('199', 'https://rika.vteximg.com.br/arquivos/ids/156983/-bonelli-tex-199.jpg?v=635312864897700000'),
    ('200', 'https://rika.vteximg.com.br/arquivos/ids/156984/-bonelli-tex-200.jpg?v=635312864915070000'),
    ('201', 'https://rika.vteximg.com.br/arquivos/ids/156985/-bonelli-tex-201.jpg?v=635312864932130000'),
    ('202', 'https://rika.vteximg.com.br/arquivos/ids/156986/-bonelli-tex-202.jpg?v=635312864950300000'),
    ('203', 'https://rika.vteximg.com.br/arquivos/ids/156987/-bonelli-tex-203.jpg?v=635312864968230000'),
    ('204', 'https://rika.vteximg.com.br/arquivos/ids/156988/-bonelli-tex-204.jpg?v=635312864986430000'),
    ('205', 'https://rika.vteximg.com.br/arquivos/ids/156989/-bonelli-tex-205.jpg?v=635312865006330000'),
    ('206', 'https://rika.vteximg.com.br/arquivos/ids/156990/-bonelli-tex-206.jpg?v=635312865025170000')
), serie_tex_rge AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('RGE'),
          hqhub_normalizar_titulo_serie('RGE / Rio Grafica'),
          hqhub_normalizar_titulo_serie('Rio Grafica e Editora')
      )
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, url_capa, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Tex #' || capa.numero,
    'Tex - numero ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-rge-' || capa.numero,
    'https://www.rika.com.br/tex--' || capa.numero || '12000' || capa.numero || '/p',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_rge serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

