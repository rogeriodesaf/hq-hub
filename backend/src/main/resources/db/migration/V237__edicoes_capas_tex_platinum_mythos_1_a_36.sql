-- Cadastra Tex Platinum publicada pela Mythos, dos numeros 1 a 36.
-- Fontes das capas: catalogos publicos da Rika e Martins Fontes Paulista.
-- Imagens genericas indisponiveis sao ignoradas. Nenhuma imagem vem do Guia dos Quadrinhos.

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
    'Tex Platinum',
    'Tex Platinum publicada pela Mythos, dos números 1 a 36.',
    1,
    'RIKA',
    'tex-platinum-mythos-volume-1',
    'https://www.rika.com.br/tex-platinum--0112002922/p',
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
    ('1', NULL, 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/319399/Tex-Platinum-02.jpg?v=636894796731500000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/319289/Platinum-Tex-03.jpg?v=636893779678900000', 'RIKA'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/405901/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_04.jpg?v=637593803656200000', 'RIKA'),
    ('5', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/305728/842920_ampliada.jpg?v=637253981641370000', 'MARTINS_FONTES_PAULISTA'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/405903/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_06.jpg?v=637593803696070000', 'RIKA'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/405905/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_07.jpg?v=637593803736530000', 'RIKA'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/405907/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_08.jpg?v=637593803774800000', 'RIKA'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/405909/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_09.jpg?v=637593803814970000', 'RIKA'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/405911/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_10.jpg?v=637593803855630000', 'RIKA'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/405913/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_11.jpg?v=637593803891900000', 'RIKA'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/405915/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_12.jpg?v=637593803930400000', 'RIKA'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/333152/Tex-Platinum-13.jpg?v=637019072270900000', 'RIKA'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/333153/Tex-Platinum-14.jpg?v=637019072279330000', 'RIKA'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/333154/Tex-Platinum-15.jpg?v=637019072286530000', 'RIKA'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/333155/Tex-Platinum-16.jpg?v=637019072295070000', 'RIKA'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/333156/Tex-Platinum-17.jpg?v=637019072301270000', 'RIKA'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/333157/Tex-Platinum-18.jpg?v=637019072306770000', 'RIKA'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/333158/Tex-Platinum-19.jpg?v=637019072312230000', 'RIKA'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/405931/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_20.jpg?v=637593804263070000', 'RIKA'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/405933/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_21.jpg?v=637593804301700000', 'RIKA'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/405935/https---www.artesequencial.com.br-imagens-bonelli-Tex_Platinum_22.jpg?v=637593804341770000', 'RIKA'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/345602/Tex-Platinum-23.jpg?v=637234521892400000', 'RIKA'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/345603/Tex-Platinum-24.jpg?v=637234521901700000', 'RIKA'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/345604/Tex-Platinum-25.jpg?v=637234521907670000', 'RIKA'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/395021/Tex-Platinum-26.jpg?v=637483228553700000', 'RIKA'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/395022/Tex-Platinum-27.jpg?v=637483228559030000', 'RIKA'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/395023/Tex-Platinum-28.jpg?v=637483228563230000', 'RIKA'),
    ('29', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1425452/972781.jpg?v=637756288381430000', 'MARTINS_FONTES_PAULISTA'),
    ('30', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1425445/972772.jpg?v=637756246328200000', 'MARTINS_FONTES_PAULISTA'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/411588/Tex-Platinum-31.jpg?v=637844306124300000', 'RIKA'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/411589/Tex-Platinum-32.jpg?v=637844306135430000', 'RIKA'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/411590/Tex-Platinum-33.jpg?v=637844306145900000', 'RIKA'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/411591/Tex-Platinum-34.jpg?v=637844306155130000', 'RIKA'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/411592/Tex-Platinum-35.jpg?v=637844306164830000', 'RIKA'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/411593/Tex-Platinum-36.jpg?v=637844306175130000', 'RIKA')
), serie_tex_platinum AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Platinum')
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
    'Tex Platinum #' || capa.numero,
    'Tex Platinum - número ' || capa.numero,
    capa.url_capa,
    capa.fonte,
    'tex-platinum-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_platinum serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = COALESCE(EXCLUDED.url_capa, edicoes.url_capa),
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

