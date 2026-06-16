CREATE TABLE edicoes (
    id BIGSERIAL PRIMARY KEY,
    numero VARCHAR(50) NOT NULL,
    titulo VARCHAR(255),
    descricao VARCHAR(2000),
    data_publicacao DATE,
    url_capa VARCHAR(1000),
    codigo_barras VARCHAR(100),
    quantidade_paginas INTEGER,
    preco_capa NUMERIC(10, 2),
    serie_id BIGINT NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_edicoes_series FOREIGN KEY (serie_id) REFERENCES series(id),
    CONSTRAINT uk_edicoes_numero_serie UNIQUE (numero, serie_id)
);
