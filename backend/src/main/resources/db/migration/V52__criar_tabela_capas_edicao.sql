CREATE TABLE capas_edicao (
    id BIGSERIAL PRIMARY KEY,
    edicao_id BIGINT NOT NULL,
    url_imagem VARCHAR(1000) NOT NULL,
    public_id_cloudinary VARCHAR(500),
    enviado_por_usuario_id BIGINT,
    status VARCHAR(30) NOT NULL,
    origem VARCHAR(40) NOT NULL,
    observacao VARCHAR(1000),
    data_envio TIMESTAMP NOT NULL,
    data_aprovacao TIMESTAMP,
    aprovado_por_usuario_id BIGINT,
    CONSTRAINT fk_capas_edicao_edicao FOREIGN KEY (edicao_id) REFERENCES edicoes(id) ON DELETE CASCADE,
    CONSTRAINT fk_capas_edicao_usuario_envio FOREIGN KEY (enviado_por_usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_capas_edicao_usuario_aprovacao FOREIGN KEY (aprovado_por_usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_capas_edicao_edicao_status ON capas_edicao(edicao_id, status);
CREATE INDEX idx_capas_edicao_data_envio ON capas_edicao(data_envio DESC);
