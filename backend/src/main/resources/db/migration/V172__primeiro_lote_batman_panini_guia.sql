-- Primeiro lote confirmado do guia cronologico do Batman.
-- Metadados, referencias e capas sao provenientes das paginas oficiais da Panini.

WITH referencias(titulo, descricao, ano, volume, id_externo, url_origem) AS (VALUES
    ('Gotham City: Ano Um', 'Edicao brasileira que reune Gotham City: Year One 1 a 6.', 2023, 1, 'AGCAN001', 'https://panini.com.br/gotham-city-ano-um'),
    ('Batman: O Cavaleiro', 'Edicao brasileira da minisserie Batman: The Knight.', 2023, 1, 'ACVAL', 'https://panini.com.br/batman-o-cavaleiro-01'),
    ('Batman: Ano Um', 'Edicao Absoluta brasileira que reune Batman 404 a 407 e material adicional.', 2023, 1, 'ABMAC001', 'https://panini.com.br/batman-ano-um-edicao-absoluta'),
    ('Batman: Xama', 'Edicao brasileira que reune Batman: Legends of the Dark Knight 1 a 5.', 2024, 1, 'ABMBL001', 'https://panini.com.br/batman-xama-abmbl001')
)
INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    referencia.titulo, referencia.descricao, referencia.ano, referencia.ano,
    referencia.volume, 'PANINI', referencia.id_externo, referencia.url_origem,
    editora.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN LATERAL (
    SELECT id FROM editoras WHERE lower(trim(nome)) = 'panini' ORDER BY id LIMIT 1
) editora
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH referencias(titulo_serie, numero, titulo_edicao, nome_volume, ano, formato, id_externo, url_capa, url_origem) AS (VALUES
    ('Gotham City: Ano Um', 'UNICA', 'Gotham City: Ano Um', NULL, 2023, '192 paginas, capa cartao', 'AGCAN001', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_o6vi6rna3162f3g6pdmq8a2d7l/-S265-FWEBP', 'https://panini.com.br/gotham-city-ano-um'),
    ('Batman: O Cavaleiro', '1', 'Batman: O Cavaleiro 01', 'Volume 1', 2023, '144 paginas, capa dura', 'ACVAL001', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uvkiekmkrd5bn39skpkf5h2e4p/-S265-FWEBP', 'https://panini.com.br/batman-o-cavaleiro-01'),
    ('Batman: O Cavaleiro', '2', 'Batman: O Cavaleiro 02', 'Volume 2', 2023, '144 paginas, capa dura', 'ACVAL002', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_i0191i91ht44d7lkbd49mvah3s/-S265-FWEBP', 'https://panini.com.br/batman-o-cavaleiro-02'),
    ('Batman: Ano Um', 'UNICA', 'Batman: Ano Um - Edicao Absoluta', 'Edicao Absoluta', 2023, '296 paginas, capa dura', 'ABMAC001', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_dik9df4ijd5m7fl7q2ndvd9913/-S265-FWEBP', 'https://panini.com.br/batman-ano-um-edicao-absoluta'),
    ('Batman: Xama', 'UNICA', 'Batman: Xama', NULL, 2024, '144 paginas, capa dura', 'ABMBL001', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_kvvt3h0v511vtc13a0gtfqvb3s/-S265-FWEBP', 'https://panini.com.br/batman-xama-abmbl001')
), series_alvo AS (
    SELECT serie.id, serie.titulo
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini' AND serie.volume = 1
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, url_capa, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    referencia.numero, referencia.titulo_edicao, referencia.nome_volume,
    referencia.url_capa, referencia.formato, 'PANINI', referencia.id_externo,
    referencia.url_origem, serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM referencias referencia
JOIN series_alvo serie
  ON hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(referencia.titulo_serie)
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

WITH vinculos(posicao, id_externo, ano, observacao) AS (VALUES
    (1, 'AGCAN001', 2023, 'Identificacao confirmada na pagina oficial da Panini (referencia AGCAN001).'),
    (2, 'ACVAL001', 2023, 'Identificacao confirmada na pagina oficial da Panini (referencia ACVAL001).'),
    (3, 'ACVAL002', 2023, 'Identificacao confirmada na pagina oficial da Panini (referencia ACVAL002).'),
    (4, 'ABMAC001', 2023, 'Vinculada a Edicao Absoluta brasileira da Panini (referencia ABMAC001).'),
    (6, 'ABMBL001', 2024, 'Identificacao confirmada na pagina oficial da Panini (referencia ABMBL001).')
), edicoes_alvo AS (
    SELECT DISTINCT ON (vinculo.posicao)
        vinculo.posicao, vinculo.ano, vinculo.observacao, edicao.id, edicao.url_capa
    FROM vinculos vinculo
    JOIN edicoes edicao ON upper(trim(edicao.id_externo)) = vinculo.id_externo
    ORDER BY vinculo.posicao, edicao.id
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = edicao.observacao,
    ano_referencia = edicao.ano
FROM edicoes_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = edicao.posicao;
