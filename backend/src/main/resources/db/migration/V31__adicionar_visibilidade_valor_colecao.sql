ALTER TABLE configuracoes_colecao
    ADD COLUMN IF NOT EXISTS exibir_valor_colecao BOOLEAN NOT NULL DEFAULT TRUE;
