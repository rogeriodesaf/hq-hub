-- Quinto lote de Tex da Mythos: garante as edicoes 451 a 500 e suas capas.
-- Fonte das capas: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('451', 'https://rika.vteximg.com.br/arquivos/ids/157233/-bonelli-tex-451.jpg?v=635312869991930000'),
    ('452', 'https://rika.vteximg.com.br/arquivos/ids/157234/-bonelli-tex-452.jpg?v=635312870009400000'),
    ('453', 'https://rika.vteximg.com.br/arquivos/ids/157235/-bonelli-tex-453.jpg?v=635312870047770000'),
    ('454', 'https://rika.vteximg.com.br/arquivos/ids/157236/-bonelli-tex-454.jpg?v=635312870066500000'),
    ('455', 'https://rika.vteximg.com.br/arquivos/ids/157237/-bonelli-tex-455.jpg?v=635312870083970000'),
    ('456', 'https://rika.vteximg.com.br/arquivos/ids/157238/-bonelli-tex-456.jpg?v=635312870125330000'),
    ('457', 'https://rika.vteximg.com.br/arquivos/ids/157239/-bonelli-tex-457.jpg?v=635312870145200000'),
    ('458', 'https://rika.vteximg.com.br/arquivos/ids/157240/-bonelli-tex-458.jpg?v=635312870162470000'),
    ('459', 'https://rika.vteximg.com.br/arquivos/ids/157241/-bonelli-tex-459.jpg?v=635312870178930000'),
    ('460', 'https://rika.vteximg.com.br/arquivos/ids/157242/-bonelli-tex-460.jpg?v=635312870196530000'),
    ('461', 'https://rika.vteximg.com.br/arquivos/ids/157243/-bonelli-tex-461.jpg?v=635312870213230000'),
    ('462', 'https://rika.vteximg.com.br/arquivos/ids/157244/-bonelli-tex-462.jpg?v=635312870228400000'),
    ('463', 'https://rika.vteximg.com.br/arquivos/ids/157245/-bonelli-tex-463.jpg?v=635312870247600000'),
    ('464', 'https://rika.vteximg.com.br/arquivos/ids/157246/-bonelli-tex-464.jpg?v=635312870261330000'),
    ('465', 'https://rika.vteximg.com.br/arquivos/ids/157247/-bonelli-tex-465.jpg?v=635312870275630000'),
    ('466', 'https://rika.vteximg.com.br/arquivos/ids/157248/-bonelli-tex-466.jpg?v=635312870292030000'),
    ('467', 'https://rika.vteximg.com.br/arquivos/ids/157249/-bonelli-tex-467.jpg?v=635312870309370000'),
    ('468', 'https://rika.vteximg.com.br/arquivos/ids/157250/-bonelli-tex-468.jpg?v=635312870322770000'),
    ('469', 'https://rika.vteximg.com.br/arquivos/ids/157251/-bonelli-tex-469.jpg?v=635312870341470000'),
    ('470', 'https://rika.vteximg.com.br/arquivos/ids/157252/-bonelli-tex-470.jpg?v=635312870369170000'),
    ('471', 'https://rika.vteximg.com.br/arquivos/ids/157253/-bonelli-tex-471.jpg?v=635312870386970000'),
    ('472', 'https://rika.vteximg.com.br/arquivos/ids/157254/-bonelli-tex-472.jpg?v=635312870404230000'),
    ('473', 'https://rika.vteximg.com.br/arquivos/ids/157255/-bonelli-tex-473.jpg?v=635312870422170000'),
    ('474', 'https://rika.vteximg.com.br/arquivos/ids/157256/-bonelli-tex-474.jpg?v=635312870439400000'),
    ('475', 'https://rika.vteximg.com.br/arquivos/ids/157257/-bonelli-tex-475.jpg?v=635312870457300000'),
    ('476', 'https://rika.vteximg.com.br/arquivos/ids/157258/-bonelli-tex-476.jpg?v=635312870476930000'),
    ('477', 'https://rika.vteximg.com.br/arquivos/ids/157259/-bonelli-tex-477.jpg?v=635312870495200000'),
    ('478', 'https://rika.vteximg.com.br/arquivos/ids/157260/-bonelli-tex-478.jpg?v=635312870510400000'),
    ('479', 'https://rika.vteximg.com.br/arquivos/ids/157261/-bonelli-tex-479.jpg?v=635312870528330000'),
    ('480', 'https://rika.vteximg.com.br/arquivos/ids/157262/-bonelli-tex-480.jpg?v=635312870547200000'),
    ('481', 'https://rika.vteximg.com.br/arquivos/ids/157263/-bonelli-tex-481.jpg?v=635312870564330000'),
    ('482', 'https://rika.vteximg.com.br/arquivos/ids/157264/-bonelli-tex-482.jpg?v=635312870602830000'),
    ('483', 'https://rika.vteximg.com.br/arquivos/ids/157265/-bonelli-tex-483.jpg?v=635312870629230000'),
    ('484', 'https://rika.vteximg.com.br/arquivos/ids/157266/-bonelli-tex-484.jpg?v=635312870653300000'),
    ('485', 'https://rika.vteximg.com.br/arquivos/ids/157267/-bonelli-tex-485.jpg?v=635312870671400000'),
    ('486', 'https://rika.vteximg.com.br/arquivos/ids/157268/-bonelli-tex-486.jpg?v=635312870690600000'),
    ('487', 'https://rika.vteximg.com.br/arquivos/ids/157269/-bonelli-tex-487.jpg?v=635312870739770000'),
    ('488', 'https://rika.vteximg.com.br/arquivos/ids/157270/-bonelli-tex-488.jpg?v=635312870758230000'),
    ('489', 'https://rika.vteximg.com.br/arquivos/ids/157271/-bonelli-tex-489.jpg?v=635312870819230000'),
    ('490', 'https://rika.vteximg.com.br/arquivos/ids/157272/-bonelli-tex-490.jpg?v=635312870834670000'),
    ('491', 'https://rika.vteximg.com.br/arquivos/ids/157273/-bonelli-tex-491.jpg?v=635312870848770000'),
    ('492', 'https://rika.vteximg.com.br/arquivos/ids/157274/-bonelli-tex-492.jpg?v=635312870865330000'),
    ('493', 'https://rika.vteximg.com.br/arquivos/ids/157275/-bonelli-tex-493.jpg?v=635312870883900000'),
    ('494', 'https://rika.vteximg.com.br/arquivos/ids/157276/-bonelli-tex-494.jpg?v=635312870902570000'),
    ('495', 'https://rika.vteximg.com.br/arquivos/ids/157277/-bonelli-tex-495.jpg?v=635312870918370000'),
    ('496', 'https://rika.vteximg.com.br/arquivos/ids/157278/-bonelli-tex-496.jpg?v=635312870936200000'),
    ('497', 'https://rika.vteximg.com.br/arquivos/ids/157279/-bonelli-tex-497.jpg?v=635312870954570000'),
    ('498', 'https://rika.vteximg.com.br/arquivos/ids/157280/-bonelli-tex-498.jpg?v=635312870973500000'),
    ('499', 'https://rika.vteximg.com.br/arquivos/ids/157281/-bonelli-tex-499.jpg?v=635312870989830000'),
    ('500', 'https://rika.vteximg.com.br/arquivos/ids/157282/-bonelli-tex-500.jpg?v=635312871046170000')
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
