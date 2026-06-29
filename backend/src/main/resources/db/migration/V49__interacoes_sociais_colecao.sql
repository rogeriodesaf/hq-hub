CREATE TABLE curtidas_colecoes (
    id BIGSERIAL PRIMARY KEY,
    dono_colecao_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_curtidas_colecoes_dono FOREIGN KEY (dono_colecao_id) REFERENCES usuarios(id),
    CONSTRAINT fk_curtidas_colecoes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT uk_curtidas_colecoes_dono_usuario UNIQUE (dono_colecao_id, usuario_id)
);

CREATE INDEX idx_curtidas_colecoes_dono ON curtidas_colecoes(dono_colecao_id);
CREATE INDEX idx_curtidas_colecoes_usuario ON curtidas_colecoes(usuario_id);

CREATE TABLE comentarios_colecoes (
    id BIGSERIAL PRIMARY KEY,
    dono_colecao_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    texto VARCHAR(1000) NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentarios_colecoes_dono FOREIGN KEY (dono_colecao_id) REFERENCES usuarios(id),
    CONSTRAINT fk_comentarios_colecoes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_comentarios_colecoes_dono_data ON comentarios_colecoes(dono_colecao_id, data_criacao);

CREATE TABLE curtidas_itens_colecao (
    id BIGSERIAL PRIMARY KEY,
    item_colecao_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_curtidas_itens_colecao_item FOREIGN KEY (item_colecao_id) REFERENCES itens_colecao(id) ON DELETE CASCADE,
    CONSTRAINT fk_curtidas_itens_colecao_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT uk_curtidas_itens_colecao_item_usuario UNIQUE (item_colecao_id, usuario_id)
);

CREATE INDEX idx_curtidas_itens_colecao_item ON curtidas_itens_colecao(item_colecao_id);
CREATE INDEX idx_curtidas_itens_colecao_usuario ON curtidas_itens_colecao(usuario_id);

CREATE TABLE comentarios_itens_colecao (
    id BIGSERIAL PRIMARY KEY,
    item_colecao_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    texto VARCHAR(1000) NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentarios_itens_colecao_item FOREIGN KEY (item_colecao_id) REFERENCES itens_colecao(id) ON DELETE CASCADE,
    CONSTRAINT fk_comentarios_itens_colecao_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_comentarios_itens_colecao_item_data ON comentarios_itens_colecao(item_colecao_id, data_criacao);
