-- Atualiza os dois volumes de Rei Conan Omnibus com capas do catalogo oficial da Mythos.
-- O Guia dos Quadrinhos nao foi usado como fonte das imagens.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Mythos', 'Editora brasileira de quadrinhos e livros.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Rei Conan Omnibus',
    'Colecao em dois volumes com as aventuras de Conan como rei da Aquilonia, publicada pela Mythos.',
    2024, 2025, 1, 'MYTHOS', 'rei-conan-omnibus-mythos-2024',
    'https://www.lojamythos.com.br/hq-s/pre-venda-rei-conan-omnibus-vol-1-setembro2024',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(editora_existente.nome) = hqhub_normalizar_titulo_serie('Mythos')
        AND hqhub_normalizar_titulo_serie(existente.titulo) = hqhub_normalizar_titulo_serie('Rei Conan Omnibus')
  )
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO NOTHING;

UPDATE series serie
SET descricao = 'Colecao em dois volumes com as aventuras de Conan como rei da Aquilonia, publicada pela Mythos.',
    ano_inicio = 2024,
    ano_fim = 2025,
    fonte_externa = 'MYTHOS',
    id_externo = 'rei-conan-omnibus-mythos-2024',
    url_origem = 'https://www.lojamythos.com.br/hq-s/pre-venda-rei-conan-omnibus-vol-1-setembro2024',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
  AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Rei Conan Omnibus');

WITH volumes(numero, subtitulo, data_publicacao, isbn, paginas, url_origem, url_capa) AS (VALUES
    ('1', 'Deuses e Demônios', DATE '2024-09-01', '9786559516315', 420,
     'https://www.lojamythos.com.br/hq-s/pre-venda-rei-conan-omnibus-vol-1-setembro2024',
     'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_rei_conan_omnibus_vol_1_setembro_2024_1711171_1_2aee6ad21077298322fc98136da140b8.jpg'),
    ('2', 'Conquistas e Legados', DATE '2025-04-01', '9786559516599', 488,
     'https://www.lojamythos.com.br/hq-s/pre-venda-rei-conan-omnibus-vol-2-abril2025',
     'https://images.tcdn.com.br/img/img_prod/1119494/pre_venda_rei_conan_omnibus_vol_2_abril_2025_1711495_1_7b0592086d873309b84621f0f14802c3.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Mythos')
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Rei Conan Omnibus')
    ORDER BY
        CASE WHEN serie.id_externo = 'rei-conan-omnibus-mythos-2024' THEN 0 ELSE 1 END,
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
    'Rei Conan Omnibus Vol. ' || volume.numero || ': ' || volume.subtitulo,
    'Volume ' || volume.numero || ' da colecao Rei Conan Omnibus da Mythos.',
    volume.subtitulo,
    volume.data_publicacao,
    volume.url_capa,
    volume.isbn,
    volume.paginas,
    'Capa brochura, 17 x 26 cm, colorido',
    'MYTHOS',
    'rei-conan-omnibus-mythos-' || volume.numero,
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
