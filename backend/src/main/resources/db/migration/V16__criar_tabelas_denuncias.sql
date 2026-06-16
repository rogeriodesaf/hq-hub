CREATE TABLE denuncias_anuncios (
    id BIGSERIAL PRIMARY KEY,
    denunciante_id BIGINT NOT NULL,
    anuncio_id BIGINT NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    descricao VARCHAR(1000),
    status VARCHAR(30) NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_denuncias_anuncios_denunciante FOREIGN KEY (denunciante_id) REFERENCES usuarios(id),
    CONSTRAINT fk_denuncias_anuncios_anuncio FOREIGN KEY (anuncio_id) REFERENCES anuncios(id)
);

CREATE INDEX idx_denuncias_anuncios_denunciante ON denuncias_anuncios(denunciante_id, data_criacao DESC);
CREATE INDEX idx_denuncias_anuncios_status ON denuncias_anuncios(status, data_criacao DESC);

CREATE TABLE denuncias_usuarios (
    id BIGSERIAL PRIMARY KEY,
    denunciante_id BIGINT NOT NULL,
    usuario_denunciado_id BIGINT NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    descricao VARCHAR(1000),
    status VARCHAR(30) NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_denuncias_usuarios_denunciante FOREIGN KEY (denunciante_id) REFERENCES usuarios(id),
    CONSTRAINT fk_denuncias_usuarios_denunciado FOREIGN KEY (usuario_denunciado_id) REFERENCES usuarios(id),
    CONSTRAINT ck_denuncias_usuarios_diferentes CHECK (denunciante_id <> usuario_denunciado_id)
);

CREATE INDEX idx_denuncias_usuarios_denunciante ON denuncias_usuarios(denunciante_id, data_criacao DESC);
CREATE INDEX idx_denuncias_usuarios_status ON denuncias_usuarios(status, data_criacao DESC);
