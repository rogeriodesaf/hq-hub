-- Cadastra os quatro volumes de Conan, O Cimério - Edição Definitiva,
-- publicados pela Pipoca & Nanquim entre 2022 e 2024.
-- Capas obtidas na Estante Virtual; o Guia dos Quadrinhos não foi usado como fonte das imagens.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Pipoca & Nanquim', 'Editora brasileira de quadrinhos e livros.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan, O Cimério - Edição Definitiva',
    'Coleção em quatro volumes publicada pela Pipoca & Nanquim entre 2022 e 2024, reunindo adaptações francesas dos contos de Robert E. Howard.',
    1,
    'ESTANTE_VIRTUAL',
    'conan-o-cimerio-edicao-definitiva-pipoca-nanquim',
    'https://www.estantevirtual.com.br/livro/conan-o-cimerio-edicao-definitiva-vol-1-reimpressao-EBT-3022-000-BK',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Pipoca & Nanquim')
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

WITH capas(numero, ano_publicacao, url_capa) AS (VALUES
    ('1', 2022, 'https://static.estantevirtual.com.br/book/00/EBT-3022-000/EBT-3022-000_detail1.jpg?ts=1731131577137'),
    ('2', 2022, 'https://static.estantevirtual.com.br/book/00/E1X-0410-000/E1X-0410-000_detail1.jpg?ts=1722857080705'),
    ('3', 2023, 'https://static.estantevirtual.com.br/book/00/E1X-0414-000/E1X-0414-000_detail1.jpg?ts=1738274555403'),
    ('4', 2024, 'https://static.estantevirtual.com.br/book/00/EF3-5159-000/EF3-5159-000_detail1.jpg?ts=1724349221472')
), serie_conan AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'conan-o-cimerio-edicao-definitiva-pipoca-nanquim'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Pipoca & Nanquim')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Conan, O Cimério - Edição Definitiva Vol. ' || capa.numero,
    'Volume ' || capa.numero || ' da coleção Conan, O Cimério - Edição Definitiva.',
    'Volume ' || capa.numero,
    make_date(capa.ano_publicacao, 1, 1),
    capa.url_capa,
    'ESTANTE_VIRTUAL',
    'conan-o-cimerio-edicao-definitiva-pipoca-nanquim-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_conan serie
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
