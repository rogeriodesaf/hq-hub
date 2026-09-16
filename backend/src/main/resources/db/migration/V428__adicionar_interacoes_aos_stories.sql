CREATE TABLE curtidas_historia_leitura (
    id BIGSERIAL PRIMARY KEY,
    historia_id BIGINT NOT NULL REFERENCES historias_leitura(id) ON DELETE CASCADE,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_curtida_historia_usuario UNIQUE (historia_id, usuario_id)
);

CREATE TABLE comentarios_historia_leitura (
    id BIGSERIAL PRIMARY KEY,
    historia_id BIGINT NOT NULL REFERENCES historias_leitura(id) ON DELETE CASCADE,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    texto VARCHAR(500) NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comentarios_historia ON comentarios_historia_leitura (historia_id, data_criacao);
