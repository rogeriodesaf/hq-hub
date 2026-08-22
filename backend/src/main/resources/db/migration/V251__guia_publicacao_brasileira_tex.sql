-- Cria o guia completo de Tex com as colecoes brasileiras presentes no catalogo.
-- A ordem entre as colecoes considera o inicio de publicacao no Brasil; dentro de
-- cada colecao, as edicoes seguem a numeracao editorial cadastrada no HQ-HUB.

INSERT INTO ordens_leitura (
    slug, titulo, descricao, publicada, data_criacao, data_atualizacao
)
VALUES (
    'tex-ordem-publicacao-brasileira',
    'Tex — Ordem de Publicação Brasileira',
    'Guia das edições brasileiras de Tex disponíveis no HQ-HUB, organizado pela data de lançamento de cada coleção e pela sequência editorial de seus números. Inclui a revista principal, reedições, coleções, especiais e linhas paralelas.',
    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (slug) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    publicada = EXCLUDED.publicada,
    data_atualizacao = CURRENT_TIMESTAMP;

CREATE TEMP TABLE hqhub_tex_colecoes_guia (
    ordem_colecao INTEGER PRIMARY KEY,
    inicio DATE NOT NULL,
    secao VARCHAR(180) NOT NULL,
    editora VARCHAR(120) NOT NULL,
    volume INTEGER NOT NULL,
    id_serie VARCHAR(180),
    titulo_serie VARCHAR(255) NOT NULL,
    rotulo VARCHAR(300) NOT NULL,
    observacao VARCHAR(1000)
) ON COMMIT DROP;

INSERT INTO hqhub_tex_colecoes_guia (
    ordem_colecao, inicio, secao, editora, volume, id_serie,
    titulo_serie, rotulo, observacao
) VALUES
    (10, DATE '1971-02-01', 'Década de 1970 — estreia pela Vecchi', 'Vecchi', 1, NULL,
     'Tex', 'Tex — Vecchi (1ª edição, desde fev/1971)',
     'Série principal brasileira. A numeração continua posteriormente pela RGE, Globo e Mythos.'),
    (20, DATE '1977-04-01', 'Década de 1970 — reedição da Vecchi', 'Vecchi', 2, 'tex-vecchi-segunda-edicao',
     'Tex', 'Tex — Vecchi (2ª edição, desde abr/1977)',
     'Republicação. Pode repetir histórias existentes na série principal.'),
    (30, DATE '1983-09-01', 'Década de 1980 — fase RGE', 'RGE', 2, 'tex-rge-segunda-edicao',
     'Tex', 'Tex — RGE (2ª edição, desde 1983)',
     'Continuação da segunda edição iniciada pela Vecchi; começa pelo número 94-A.'),
    (40, DATE '1983-10-01', 'Década de 1980 — fase RGE', 'RGE', 1, 'tex-rge-volume-1',
     'Tex', 'Tex — RGE (série principal, desde out/1983)',
     'Continuação direta da numeração da primeira edição da Vecchi.'),
    (50, DATE '1987-01-01', 'Década de 1980 — fase Globo', 'Globo', 1, 'tex-globo-volume-1',
     'Tex', 'Tex — Globo (série principal, desde jan/1987)',
     'Continuação direta da numeração da RGE.'),
    (60, DATE '1987-03-01', 'Década de 1980 — republicações da Globo', 'Globo', 1, 'tex-colecao-globo-volume-1',
     'Tex Coleção', 'Tex Coleção — Globo (desde mar/1987)',
     'Republicação em ordem italiana. O número 1 foi publicado pela RGE em novembro de 1986.'),
    (70, DATE '1993-08-01', 'Década de 1990 — edições históricas', 'Globo', 1, 'tex-edicao-historica-globo-volume-1',
     'Tex Edição Histórica', 'Tex Edição Histórica — Globo (desde ago/1993)',
     'Republicação de histórias completas; pode repetir material de Tex Coleção.'),
    (80, DATE '1999-01-01', 'Década de 1990 — início da Mythos', 'Mythos', 1, NULL,
     'Tex', 'Tex — Mythos (série principal, desde jan/1999)',
     'Continuação direta da numeração da Globo.'),
    (90, DATE '1999-01-01', 'Década de 1990 — início da Mythos', 'Mythos', 1, 'tex-colecao-mythos-volume-1',
     'Tex Coleção', 'Tex Coleção — Mythos (desde jan/1999)',
     'Continuação da coleção publicada pela Globo; republica histórias clássicas.'),
    (100, DATE '1999-03-01', 'Década de 1990 — especiais da Mythos', 'Mythos', 1, 'tex-gigante-mythos-volume-1',
     'Tex Gigante', 'Tex Edição Gigante — Mythos (desde mar/1999)',
     'Histórias especiais em formato ampliado.'),
    (110, DATE '1999-12-01', 'Década de 1990 — especiais da Mythos', 'Mythos', 1, 'tex-anual-mythos-volume-1',
     'Tex Anual', 'Tex Anual — Mythos (desde dez/1999)',
     'Edição especial anual.'),
    (120, DATE '2002-06-01', 'Década de 2000 — novas coleções', 'Mythos', 1, 'tex-edicao-de-ouro-mythos-volume-1',
     'Tex Edição de Ouro', 'Tex Edição de Ouro — Mythos (desde jun/2002)',
     'Seleção de histórias completas; pode republicar material já presente em outras coleções.'),
    (130, DATE '2012-04-01', 'Década de 2010 — edições coloridas e de luxo', 'Mythos', 1, 'tex-edicao-especial-colorida-mythos-volume-1',
     'Tex Edição Especial Colorida', 'Tex Edição Especial Colorida — Mythos (desde abr/2012)',
     'Edições especiais em cores.'),
    (140, DATE '2014-01-01', 'Década de 2010 — edições coloridas e de luxo', 'Mythos', 1, 'tex-edicao-gigante-em-cores-mythos-volume-1',
     'Tex Edição Gigante em Cores', 'Tex Edição Gigante em Cores — Mythos (desde 2014)',
     'Versões coloridas de histórias da linha gigante; republicação alternativa.'),
    (150, DATE '2016-02-01', 'Década de 2010 — formatos especiais', 'Mythos', 1, 'tex-platinum-mythos-volume-1',
     'Tex Platinum', 'Tex Platinum — Mythos (desde fev/2016)',
     'Histórias completas em edição especial; pode conter republicações.'),
    (160, DATE '2016-04-01', 'Década de 2010 — formatos especiais', 'Mythos', 1, 'tex-graphic-novel-mythos-volume-1',
     'Tex Graphic Novel', 'Tex Graphic Novel — Mythos (desde abr/2016)',
     'Graphic novels autorais e independentes da sequência mensal.'),
    (170, DATE '2017-10-01', 'Década de 2010 — coleções de luxo', 'Salvat', 1, 'tex-gold-salvat-volume-1',
     'Tex Gold', 'Tex Gold — Salvat (desde out/2017)',
     'Coleção de luxo em cores; republica histórias selecionadas.'),
    (180, DATE '2018-12-01', 'Década de 2010 — coleções de luxo', 'Mythos', 1, 'tex-omnibus-mythos-volume-1',
     'Tex Omnibus', 'Tex Omnibus — Mythos (desde dez/2018)',
     'Republicação de luxo da saga clássica em grandes volumes.'),
    (190, DATE '2019-01-01', 'Década de 2010 — juventude de Tex', 'Mythos', 1, 'tex-willer-mythos-volume-1',
     'Tex Willer', 'Tex Willer — Mythos (desde jan/2019)',
     'Série paralela dedicada à juventude de Tex.'),
    (200, DATE '2020-12-01', 'Década de 2020 — juventude de Tex', 'Mythos', 1, 'tex-willer-especial-mythos-volume-1',
     'Tex Willer Especial', 'Tex Willer Especial — Mythos (desde dez/2020)',
     'Especiais ligados à série da juventude de Tex.'),
    (210, DATE '2024-01-01', 'Década de 2020 — grandes autores', 'Mythos', 1, 'tex-grandes-mestres-mythos-volume-1',
     'Tex - Grandes Mestres', 'Tex — Grandes Mestres (desde jan/2024)',
     'Seleção por grandes desenhistas; contém republicações.'),
    (220, DATE '2025-02-01', 'Década de 2020 — republicações atuais', 'Mythos', 2, 'tex-gigante-mythos-volume-2',
     'Tex Gigante', 'Tex Gigante — 2ª série (desde fev/2025)',
     'Republicação em papel offset da coleção gigante.' );

-- Evita itens obsoletos caso o guia seja recriado durante desenvolvimento.
DELETE FROM itens_ordem_leitura
WHERE ordem_leitura_id = (
    SELECT id FROM ordens_leitura WHERE slug = 'tex-ordem-publicacao-brasileira'
);

WITH series_guia AS (
    SELECT DISTINCT ON (mapa.ordem_colecao)
        mapa.*,
        serie.id AS serie_id
    FROM hqhub_tex_colecoes_guia mapa
    JOIN editoras editora
      ON hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie(mapa.editora)
    JOIN series serie ON serie.editora_id = editora.id
    WHERE serie.tipo_serie = 'BRASILEIRA'
      AND coalesce(serie.volume, 1) = mapa.volume
      AND (
          (mapa.id_serie IS NOT NULL AND serie.id_externo = mapa.id_serie)
          OR (
              mapa.id_serie IS NULL
              AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(mapa.titulo_serie)
          )
      )
    ORDER BY mapa.ordem_colecao, serie.id
), edicoes_guia AS (
    SELECT
        colecao.*,
        edicao.id AS edicao_id,
        edicao.numero,
        edicao.titulo,
        edicao.url_capa,
        edicao.data_publicacao,
        row_number() OVER (
            PARTITION BY colecao.ordem_colecao
            ORDER BY
                CASE WHEN edicao.numero ~ '^[0-9]+' THEN regexp_replace(edicao.numero, '[^0-9].*$', '')::integer ELSE 2147483647 END,
                CASE WHEN upper(edicao.numero) LIKE '%A%' THEN 1 ELSE 0 END,
                edicao.id
        ) AS ordem_edicao
    FROM series_guia colecao
    JOIN edicoes edicao ON edicao.serie_id = colecao.serie_id
), itens_ordenados AS (
    SELECT
        row_number() OVER (ORDER BY ordem_colecao, ordem_edicao)::integer AS posicao,
        edicoes_guia.*
    FROM edicoes_guia
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT
    ordem.id,
    item.posicao,
    item.secao,
    item.edicao_id,
    coalesce(item.titulo, item.rotulo || ' #' || item.numero),
    item.rotulo,
    item.url_capa,
    'CONFIRMADO',
    item.observacao,
    CASE
        WHEN item.data_publicacao IS NOT NULL THEN extract(year FROM item.data_publicacao)::integer
        ELSE NULL
    END
FROM itens_ordenados item
JOIN ordens_leitura ordem ON ordem.slug = 'tex-ordem-publicacao-brasileira';

UPDATE ordens_leitura ordem
SET url_capa = primeira.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM (
    SELECT item.ordem_leitura_id, edicao.url_capa
    FROM itens_ordem_leitura item
    JOIN edicoes edicao ON edicao.id = item.edicao_id
    JOIN ordens_leitura guia ON guia.id = item.ordem_leitura_id
    WHERE guia.slug = 'tex-ordem-publicacao-brasileira'
      AND edicao.url_capa IS NOT NULL
    ORDER BY item.posicao
    LIMIT 1
) primeira
WHERE ordem.id = primeira.ordem_leitura_id;
