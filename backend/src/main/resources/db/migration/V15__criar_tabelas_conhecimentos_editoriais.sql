CREATE TABLE conhecimentos_editoriais (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tipo VARCHAR(50) NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    conteudo TEXT NOT NULL,
    fonte VARCHAR(255),
    url_fonte VARCHAR(255),
    confianca VARCHAR(50) DEFAULT 'COMUNITARIA',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    origem_dados VARCHAR(100),
    tags VARCHAR(500),
    relacionadas VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conhecimentos_tipo ON conhecimentos_editoriais(tipo);
CREATE INDEX idx_conhecimentos_titulo ON conhecimentos_editoriais(titulo);
CREATE INDEX idx_conhecimentos_confianca ON conhecimentos_editoriais(confianca);
CREATE INDEX idx_conhecimentos_origem ON conhecimentos_editoriais(origem_dados);
