-- Novos tokens são armazenados somente como SHA-256 hexadecimal.
-- UUIDs antigos permanecem válidos até sua expiração natural.
ALTER TABLE tokens_redefinicao_senha ALTER COLUMN token TYPE VARCHAR(64);
