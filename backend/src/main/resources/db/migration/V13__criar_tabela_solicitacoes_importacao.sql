CREATE TABLE solicitacoes_importacao (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    fonte_externa VARCHAR(100) NOT NULL,
    termo VARCHAR(255) NOT NULL,
    url_origem VARCHAR(1000),
    status VARCHAR(50) NOT NULL,
    mensagem VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_solicitacoes_importacao_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_solicitacoes_importacao_usuario ON solicitacoes_importacao (usuario_id);
CREATE INDEX idx_solicitacoes_importacao_status ON solicitacoes_importacao (status);
