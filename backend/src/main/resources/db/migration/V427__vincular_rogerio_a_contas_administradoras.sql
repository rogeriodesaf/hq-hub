-- Garante que a conta indicada do projeto e as contas administradoras
-- compartilhem stories entre si, mantendo a regra geral restrita a amigos.
UPDATE amizades amizade
SET status = 'ACEITA',
    data_resposta = COALESCE(amizade.data_resposta, CURRENT_TIMESTAMP)
FROM usuarios rogerio, usuarios administrador
WHERE lower(rogerio.email) = 'rogeriodesaf@gmail.com'
  AND administrador.perfil = 'ADMINISTRADOR'
  AND administrador.id <> rogerio.id
  AND amizade.status <> 'BLOQUEADA'
  AND (
      (amizade.solicitante_id = rogerio.id AND amizade.solicitado_id = administrador.id)
      OR
      (amizade.solicitante_id = administrador.id AND amizade.solicitado_id = rogerio.id)
  );

INSERT INTO amizades (
    solicitante_id,
    solicitado_id,
    status,
    data_solicitacao,
    data_resposta
)
SELECT
    rogerio.id,
    administrador.id,
    'ACEITA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM usuarios rogerio
JOIN usuarios administrador
  ON administrador.perfil = 'ADMINISTRADOR'
 AND administrador.id <> rogerio.id
WHERE lower(rogerio.email) = 'rogeriodesaf@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM amizades amizade
      WHERE (amizade.solicitante_id = rogerio.id AND amizade.solicitado_id = administrador.id)
         OR (amizade.solicitante_id = administrador.id AND amizade.solicitado_id = rogerio.id)
  );
