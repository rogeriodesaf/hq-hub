-- Corrige a senha do usuário administrador (V33 teve hash BCrypt inválido)
-- Esta migration atualiza para senha em texto simples que é comparada diretamente

UPDATE usuarios
SET senha = '123456',
    data_atualizacao = NOW()
WHERE email = 'rogeriodesaf@adm';
