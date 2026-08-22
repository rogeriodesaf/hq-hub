-- Cadastra Tex Willer publicada pela Mythos, dos numeros 1 a 60.
-- Fontes das capas: catalogos publicos da Rika e Martins Fontes Paulista.
-- Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Mythos',
    'Editora brasileira de historias em quadrinhos.',
    'Brasil',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (nome) DO UPDATE SET
    data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Tex Willer',
    'Tex Willer publicada pela Mythos, dos números 1 a 60.',
    1,
    'RIKA',
    'tex-willer-mythos-volume-1',
    'https://www.rika.com.br/tex-willer--01-12003046/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
    hqhub_normalizar_titulo_serie('Mythos'),
    hqhub_normalizar_titulo_serie('Mythos Editora')
)
ORDER BY CASE
    WHEN hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos') THEN 0
    ELSE 1
END, editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, url_capa, fonte) AS (VALUES
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/333171/Tex-Willer-1.jpg?v=637019072445370000', 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/333172/Tex-Willer-2.jpg?v=637019072459930000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/405945/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_03.jpg?v=637593804551370000', 'RIKA'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/405947/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_04.jpg?v=637593804616670000', 'RIKA'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/405949/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_05.jpg?v=637593804655100000', 'RIKA'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/405951/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_06.jpg?v=637593804693000000', 'RIKA'),
    ('7', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1227998/883031_ampliada.jpg?v=637298062600100000', 'MARTINS_FONTES_PAULISTA'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/405953/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_08.jpg?v=637593804735200000', 'RIKA'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/406053/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_09.jpg?v=637593806944600000', 'RIKA'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/345576/Tex-Willer-10.jpg?v=637234521699030000', 'RIKA'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/345577/Tex-Willer-11.jpg?v=637234521708070000', 'RIKA'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/345578/Tex-Willer-12.jpg?v=637234521717000000', 'RIKA'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/345579/Tex-Willer-13.jpg?v=637234521723170000', 'RIKA'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/345580/Tex-Willer-14.jpg?v=637234521729400000', 'RIKA'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/406055/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_15.jpg?v=637593807003170000', 'RIKA'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/395049/Tex-Willer-16.jpg?v=637483228668030000', 'RIKA'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/395050/Tex-Willer-17.jpg?v=637483228673030000', 'RIKA'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/395051/Tex-Willer-18.jpg?v=637483228677400000', 'RIKA'),
    ('19', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1279342/918085.jpg?v=637332740769200000', 'MARTINS_FONTES_PAULISTA'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/395053/Tex-Willer-20.jpg?v=637483228686170000', 'RIKA'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/395054/Tex-Willer-21.jpg?v=637483228690870000', 'RIKA'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/406136/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_22.jpg?v=637593810050630000', 'RIKA'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/406138/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_23.jpg?v=637593810124030000', 'RIKA'),
    ('24', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1393415/950821.jpg?v=637612849374530000', 'MARTINS_FONTES_PAULISTA'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/406164/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_25.jpg?v=637593810630700000', 'RIKA'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/406166/https---www.artesequencial.com.br-imagens-bonelli-Tex_Willer_26.jpg?v=637593810669700000', 'RIKA'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/411556/Tex-Willer-27.jpg?v=637844305763670000', 'RIKA'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/411557/Tex-Willer-28.jpg?v=637844305774800000', 'RIKA'),
    ('29', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1393937/951056.jpg?v=637616911544970000', 'MARTINS_FONTES_PAULISTA'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/411559/Tex-Willer-30.jpg?v=637844305796070000', 'RIKA'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/411560/Tex-Willer-31.jpg?v=637844305809670000', 'RIKA'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/411561/Tex-Willer-32.jpg?v=637844305821030000', 'RIKA'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/411562/Tex-Willer-33.jpg?v=637844305831500000', 'RIKA'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/411563/Tex-Willer-34.jpg?v=637844305842300000', 'RIKA'),
    ('35', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1423490/971775.jpg?v=637747516487930000', 'MARTINS_FONTES_PAULISTA'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/411565/Tex-Willer-36.jpg?v=637844305867470000', 'RIKA'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/411566/Tex-Willer-37.jpg?v=637844305880930000', 'RIKA'),
    ('38', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1459875/987144.jpg?v=637819535014470000', 'MARTINS_FONTES_PAULISTA'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/412917/Tex-Willer-39.jpg?v=637925319650030000', 'RIKA'),
    ('40', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1474300/995633.jpg?v=637873109048500000', 'MARTINS_FONTES_PAULISTA'),
    ('41', 'https://rika.vteximg.com.br/arquivos/ids/444318/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-41.jpg?v=638269470150000000', 'RIKA'),
    ('42', 'https://rika.vteximg.com.br/arquivos/ids/444320/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-42.jpg?v=638269470181470000', 'RIKA'),
    ('43', 'https://rika.vteximg.com.br/arquivos/ids/444322/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-43.jpg?v=638269470206170000', 'RIKA'),
    ('44', 'https://rika.vteximg.com.br/arquivos/ids/444324/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-44.jpg?v=638269470236200000', 'RIKA'),
    ('45', 'https://rika.vteximg.com.br/arquivos/ids/444326/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-45.jpg?v=638269470264170000', 'RIKA'),
    ('46', 'https://rika.vteximg.com.br/arquivos/ids/444328/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-46.jpg?v=638269470288470000', 'RIKA'),
    ('47', 'https://rika.vteximg.com.br/arquivos/ids/444330/https---www.artesequencial.com.br-imagens-2023-08-Tex-Willer-47.jpg?v=638269470311300000', 'RIKA'),
    ('48', 'https://rika.vteximg.com.br/arquivos/ids/509134/Tex-Willer---48.jpg?v=638947501617470000', 'RIKA'),
    ('49', 'https://rika.vteximg.com.br/arquivos/ids/509136/Tex-Willer---49.jpg?v=638947501653000000', 'RIKA'),
    ('50', 'https://rika.vteximg.com.br/arquivos/ids/509138/Tex-Willer---50.jpg?v=638947501683900000', 'RIKA'),
    ('51', 'https://rika.vteximg.com.br/arquivos/ids/509140/Tex-Willer---51.jpg?v=638947501719200000', 'RIKA'),
    ('52', 'https://rika.vteximg.com.br/arquivos/ids/509142/Tex-Willer---52.jpg?v=638947501753600000', 'RIKA'),
    ('53', 'https://rika.vteximg.com.br/arquivos/ids/509144/Tex-Willer---53.jpg?v=638947501788470000', 'RIKA'),
    ('54', 'https://rika.vteximg.com.br/arquivos/ids/509146/Tex-Willer---54.jpg?v=638947501828300000', 'RIKA'),
    ('55', 'https://rika.vteximg.com.br/arquivos/ids/509148/Tex-Willer---55.jpg?v=638947501865470000', 'RIKA'),
    ('56', 'https://rika.vteximg.com.br/arquivos/ids/509150/Tex-Willer---56.jpg?v=638947501901070000', 'RIKA'),
    ('57', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1739782/1170743.jpg?v=638953581090800000', 'MARTINS_FONTES_PAULISTA'),
    ('58', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1756313/1183485.jpg?v=638985721990700000', 'MARTINS_FONTES_PAULISTA'),
    ('59', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1780840/1198392.jpg?v=639088370113000000', 'MARTINS_FONTES_PAULISTA'),
    ('60', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1804156/1213621.jpg.jpg?v=639180938020900000', 'MARTINS_FONTES_PAULISTA')
), serie_tex_willer AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Willer')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Mythos'),
          hqhub_normalizar_titulo_serie('Mythos Editora')
      )
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, url_capa, fonte_externa, id_externo,
    serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Tex Willer #' || capa.numero,
    'Tex Willer - número ' || capa.numero,
    capa.url_capa,
    capa.fonte,
    'tex-willer-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_willer serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

