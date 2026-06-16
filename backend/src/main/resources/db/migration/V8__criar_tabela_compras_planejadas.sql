CREATE TABLE compras_planejadas (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    edicao_id BIGINT NOT NULL,
    mes INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    prioridade VARCHAR(50) NOT NULL,
    preco_estimado NUMERIC(10, 2),
    link_compra VARCHAR(1000),
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_compras_planejadas_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_compras_planejadas_edicoes FOREIGN KEY (edicao_id) REFERENCES edicoes(id),
    CONSTRAINT uk_compras_planejadas_usuario_edicao_mes_ano UNIQUE (usuario_id, edicao_id, mes, ano)
);
