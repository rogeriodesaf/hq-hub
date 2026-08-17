-- Substitui as imagens bloqueadas do Guia dos Quadrinhos por capas diretas
-- verificadas dos dois encadernados brasileiros de Jean Grey (Panini).

WITH referencias(numero, titulo, url_capa, url_origem) AS (VALUES
    (
        '1',
        'O Retorno de Jean',
        'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgbbWf7EG0h9PYFA4lXitAEclTwjfyb8Cjj80L7rGCeetUK5pZdOhzNFPTBIm0W3fMFdExbQHV6bTmLr5UnloPWVQOtQ9ALW_Az4HXLdswm5BBofkyo3CM9e0HOPoyv69jtF8svdcOq9S4/s320-rw/EN%2BJEAN%2BGREY1.jpg',
        'https://www.planetagibiblog.com.br/2018/09/checklist-marvel-panini-comics-setembro.html'
    ),
    (
        '2',
        'Guerras Psíquicas',
        'https://splashpages.wordpress.com/wp-content/uploads/2019/04/abrjeangrey.jpg?w=840',
        'https://splashpages.wordpress.com/2019/04/30/melhores-e-piores-leituras-de-abril-de-2019/'
    )
)
UPDATE edicoes edicao
SET titulo = referencia.titulo,
    nome_volume = 'Jean Grey Vol. ' || referencia.numero,
    url_capa = referencia.url_capa,
    fonte_externa = 'IMPRENSA_QUADRINHOS',
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(editora.nome)) = 'panini'
  AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Jean Grey')
  AND coalesce(serie.volume, 0) = 1
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(referencia.numero);

WITH referencias(posicao, numero) AS (VALUES
    (401, '1'),
    (402, '2')
), edicoes_alvo AS (
    SELECT referencia.posicao, edicao.id, edicao.url_capa
    FROM referencias referencia
    JOIN edicoes edicao
      ON hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(referencia.numero)
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Jean Grey')
      AND coalesce(serie.volume, 0) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM edicoes_alvo edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = edicao.posicao;
