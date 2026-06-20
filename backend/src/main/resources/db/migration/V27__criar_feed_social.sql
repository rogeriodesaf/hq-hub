CREATE TABLE postagens_feed (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    conteudo VARCHAR(2000) NOT NULL,
    url_imagem VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_postagens_feed_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_postagens_feed_usuario_data ON postagens_feed(usuario_id, data_criacao DESC);
CREATE INDEX idx_postagens_feed_data ON postagens_feed(data_criacao DESC);

CREATE TABLE comentarios_feed (
    id BIGSERIAL PRIMARY KEY,
    postagem_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    texto VARCHAR(1000) NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_comentarios_feed_postagem FOREIGN KEY (postagem_id) REFERENCES postagens_feed(id) ON DELETE CASCADE,
    CONSTRAINT fk_comentarios_feed_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_comentarios_feed_postagem_data ON comentarios_feed(postagem_id, data_criacao);

CREATE TABLE curtidas_postagens_feed (
    id BIGSERIAL PRIMARY KEY,
    postagem_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_curtidas_feed_postagem FOREIGN KEY (postagem_id) REFERENCES postagens_feed(id) ON DELETE CASCADE,
    CONSTRAINT fk_curtidas_feed_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT uk_curtidas_feed_postagem_usuario UNIQUE (postagem_id, usuario_id)
);

CREATE INDEX idx_curtidas_feed_postagem ON curtidas_postagens_feed(postagem_id);
CREATE INDEX idx_curtidas_feed_usuario ON curtidas_postagens_feed(usuario_id);
