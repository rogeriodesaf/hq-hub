-- Sexto lote de Tex da Mythos: garante as edicoes 501 a 550 e suas capas.
-- Fonte das capas: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('501', 'https://rika.vteximg.com.br/arquivos/ids/157283/-bonelli-tex-501.jpg?v=635312871065070000'),
    ('502', 'https://rika.vteximg.com.br/arquivos/ids/157284/-bonelli-tex-502.jpg?v=635312871082630000'),
    ('503', 'https://rika.vteximg.com.br/arquivos/ids/157285/-bonelli-tex-503.jpg?v=635312871122300000'),
    ('504', 'https://rika.vteximg.com.br/arquivos/ids/157286/-bonelli-tex-504.jpg?v=635312871139170000'),
    ('505', 'https://rika.vteximg.com.br/arquivos/ids/157287/-bonelli-tex-505.jpg?v=635312871153800000'),
    ('506', 'https://rika.vteximg.com.br/arquivos/ids/157288/-bonelli-tex-506.jpg?v=635312871169800000'),
    ('507', 'https://rika.vteximg.com.br/arquivos/ids/157289/-bonelli-tex-507.jpg?v=635312871189700000'),
    ('508', 'https://rika.vteximg.com.br/arquivos/ids/157290/-bonelli-tex-508.jpg?v=635312871208070000'),
    ('509', 'https://rika.vteximg.com.br/arquivos/ids/157293/-bonelli-tex-509.jpg?v=635312871264930000'),
    ('510', 'https://rika.vteximg.com.br/arquivos/ids/157294/-bonelli-tex-510.jpg?v=635312871282900000'),
    ('511', 'https://rika.vteximg.com.br/arquivos/ids/318731/Tex-511.jpg?v=636855938370200000'),
    ('512', 'https://rika.vteximg.com.br/arquivos/ids/285647/tex-512.jpg?v=636195814759630000'),
    ('513', 'https://rika.vteximg.com.br/arquivos/ids/285648/tex-513.jpg?v=636195815393830000'),
    ('514', 'https://rika.vteximg.com.br/arquivos/ids/319307/Tex-514.jpg?v=636893831432830000'),
    ('515', 'https://rika.vteximg.com.br/arquivos/ids/405697/https---www.artesequencial.com.br-imagens-bonelli-Tex_515.jpg?v=637593799535300000'),
    ('516', 'https://rika.vteximg.com.br/arquivos/ids/285649/tex-516.jpg?v=636195816170600000'),
    ('517', 'https://rika.vteximg.com.br/arquivos/ids/318732/Tex-517.jpg?v=636855938814300000'),
    ('518', 'https://rika.vteximg.com.br/arquivos/ids/318733/Tex-518.jpg?v=636855939090970000'),
    ('519', 'https://rika.vteximg.com.br/arquivos/ids/405699/https---www.artesequencial.com.br-imagens-bonelli-Tex_519.jpg?v=637593799573300000'),
    ('520', 'https://rika.vteximg.com.br/arquivos/ids/319308/Tex-520.jpg?v=636893832028900000'),
    ('521', 'https://rika.vteximg.com.br/arquivos/ids/285650/tex-521.jpg?v=636195817362500000'),
    ('522', 'https://rika.vteximg.com.br/arquivos/ids/319309/Tex-522.jpg?v=636893832683270000'),
    ('523', 'https://rika.vteximg.com.br/arquivos/ids/318735/Tex-523.jpg?v=636855940363730000'),
    ('524', 'https://rika.vteximg.com.br/arquivos/ids/285651/tex-524.jpg?v=636195818290270000'),
    ('525', 'https://rika.vteximg.com.br/arquivos/ids/319310/Tex-525.jpg?v=636893833105470000'),
    ('526', 'https://rika.vteximg.com.br/arquivos/ids/318734/Tex-526.jpg?v=636855940032530000'),
    ('527', 'https://rika.vteximg.com.br/arquivos/ids/283480/tex-527.jpg?v=635915768654630000'),
    ('528', 'https://rika.vteximg.com.br/arquivos/ids/283481/tex-528.jpg?v=635915768677430000'),
    ('529', 'https://rika.vteximg.com.br/arquivos/ids/283482/tex-529.jpg?v=635915768697000000'),
    ('530', 'https://rika.vteximg.com.br/arquivos/ids/283483/tex-530.jpg?v=635915768718270000'),
    ('531', 'https://rika.vteximg.com.br/arquivos/ids/283484/tex-531.jpg?v=635915768739730000'),
    ('532', 'https://rika.vteximg.com.br/arquivos/ids/283485/tex-532.jpg?v=635915768758100000'),
    ('533', 'https://rika.vteximg.com.br/arquivos/ids/283486/tex-533.jpg?v=635915768778230000'),
    ('534', 'https://rika.vteximg.com.br/arquivos/ids/283487/tex-534.jpg?v=635915768798430000'),
    ('535', 'https://rika.vteximg.com.br/arquivos/ids/283488/tex-535.jpg?v=635915768815900000'),
    ('536', 'https://rika.vteximg.com.br/arquivos/ids/283489/tex-536.jpg?v=635915768837500000'),
    ('537', 'https://rika.vteximg.com.br/arquivos/ids/283490/tex-537.jpg?v=635915768855830000'),
    ('538', 'https://rika.vteximg.com.br/arquivos/ids/283491/tex-538.jpg?v=635915768876870000'),
    ('539', 'https://rika.vteximg.com.br/arquivos/ids/283492/tex-539.jpg?v=635915768897830000'),
    ('540', 'https://rika.vteximg.com.br/arquivos/ids/283493/tex-540.jpg?v=635915768919630000'),
    ('541', 'https://rika.vteximg.com.br/arquivos/ids/283494/tex-541.jpg?v=635915768937230000'),
    ('542', 'https://rika.vteximg.com.br/arquivos/ids/283495/tex-542.jpg?v=635915768957270000'),
    ('543', 'https://rika.vteximg.com.br/arquivos/ids/283496/tex-543.jpg?v=635915769081800000'),
    ('544', 'https://rika.vteximg.com.br/arquivos/ids/283497/tex-544.jpg?v=635915769104500000'),
    ('545', 'https://rika.vteximg.com.br/arquivos/ids/283498/tex-545.jpg?v=635915769134930000'),
    ('546', 'https://rika.vteximg.com.br/arquivos/ids/283499/tex-546.jpg?v=635915769154500000'),
    ('547', 'https://rika.vteximg.com.br/arquivos/ids/283500/tex-547.jpg?v=635915769176100000'),
    ('548', 'https://rika.vteximg.com.br/arquivos/ids/283501/tex-548.jpg?v=635915769197500000'),
    ('549', 'https://rika.vteximg.com.br/arquivos/ids/283502/tex-549.jpg?v=635915769220100000'),
    ('550', 'https://rika.vteximg.com.br/arquivos/ids/283503/tex-550.jpg?v=635915769240100000')
), series_tex AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Mythos'),
          hqhub_normalizar_titulo_serie('Mythos Editora')
      )
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
)
INSERT INTO edicoes (
    numero,
    titulo,
    descricao,
    url_capa,
    fonte_externa,
    id_externo,
    serie_id,
    data_criacao,
    data_atualizacao
)
SELECT
    capa.numero,
    'Tex #' || capa.numero,
    'Tex - nº ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN series_tex serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    url_capa = EXCLUDED.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP;
