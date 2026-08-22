-- Cadastra o encadernado Guerra Civil II da linha Nova Marvel Deluxe.
-- Não altera a minissérie mensal homônima de seis edições já existente.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Nova Marvel Deluxe: Guerra Civil II',
    'Encadernado integral de Guerra Civil II publicado pela Panini na linha Nova Marvel Deluxe.',
    1,
    'PANINI',
    'nova-marvel-deluxe-guerra-civil-ii-panini-v1',
    'https://www.rika.com.br/guerra-civil-ii-15008658/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
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

WITH serie_guerra_civil_ii AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'nova-marvel-deluxe-guerra-civil-ii-panini-v1'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    '1',
    'Nova Marvel Deluxe: Guerra Civil II',
    'Reúne Civil War II 0-8 e Free Comic Book Day 2016: Civil War II.',
    'Guerra Civil II',
    DATE '2022-02-01',
    'https://rika.vteximg.com.br/arquivos/ids/423308/https---www.artesequencial.com.br-imagens-2023-04-guerra-civil-2.jpg?v=639078036216670000',
    'RIKA',
    'nova-marvel-deluxe-guerra-civil-ii-panini-1',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_guerra_civil_ii serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
