-- Cria usuário administrador rogeriodesaf@adm com senha 123456

INSERT INTO usuarios (nome, email, senha, perfil, data_criacao, data_atualizacao)
VALUES ('Rogério de Souza Admin', 'rogeriodesaf@adm', '123456', 'ADMINISTRADOR', NOW(), NOW())
ON CONFLICT (email) DO UPDATE
SET senha = '123456',
    perfil = 'ADMINISTRADOR',
    data_atualizacao = NOW();
