INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Batman',
    'Batman e o alter ego de Bruce Wayne, criado por Bob Kane e Bill Finger, com primeira aparicao em Detective Comics #27 (1939).',
    'DC Comics',
    'https://www.dc.com/characters/batman',
    'OFICIAL',
    'SEED',
    'batman,heroi,dc,curiosidade'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'batman'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'AUTOR',
    'Frank Miller',
    'Frank Miller e um roteirista e desenhista conhecido por obras como Batman: Ano Um e O Cavaleiro das Trevas.',
    'DC Comics / Biografia Editorial',
    'https://www.dc.com/talent/frank-miller',
    'VERIFICADA',
    'SEED',
    'frank-miller,autor,batman,dc'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'frank miller'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SAGA',
    'Saga do Batman',
    'A chamada Saga do Batman normalmente reune diferentes fases e arcos marcantes do personagem em publicacoes brasileiras, variando por editora e periodo.',
    'Guia Editorial HQ-HUB',
    null,
    'COMUNITARIA',
    'SEED',
    'saga,batman,arcos,colecao'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'saga do batman'
);
