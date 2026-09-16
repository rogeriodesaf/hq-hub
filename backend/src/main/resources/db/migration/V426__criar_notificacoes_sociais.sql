CREATE TABLE notificacoes_sociais (
    id BIGSERIAL PRIMARY KEY,
    destinatario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    autor_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo VARCHAR(40) NOT NULL,
    postagem_id BIGINT REFERENCES postagens_feed(id) ON DELETE CASCADE,
    comentario_id BIGINT REFERENCES comentarios_feed(id) ON DELETE CASCADE,
    mensagem VARCHAR(500) NOT NULL,
    lida BOOLEAN NOT NULL DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notificacoes_destinatario ON notificacoes_sociais (destinatario_id, lida, data_criacao DESC);
CREATE UNIQUE INDEX uk_notificacao_curtida_postagem ON notificacoes_sociais (destinatario_id, autor_id, tipo, postagem_id)
    WHERE tipo = 'CURTIDA_POSTAGEM';
CREATE UNIQUE INDEX uk_notificacao_curtida_comentario ON notificacoes_sociais (destinatario_id, autor_id, tipo, comentario_id)
    WHERE tipo = 'CURTIDA_COMENTARIO';
