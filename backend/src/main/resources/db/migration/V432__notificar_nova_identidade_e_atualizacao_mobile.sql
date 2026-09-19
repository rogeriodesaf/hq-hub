-- Comunica a nova identidade e orienta a reinstalacao do atalho mobile.
-- A verificacao por tipo e mensagem torna o envio idempotente por usuario.
WITH autor_sistema AS (
    SELECT id
    FROM usuarios
    ORDER BY CASE WHEN perfil = 'ADMINISTRADOR' THEN 0 ELSE 1 END, id
    LIMIT 1
), aviso AS (
    SELECT 'Nova identidade: agora somos ColecionaHQ. Para atualizar o ícone no celular, remova o atalho antigo e instale novamente. Android/Chrome: menu de três pontos > Adicionar à tela inicial. iPhone/Safari: Compartilhar > Adicionar à Tela de Início.'::varchar(500) AS mensagem
)
INSERT INTO notificacoes_sociais (
    destinatario_id,
    autor_id,
    tipo,
    postagem_id,
    comentario_id,
    mensagem,
    lida,
    data_criacao
)
SELECT
    usuario.id,
    autor_sistema.id,
    'SISTEMA',
    NULL,
    NULL,
    aviso.mensagem,
    FALSE,
    CURRENT_TIMESTAMP
FROM usuarios usuario
CROSS JOIN autor_sistema
CROSS JOIN aviso
WHERE NOT EXISTS (
    SELECT 1
    FROM notificacoes_sociais existente
    WHERE existente.destinatario_id = usuario.id
      AND existente.tipo = 'SISTEMA'
      AND existente.mensagem = aviso.mensagem
);
