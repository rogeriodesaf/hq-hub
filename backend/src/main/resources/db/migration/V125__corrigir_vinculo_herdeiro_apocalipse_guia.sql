-- O cadastro existente usa numero "UNICA", não "1". Vincula essa edição
-- ao guia usando a identidade normalizada da série e a numeração real.

WITH candidatos AS (
    SELECT
        edicao.id AS edicao_id,
        row_number() OVER (
            ORDER BY
                CASE WHEN upper(trim(edicao.numero)) IN ('UNICA', 'ÚNICA', 'UNICO', 'ÚNICO') THEN 0 ELSE 1 END,
                edicao.id
        ) AS prioridade
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Panini')
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('X-Men: O Herdeiro de Apocalipse')
      AND coalesce(serie.volume, 1) = 1
      AND (
          upper(trim(edicao.numero)) IN ('UNICA', 'ÚNICA', 'UNICO', 'ÚNICO')
          OR ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '1'
      )
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = coalesce(
        (
            SELECT edicao.url_capa
            FROM edicoes edicao
            WHERE edicao.id = candidato.edicao_id
        ),
        item.url_capa_referencia
    )
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = 587
  AND candidato.prioridade = 1;
