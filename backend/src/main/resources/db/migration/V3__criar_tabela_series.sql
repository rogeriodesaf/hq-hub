CREATE TABLE series (
    id BIGSERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao VARCHAR(1000),
    ano_inicio INTEGER,
    ano_fim INTEGER,
    editora_id BIGINT NOT NULL,
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_series_editoras FOREIGN KEY (editora_id) REFERENCES editoras(id),
    CONSTRAINT uk_series_titulo_editora UNIQUE (titulo, editora_id)
);
