-- Correlaciona a historia curta "Cicatrizes" ("Scars"), publicada originalmente
-- em Batman: Gotham Knights (2000) #8, com duas de suas publicacoes brasileiras.
-- A edicao original usa o identificador canonico do Comic Vine; a relacao entre
-- as publicacoes brasileiras foi conferida no Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES
    ('DC Comics', 'Editora norte-americana de quadrinhos.', 'Estados Unidos da America', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Abril', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('Panini Comics', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO NOTHING;

WITH dados(titulo, descricao, ano_inicio, volume, fonte_externa, id_externo, url_origem, editora, tipo_serie) AS (
    VALUES
        ('Batman: Gotham Knights', 'Serie original publicada pela DC Comics.', 2000, 1,
         'COMICVINE', '4050-7207', 'https://comicvine.gamespot.com/batman-gotham-knights/4050-7207/', 'DC Comics', 'ESTRANGEIRA'),
        ('Batman', 'Sexta serie brasileira de Batman publicada pela Abril.', 2000, 6,
         'GUIA_DOS_QUADRINHOS', 'batman-abril-sexta-serie', NULL, 'Abril', 'BRASILEIRA'),
        ('Batman Noir: Eduardo Risso', 'Volume unico publicado pela Panini em 2019.', 2019, 1,
         'GUIA_DOS_QUADRINHOS', 'batman-noir-eduardo-risso-panini', NULL, 'Panini Comics', 'BRASILEIRA')
)
INSERT INTO series (
    titulo, descricao, ano_inicio, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    dados.titulo, dados.descricao, dados.ano_inicio, dados.volume,
    dados.fonte_externa, dados.id_externo, dados.url_origem,
    editora.id, dados.tipo_serie, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM dados
JOIN editoras editora ON hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie(dados.editora)
WHERE NOT EXISTS (
    SELECT 1
    FROM series existente
    WHERE existente.editora_id = editora.id
      AND coalesce(existente.volume, 0) = coalesce(dados.volume, 0)
      AND hqhub_normalizar_titulo_serie(existente.titulo) = hqhub_normalizar_titulo_serie(dados.titulo)
);

WITH edicoes_desejadas(numero, titulo, nome_volume, data_publicacao, fonte_externa, id_externo, url_origem,
                       serie_titulo, serie_volume, editora_nome) AS (
    VALUES
        ('8', 'Batman: Gotham Knights #8', 'Transference, Part 1 of Four', DATE '2000-10-01',
         'COMICVINE', '4000-55302', 'https://comicvine.gamespot.com/batman-gotham-knights-8/4000-55302/',
         'Batman: Gotham Knights', 1, 'DC Comics'),
        ('17', 'Batman #17', 'Batman #17', DATE '2001-12-01',
         'GUIA_DOS_QUADRINHOS', 'batman-abril-6-17', NULL,
         'Batman', 6, 'Abril'),
        ('UNICA', 'Batman Noir: Eduardo Risso', 'Batman Noir: Eduardo Risso', DATE '2019-12-01',
         'GUIA_DOS_QUADRINHOS', 'batman-noir-eduardo-risso-unica', NULL,
         'Batman Noir: Eduardo Risso', 1, 'Panini Comics')
), alvos AS (
    SELECT dados.*, serie.id AS serie_id
    FROM edicoes_desejadas dados
    JOIN editoras editora
      ON hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie(dados.editora_nome)
    JOIN series serie
      ON serie.editora_id = editora.id
     AND coalesce(serie.volume, 0) = dados.serie_volume
     AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(dados.serie_titulo)
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, data_publicacao, fonte_externa, id_externo,
    url_origem, url_comic_vine, id_comic_vine, serie_id, data_criacao, data_atualizacao
)
SELECT
    numero, titulo, nome_volume, data_publicacao, fonte_externa, id_externo,
    url_origem,
    CASE WHEN fonte_externa = 'COMICVINE' THEN url_origem END,
    CASE WHEN fonte_externa = 'COMICVINE' THEN id_externo END,
    serie_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM alvos
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero)) DO UPDATE SET
    titulo = coalesce(edicoes.titulo, EXCLUDED.titulo),
    nome_volume = coalesce(edicoes.nome_volume, EXCLUDED.nome_volume),
    data_publicacao = coalesce(edicoes.data_publicacao, EXCLUDED.data_publicacao),
    fonte_externa = coalesce(edicoes.fonte_externa, EXCLUDED.fonte_externa),
    id_externo = coalesce(edicoes.id_externo, EXCLUDED.id_externo),
    url_origem = coalesce(edicoes.url_origem, EXCLUDED.url_origem),
    url_comic_vine = coalesce(edicoes.url_comic_vine, EXCLUDED.url_comic_vine),
    id_comic_vine = coalesce(edicoes.id_comic_vine, EXCLUDED.id_comic_vine),
    data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO historias (
    titulo, titulo_original, titulo_portugues, descricao, quantidade_paginas, tipo,
    fonte_externa, id_externo, url_origem, data_criacao, data_atualizacao
)
SELECT
    'Cicatrizes', 'Scars', 'Cicatrizes',
    'Historia curta em preto e branco escrita por Brian Azzarello e desenhada por Eduardo Risso.',
    8, 'HISTORIA', 'GUIA_DOS_QUADRINHOS',
    'batman-gotham-knights|8|2000|scars',
    'https://www.guiadosquadrinhos.com/edicao-estrangeira/batman-gotham-knights-%282000%29-n-8/1146/11625',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM historias
    WHERE fonte_externa = 'GUIA_DOS_QUADRINHOS'
      AND id_externo = 'batman-gotham-knights|8|2000|scars'
);

