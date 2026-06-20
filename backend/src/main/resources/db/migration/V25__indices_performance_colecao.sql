CREATE INDEX IF NOT EXISTS idx_itens_colecao_usuario_status_id
    ON itens_colecao (usuario_id, status_leitura, id);

CREATE INDEX IF NOT EXISTS idx_itens_colecao_usuario_data_atualizacao
    ON itens_colecao (usuario_id, data_atualizacao DESC);

CREATE INDEX IF NOT EXISTS idx_itens_colecao_edicao
    ON itens_colecao (edicao_id);

CREATE INDEX IF NOT EXISTS idx_edicoes_serie_numero_lower
    ON edicoes (serie_id, lower(numero));

CREATE INDEX IF NOT EXISTS idx_edicoes_titulo_lower
    ON edicoes (lower(titulo));

CREATE INDEX IF NOT EXISTS idx_series_editora_titulo_lower
    ON series (editora_id, lower(titulo));

CREATE INDEX IF NOT EXISTS idx_editoras_nome_lower
    ON editoras (lower(nome));

CREATE INDEX IF NOT EXISTS idx_contribuicoes_catalogo_status_data
    ON contribuicoes_catalogo (status, data_criacao);
