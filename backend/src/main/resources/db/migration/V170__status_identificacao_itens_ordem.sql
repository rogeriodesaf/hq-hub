ALTER TABLE itens_ordem_leitura
    ADD COLUMN status_identificacao VARCHAR(30) NOT NULL DEFAULT 'PENDENTE_REVISAO',
    ADD COLUMN observacao VARCHAR(1000),
    ADD COLUMN ano_referencia INTEGER;

UPDATE itens_ordem_leitura
SET status_identificacao = 'CONFIRMADO'
WHERE edicao_id IS NOT NULL;

ALTER TABLE itens_ordem_leitura
    ADD CONSTRAINT ck_item_ordem_status_identificacao
    CHECK (status_identificacao IN ('CONFIRMADO', 'PENDENTE_REVISAO'));
