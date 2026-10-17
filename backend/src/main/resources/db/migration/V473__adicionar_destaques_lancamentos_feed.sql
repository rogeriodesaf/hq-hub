ALTER TABLE postagens_feed
    ADD COLUMN edicao_lancamento_id BIGINT REFERENCES edicoes(id) ON DELETE SET NULL,
    ADD COLUMN data_lancamento DATE;

CREATE INDEX idx_postagens_feed_lancamentos
    ON postagens_feed (tipo_postagem, data_lancamento DESC, data_criacao DESC);
