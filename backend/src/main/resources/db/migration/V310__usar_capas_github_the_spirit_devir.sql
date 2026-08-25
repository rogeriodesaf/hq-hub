-- Usa os arquivos versionados no proprio repositorio para evitar dependencia
-- do roteamento de recursos estaticos do servico de backend.

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'devir%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('The Spirit')
      AND COALESCE(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
), capas(numero, url_capa) AS (
    VALUES
        ('3', 'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/backend/src/main/resources/META-INF/resources/capas/the-spirit-devir/the-spirit-3.jpg'),
        ('4', 'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/backend/src/main/resources/META-INF/resources/capas/the-spirit-devir/the-spirit-4.jpg'),
        ('5', 'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/backend/src/main/resources/META-INF/resources/capas/the-spirit-devir/the-spirit-5.jpg'),
        ('6', 'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/backend/src/main/resources/META-INF/resources/capas/the-spirit-devir/the-spirit-6.jpg'),
        ('8', 'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/backend/src/main/resources/META-INF/resources/capas/the-spirit-devir/the-spirit-8.jpg')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie, capas capa
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade(capa.numero);
