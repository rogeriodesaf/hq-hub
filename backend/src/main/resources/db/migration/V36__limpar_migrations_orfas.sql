-- Limpa registros órfãos de V33 e V34 do histórico do Flyway
-- Essas migrations foram deletadas do repositório devido a checksum mismatch

DELETE FROM flyway_schema_history WHERE version IN (33, 34);
