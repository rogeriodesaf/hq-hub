CREATE TABLE historias (
    id BIGSERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    titulo_original VARCHAR(255),
    descricao VARCHAR(2000),
    quantidade_paginas INTEGER,
    tipo VARCHAR(50) NOT NULL,
    fonte_externa VARCHAR(100),
    id_externo VARCHAR(100),
    url_origem VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL
);

CREATE INDEX idx_historias_titulo ON historias(titulo);
CREATE INDEX idx_historias_origem_externa ON historias(fonte_externa, id_externo);

CREATE TABLE conteudos_edicoes (
    id BIGSERIAL PRIMARY KEY,
    edicao_id BIGINT NOT NULL,
    historia_id BIGINT NOT NULL,
    ordem INTEGER NOT NULL,
    titulo_usado VARCHAR(255),
    pagina_inicio INTEGER,
    pagina_fim INTEGER,
    quantidade_paginas INTEGER,
    tipo VARCHAR(50) NOT NULL,
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_conteudos_edicoes_edicao FOREIGN KEY (edicao_id) REFERENCES edicoes(id),
    CONSTRAINT fk_conteudos_edicoes_historia FOREIGN KEY (historia_id) REFERENCES historias(id),
    CONSTRAINT uk_conteudos_edicoes_edicao_ordem UNIQUE (edicao_id, ordem)
);

CREATE INDEX idx_conteudos_edicoes_edicao ON conteudos_edicoes(edicao_id, ordem);
CREATE INDEX idx_conteudos_edicoes_historia ON conteudos_edicoes(historia_id);

CREATE TABLE publicacoes_historias (
    id BIGSERIAL PRIMARY KEY,
    historia_id BIGINT NOT NULL,
    edicao_original_id BIGINT NOT NULL,
    edicao_publicada_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL,
    titulo_usado VARCHAR(255),
    paginas_publicadas INTEGER,
    paginas_cortadas INTEGER,
    fonte_externa VARCHAR(100),
    url_origem VARCHAR(1000),
    observacoes VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL,
    data_atualizacao TIMESTAMP NOT NULL,
    CONSTRAINT fk_publicacoes_historias_historia FOREIGN KEY (historia_id) REFERENCES historias(id),
    CONSTRAINT fk_publicacoes_historias_edicao_original FOREIGN KEY (edicao_original_id) REFERENCES edicoes(id),
    CONSTRAINT fk_publicacoes_historias_edicao_publicada FOREIGN KEY (edicao_publicada_id) REFERENCES edicoes(id),
    CONSTRAINT uk_publicacoes_historias_historia_edicao UNIQUE (historia_id, edicao_publicada_id),
    CONSTRAINT ck_publicacoes_historias_edicoes_diferentes CHECK (edicao_original_id <> edicao_publicada_id)
);

CREATE INDEX idx_publicacoes_historias_historia ON publicacoes_historias(historia_id);
CREATE INDEX idx_publicacoes_historias_original_publicada ON publicacoes_historias(edicao_original_id, edicao_publicada_id);
