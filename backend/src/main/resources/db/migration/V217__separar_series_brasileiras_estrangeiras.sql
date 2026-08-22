ALTER TABLE series
    ADD COLUMN IF NOT EXISTS tipo_serie VARCHAR(20) NOT NULL DEFAULT 'BRASILEIRA';

-- Uma serie e estrangeira quando suas edicoes aparecem como publicacao original
-- de outra serie, mas nunca como a edicao brasileira/publicada desses vinculos.
UPDATE series serie
SET tipo_serie = 'ESTRANGEIRA'
WHERE EXISTS (
    SELECT 1
    FROM edicoes original
    JOIN publicacoes_historias publicacao ON publicacao.edicao_original_id = original.id
    WHERE original.serie_id = serie.id
      AND publicacao.edicao_original_id <> publicacao.edicao_publicada_id
)
AND NOT EXISTS (
    SELECT 1
    FROM edicoes publicada
    JOIN publicacoes_historias publicacao ON publicacao.edicao_publicada_id = publicada.id
    WHERE publicada.serie_id = serie.id
      AND publicacao.edicao_original_id <> publicacao.edicao_publicada_id
);

CREATE INDEX IF NOT EXISTS idx_series_tipo_titulo
    ON series(tipo_serie, lower(titulo));
