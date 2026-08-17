-- Completa a capa que faltava no segundo item de Surpreendentes X-Men.

WITH edicao_alvo AS (
    SELECT edicao.id
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Surpreendentes X-Men: Um Homem Chamado X')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY edicao.id
    LIMIT 1
), atualizada AS (
    UPDATE edicoes edicao
    SET url_capa = 'https://filfelix.com.br/wp-content/uploads/2020/08/Surpreendentes-X-Men-Um-Homem-Chamado-X-capa-666x1024.jpg',
        fonte_externa = 'FIL_FELIX',
        url_origem = 'https://filfelix.com.br/2020/08/review-surpreendentes-x-men-um-homem-chamado-x.html',
        data_atualizacao = CURRENT_TIMESTAMP
    FROM edicao_alvo alvo
    WHERE edicao.id = alvo.id
    RETURNING edicao.id, edicao.url_capa
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa
FROM atualizada edicao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 406;
