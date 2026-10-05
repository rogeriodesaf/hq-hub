-- A recomendacao de amizade do painel aponta para esta conta. O perfil
-- administrativo tambem torna todas as suas publicacoes visiveis no feed de
-- todos os usuarios, inclusive os que acabaram de se cadastrar.
UPDATE usuarios
   SET perfil = 'ADMINISTRADOR'
 WHERE lower(trim(email)) = 'rogeriodesaf@gmail.com'
   AND perfil IS DISTINCT FROM 'ADMINISTRADOR';
