CREATE TABLE links_edicoes (
    id BIGSERIAL PRIMARY KEY,
    edicao_id BIGINT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    url VARCHAR(1000) NOT NULL,
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_links_edicoes_edicoes FOREIGN KEY (edicao_id) REFERENCES edicoes(id),
    CONSTRAINT uk_links_edicoes_edicao_url UNIQUE (edicao_id, url)
);
