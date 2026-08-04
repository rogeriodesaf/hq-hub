CREATE TABLE curtidas_comentarios_feed (
    id BIGSERIAL PRIMARY KEY,
    comentario_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_curtidas_comentarios_feed_comentario
        FOREIGN KEY (comentario_id) REFERENCES comentarios_feed(id) ON DELETE CASCADE,
    CONSTRAINT fk_curtidas_comentarios_feed_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT uk_curtidas_comentarios_feed_comentario_usuario UNIQUE (comentario_id, usuario_id)
);

CREATE INDEX idx_curtidas_comentarios_feed_comentario
    ON curtidas_comentarios_feed(comentario_id);

CREATE INDEX idx_curtidas_comentarios_feed_usuario
    ON curtidas_comentarios_feed(usuario_id);
