-- Cadastra as edicoes 1 a 26 de Tex Anual publicadas pela Mythos.
-- Fontes das capas: Rika e loja oficial da Mythos. Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de historias em quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Tex Anual',
    'Tex Anual publicada pela Mythos, dos numeros 1 a 26.',
    1,
    'MYTHOS',
    'tex-anual-mythos-volume-1',
    'https://www.lojamythos.com.br/tex-anual',
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
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/158025/-bonelli-tex-anual-01.jpg?v=635312939478430000', 'RIKA'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/158026/-bonelli-tex-anual-02.jpg?v=635312939493300000', 'RIKA'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/158027/-bonelli-tex-anual-03.jpg?v=635312939507900000', 'RIKA'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/158028/-bonelli-tex-anual-04.jpg?v=635312939524070000', 'RIKA'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/158029/-bonelli-tex-anual-05.jpg?v=635312939539170000', 'RIKA'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/158030/-bonelli-tex-anual-06.jpg?v=635312939552700000', 'RIKA'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/158031/-bonelli-tex-anual-07.jpg?v=635312939567670000', 'RIKA'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/158032/-bonelli-tex-anual-08.jpg?v=635312939585300000', 'RIKA'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/158033/-bonelli-tex-anual-09.jpg?v=635312939599330000', 'RIKA'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/158034/-bonelli-tex-anual-10.jpg?v=635312939616370000', 'RIKA'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/158035/-bonelli-tex-anual-11.jpg?v=635312939629630000', 'RIKA'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/158036/-bonelli-tex-anual-12.jpg?v=635312939644600000', 'RIKA'),
    ('13', 'https://rika.vteximg.com.br/arquivos/ids/158037/-bonelli-tex-anual-13.jpg?v=635312939659770000', 'RIKA'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/283607/tex-anual-14.jpg?v=635915771455730000', 'RIKA'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/283608/tex-anual-15.jpg?v=635915771479130000', 'RIKA'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/283609/tex-anual-16.jpg?v=635915771502730000', 'RIKA'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/405819/https---www.artesequencial.com.br-imagens-bonelli-Tex_Anual_17.jpg?v=637593801884270000', 'RIKA'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/405853/https---www.artesequencial.com.br-imagens-bonelli-Tex_Anual_18.jpg?v=637593802662000000', 'RIKA'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/319332/Tex-Anual-19.jpg?v=636893920774430000', 'RIKA'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/406069/https---www.artesequencial.com.br-imagens-bonelli-Tex_Anual_20.jpg?v=637593807512830000', 'RIKA'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/345601/Tex-Anual-21.jpg?v=637234521883330000', 'RIKA'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/411582/Tex-Anual-22.jpg?v=637844306063300000', 'RIKA'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/411583/Tex-Anual-23.jpg?v=637844306074200000', 'RIKA'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/454802/https---www.artesequencial.com.br-imagens-2024-05-Tex-Anual-24.jpg?v=638506285472330000', 'RIKA'),
    ('25', 'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_tex_anual_no_025_dezembro_2024_1711245_1_07f5bc67722efe48daffa6fc923edaeb.jpg', 'MYTHOS'),
    ('26', 'https://images.tcdn.com.br/img/img_prod/1119494/pr_venda_tex_anual_n_026_dezembro2025_1_20251201111136_a8d680f8902c.jpg', 'MYTHOS')
), serie_tex_anual AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex Anual')
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
    'Tex Anual #' || capa.numero,
    'Tex Anual - numero ' || capa.numero,
    capa.url_capa,
    capa.fonte,
    'tex-anual-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_anual serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
