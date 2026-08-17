-- Cadastra a segunda serie mensal brasileira de X-Men (Panini, 2013-2016),
-- composta por 34 edicoes, e vincula ao guia a edicao 29.
-- A fonte possui fotografias reais da colecao; a foto de referencia da #29
-- mostra o lote correspondente sem recorrer a uma capa estrangeira incorreta.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'X-Men',
    'Segunda serie mensal brasileira de X-Men, fase Nova Marvel, publicada em 34 edicoes.',
    2013, 2016, 2, 'COMIC_CITY', 'COMIC-CITY-X-MEN-V2-1-34',
    'https://www.comiccitystore.com.br/x-men-2-serie-nova-totalmente-nova-marvel-volumes-1-a-34-completo',
    editora.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men')
      AND serie.volume = 2
    ORDER BY serie.id
    LIMIT 1
), referencias AS (
    SELECT
        numero,
        CASE
            WHEN numero = 1 THEN 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/12/x-men-panini-2aserie-01-danif-768x1199.jpg'
            WHEN numero BETWEEN 2 AND 10 THEN 'https://cdn.awsli.com.br/2500x2500/222/222576/produto/234875825/whatsapp-image-2023-09-07-at-12-39-52--1--0eartx7sa7.jpeg'
            WHEN numero BETWEEN 11 AND 20 THEN 'https://cdn.awsli.com.br/2500x2500/222/222576/produto/234875825/whatsapp-image-2023-09-07-at-12-39-51--1--9xwm189ue0.jpeg'
            WHEN numero BETWEEN 21 AND 30 THEN 'https://cdn.awsli.com.br/2500x2500/222/222576/produto/234875825/whatsapp-image-2023-09-07-at-12-39-50--2--91txdmpt4v.jpeg'
            ELSE 'https://cdn.awsli.com.br/2500x2500/222/222576/produto/234875825/whatsapp-image-2023-09-07-at-12-39-50--1--rwnmpzsnni.jpeg'
        END AS url_capa
    FROM generate_series(1, 34) AS numero
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, data_publicacao, url_capa, formato,
    fonte_externa, id_externo, url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    referencia.numero::varchar,
    'X-Men #' || referencia.numero,
    'X-Men - Segunda Serie',
    (DATE '2013-11-01' + ((referencia.numero - 1) || ' months')::interval)::date,
    referencia.url_capa,
    '17 x 26 cm, capa cartao, lombada com grampos',
    'COMIC_CITY',
    'COMIC-CITY-X-MEN-V2-' || referencia.numero,
    'https://www.comiccitystore.com.br/x-men-2-serie-nova-totalmente-nova-marvel-volumes-1-a-34-completo',
    serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('X-Men')
      AND serie.volume = 2
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('29')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 279;
