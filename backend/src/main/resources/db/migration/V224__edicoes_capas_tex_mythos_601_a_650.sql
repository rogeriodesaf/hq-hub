-- Oitavo lote de Tex da Mythos: garante as edicoes 601 a 650 e suas capas.
-- Fonte das capas: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('601', 'https://rika.vteximg.com.br/arquivos/ids/345549/Tex-601.jpg?v=637234521473930000'),
    ('602', 'https://rika.vteximg.com.br/arquivos/ids/345550/Tex-602.jpg?v=637234521481970000'),
    ('603', 'https://rika.vteximg.com.br/arquivos/ids/345551/Tex-603.jpg?v=637234521491470000'),
    ('604', 'https://rika.vteximg.com.br/arquivos/ids/406033/https---www.artesequencial.com.br-imagens-bonelli-Tex_604.jpg?v=637593806396030000'),
    ('605', 'https://rika.vteximg.com.br/arquivos/ids/406035/https---www.artesequencial.com.br-imagens-bonelli-Tex_605.jpg?v=637593806433900000'),
    ('606', 'https://rika.vteximg.com.br/arquivos/ids/395011/Tex-606.jpg?v=637483228513830000'),
    ('607', 'https://rika.vteximg.com.br/arquivos/ids/395012/Tex-607.jpg?v=637483228518200000'),
    ('608', 'https://rika.vteximg.com.br/arquivos/ids/395013/Tex-608.jpg?v=637483228522900000'),
    ('609', 'https://rika.vteximg.com.br/arquivos/ids/395014/Tex-609.jpg?v=637483228526330000'),
    ('610', 'https://rika.vteximg.com.br/arquivos/ids/395015/Tex-610.jpg?v=637483228529930000'),
    ('611', 'https://rika.vteximg.com.br/arquivos/ids/395016/Tex-611.jpg?v=637483228533370000'),
    ('612', 'https://rika.vteximg.com.br/arquivos/ids/395017/imagem_indisponivel.jpg?v=637483228537430000'),
    ('613', 'https://rika.vteximg.com.br/arquivos/ids/406124/https---www.artesequencial.com.br-imagens-bonelli-Tex_613.jpg?v=637593809804500000'),
    ('614', 'https://rika.vteximg.com.br/arquivos/ids/406126/https---www.artesequencial.com.br-imagens-bonelli-Tex_614.jpg?v=637593809844000000'),
    ('615', 'https://rika.vteximg.com.br/arquivos/ids/395020/imagem_indisponivel.jpg?v=637483228548830000'),
    ('616', 'https://rika.vteximg.com.br/arquivos/ids/406174/https---www.artesequencial.com.br-imagens-bonelli-Tex_616.jpg?v=637593810826430000'),
    ('617', 'https://rika.vteximg.com.br/arquivos/ids/406176/https---www.artesequencial.com.br-imagens-bonelli-Tex_617.jpg?v=637593810863400000'),
    ('618', 'https://rika.vteximg.com.br/arquivos/ids/411531/Tex-618.jpg?v=637844305500200000'),
    ('619', 'https://rika.vteximg.com.br/arquivos/ids/411532/Tex-619.jpg?v=637844305509770000'),
    ('620', 'https://rika.vteximg.com.br/arquivos/ids/411533/Tex-620.jpg?v=637844305520100000'),
    ('621', 'https://rika.vteximg.com.br/arquivos/ids/411534/Tex-621.jpg?v=637844305530570000'),
    ('622', 'https://rika.vteximg.com.br/arquivos/ids/411535/Tex-622.jpg?v=637844305541670000'),
    ('623', 'https://rika.vteximg.com.br/arquivos/ids/411536/Tex-623.jpg?v=637844305552170000'),
    ('624', 'https://rika.vteximg.com.br/arquivos/ids/411537/Tex-624.jpg?v=637844305562470000'),
    ('625', 'https://rika.vteximg.com.br/arquivos/ids/411538/Tex-625.jpg?v=637844305573600000'),
    ('626', 'https://rika.vteximg.com.br/arquivos/ids/411539/Tex-626.jpg?v=637844305583300000'),
    ('627', 'https://rika.vteximg.com.br/arquivos/ids/411540/Tex-627.jpg?v=637844305593770000'),
    ('628', 'https://rika.vteximg.com.br/arquivos/ids/411541/Tex-628.jpg?v=637844305604570000'),
    ('629', 'https://rika.vteximg.com.br/arquivos/ids/412911/Tex-629.jpg?v=637925319625170000'),
    ('630', 'https://rika.vteximg.com.br/arquivos/ids/412912/Tex-630.jpg?v=637925319628770000'),
    ('631', 'https://rika.vteximg.com.br/arquivos/ids/412913/imagem_indisponivel.jpg?v=637925319632500000'),
    ('632', 'https://rika.vteximg.com.br/arquivos/ids/412914/imagem_indisponivel.jpg?v=637925319636430000'),
    ('633', 'https://rika.vteximg.com.br/arquivos/ids/444282/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-633.jpg?v=638269469680470000'),
    ('634', 'https://rika.vteximg.com.br/arquivos/ids/444284/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-634.jpg?v=638269469701300000'),
    ('635', 'https://rika.vteximg.com.br/arquivos/ids/444286/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-635.jpg?v=638269469725830000'),
    ('636', 'https://rika.vteximg.com.br/arquivos/ids/444288/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-636.jpg?v=638269469749930000'),
    ('637', 'https://rika.vteximg.com.br/arquivos/ids/444292/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-637.jpg?v=638269469798670000'),
    ('638', 'https://rika.vteximg.com.br/arquivos/ids/444294/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-638.jpg?v=638269469825430000'),
    ('639', 'https://rika.vteximg.com.br/arquivos/ids/444296/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-639.jpg?v=638269469850300000'),
    ('640', 'https://rika.vteximg.com.br/arquivos/ids/444298/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-640.jpg?v=638269469874900000'),
    ('641', 'https://rika.vteximg.com.br/arquivos/ids/444300/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-641.jpg?v=638269469900570000'),
    ('642', 'https://rika.vteximg.com.br/arquivos/ids/444304/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-642.jpg?v=638269469946730000'),
    ('643', 'https://rika.vteximg.com.br/arquivos/ids/444306/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-643.jpg?v=638269469971570000'),
    ('644', 'https://rika.vteximg.com.br/arquivos/ids/444308/https---www.artesequencial.com.br-imagens-2023-08-Tex-Mythos-644.jpg?v=638269469996000000'),
    ('645', 'https://rika.vteximg.com.br/arquivos/ids/454764/https---www.artesequencial.com.br-imagens-2024-05-Tex-645.jpg?v=638506285046270000'),
    ('646', 'https://rika.vteximg.com.br/arquivos/ids/454766/https---www.artesequencial.com.br-imagens-2024-05-Tex-646.jpg?v=638506285067770000'),
    ('647', 'https://rika.vteximg.com.br/arquivos/ids/454768/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285090330000'),
    ('648', 'https://rika.vteximg.com.br/arquivos/ids/454770/https---www.artesequencial.com.br-imagens-2024-05-Tex-648.jpg?v=638506285112430000'),
    ('649', 'https://rika.vteximg.com.br/arquivos/ids/454772/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285136630000'),
    ('650', 'https://rika.vteximg.com.br/arquivos/ids/454774/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285158330000')
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
