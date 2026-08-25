-- Atualiza os dois volumes de Conan - O Cimerio Omnibus com capas oficiais da Mythos.
-- O Guia dos Quadrinhos nao foi usado como fonte das imagens.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de quadrinhos e livros.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Conan - O Cimério Omnibus',
    'Colecao em dois volumes com minisserias e aventuras da fase Dark Horse de Conan, publicada pela Mythos em 2026.',
    2026, 2026, 1, 'MYTHOS', 'conan-o-cimerio-omnibus-mythos-2026',
    'https://www.lojamythos.com.br/hqs-livro/pre-venda-conan-o-cimerio-omnibus-vol-01-fevereiro2026',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) = hqhub_normalizar_titulo_serie('Mythos')
        AND hqhub_normalizar_titulo_serie(existente.titulo) = hqhub_normalizar_titulo_serie('Conan - O Cimério Omnibus')
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

UPDATE series serie
SET descricao = 'Colecao em dois volumes com minisserias e aventuras da fase Dark Horse de Conan, publicada pela Mythos em 2026.',
    ano_inicio = 2026,
    ano_fim = 2026,
    fonte_externa = 'MYTHOS',
    id_externo = 'conan-o-cimerio-omnibus-mythos-2026',
    url_origem = 'https://www.lojamythos.com.br/hqs-livro/pre-venda-conan-o-cimerio-omnibus-vol-01-fevereiro2026',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
  AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Conan - O Cimério Omnibus');

WITH volumes(numero, data_publicacao, isbn, paginas, url_origem, url_capa) AS (VALUES
    ('1', DATE '2026-02-01', '9786559517978', 396,
     'https://www.lojamythos.com.br/hqs-livro/pre-venda-conan-o-cimerio-omnibus-vol-01-fevereiro2026',
     'https://images.tcdn.com.br/img/img_prod/1119494/conan_o_cimrio_omnibus_vol01_1_20260619184945_ffd6161a5e46.jpg'),
    ('2', DATE '2026-04-01', '9786559518203', 372,
     'https://www.lojamythos.com.br/hqs-livro/pre-venda-conan-o-cimerio-omnibus-vol-02-abril2026',
     'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_conan_o_cimerio_omnibus_vol_02_abril_2026_1711953_1_ce813754aa199c8d337fc4dec12b2154.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Conan - O Cimério Omnibus')
    ORDER BY
        CASE WHEN serie.id_externo = 'conan-o-cimerio-omnibus-mythos-2026' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    codigo_barras, quantidade_paginas, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    volume.numero,
    'Conan - O Cimério Omnibus Vol. ' || volume.numero,
    'Volume ' || volume.numero || ' da colecao Conan - O Cimerio Omnibus da Mythos.',
    'Volume ' || volume.numero,
    volume.data_publicacao,
    volume.url_capa,
    volume.isbn,
    volume.paginas,
    'Capa brochura, 17 x 26 cm, colorido',
    'MYTHOS',
    'conan-o-cimerio-omnibus-mythos-' || volume.numero,
    volume.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM volumes volume
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    codigo_barras = EXCLUDED.codigo_barras,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
