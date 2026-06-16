CREATE TABLE criadores (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    nome_artistico VARCHAR(255),
    fonte_externa VARCHAR(100),
    id_externo VARCHAR(255),
    url_origem VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL
);

CREATE TABLE creditos_edicoes (
    id BIGSERIAL PRIMARY KEY,
    edicao_id BIGINT NOT NULL,
    criador_id BIGINT NOT NULL,
    papel VARCHAR(50) NOT NULL,
    observacoes VARCHAR(500),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_creditos_edicoes_edicoes FOREIGN KEY (edicao_id) REFERENCES edicoes(id),
    CONSTRAINT fk_creditos_edicoes_criadores FOREIGN KEY (criador_id) REFERENCES criadores(id),
    CONSTRAINT uk_creditos_edicoes_edicao_criador_papel UNIQUE (edicao_id, criador_id, papel)
);

CREATE UNIQUE INDEX uk_criadores_origem_externa
    ON criadores (fonte_externa, id_externo)
    WHERE fonte_externa IS NOT NULL AND id_externo IS NOT NULL;
