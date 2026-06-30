ALTER TABLE contribuicoes_catalogo
    ADD COLUMN revisor_id BIGINT;

ALTER TABLE contribuicoes_catalogo
    ADD CONSTRAINT fk_contribuicoes_catalogo_revisor
    FOREIGN KEY (revisor_id) REFERENCES usuarios(id);

CREATE INDEX idx_contribuicoes_catalogo_revisor ON contribuicoes_catalogo(revisor_id);
