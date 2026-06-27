INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Batman',
    'Batman e o alter ego de Bruce Wayne, criado por Bob Kane e Bill Finger. Ele apareceu pela primeira vez em Detective Comics #27, em 1939, e e um dos principais personagens da DC Comics.',
    'DC Comics',
    'https://www.dc.com/characters/batman',
    'OFICIAL',
    'SEED',
    'batman,heroi,dc,bruce-wayne'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'batman'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Superman',
    'Superman e o alter ego de Clark Kent/Kal-El, criado por Jerry Siegel e Joe Shuster. Ele estreou em Action Comics #1, em 1938.',
    'DC Comics',
    'https://www.dc.com/characters/superman',
    'OFICIAL',
    'SEED',
    'superman,heroi,dc,clark-kent,kal-el'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'superman'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Homem-Aranha',
    'Homem-Aranha e o alter ego de Peter Parker, criado por Stan Lee e Steve Ditko. Ele apareceu pela primeira vez em Amazing Fantasy #15, em 1962.',
    'Marvel',
    'https://www.marvel.com/characters/spider-man-peter-parker',
    'OFICIAL',
    'SEED',
    'homem-aranha,spider-man,heroi,marvel,peter-parker'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) IN ('homem-aranha', 'homem aranha', 'spider-man')
);
