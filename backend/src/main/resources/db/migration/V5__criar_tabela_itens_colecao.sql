CREATE TABLE itens_colecao (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    edicao_id BIGINT NOT NULL,
    estado_conservacao VARCHAR(50) NOT NULL,
    data_aquisicao DATE,
    preco_pago NUMERIC(10, 2),
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_itens_colecao_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_itens_colecao_edicoes FOREIGN KEY (edicao_id) REFERENCES edicoes(id),
    CONSTRAINT uk_itens_colecao_usuario_edicao UNIQUE (usuario_id, edicao_id)
);
