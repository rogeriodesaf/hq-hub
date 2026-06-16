CREATE TABLE publicacoes_relacionadas (
    id BIGSERIAL PRIMARY KEY,
    edicao_origem_id BIGINT NOT NULL,
    edicao_destino_id BIGINT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    fonte_externa VARCHAR(100),
    url_origem VARCHAR(1000),
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_publicacoes_relacionadas_origem FOREIGN KEY (edicao_origem_id) REFERENCES edicoes(id),
    CONSTRAINT fk_publicacoes_relacionadas_destino FOREIGN KEY (edicao_destino_id) REFERENCES edicoes(id),
    CONSTRAINT uk_publicacoes_relacionadas_origem_destino_tipo UNIQUE (edicao_origem_id, edicao_destino_id, tipo),
    CONSTRAINT ck_publicacoes_relacionadas_edicoes_diferentes CHECK (edicao_origem_id <> edicao_destino_id)
);

CREATE INDEX idx_series_titulo_lower ON series (lower(titulo));
CREATE INDEX idx_edicoes_serie ON edicoes (serie_id);
CREATE INDEX idx_edicoes_data_publicacao ON edicoes (data_publicacao);
CREATE INDEX idx_creditos_edicoes_criador ON creditos_edicoes (criador_id);
CREATE INDEX idx_itens_colecao_usuario ON itens_colecao (usuario_id);
CREATE INDEX idx_publicacoes_relacionadas_origem ON publicacoes_relacionadas (edicao_origem_id);
CREATE INDEX idx_publicacoes_relacionadas_destino ON publicacoes_relacionadas (edicao_destino_id);
