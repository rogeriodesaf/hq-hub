-- Completa o cadastro Panini de Aniquilação Final e reafirma o vínculo no guia.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Aniquilação Final')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE series serie
SET descricao = 'Encadernado brasileiro do evento cósmico A Aniquilação Final.',
    ano_inicio = 2022,
    ano_fim = 2022,
    fonte_externa = 'COMIX',
    id_externo = '9786559602919',
    url_origem = 'https://www.comix.com.br/a-aniquilac-o-final.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Aniquilação Final')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = 'Frentes de Guerra',
    descricao = 'Uma nova Aniquilação ameaça o cosmo e envolve os Guardiões da Galáxia, a E.S.P.A.D.A., Hulkling, Wiccano, Cable, o Pantera Negra e o Doutor Destino.',
    nome_volume = 'Aniquilação Final — Frentes de Guerra',
    data_publicacao = DATE '2022-07-15',
    url_capa = 'https://www.comix.com.br/media/catalog/product/a/n/aniqueila_ao.jpg',
    codigo_barras = '9786559602919',
    quantidade_paginas = 104,
    preco_capa = 52.90,
    formato = '17 x 26 cm, capa dura',
    fonte_externa = 'COMIX',
    id_externo = '9786559602919',
    url_origem = 'https://www.comix.com.br/a-aniquilac-o-final.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA');

WITH edicao_alvo AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Aniquilação Final')
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA')
    ORDER BY edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicao_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 484;
