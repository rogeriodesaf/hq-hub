-- Mantem somente a Colecao Carl Barks Definitiva Panini V1 e consolida seus volumes.
DO $$
DECLARE
    canonico BIGINT;
BEGIN
    SELECT s.id INTO canonico
    FROM series s JOIN editoras e ON e.id = s.editora_id
    WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva')
      AND lower(trim(e.nome)) LIKE 'panini%'
    ORDER BY CASE WHEN coalesce(s.volume, 1) = 1 THEN 0 ELSE 1 END, s.id
    LIMIT 1;

    IF canonico IS NULL THEN RETURN; END IF;

    -- Preserva na V1 uma capa disponível na edição duplicada antes da remoção.
    UPDATE edicoes existente
    SET url_capa = duplicada.url_capa, data_atualizacao = CURRENT_TIMESTAMP
    FROM edicoes duplicada
    WHERE existente.serie_id = canonico
      AND (existente.url_capa IS NULL OR trim(existente.url_capa) = '')
      AND duplicada.url_capa IS NOT NULL AND trim(duplicada.url_capa) <> ''
      AND duplicada.serie_id IN (
          SELECT s.id FROM series s JOIN editoras e ON e.id = s.editora_id
          WHERE s.id <> canonico
            AND hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva')
            AND lower(trim(e.nome)) LIKE 'panini%'
      )
      AND hqhub_normalizar_identidade(duplicada.numero::text) =
          hqhub_normalizar_identidade(existente.numero::text);

    -- Remove primeiro as edições duplicadas que já existem na V1. Sem isso,
    -- a troca de serie_id viola a identidade única (serie, numero).
    DELETE FROM edicoes duplicada
    USING edicoes existente
    WHERE duplicada.serie_id IN (
        SELECT s.id FROM series s JOIN editoras e ON e.id = s.editora_id
        WHERE s.id <> canonico
          AND hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva')
          AND lower(trim(e.nome)) LIKE 'panini%'
    )
      AND existente.serie_id = canonico
      AND hqhub_normalizar_identidade(duplicada.numero::text) =
          hqhub_normalizar_identidade(existente.numero::text);

    -- Transfere as edições restantes das séries duplicadas para a série canônica.
    UPDATE edicoes ed
    SET serie_id = canonico, data_atualizacao = CURRENT_TIMESTAMP
    WHERE ed.serie_id IN (
        SELECT s.id FROM series s JOIN editoras e ON e.id = s.editora_id
        WHERE s.id <> canonico
          AND hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva')
          AND lower(trim(e.nome)) LIKE 'panini%'
    );

    UPDATE series SET titulo = 'Coleção Carl Barks Definitiva', volume = 1, data_atualizacao = CURRENT_TIMESTAMP WHERE id = canonico;

    DELETE FROM series s
    WHERE s.id <> canonico
      AND hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva')
      AND s.editora_id IN (SELECT e.id FROM editoras e WHERE lower(trim(e.nome)) LIKE 'panini%');
END $$;

-- Aproveita capas existentes em qualquer edição consolidada para preencher lacunas.
UPDATE edicoes alvo
SET url_capa = fonte.url_capa, data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes fonte
WHERE alvo.serie_id IN (SELECT s.id FROM series s JOIN editoras e ON e.id=s.editora_id WHERE hqhub_normalizar_titulo_serie(s.titulo)=hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva') AND lower(trim(e.nome)) LIKE 'panini%')
  AND (alvo.url_capa IS NULL OR trim(alvo.url_capa) = '')
  AND fonte.url_capa IS NOT NULL AND trim(fonte.url_capa) <> ''
  AND ltrim(substring(alvo.numero FROM '([0-9]+)'), '0') = ltrim(substring(fonte.numero FROM '([0-9]+)'), '0');
