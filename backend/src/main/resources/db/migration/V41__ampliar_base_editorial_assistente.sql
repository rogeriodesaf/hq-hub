INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como adicionar uma HQ a colecao',
    'Para adicionar uma HQ a sua colecao no HQ-HUB, use a area Colecao, pesquise a edicao no catalogo interno ou em uma fonte externa disponivel, abra o resultado e registre o item na sua estante. Quando a edicao ainda nao existir no catalogo interno, primeiro cadastre ou importe a edicao e depois adicione o item a colecao.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,colecao,adicionar,hq,edicao,estante,catalogo'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como adicionar uma hq a colecao'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Diferenca entre colecao wishlist e catalogo',
    'No HQ-HUB, Catalogo e a base de series e edicoes conhecidas pelo sistema. Colecao representa o que voce possui na sua estante. Wishlist ou compras planejadas representa o que voce ainda quer acompanhar ou comprar. Uma mesma edicao pode existir no catalogo sem estar na sua colecao.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,colecao,wishlist,compras,catalogo,estante'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'diferenca entre colecao wishlist e catalogo'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'O que e catalogo interno',
    'Catalogo interno e o conjunto de series e edicoes ja cadastradas no banco do HQ-HUB. Quando a busca mostra Catalogo interno, significa que aquele resultado ja esta salvo localmente e pode ser usado para colecao, compras, revisao e relacionamentos entre series.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,catalogo,catalogo-interno,banco-local,edicoes,series'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'o que e catalogo interno'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como usar volumes de serie',
    'O volume da serie ajuda a diferenciar publicacoes com o mesmo titulo em fases diferentes, como uma primeira serie e uma segunda serie. Em buscas e listagens, um marcador como V2 indica o volume cadastrado para evitar confusao entre edicoes de nomes parecidos.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,volume,v2,serie,temporada,busca,catalogo'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como usar volumes de serie'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como planejar compras',
    'Compras planejadas servem para organizar edicoes que voce pretende comprar em um mes ou ano especifico. O assistente consegue consultar esse planejamento quando a pergunta informa o periodo, por exemplo: quais compras tenho planejadas para junho de 2026?',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,compras,compras-planejadas,planejamento,wishlist,mes,ano'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como planejar compras'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'O que o assistente do HQ-HUB consegue responder',
    'O assistente do HQ-HUB consegue responder sobre resumo da colecao, faltantes, completude por serie, compras planejadas, criadores cadastrados, continuidade entre series, uso do sistema e conhecimentos basicos sobre quadrinhos salvos na base editorial local.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,assistente,huguinho,ajuda,perguntas,escopo'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'o que o assistente do hq-hub consegue responder'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Demolidor',
    'Demolidor e o heroi Matt Murdock, advogado cego de Hell''s Kitchen que combate o crime usando sentidos ampliados. Criado por Stan Lee e Bill Everett, com contribuicoes visuais de Jack Kirby, estreou em Daredevil #1, em 1964, pela Marvel Comics.',
    'Marvel',
    'https://www.marvel.com/characters/daredevil-matthew-murdock',
    'OFICIAL',
    'SEED',
    'demolidor,daredevil,matt-murdock,marvel,heroi,hells-kitchen'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) IN ('demolidor', 'daredevil')
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'X-Men',
    'X-Men e uma equipe de mutantes da Marvel criada por Stan Lee e Jack Kirby. O grupo estreou em The X-Men #1, em 1963, e suas historias costumam trabalhar temas como preconceito, identidade, convivencia e conflito entre humanos e mutantes.',
    'Marvel',
    'https://www.marvel.com/teams-and-groups/x-men',
    'OFICIAL',
    'SEED',
    'x-men,xmen,mutantes,marvel,equipe,professor-x,magneto'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) IN ('x-men', 'xmen')
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Quarteto Fantastico',
    'Quarteto Fantastico e uma equipe da Marvel criada por Stan Lee e Jack Kirby. Reed Richards, Sue Storm, Johnny Storm e Ben Grimm ganharam poderes apos uma viagem espacial e estrearam em Fantastic Four #1, em 1961.',
    'Marvel',
    'https://www.marvel.com/teams-and-groups/fantastic-four',
    'OFICIAL',
    'SEED',
    'quarteto-fantastico,fantastic-four,marvel,equipe,reed-richards,sue-storm,tocha-humana,coisa'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) IN ('quarteto fantastico', 'fantastic four')
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Mulher-Maravilha',
    'Mulher-Maravilha e Diana, princesa amazona da DC Comics criada por William Moulton Marston e H. G. Peter. Ela estreou em All Star Comics #8, em 1941, e e um dos principais simbolos heroicos da editora.',
    'DC Comics',
    'https://www.dc.com/characters/wonder-woman',
    'OFICIAL',
    'SEED',
    'mulher-maravilha,wonder-woman,diana,dc,amazona,heroina'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) IN ('mulher-maravilha', 'mulher maravilha', 'wonder woman')
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'HEROI',
    'Lanterna Verde',
    'Lanterna Verde e um legado heroico da DC Comics ligado a aneis de poder e a Tropa dos Lanternas Verdes. Hal Jordan e uma das versoes mais conhecidas, mas o manto tambem foi usado por personagens como Alan Scott, John Stewart, Guy Gardner, Kyle Rayner, Jessica Cruz e Simon Baz.',
    'DC Comics',
    'https://www.dc.com/characters/green-lantern',
    'OFICIAL',
    'SEED',
    'lanterna-verde,green-lantern,hal-jordan,dc,tropa-dos-lanternas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) IN ('lanterna verde', 'lanterna-verde', 'green lantern')
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SAGA',
    'Batman Ano Um',
    'Batman: Ano Um e uma historia de Frank Miller e David Mazzucchelli publicada originalmente em Batman #404-407. Ela reconta o inicio da carreira de Bruce Wayne como Batman e a chegada de James Gordon a Gotham.',
    'DC Comics / Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'batman,ano-um,frank-miller,david-mazzucchelli,gordon,gotham,origem'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'batman ano um'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SAGA',
    'O Cavaleiro das Trevas',
    'O Cavaleiro das Trevas, de Frank Miller, Klaus Janson e Lynn Varley, mostra um Bruce Wayne mais velho voltando a atuar como Batman em uma Gotham violenta e politicamente tensa. E uma das obras mais influentes do personagem.',
    'DC Comics / Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'batman,cavaleiro-das-trevas,dark-knight-returns,frank-miller,klaus-janson,lynn-varley'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'o cavaleiro das trevas'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SAGA',
    'Saga do Clone',
    'Saga do Clone e um conjunto de historias do Homem-Aranha que coloca Peter Parker diante do clone Ben Reilly e de questoes sobre identidade, responsabilidade e legado. No Brasil, o material foi publicado em diferentes formatos e fases editoriais.',
    'Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'homem-aranha,spider-man,saga-do-clone,ben-reilly,peter-parker,clone'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'saga do clone'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SAGA',
    'A Queda de Murdock',
    'A Queda de Murdock, conhecida em ingles como Born Again, e uma fase do Demolidor escrita por Frank Miller e desenhada por David Mazzucchelli. A historia mostra Matt Murdock sendo destruido pessoalmente por Wilson Fisk e tentando reconstruir sua vida.',
    'Marvel / Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'demolidor,daredevil,queda-de-murdock,born-again,frank-miller,david-mazzucchelli,rei-do-crime'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'a queda de murdock'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SAGA',
    'Dias de um Futuro Esquecido',
    'Dias de um Futuro Esquecido e uma historia dos X-Men de Chris Claremont, John Byrne e Terry Austin publicada em The Uncanny X-Men #141-142. Ela apresenta um futuro distopico dominado por Sentinelas e se tornou uma das tramas mais conhecidas dos mutantes.',
    'Marvel / Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'x-men,dias-de-um-futuro-esquecido,days-of-future-past,chris-claremont,john-byrne,sentinelas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'dias de um futuro esquecido'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'AUTOR',
    'Alan Moore',
    'Alan Moore e um roteirista britanico conhecido por obras como Watchmen, V de Vinganca, Monstro do Pantano, Do Inferno e A Liga Extraordinaria. Seu trabalho e associado a estruturas narrativas densas, critica social e experimentacao formal.',
    'Biografia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'alan-moore,autor,roteirista,watchmen,v-de-vinganca,monstro-do-pantano'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'alan moore'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'AUTOR',
    'Chris Claremont',
    'Chris Claremont e um roteirista associado principalmente aos X-Men, onde escreveu uma longa fase que ajudou a definir personagens, conflitos e sagas centrais dos mutantes, como A Saga da Fenix Negra e Dias de um Futuro Esquecido.',
    'Biografia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'chris-claremont,autor,roteirista,x-men,fenix-negra,dias-de-um-futuro-esquecido'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'chris claremont'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CONCEITO',
    'Diferenca entre universo cronologia e fase',
    'Em quadrinhos, universo costuma indicar o conjunto compartilhado de personagens e eventos. Cronologia e a ordem interna dos acontecimentos. Fase e um periodo editorial ou criativo, geralmente ligado a uma equipe criativa, reformulacao ou linha de publicacao.',
    'Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'conceito,universo,cronologia,fase,continuidade,quadrinhos'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'diferenca entre universo cronologia e fase'
);
