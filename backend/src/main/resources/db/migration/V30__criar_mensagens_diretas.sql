CREATE TABLE mensagens_diretas (
    id BIGSERIAL PRIMARY KEY,
    remetente_id BIGINT NOT NULL,
    destinatario_id BIGINT NOT NULL,
    texto TEXT NOT NULL,
    lida BOOLEAN NOT NULL DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mensagens_diretas_remetente FOREIGN KEY (remetente_id) REFERENCES usuarios(id),
    CONSTRAINT fk_mensagens_diretas_destinatario FOREIGN KEY (destinatario_id) REFERENCES usuarios(id),
    CONSTRAINT ck_mensagens_diretas_usuarios_diferentes CHECK (remetente_id <> destinatario_id)
);

CREATE INDEX idx_mensagens_diretas_conversa
    ON mensagens_diretas(remetente_id, destinatario_id, data_criacao DESC);

CREATE INDEX idx_mensagens_diretas_destinatario_lida
    ON mensagens_diretas(destinatario_id, lida, data_criacao DESC);
