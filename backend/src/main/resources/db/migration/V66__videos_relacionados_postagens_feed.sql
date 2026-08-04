CREATE TABLE videos_relacionados_feed (
    id UUID PRIMARY KEY,
    postagem_id BIGINT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    url VARCHAR(1000) NOT NULL,
    thumbnail VARCHAR(1000),
    nome_canal VARCHAR(200),
    duracao_segundos INTEGER,
    visualizacoes BIGINT,
    ordem INTEGER NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_videos_relacionados_postagem
        FOREIGN KEY (postagem_id) REFERENCES postagens_feed(id) ON DELETE CASCADE,
    CONSTRAINT uk_videos_relacionados_postagem_ordem UNIQUE (postagem_id, ordem)
);

CREATE INDEX idx_videos_relacionados_postagem
    ON videos_relacionados_feed(postagem_id, ordem);
