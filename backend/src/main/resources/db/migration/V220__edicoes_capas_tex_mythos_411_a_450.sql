-- Quarto lote de Tex da Mythos: garante as edicoes 411 a 450 e suas capas.
-- Fonte das capas: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('411', 'https://rika.vteximg.com.br/arquivos/ids/157193/-bonelli-tex-411.jpg?v=635312869136900000'),
    ('412', 'https://rika.vteximg.com.br/arquivos/ids/157194/-bonelli-tex-412.jpg?v=635312869203100000'),
    ('413', 'https://rika.vteximg.com.br/arquivos/ids/157195/-bonelli-tex-413.jpg?v=635312869221370000'),
    ('414', 'https://rika.vteximg.com.br/arquivos/ids/157196/-bonelli-tex-414.jpg?v=635312869237370000'),
    ('415', 'https://rika.vteximg.com.br/arquivos/ids/157197/-bonelli-tex-415.jpg?v=635312869260070000'),
    ('416', 'https://rika.vteximg.com.br/arquivos/ids/157198/-bonelli-tex-416.jpg?v=635312869277770000'),
    ('417', 'https://rika.vteximg.com.br/arquivos/ids/157199/-bonelli-tex-417.jpg?v=635312869295400000'),
    ('418', 'https://rika.vteximg.com.br/arquivos/ids/157200/-bonelli-tex-418.jpg?v=635312869312930000'),
    ('419', 'https://rika.vteximg.com.br/arquivos/ids/157201/-bonelli-tex-419.jpg?v=635312869353570000'),
    ('420', 'https://rika.vteximg.com.br/arquivos/ids/157202/-bonelli-tex-420.jpg?v=635312869376370000'),
    ('421', 'https://rika.vteximg.com.br/arquivos/ids/157203/-bonelli-tex-421.jpg?v=635312869396300000'),
    ('422', 'https://rika.vteximg.com.br/arquivos/ids/157204/-bonelli-tex-422.jpg?v=635312869423900000'),
    ('423', 'https://rika.vteximg.com.br/arquivos/ids/157205/-bonelli-tex-423.jpg?v=635312869444270000'),
    ('424', 'https://rika.vteximg.com.br/arquivos/ids/157206/-bonelli-tex-424.jpg?v=635312869480130000'),
    ('425', 'https://rika.vteximg.com.br/arquivos/ids/157207/-bonelli-tex-425.jpg?v=635312869497370000'),
    ('426', 'https://rika.vteximg.com.br/arquivos/ids/157208/-bonelli-tex-426.jpg?v=635312869515700000'),
    ('427', 'https://rika.vteximg.com.br/arquivos/ids/157209/-bonelli-tex-427.jpg?v=635312869534370000'),
    ('428', 'https://rika.vteximg.com.br/arquivos/ids/157210/-bonelli-tex-428.jpg?v=635312869553430000'),
    ('429', 'https://rika.vteximg.com.br/arquivos/ids/157211/-bonelli-tex-429.jpg?v=635312869568030000'),
    ('430', 'https://rika.vteximg.com.br/arquivos/ids/157212/-bonelli-tex-430.jpg?v=635312869585870000'),
    ('431', 'https://rika.vteximg.com.br/arquivos/ids/157213/-bonelli-tex-431.jpg?v=635312869603370000'),
    ('432', 'https://rika.vteximg.com.br/arquivos/ids/157214/-bonelli-tex-432.jpg?v=635312869620600000'),
    ('433', 'https://rika.vteximg.com.br/arquivos/ids/157215/-bonelli-tex-433.jpg?v=635312869637670000'),
    ('434', 'https://rika.vteximg.com.br/arquivos/ids/157216/-bonelli-tex-434.jpg?v=635312869653300000'),
    ('435', 'https://rika.vteximg.com.br/arquivos/ids/157217/-bonelli-tex-435.jpg?v=635312869672370000'),
    ('436', 'https://rika.vteximg.com.br/arquivos/ids/157218/-bonelli-tex-436.jpg?v=635312869691070000'),
    ('437', 'https://rika.vteximg.com.br/arquivos/ids/157219/-bonelli-tex-437.jpg?v=635312869746600000'),
    ('438', 'https://rika.vteximg.com.br/arquivos/ids/157220/-bonelli-tex-438.jpg?v=635312869765600000'),
    ('439', 'https://rika.vteximg.com.br/arquivos/ids/157221/-bonelli-tex-439.jpg?v=635312869781770000'),
    ('440', 'https://rika.vteximg.com.br/arquivos/ids/157222/-bonelli-tex-440.jpg?v=635312869798700000'),
    ('441', 'https://rika.vteximg.com.br/arquivos/ids/157223/-bonelli-tex-441.jpg?v=635312869815730000'),
    ('442', 'https://rika.vteximg.com.br/arquivos/ids/157224/-bonelli-tex-442.jpg?v=635312869835470000'),
    ('443', 'https://rika.vteximg.com.br/arquivos/ids/157225/-bonelli-tex-443.jpg?v=635312869854330000'),
    ('444', 'https://rika.vteximg.com.br/arquivos/ids/157226/-bonelli-tex-444.jpg?v=635312869872900000'),
    ('445', 'https://rika.vteximg.com.br/arquivos/ids/157227/-bonelli-tex-445.jpg?v=635312869891570000'),
    ('446', 'https://rika.vteximg.com.br/arquivos/ids/157228/-bonelli-tex-446.jpg?v=635312869912270000'),
    ('447', 'https://rika.vteximg.com.br/arquivos/ids/157229/-bonelli-tex-447.jpg?v=635312869930400000'),
    ('448', 'https://rika.vteximg.com.br/arquivos/ids/157230/-bonelli-tex-448.jpg?v=635312869943570000'),
    ('449', 'https://rika.vteximg.com.br/arquivos/ids/157231/-bonelli-tex-449.jpg?v=635312869959230000'),
    ('450', 'https://rika.vteximg.com.br/arquivos/ids/157232/-bonelli-tex-450.jpg?v=635312869977700000')
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
