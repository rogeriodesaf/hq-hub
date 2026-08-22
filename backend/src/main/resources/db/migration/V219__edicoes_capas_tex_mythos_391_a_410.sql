-- Terceiro lote de Tex da Mythos: garante as edicoes 391 a 410 e suas capas.
-- Fonte das capas: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('391', 'https://rika.vteximg.com.br/arquivos/ids/157173/-bonelli-tex-391.jpg?v=635312868736770000'),
    ('392', 'https://rika.vteximg.com.br/arquivos/ids/157174/-bonelli-tex-392.jpg?v=635312868773500000'),
    ('393', 'https://rika.vteximg.com.br/arquivos/ids/157175/-bonelli-tex-393.jpg?v=635312868792930000'),
    ('394', 'https://rika.vteximg.com.br/arquivos/ids/157176/-bonelli-tex-394.jpg?v=635312868807400000'),
    ('395', 'https://rika.vteximg.com.br/arquivos/ids/157177/-bonelli-tex-395.jpg?v=635312868830770000'),
    ('396', 'https://rika.vteximg.com.br/arquivos/ids/157178/-bonelli-tex-396.jpg?v=635312868846670000'),
    ('397', 'https://rika.vteximg.com.br/arquivos/ids/157179/-bonelli-tex-397.jpg?v=635312868870470000'),
    ('398', 'https://rika.vteximg.com.br/arquivos/ids/157180/-bonelli-tex-398.jpg?v=635312868890670000'),
    ('399', 'https://rika.vteximg.com.br/arquivos/ids/157181/-bonelli-tex-399.jpg?v=635312868909170000'),
    ('400', 'https://rika.vteximg.com.br/arquivos/ids/157182/-bonelli-tex-400.jpg?v=635312868928330000'),
    ('401', 'https://rika.vteximg.com.br/arquivos/ids/157183/-bonelli-tex-401.jpg?v=635312868947300000'),
    ('402', 'https://rika.vteximg.com.br/arquivos/ids/157184/-bonelli-tex-402.jpg?v=635312868966200000'),
    ('403', 'https://rika.vteximg.com.br/arquivos/ids/157185/-bonelli-tex-403.jpg?v=635312868982830000'),
    ('404', 'https://rika.vteximg.com.br/arquivos/ids/157186/-bonelli-tex-404.jpg?v=635312869007170000'),
    ('405', 'https://rika.vteximg.com.br/arquivos/ids/157187/-bonelli-tex-405.jpg?v=635312869028230000'),
    ('406', 'https://rika.vteximg.com.br/arquivos/ids/157188/-bonelli-tex-406.jpg?v=635312869045900000'),
    ('407', 'https://rika.vteximg.com.br/arquivos/ids/157189/-bonelli-tex-407.jpg?v=635312869063470000'),
    ('408', 'https://rika.vteximg.com.br/arquivos/ids/157190/-bonelli-tex-408.jpg?v=635312869083300000'),
    ('409', 'https://rika.vteximg.com.br/arquivos/ids/157191/-bonelli-tex-409.jpg?v=635312869103500000'),
    ('410', 'https://rika.vteximg.com.br/arquivos/ids/157192/-bonelli-tex-410.jpg?v=635312869121400000')
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
