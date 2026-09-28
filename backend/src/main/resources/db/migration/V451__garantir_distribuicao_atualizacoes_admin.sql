DELETE FROM notificacoes_sociais duplicada
USING notificacoes_sociais mantida
WHERE duplicada.tipo = 'NOVA_POSTAGEM_ADMIN'
  AND mantida.tipo = 'NOVA_POSTAGEM_ADMIN'
  AND duplicada.destinatario_id = mantida.destinatario_id
  AND duplicada.postagem_id = mantida.postagem_id
  AND duplicada.id < mantida.id;

CREATE UNIQUE INDEX uk_notificacao_postagem_admin_destinatario
    ON notificacoes_sociais (destinatario_id, postagem_id)
    WHERE tipo = 'NOVA_POSTAGEM_ADMIN';
