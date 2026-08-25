-- Corrige a importacao anterior de The Spirit: o texto "Spirit n. 30 Kitchen Sink"
-- foi interpretado como numero da edicao brasileira, criando um registro espurio #30.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('The Spirit')
      AND COALESCE(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
DELETE FROM edicoes edicao
USING serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('30')
  AND edicao.id_externo = 'devir|the spirit|1|30';

UPDATE series serie
SET descricao = 'Serie brasileira de historias classicas de The Spirit, publicada em coedicao pela Acme e Devir.',
    ano_inicio = 1994,
    ano_fim = 1995,
    fonte_externa = 'ACME_DEVIR',
    id_externo = 'THE-SPIRIT-ACME-DEVIR-1994',
    url_origem = 'https://www.comix.com.br/colec-o-general-the-spirit-will-eisner-devir-acme.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('The Spirit')
  AND COALESCE(serie.volume, 0) = 1;
