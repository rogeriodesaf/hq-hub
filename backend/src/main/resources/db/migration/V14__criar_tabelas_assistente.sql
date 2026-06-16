CREATE TABLE conversas_assistente (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_conversas_assistente_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE mensagens_assistente (
    id BIGSERIAL PRIMARY KEY,
    conversa_id BIGINT NOT NULL,
    remetente VARCHAR(30) NOT NULL,
    conteudo TEXT NOT NULL,
    origem VARCHAR(80),
    dados TEXT,
    data_criacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_mensagens_assistente_conversa FOREIGN KEY (conversa_id) REFERENCES conversas_assistente(id)
);

CREATE INDEX idx_conversas_assistente_usuario_data ON conversas_assistente(usuario_id, data_atualizacao DESC);
CREATE INDEX idx_mensagens_assistente_conversa_data ON mensagens_assistente(conversa_id, data_criacao ASC);
