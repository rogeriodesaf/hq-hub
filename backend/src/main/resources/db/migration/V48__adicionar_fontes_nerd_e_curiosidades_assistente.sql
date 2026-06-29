INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'REFERENCIA',
    'Velhinho do RPG como fonte nerd e RPG',
    'O Velhinho do RPG e um blog nerd com foco em RPG de mesa, campanhas, downloads, resenhas e adaptacoes. A pagina principal organiza conteudos sobre jogos como Vampiro: A Mascara, Chamado de Cthulhu, Mundo das Trevas, Star Wars RPG, Marvel Multiverse RPG e materiais de campanhas. Para o assistente do HQ-HUB, essa fonte serve como contexto para perguntas que misturam quadrinhos, cultura nerd, adaptacoes, RPG e campanhas inspiradas em universos de super-herois.',
    'Velhinho do RPG',
    'https://velhinhodorpg.com/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'velhinho-do-rpg,rpg,cultura-nerd,marvel-multiverse-rpg,dc,supers,adaptacoes,campanhas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'velhinho do rpg como fonte nerd e rpg'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'REFERENCIA',
    'Quadrinhos e RPG de super-herois',
    'O conteudo do Velhinho do RPG inclui materiais e resenhas ligados a supers e Marvel Multiverse RPG, como expansoes de X-Men, Guerras Secretas e adaptacoes de personagens ou ideias para mesa. Quando o usuario perguntar sobre transformar HQs em campanha, aventura ou ficha, o assistente pode explicar que quadrinhos funcionam bem como inspiracao para arcos, conflitos, cenas de acao, equipes, viloes e cenarios, mas deve diferenciar a continuidade editorial da adaptacao livre para jogo.',
    'Velhinho do RPG',
    'https://velhinhodorpg.com/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'rpg,super-herois,marvel-multiverse-rpg,x-men,guerras-secretas,adaptacao,hq,campanha'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'quadrinhos e rpg de super-herois'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CURIOSIDADE',
    'Curiosidades historicas dos quadrinhos',
    'O artigo do Comics Crossover sobre curiosidades dos quadrinhos destaca como a nona arte foi moldada por mudancas editoriais, erros de impressao, censura, easter eggs e crossovers incomuns. Exemplos uteis para o assistente: o Hulk nasceu cinza antes de se tornar verde, o Superman originalmente saltava em vez de voar, o Coringa tem origem propositalmente ambigua, o Comics Code Authority influenciou por decadas o tom das HQs americanas, e a publicacao de uma historia do Homem-Aranha sobre drogas sem o selo do CCA ajudou a enfraquecer essa censura.',
    'Comics Crossover',
    'https://comicscrossover.com/curiosidades-dos-quadrinhos-25-fatos-que-vao-te-surpreender/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'curiosidades,hulk,superman,coringa,comics-code-authority,homem-aranha,censura,historia-dos-quadrinhos'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'curiosidades historicas dos quadrinhos'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CURIOSIDADE',
    'Easter eggs e crossovers nos quadrinhos',
    'O Comics Crossover tambem resume como os quadrinhos usam easter eggs, referencias internas e encontros improvaveis como parte da diversao do meio. Entre exemplos de contexto estao a presenca recorrente do numero 52 na DC, assinaturas escondidas de George Perez, encontros como Archie com Justiceiro, Superman contra Muhammad Ali, Star Trek com X-Men e Batman com Tartarugas Ninja. Para o assistente, isso deve virar resposta curta sobre criatividade, intertextualidade e liberdade narrativa dos quadrinhos.',
    'Comics Crossover',
    'https://comicscrossover.com/curiosidades-dos-quadrinhos-25-fatos-que-vao-te-surpreender/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'easter-eggs,crossovers,dc-52,george-perez,justiceiro,archie,superman,muhammad-ali,x-men,tartarugas-ninja'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'easter eggs e crossovers nos quadrinhos'
);
