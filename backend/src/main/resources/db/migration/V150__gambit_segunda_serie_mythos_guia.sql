-- Cadastra a segunda serie brasileira de Gambit (Mythos, 1999), suas duas
-- edicoes e capas, e vincula ambas as referencias existentes no guia mutante.

INSERT INTO editoras (
    nome, descricao, pais_origem, data_criacao, data_atualizacao
)
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
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Gambit',
    'Minisserie brasileira em duas edicoes que compila Gambit (1997) 1 a 4.',
    1999,
    1999,
    2,
    'BANCA_DO_GIBI',
    'MYTHOS-GAMBIT-SEGUNDA-SERIE',
    'https://www.bancadogibi.com.br/9738441-GAMBIT-2-SERIE-n-1-ao-2-COMPLETO',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'mythos'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, titulo, url_capa) AS (VALUES
    ('1', 'Demônios Internos', 'https://maniadegibi.com/medias/Gambit_1Serie_01-1.jpg'),
    ('2', 'Um Beijo Antes da Morte!', 'https://maniadegibi.com/medias/Gambit_1Serie_02-1.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'mythos'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Gambit')
      AND coalesce(serie.volume, 0) = 2
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    capa.titulo,
    capa.url_capa,
    'MANIA_DE_GIBI',
    'MYTHOS-GAMBIT-V2-' || capa.numero,
    'https://maniadegibi.com/categoria-produto/marvel/x-men/editora-mythos-x-men/',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH referencias(posicao, numero) AS (VALUES
    (128, '1'),
    (129, '2')
), candidatos AS (
    SELECT referencia.posicao, referencia.numero, edicao.id AS edicao_id, edicao.url_capa
    FROM referencias referencia
    JOIN edicoes edicao ON trim(edicao.numero) = referencia.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'mythos'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Gambit')
      AND coalesce(serie.volume, 0) = 2
)
UPDATE itens_ordem_leitura item
SET titulo_referencia = 'Gambit',
    detalhe_referencia = 'V2 #' || referencia.numero,
    edicao_id = referencia.edicao_id,
    url_capa_referencia = referencia.url_capa
FROM candidatos referencia
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = referencia.posicao;
