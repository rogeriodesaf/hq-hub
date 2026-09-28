ALTER TABLE notificacoes_sociais
    ADD COLUMN data_visualizacao TIMESTAMP;

UPDATE notificacoes_sociais
SET data_visualizacao = data_criacao
WHERE lida = TRUE;

DELETE FROM notificacoes_sociais
WHERE lida = TRUE
  AND data_visualizacao < CURRENT_TIMESTAMP - INTERVAL '30 days';

CREATE INDEX idx_notificacoes_lidas_visualizacao
    ON notificacoes_sociais (data_visualizacao)
    WHERE lida = TRUE;
