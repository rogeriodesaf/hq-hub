ALTER TABLE postagens_feed
    ADD COLUMN IF NOT EXISTS sistema BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_postagens_feed_sistema_data
    ON postagens_feed(sistema, data_criacao DESC);
