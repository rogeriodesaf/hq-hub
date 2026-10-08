-- Publicacao institucional criada com os totais reais existentes no momento
-- da implantacao. O prefixo funciona como identificador auditavel e impede
-- duplicacao caso a migracao seja reaplicada manualmente.
WITH autor_oficial AS (
    SELECT id
      FROM usuarios
     WHERE perfil = 'ADMINISTRADOR'
     ORDER BY
           CASE WHEN lower(trim(email)) = 'rogeriodesaf@gmail.com' THEN 0 ELSE 1 END,
           id
     LIMIT 1
), totais AS (
    SELECT
        (SELECT count(*) FROM series) AS titulos,
        (SELECT count(*) FROM edicoes) AS edicoes
), publicacao AS (
    SELECT
        '#CatalogoColecionaHQ' || E'\n\n' ||
        'Nosso catálogo continua crescendo! Já reunimos ' ||
        replace(to_char(titulos, 'FM999,999,999'), ',', '.') ||
        ' títulos e ' ||
        replace(to_char(edicoes, 'FM999,999,999'), ',', '.') ||
        E' edições cadastradas.\n\n' ||
        'Explore o acervo, organize sua coleção e compartilhe essa marca com outros colecionadores!'
        AS conteudo
    FROM totais
)
INSERT INTO postagens_feed (
    usuario_id,
    conteudo,
    url_imagem,
    sistema,
    fixada,
    tipo_postagem,
    data_criacao,
    data_atualizacao
)
SELECT
    autor_oficial.id,
    publicacao.conteudo,
    'https://hqhub.space/assets/coleciona-hq-compartilhamento.png',
    TRUE,
    FALSE,
    'MANUAL',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM autor_oficial
CROSS JOIN publicacao
WHERE NOT EXISTS (
    SELECT 1
      FROM postagens_feed
     WHERE conteudo LIKE '#CatalogoColecionaHQ%'
);
