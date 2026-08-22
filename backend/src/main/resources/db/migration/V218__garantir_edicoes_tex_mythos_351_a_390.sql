-- Garante que os dois primeiros lotes de Tex existam no catalogo.
-- Edicoes existentes sao preservadas e recebem somente a capa validada.
WITH capas(numero, url_capa) AS (VALUES
    ('351', 'https://rika.vteximg.com.br/arquivos/ids/157133/-bonelli-tex-351.jpg?v=635312867854570000'),
    ('352', 'https://rika.vteximg.com.br/arquivos/ids/157134/-bonelli-tex-352.jpg?v=635312867875800000'),
    ('353', 'https://rika.vteximg.com.br/arquivos/ids/157135/-bonelli-tex-353.jpg?v=635312867891100000'),
    ('354', 'https://rika.vteximg.com.br/arquivos/ids/157136/-bonelli-tex-354.jpg?v=635312867911200000'),
    ('355', 'https://rika.vteximg.com.br/arquivos/ids/157137/-bonelli-tex-355.jpg?v=635312867932000000'),
    ('356', 'https://rika.vteximg.com.br/arquivos/ids/157138/-bonelli-tex-356.jpg?v=635312867953570000'),
    ('357', 'https://rika.vteximg.com.br/arquivos/ids/157139/-bonelli-tex-357.jpg?v=635312867973630000'),
    ('358', 'https://rika.vteximg.com.br/arquivos/ids/157140/-bonelli-tex-358.jpg?v=635312867988430000'),
    ('359', 'https://rika.vteximg.com.br/arquivos/ids/157141/-bonelli-tex-359.jpg?v=635312868007330000'),
    ('360', 'https://rika.vteximg.com.br/arquivos/ids/157142/-bonelli-tex-360.jpg?v=635312868026500000'),
    ('361', 'https://rika.vteximg.com.br/arquivos/ids/157143/-bonelli-tex-361.jpg?v=635312868045270000'),
    ('362', 'https://rika.vteximg.com.br/arquivos/ids/157144/-bonelli-tex-362.jpg?v=635312868076070000'),
    ('363', 'https://rika.vteximg.com.br/arquivos/ids/157145/-bonelli-tex-363.jpg?v=635312868094300000'),
    ('364', 'https://rika.vteximg.com.br/arquivos/ids/157146/-bonelli-tex-364.jpg?v=635312868113400000'),
    ('365', 'https://rika.vteximg.com.br/arquivos/ids/157147/-bonelli-tex-365.jpg?v=635312868135130000'),
    ('366', 'https://rika.vteximg.com.br/arquivos/ids/157148/-bonelli-tex-366.jpg?v=635312868153430000'),
    ('367', 'https://rika.vteximg.com.br/arquivos/ids/157149/-bonelli-tex-367.jpg?v=635312868206900000'),
    ('368', 'https://rika.vteximg.com.br/arquivos/ids/157150/-bonelli-tex-368.jpg?v=635312868256130000'),
    ('369', 'https://rika.vteximg.com.br/arquivos/ids/157151/-bonelli-tex-369.jpg?v=635312868274370000'),
    ('370', 'https://rika.vteximg.com.br/arquivos/ids/157152/-bonelli-tex-370.jpg?v=635312868296500000'),
    ('371', 'https://rika.vteximg.com.br/arquivos/ids/157153/-bonelli-tex-371.jpg?v=635312868316830000'),
    ('372', 'https://rika.vteximg.com.br/arquivos/ids/157154/-bonelli-tex-372.jpg?v=635312868332200000'),
    ('373', 'https://rika.vteximg.com.br/arquivos/ids/157155/-bonelli-tex-373.jpg?v=635312868371330000'),
    ('374', 'https://rika.vteximg.com.br/arquivos/ids/157156/-bonelli-tex-374.jpg?v=635312868392130000'),
    ('375', 'https://rika.vteximg.com.br/arquivos/ids/157157/-bonelli-tex-375.jpg?v=635312868416730000'),
    ('376', 'https://rika.vteximg.com.br/arquivos/ids/157158/-bonelli-tex-376.jpg?v=635312868432230000'),
    ('377', 'https://rika.vteximg.com.br/arquivos/ids/157159/-bonelli-tex-377.jpg?v=635312868450530000'),
    ('378', 'https://rika.vteximg.com.br/arquivos/ids/157160/-bonelli-tex-378.jpg?v=635312868475130000'),
    ('379', 'https://rika.vteximg.com.br/arquivos/ids/157161/-bonelli-tex-379.jpg?v=635312868493370000'),
    ('380', 'https://rika.vteximg.com.br/arquivos/ids/157162/-bonelli-tex-380.jpg?v=635312868512130000'),
    ('381', 'https://rika.vteximg.com.br/arquivos/ids/157163/-bonelli-tex-381.jpg?v=635312868547130000'),
    ('382', 'https://rika.vteximg.com.br/arquivos/ids/157164/-bonelli-tex-382.jpg?v=635312868565570000'),
    ('383', 'https://rika.vteximg.com.br/arquivos/ids/157165/-bonelli-tex-383.jpg?v=635312868580030000'),
    ('384', 'https://rika.vteximg.com.br/arquivos/ids/157166/-bonelli-tex-384.jpg?v=635312868601900000'),
    ('385', 'https://rika.vteximg.com.br/arquivos/ids/157167/-bonelli-tex-385.jpg?v=635312868620070000'),
    ('386', 'https://rika.vteximg.com.br/arquivos/ids/157168/-bonelli-tex-386.jpg?v=635312868637170000'),
    ('387', 'https://rika.vteximg.com.br/arquivos/ids/157169/-bonelli-tex-387.jpg?v=635312868657500000'),
    ('388', 'https://rika.vteximg.com.br/arquivos/ids/157170/-bonelli-tex-388.jpg?v=635312868677030000'),
    ('389', 'https://rika.vteximg.com.br/arquivos/ids/157171/-bonelli-tex-389.jpg?v=635312868696930000'),
    ('390', 'https://rika.vteximg.com.br/arquivos/ids/157172/-bonelli-tex-390.jpg?v=635312868719870000')
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
