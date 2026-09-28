DELETE FROM notificacoes_sociais WHERE lida = TRUE;

CREATE TABLE visualizacoes_alteracoes_estante (
    usuario_id BIGINT NOT NULL,
    contribuicao_id BIGINT NOT NULL,
    data_visualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, contribuicao_id),
    CONSTRAINT fk_visualizacoes_alteracoes_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_visualizacoes_alteracoes_contribuicao
        FOREIGN KEY (contribuicao_id) REFERENCES contribuicoes_catalogo(id) ON DELETE CASCADE
);

CREATE INDEX idx_visualizacoes_alteracoes_contribuicao
    ON visualizacoes_alteracoes_estante(contribuicao_id);
