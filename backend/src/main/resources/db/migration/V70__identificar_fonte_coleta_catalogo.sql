ALTER TABLE coletas_guia
    ADD COLUMN fonte VARCHAR(20) NOT NULL DEFAULT 'GUIA';

CREATE INDEX idx_coletas_guia_usuario_fonte_data
    ON coletas_guia(usuario_id, fonte, data_criacao DESC);
