ALTER TABLE series
    ADD COLUMN volume INTEGER,
    ADD COLUMN ordem_cronologica INTEGER;

CREATE TABLE relacionamentos_series (
    id BIGSERIAL PRIMARY KEY,
    serie_origem_id BIGINT NOT NULL,
    serie_destino_id BIGINT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    observacoes VARCHAR(500),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_relacionamentos_series_origem FOREIGN KEY (serie_origem_id) REFERENCES series(id),
    CONSTRAINT fk_relacionamentos_series_destino FOREIGN KEY (serie_destino_id) REFERENCES series(id),
    CONSTRAINT uk_relacionamentos_series_origem_destino_tipo UNIQUE (serie_origem_id, serie_destino_id, tipo),
    CONSTRAINT ck_relacionamentos_series_series_diferentes CHECK (serie_origem_id <> serie_destino_id)
);
