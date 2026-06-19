ALTER TABLE series DROP CONSTRAINT IF EXISTS uk_series_titulo_editora;

CREATE UNIQUE INDEX IF NOT EXISTS uk_series_titulo_editora_volume
ON series (titulo, editora_id, COALESCE(volume, 0));
