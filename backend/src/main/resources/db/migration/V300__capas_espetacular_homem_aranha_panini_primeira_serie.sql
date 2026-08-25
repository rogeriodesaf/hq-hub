-- Atualiza O Espetacular Homem-Aranha, 1a serie (Panini, 2011).
-- A edicao 1 usa a capa publicada pelo Universo HQ.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 1ª Série')
    ORDER BY
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
), capas(numero, data_publicacao, url_capa, fonte_externa, id_externo, url_origem) AS (
    VALUES
        ('1', DATE '2011-03-01',
         'https://images.universohq.com/2011/09/EspetacularHA1.jpg',
         'UNIVERSO_HQ', 'ESPETACULARHA1',
         'https://universohq.com/reviews/o-espetacular-homem-aranha-1/')
)
UPDATE edicoes edicao
SET data_publicacao = capa.data_publicacao,
    url_capa = capa.url_capa,
    quantidade_paginas = 28,
    formato = 'Magazine, capa couche, miolo pisa',
    fonte_externa = capa.fonte_externa,
    id_externo = capa.id_externo,
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie, capas capa
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(capa.numero);

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha, 1ª Série')
    ORDER BY
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
)
UPDATE series serie
SET ano_inicio = 2011,
    ano_fim = 2011,
    volume = 1,
    fonte_externa = 'PLANETA_GIBI',
    id_externo = 'ESPETACULAR_HOMEM_ARANHA_2011',
    url_origem = 'https://www.planetagibiblog.com.br/2011/03/checklist-marco-2011-marvel.html',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo alvo
WHERE serie.id = alvo.id;
