-- V37: Limpa V33 do histórico do Flyway e cria usuário administrador
DELETE FROM flyway_schema_history WHERE version = 33;

DELETE FROM usuarios WHERE email = 'rogeriodesaf@adm';

INSERT INTO usuarios (nome, email, senha, perfil, data_criacao, data_atualizacao)
VALUES ('Rogério de Souza Admin', 'rogeriodesaf@adm', '123456', 'ADMINISTRADOR', NOW(), NOW());
