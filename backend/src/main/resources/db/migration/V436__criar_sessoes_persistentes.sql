CREATE TABLE sessoes_persistentes (
    token_hash VARCHAR(64) PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    expira_em TIMESTAMP NOT NULL
);

CREATE INDEX idx_sessoes_persistentes_usuario ON sessoes_persistentes(usuario_id);
