ALTER TABLE postagens_feed
    ADD COLUMN IF NOT EXISTS tipo_postagem VARCHAR(40) NOT NULL DEFAULT 'MANUAL',
    ADD COLUMN IF NOT EXISTS tipo_atividade VARCHAR(50);

UPDATE postagens_feed
SET tipo_postagem = 'ATIVIDADE_ESTANTE',
    tipo_atividade = 'ADICIONOU_COLECAO'
WHERE item_colecao_id IS NOT NULL
  AND tipo_postagem = 'MANUAL';

ALTER TABLE configuracoes_colecao
    ADD COLUMN IF NOT EXISTS visibilidade_atividades VARCHAR(20) NOT NULL DEFAULT 'AMIGOS';

CREATE TABLE IF NOT EXISTS edicoes_atividades_estante (
    id BIGSERIAL PRIMARY KEY,
    postagem_id BIGINT NOT NULL,
    edicao_id BIGINT,
    item_colecao_id BIGINT,
    titulo_snapshot VARCHAR(500) NOT NULL,
    url_capa_snapshot VARCHAR(1000),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_atividade_estante_postagem FOREIGN KEY (postagem_id) REFERENCES postagens_feed(id) ON DELETE CASCADE,
    CONSTRAINT fk_atividade_estante_edicao FOREIGN KEY (edicao_id) REFERENCES edicoes(id) ON DELETE SET NULL,
    CONSTRAINT fk_atividade_estante_item FOREIGN KEY (item_colecao_id) REFERENCES itens_colecao(id) ON DELETE SET NULL,
    CONSTRAINT uk_atividade_estante_postagem_edicao UNIQUE (postagem_id, edicao_id)
);

CREATE INDEX IF NOT EXISTS idx_atividade_estante_postagem
    ON edicoes_atividades_estante(postagem_id, data_criacao);

CREATE INDEX IF NOT EXISTS idx_postagem_atividade_agrupamento
    ON postagens_feed(usuario_id, tipo_postagem, tipo_atividade, data_criacao DESC);

INSERT INTO edicoes_atividades_estante (
    postagem_id, edicao_id, item_colecao_id, titulo_snapshot, url_capa_snapshot, data_criacao
)
SELECT p.id,
       ed.id,
       item.id,
       CONCAT(
           s.titulo,
           CASE WHEN ed.numero IS NULL OR BTRIM(ed.numero) = '' THEN '' ELSE ' #' || ed.numero END,
           CASE
               WHEN ed.titulo IS NULL OR BTRIM(ed.titulo) = '' OR LOWER(BTRIM(ed.titulo)) = LOWER(BTRIM(s.titulo)) THEN ''
               ELSE ': ' || ed.titulo
           END
       ),
       COALESCE(ed.url_capa, p.url_imagem),
       p.data_criacao
FROM postagens_feed p
JOIN itens_colecao item ON item.id = p.item_colecao_id
JOIN edicoes ed ON ed.id = item.edicao_id
JOIN series s ON s.id = ed.serie_id
WHERE p.tipo_postagem = 'ATIVIDADE_ESTANTE'
ON CONFLICT (postagem_id, edicao_id) DO NOTHING;
