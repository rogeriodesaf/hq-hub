-- Cadastra Tex Gigante publicada pela Mythos, dos numeros 1 a 42.
-- Fontes das capas: catalogos publicos da Rika e da loja oficial Mythos.
-- A serie Tex Gigante em Cores e a segunda serie nao fazem parte deste cadastro.

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
    'Tex Gigante',
    'Tex Edicao Gigante publicada pela Mythos, dos numeros 1 a 42.',
    1,
    'RIKA',
    'tex-gigante-mythos-volume-1',
    'https://www.rika.com.br/tex---edicao-gigante--0112000771/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
ORDER BY editora.id
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/157999/-bonelli-tex-gigante-01.jpg?v=635312939063470000', 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/158000/-bonelli-tex-gigante-02.jpg?v=635312939080730000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/158001/-bonelli-tex-gigante-03.jpg?v=635312939098970000', 'RIKA'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/158002/-bonelli-tex-gigante-04.jpg?v=635312939113700000', 'RIKA'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/158003/-bonelli-tex-gigante-05.jpg?v=635312939127770000', 'RIKA'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/158004/-bonelli-tex-gigante-06.jpg?v=635312939143700000', 'RIKA'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/158005/-bonelli-tex-gigante-07.jpg?v=635312939152400000', 'RIKA'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/158006/-bonelli-tex-gigante-08.jpg?v=635312939170100000', 'RIKA'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/158007/-bonelli-tex-gigante-09.jpg?v=635312939186330000', 'RIKA'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/158008/-bonelli-tex-gigante-10.jpg?v=635312939202870000', 'RIKA'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/158009/-bonelli-tex-gigante-11.jpg?v=635312939219230000', 'RIKA'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/158010/-bonelli-tex-gigante-12.jpg?v=635312939235600000', 'RIKA'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/158011/-bonelli-tex-gigante-13.jpg?v=635312939251870000', 'RIKA'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/158012/-bonelli-tex-gigante-14.jpg?v=635312939266730000', 'RIKA'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/158013/-bonelli-tex-gigante-15.jpg?v=635312939284570000', 'RIKA'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/158014/-bonelli-tex-gigante-16.jpg?v=635312939301500000', 'RIKA'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/158015/-bonelli-tex-gigante-17.jpg?v=635312939313470000', 'RIKA'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/158016/-bonelli-tex-gigante-18.jpg?v=635312939331370000', 'RIKA'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/158017/-bonelli-tex-gigante-19.jpg?v=635312939346100000', 'RIKA'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/158018/-bonelli-tex-gigante-20.jpg?v=635312939361330000', 'RIKA'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/319376/Tex-Edicao-Gigante-21.jpg?v=636894754343570000', 'RIKA'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/158020/-bonelli-tex-gigante-22.jpg?v=635312939394730000', 'RIKA'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/158021/-bonelli-tex-gigante-23.jpg?v=635312939410230000', 'RIKA'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/158022/-bonelli-tex-gigante-24.jpg?v=635312939428500000', 'RIKA'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/158023/-bonelli-tex-gigante-25.jpg?v=635312939447400000', 'RIKA'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/285657/tex-edicao-gigante-26.jpg?v=636195823425630000', 'RIKA'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/283603/tex-gigante-27.jpg?v=635915771332000000', 'RIKA'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/283604/tex-gigante-28.jpg?v=635915771350630000', 'RIKA'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/283605/tex-gigante-29.jpg?v=635915771395330000', 'RIKA'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/319375/Tex-Edicao-Gigante-30.jpg?v=636894753698070000', 'RIKA'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/319377/Tex-Edicao-Gigante-31.jpg?v=636894756244200000', 'RIKA'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/319378/Tex-Edicao-Gigante-32.jpg?v=636894760579300000', 'RIKA'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/345607/Tex-Edicao-Gigante-33.jpg?v=637234521934730000', 'RIKA'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/345608/Tex-Edicao-Gigante-34.jpg?v=637234521944000000', 'RIKA'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/395073/Tex-Edicao-Gigante-35.jpg?v=637483228766600000', 'RIKA'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/411569/Tex-Gigante-36.jpg?v=637844305913300000', 'RIKA'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/411570/Tex-Gigante-37.jpg?v=637844305925530000', 'RIKA'),
    ('38', 'https://rika.vteximg.com.br/arquivos/ids/444340/https---www.artesequencial.com.br-imagens-2023-08-Tex-Edicao-Gigante-38.jpg?v=638269470437230000', 'RIKA'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/454796/https---www.artesequencial.com.br-imagens-2024-05-Tex-Edicao-Gigante-39.jpg?v=638506285403030000', 'RIKA'),
    ('40', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_040_1711205_1_681090273d4557407f245c433cdad932.jpg', 'MYTHOS'),
    ('41', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_ed_gigante_no_041_outubro_2025_1711783_1_a828755500ff018c3df21fc0fb731c75.jpg', 'MYTHOS'),
    ('42', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_ed_gigante_n_042_junho2026_1_20260602174512_a819731932f2.jpeg', 'MYTHOS')
), serie_tex_gigante AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Gigante')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
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
    'Tex Gigante #' || capa.numero,
    'Tex Edicao Gigante - numero ' || capa.numero,
    capa.url_capa,
    capa.fonte,
    'tex-gigante-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_gigante serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
