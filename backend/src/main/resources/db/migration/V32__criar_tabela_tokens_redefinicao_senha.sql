CREATE TABLE tokens_redefinicao_senha (
    token       VARCHAR(36) NOT NULL PRIMARY KEY,
    usuario_id  BIGINT      NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    expira_em   TIMESTAMP   NOT NULL
);

CREATE INDEX idx_tokens_redefinicao_senha_usuario ON tokens_redefinicao_senha(usuario_id);
