CREATE TABLE colecoes_series (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    serie_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    prioridade INTEGER,
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_colecoes_series_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_colecoes_series_series FOREIGN KEY (serie_id) REFERENCES series(id),
    CONSTRAINT uk_colecoes_series_usuario_serie UNIQUE (usuario_id, serie_id)
);
