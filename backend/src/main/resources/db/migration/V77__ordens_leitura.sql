CREATE TABLE ordens_leitura (
    id BIGSERIAL PRIMARY KEY,
    slug VARCHAR(120) NOT NULL UNIQUE,
    titulo VARCHAR(255) NOT NULL,
    descricao VARCHAR(1000),
    url_capa VARCHAR(1000),
    publicada BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE itens_ordem_leitura (
    id BIGSERIAL PRIMARY KEY,
    ordem_leitura_id BIGINT NOT NULL REFERENCES ordens_leitura(id) ON DELETE CASCADE,
    posicao INTEGER NOT NULL,
    edicao_id BIGINT REFERENCES edicoes(id) ON DELETE SET NULL,
    titulo_referencia VARCHAR(300) NOT NULL,
    detalhe_referencia VARCHAR(300),
    url_capa_referencia VARCHAR(1000),
    CONSTRAINT uk_item_ordem_posicao UNIQUE (ordem_leitura_id, posicao)
);

CREATE INDEX idx_itens_ordem_leitura_edicao ON itens_ordem_leitura(edicao_id);

CREATE TABLE progresso_ordem_leitura (
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    item_ordem_leitura_id BIGINT NOT NULL REFERENCES itens_ordem_leitura(id) ON DELETE CASCADE,
    lido BOOLEAN NOT NULL DEFAULT FALSE,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, item_ordem_leitura_id)
);

INSERT INTO ordens_leitura (slug, titulo, descricao, publicada)
VALUES (
    'ordem-de-leitura-mutante',
    'Ordem de Leitura Mutante',
    'Uma jornada cronológica pelas principais histórias dos X-Men e do universo mutante publicadas no Brasil.',
    TRUE
);
