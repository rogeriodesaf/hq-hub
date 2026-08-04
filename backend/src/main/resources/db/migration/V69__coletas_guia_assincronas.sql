CREATE TABLE coletas_guia (
    id UUID PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
    pedido_json TEXT NOT NULL,
    urls_json TEXT NOT NULL,
    edicoes_json TEXT NOT NULL,
    avisos_json TEXT NOT NULL,
    resultado_json TEXT,
    total_paginas INTEGER NOT NULL DEFAULT 0,
    paginas_processadas INTEGER NOT NULL DEFAULT 0,
    paginas_no_lote INTEGER NOT NULL DEFAULT 0,
    falhas_consecutivas INTEGER NOT NULL DEFAULT 0,
    proxima_execucao TIMESTAMP,
    mensagem VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_coletas_guia_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE INDEX idx_coletas_guia_usuario_data
    ON coletas_guia(usuario_id, data_criacao DESC);
