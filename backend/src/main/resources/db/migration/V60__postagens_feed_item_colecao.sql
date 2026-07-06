ALTER TABLE postagens_feed
    ADD COLUMN IF NOT EXISTS item_colecao_id BIGINT;

ALTER TABLE postagens_feed
    ADD CONSTRAINT fk_postagens_feed_item_colecao
    FOREIGN KEY (item_colecao_id)
    REFERENCES itens_colecao(id)
    ON DELETE SET NULL;
