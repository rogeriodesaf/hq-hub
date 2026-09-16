CREATE TABLE historias_leitura (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    texto VARCHAR(280),
    url_imagem VARCHAR(1000) NOT NULL,
    titulo_hq VARCHAR(300),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP NOT NULL
);

CREATE INDEX idx_historias_leitura_ativas ON historias_leitura (data_expiracao, data_criacao DESC);
CREATE INDEX idx_historias_leitura_usuario ON historias_leitura (usuario_id, data_criacao DESC);

CREATE TABLE visualizacoes_historia_leitura (
    id BIGSERIAL PRIMARY KEY,
    historia_id BIGINT NOT NULL REFERENCES historias_leitura(id) ON DELETE CASCADE,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    data_visualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_visualizacao_historia_usuario UNIQUE (historia_id, usuario_id)
);
