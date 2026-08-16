-- Cadastra a minisserie brasileira Guerra Civil II (Panini, 2017-2018),
-- adiciona suas seis capas e vincula as edicoes ao guia mutante.
-- As imagens foram publicadas nos checklists da Panini do Planeta Gibi.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Guerra Civil II',
    'Minisserie brasileira Guerra Civil II, publicada pela Panini em seis edicoes.',
    2017,
    2018,
    1,
    'GCD',
    'GCD-SERIES-120522',
    'https://www.comics.org/series/120522/',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
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

WITH capas(numero, url_capa, url_origem) AS (VALUES
    (1, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiJ-85nrRJ5yI1VeF7buqZuxKokqhw23cx-Au-EqbuZMQmhHcJ1-JuRGeHzeDi3tU-1-xHcUafo-9g1gzDd3c9MY-f-dxXcMw8zz4ubXahSKgZfusY6LnhHMHdL-QLPPx3zOYJ62s7scS5i/s1600/capa-GUERRA-CIVIL-II-1-669x1024.jpg', 'https://www.planetagibiblog.com.br/2017/09/checklist-marvel-panini-comics-setembro.html'),
    (2, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiTeA7cXARaHA8wytL4Ln41hyphenhyphenFdR3gzQ5CodFQ_kIvcLtc9l0z7hiGp90hl69d936ZZSBVxYR9DXxU_N6bhFSo7e9xwuHjYlaSkrDL7YY9F0QG5ZJj6kH6fsuvZzgXfObFXDrduyiu_zCVy/s1600/capa-Guerra-Civil-II-2.jpg', 'https://www.planetagibiblog.com.br/2017/10/checklist-marvel-panini-comics-outubro.html'),
    (3, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg48BoeXmxPT11Jbp821SB1rH78yGZic-RgMYqxfKKvZmQnfzGEzDP1U6xpTJ89opuDpJ8IzC8O7HsE0YPEI_6IWvONOnVd-x2h0mApb3DDxkFOhlQ6LWCLy1-Er8a9s6H3vb0ascNb7mAZ/s1600/GUERRA+CIVIL+II+3.jpg', 'https://www.planetagibiblog.com.br/2017/11/checklist-marvel-panini-comics-novembro.html'),
    (4, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjswti0T8A6f6t_54Id-zKX1BEG4v_wwKENKXURWdkpJ-4jjb83y2mA9ZrPG2TTuHc6U2iZ7WwvhpCUuPx3aKZfUeC3dcQ5riMy2h1duBKLrSmQsz8GSjyhTjgrIiNjsO-fCwpCk8UitVvg/s1600/GUERRA-CIVIL-II-4-669x1024.jpg', 'https://www.planetagibiblog.com.br/2017/12/checklist-marvel-panini-comics-dezembro.html'),
    (5, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi_M-1jRasDArKdK0eqsnxzQ7alqpWTqZIO4cOb70GkRxmr4leRlhovmdig9RA8BbTGxD4jXIrcnnyISFNRTKxOfctaI4fK36ZwYznnnczA0i-rVmK_-E8mL0U40CsE3lx83wMHymYI1YH3/s1600/GUERRA-CIVIL-II-5-669x1024.jpg', 'https://www.planetagibiblog.com.br/2018/01/checklist-marvel-panini-comics-janeiro.html'),
    (6, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgNz3P2TVn-DfAGp3wr5qZF9TikXifNcO1T7vIvzhenrYCUfw6J2HGo5ndO8fuT2rrlApCcb-K-1CuJG4L6xoUt138EhQHR0elK-fv2gpwpWr3vvHtweT-XYbLHcbZD7oKhpm_1r51sgPM/s1600/GUERRA-CIVIL-II-6-669x1024.jpg', 'https://www.planetagibiblog.com.br/2018/02/checklist-marvel-panini-comics.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Guerra Civil II')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero::text,
    'Guerra Civil II Vol. ' || lpad(capa.numero::text, 2, '0'),
    capa.url_capa,
    'PLANETA_GIBI',
    'PLANETA-GIBI-GUERRA-CIVIL-II-' || lpad(capa.numero::text, 3, '0'),
    capa.url_origem,
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

WITH vinculos(posicao, numero) AS (VALUES
    (324, '1'), (325, '2'), (326, '3'),
    (327, '4'), (328, '5'), (329, '6')
), candidatos AS (
    SELECT vinculo.posicao, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON trim(edicao.numero) = vinculo.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Guerra Civil II')
      AND coalesce(serie.volume, 0) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
