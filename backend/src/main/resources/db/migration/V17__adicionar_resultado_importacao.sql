ALTER TABLE solicitacoes_importacao
ADD COLUMN resultado_json TEXT,
ADD COLUMN data_processamento TIMESTAMP;
