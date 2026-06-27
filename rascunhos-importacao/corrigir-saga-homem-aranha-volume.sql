-- Move edicoes da Saga do Homem-Aranha, A importadas por engano em V1
-- para a serie sem volume (V-), que ja contem as edicoes 1 a 16.
--
-- Seguro para reexecutar: so move quando a edicao ainda nao existe no destino.

WITH series_saga AS (
    SELECT
        s.id,
        s.volume
    FROM series s
    JOIN editoras e ON e.id = s.editora_id
    WHERE s.titulo = 'Saga do Homem-Aranha, A'
      AND e.nome = 'Panini'
      AND COALESCE(s.volume, 0) IN (0, 1)
),
serie_destino AS (
    SELECT id
    FROM series_saga
    WHERE volume IS NULL
    LIMIT 1
),
serie_origem AS (
    SELECT id
    FROM series_saga
    WHERE volume = 1
    LIMIT 1
),
edicoes_para_mover AS (
    SELECT ed.id
    FROM edicoes ed
    JOIN serie_origem origem ON origem.id = ed.serie_id
    JOIN serie_destino destino ON TRUE
    WHERE ed.numero IN ('17', '18', '19', '20', '21', '22', '23', '24')
      AND NOT EXISTS (
          SELECT 1
          FROM edicoes existente
          WHERE existente.serie_id = destino.id
            AND existente.numero = ed.numero
      )
)
UPDATE edicoes ed
SET serie_id = (SELECT id FROM serie_destino),
    data_atualizacao = NOW()
WHERE ed.id IN (SELECT id FROM edicoes_para_mover);

DELETE FROM series s
USING editoras e
WHERE s.editora_id = e.id
  AND s.titulo = 'Saga do Homem-Aranha, A'
  AND e.nome = 'Panini'
  AND s.volume = 1
  AND NOT EXISTS (
      SELECT 1
      FROM edicoes ed
      WHERE ed.serie_id = s.id
  );
