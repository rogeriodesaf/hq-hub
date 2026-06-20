CREATE TABLE imagens_postagens_feed (
    id BIGSERIAL PRIMARY KEY,
    postagem_id BIGINT,
    url_imagem VARCHAR(1000) NOT NULL,
    url_thumbnail VARCHAR(1000) NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    tipo_mime VARCHAR(80) NOT NULL,
    tamanho_bytes BIGINT NOT NULL,
    largura INTEGER,
    altura INTEGER,
    ordem INTEGER NOT NULL DEFAULT 0,
    data_criacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_imagens_postagens_feed_postagem FOREIGN KEY (postagem_id) REFERENCES postagens_feed(id) ON DELETE CASCADE
);

CREATE INDEX idx_imagens_postagens_feed_postagem_ordem ON imagens_postagens_feed(postagem_id, ordem);
