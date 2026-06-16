CREATE TABLE amizades (
    id BIGSERIAL PRIMARY KEY,
    solicitante_id BIGINT NOT NULL,
    solicitado_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL,
    data_solicitacao TIMESTAMP NOT NULL,
    data_resposta TIMESTAMP,
    CONSTRAINT fk_amizades_solicitante FOREIGN KEY (solicitante_id) REFERENCES usuarios(id),
    CONSTRAINT fk_amizades_solicitado FOREIGN KEY (solicitado_id) REFERENCES usuarios(id),
    CONSTRAINT uk_amizades_solicitante_solicitado UNIQUE (solicitante_id, solicitado_id),
    CONSTRAINT ck_amizades_usuarios_diferentes CHECK (solicitante_id <> solicitado_id)
);

CREATE INDEX idx_amizades_solicitado_status ON amizades(solicitado_id, status);
CREATE INDEX idx_amizades_solicitante_status ON amizades(solicitante_id, status);

CREATE TABLE bloqueios_usuarios (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    usuario_bloqueado_id BIGINT NOT NULL,
    data_bloqueio TIMESTAMP NOT NULL,
    motivo VARCHAR(500),
    CONSTRAINT fk_bloqueios_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_bloqueios_usuario_bloqueado FOREIGN KEY (usuario_bloqueado_id) REFERENCES usuarios(id),
    CONSTRAINT uk_bloqueios_usuario_bloqueado UNIQUE (usuario_id, usuario_bloqueado_id),
    CONSTRAINT ck_bloqueios_usuarios_diferentes CHECK (usuario_id <> usuario_bloqueado_id)
);

CREATE INDEX idx_bloqueios_usuario ON bloqueios_usuarios(usuario_id);
CREATE INDEX idx_bloqueios_usuario_bloqueado ON bloqueios_usuarios(usuario_bloqueado_id);

CREATE TABLE configuracoes_colecao (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL UNIQUE,
    visibilidade_colecao VARCHAR(30) NOT NULL DEFAULT 'PRIVADA',
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_configuracoes_colecao_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE anuncios (
    id BIGSERIAL PRIMARY KEY,
    anunciante_id BIGINT NOT NULL,
    item_colecao_id BIGINT NOT NULL,
    tipo_anuncio VARCHAR(30) NOT NULL,
    preco NUMERIC(10, 2),
    estado_conservacao VARCHAR(30) NOT NULL,
    descricao VARCHAR(1000),
    cidade VARCHAR(255) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    contato_whatsapp VARCHAR(30),
    exibir_whatsapp BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(30) NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_anuncios_anunciante FOREIGN KEY (anunciante_id) REFERENCES usuarios(id),
    CONSTRAINT fk_anuncios_item_colecao FOREIGN KEY (item_colecao_id) REFERENCES itens_colecao(id)
);

CREATE INDEX idx_anuncios_status_data ON anuncios(status, data_criacao DESC);
CREATE INDEX idx_anuncios_anunciante_status ON anuncios(anunciante_id, status);
CREATE INDEX idx_anuncios_item_colecao ON anuncios(item_colecao_id);

CREATE TABLE fotos_anuncios (
    id BIGSERIAL PRIMARY KEY,
    anuncio_id BIGINT NOT NULL,
    url_imagem VARCHAR(1000) NOT NULL,
    principal BOOLEAN NOT NULL DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_fotos_anuncios_anuncio FOREIGN KEY (anuncio_id) REFERENCES anuncios(id)
);

CREATE INDEX idx_fotos_anuncios_anuncio ON fotos_anuncios(anuncio_id);
