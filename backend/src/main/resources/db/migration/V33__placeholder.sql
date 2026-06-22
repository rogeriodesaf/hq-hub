-- Cria usuário administrador rogeriodesaf@adm com senha 123456

INSERT INTO usuarios (nome, email, senha, perfil, data_criacao, data_atualizacao)
VALUES ('Rogério de Souza Admin', 'rogeriodesaf@adm', '$2b$12$SPl64yhZQXphjzBy9bm6c.qc6W5tirPDNzlwc5VbZLe9rrIEYMK9y', 'ADMINISTRADOR', NOW(), NOW())
ON CONFLICT (email) DO UPDATE
SET senha = '$2b$12$SPl64yhZQXphjzBy9bm6c.qc6W5tirPDNzlwc5VbZLe9rrIEYMK9y',
	perfil = 'ADMINISTRADOR',
	data_atualizacao = NOW();
