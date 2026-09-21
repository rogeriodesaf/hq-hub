-- Superman 4a Serie/Panini: edicoes 1-32 e 56-58 (a numeracao 33-35 foi
-- substituida na capa pela numeracao continua 56-58).
-- Produtos da Panini identificados individualmente na Rika; nao usar os
-- resultados homonimos da 4a serie da Ebal.
-- A edicao 6 nao e alterada: o produto da Rika usa imagem indisponivel.
WITH capas(numero, imagem_id, produto_id) AS (
    VALUES
        (1, 340943, 15006892),
        (2, 340944, 15006893),
        (3, 340945, 15006894),
        (4, 340946, 15006895),
        (5, 340947, 15006896),
        (7, 345679, 15007223),
        (8, 345680, 15007224),
        (9, 345681, 15007225),
        (10, 345683, 15007227),
        (11, 345684, 15007228),
        (12, 345685, 15007229),
        (13, 418737, 15007230),
        (14, 406412, 15007682),
        (15, 406413, 15007683),
        (16, 406414, 15007684),
        (17, 406415, 15007685),
        (18, 406416, 15007686),
        (19, 406417, 15007687),
        (20, 406418, 15007688),
        (21, 406419, 15007689),
        (22, 406420, 15007690),
        (23, 406421, 15007691),
        (24, 406422, 15007692),
        (25, 406423, 15007693),
        (26, 515965, 15007694),
        (27, 418829, 15007695),
        (28, 424536, 15009277),
        (29, 424538, 15009278),
        (30, 424539, 15009279),
        (31, 424541, 15009280),
        (32, 424543, 15009281),
        (56, 424545, 15009282),
        (57, 424547, 15009283),
        (58, 424549, 15009284)
)
UPDATE edicoes edicao
SET url_capa = format('https://rika.vtexassets.com/arquivos/ids/%s', capa.imagem_id),
    url_origem = format('https://www.rika.com.br/superman---4a-serie--%s-%s/p',
                        lpad(capa.numero::text, 2, '0'), capa.produto_id),
    fonte_externa = 'RIKA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Superman 4ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) =
      hqhub_normalizar_titulo_serie('Panini')
  AND CASE
        WHEN trim(edicao.numero) ~ '^[0-9]+$' THEN
            CASE WHEN trim(edicao.numero)::integer BETWEEN 33 AND 35
                 THEN trim(edicao.numero)::integer + 23
                 ELSE trim(edicao.numero)::integer END
        WHEN trim(edicao.numero) ~ '^[0-9]+[[:space:]]*[/-][[:space:]]*[0-9]+$' THEN
            CASE WHEN substring(trim(edicao.numero) from '^[0-9]+')::integer BETWEEN 33 AND 35
                 THEN substring(trim(edicao.numero) from '^[0-9]+')::integer + 23
                 ELSE substring(trim(edicao.numero) from '^[0-9]+')::integer END
      END = capa.numero
  AND (edicao.url_capa IS DISTINCT FROM format('https://rika.vtexassets.com/arquivos/ids/%s', capa.imagem_id)
       OR edicao.url_origem IS DISTINCT FROM format('https://www.rika.com.br/superman---4a-serie--%s-%s/p',
                                                   lpad(capa.numero::text, 2, '0'), capa.produto_id));
