CREATE TABLE contribuicoes_catalogo (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    edicao_id BIGINT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    url_capa_sugerida VARCHAR(1000),
    edicao_destino_id BIGINT,
    tipo_publicacao_relacionada VARCHAR(50),
    fonte_externa VARCHAR(100),
    url_fonte VARCHAR(1000),
    dados_sugeridos_json TEXT,
    observacoes VARCHAR(1000),
    mensagem_revisao VARCHAR(1000),
    data_revisao TIMESTAMP,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_contribuicoes_catalogo_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_contribuicoes_catalogo_edicao FOREIGN KEY (edicao_id) REFERENCES edicoes(id),
    CONSTRAINT fk_contribuicoes_catalogo_edicao_destino FOREIGN KEY (edicao_destino_id) REFERENCES edicoes(id)
);

CREATE INDEX idx_contribuicoes_catalogo_usuario ON contribuicoes_catalogo(usuario_id, data_criacao DESC);
CREATE INDEX idx_contribuicoes_catalogo_status ON contribuicoes_catalogo(status, data_criacao ASC);
CREATE INDEX idx_contribuicoes_catalogo_edicao ON contribuicoes_catalogo(edicao_id);
