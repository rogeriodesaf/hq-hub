-- Cria usuário administrador rogeriodesaf@adm com senha 123456
-- Senhas em texto simples são comparadas diretamente pela lógica em AutenticacaoService

DELETE FROM usuarios WHERE email = 'rogeriodesaf@adm';

INSERT INTO usuarios (nome, email, senha, perfil, data_criacao, data_atualizacao)
VALUES ('Rogério de Souza Admin', 'rogeriodesaf@adm', '123456', 'ADMINISTRADOR', NOW(), NOW());