WITH historia_alvo AS (
    SELECT id FROM historias
    WHERE fonte_externa = 'GUIA_DOS_QUADRINHOS'
      AND id_externo = 'batman-gotham-knights|8|2000|scars'
    ORDER BY id LIMIT 1
), edicoes_alvo AS (
    SELECT edicao.id, serie.tipo_serie, editora.nome AS editora, serie.titulo AS serie, edicao.numero
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE (edicao.id_comic_vine = '4000-55302')
       OR (hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Abril')
           AND serie.volume = 6 AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman')
           AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('17'))
       OR (hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')
           AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman Noir: Eduardo Risso')
           AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA'))
)
INSERT INTO conteudos_edicoes (
    edicao_id, historia_id, ordem, titulo_usado, quantidade_paginas, tipo,
    observacoes, data_criacao, data_atualizacao
)
SELECT
    edicao.id, historia.id,
    coalesce((SELECT max(conteudo.ordem) + 1 FROM conteudos_edicoes conteudo WHERE conteudo.edicao_id = edicao.id), 1),
    'Cicatrizes', 8, 'HISTORIA',
    CASE WHEN edicao.tipo_serie = 'ESTRANGEIRA' THEN 'Titulo original: Scars.' END,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM edicoes_alvo edicao
CROSS JOIN historia_alvo historia
WHERE NOT EXISTS (
    SELECT 1 FROM conteudos_edicoes conteudo
    WHERE conteudo.edicao_id = edicao.id AND conteudo.historia_id = historia.id
);

WITH historia_alvo AS (
    SELECT id FROM historias
    WHERE fonte_externa = 'GUIA_DOS_QUADRINHOS'
      AND id_externo = 'batman-gotham-knights|8|2000|scars'
    ORDER BY id LIMIT 1
), original AS (
    SELECT id FROM edicoes WHERE id_comic_vine = '4000-55302' ORDER BY id LIMIT 1
), brasileiras AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE (hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Abril')
           AND serie.volume = 6 AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman')
           AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('17'))
       OR (hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')
           AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Batman Noir: Eduardo Risso')
           AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA'))
)
INSERT INTO publicacoes_historias (
    historia_id, edicao_original_id, edicao_publicada_id, status, tipo_publicacao_historia,
    titulo_usado, paginas_publicadas, fonte_externa, url_origem,
    fonte_informacao, url_fonte_informacao, status_validacao,
    data_criacao, data_atualizacao
)
SELECT
    historia.id, original.id, brasileira.id, 'COMPLETA', 'PUBLICACAO_BRASILEIRA',
    'Cicatrizes', 8, 'GUIA_DOS_QUADRINHOS',
    'https://www.guiadosquadrinhos.com/edicao-estrangeira/batman-gotham-knights-%282000%29-n-8/1146/11625',
    'GUIA_DOS_QUADRINHOS',
    'https://www.guiadosquadrinhos.com/edicao-estrangeira/batman-gotham-knights-%282000%29-n-8/1146/11625',
    'APROVADA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM historia_alvo historia
CROSS JOIN original
CROSS JOIN brasileiras brasileira
ON CONFLICT (historia_id, edicao_publicada_id) DO NOTHING;
