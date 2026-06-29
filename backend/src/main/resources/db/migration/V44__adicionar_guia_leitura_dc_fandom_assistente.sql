INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Guia de leitura recomendada da DC Comics Fandom',
    'A pagina Leitura Recomendada da DC Comics da DCclopedia/Fandom e um guia editorial para leitores novos ou antigos escolherem obras marcantes da DC. Ela nao se apresenta como cronologia definitiva: funciona melhor como lista de portas de entrada e graphic novels essenciais, incluindo Watchmen, Batman: O Cavaleiro das Trevas, Sandman, Batman: Ano Um, V de Vinganca, A Saga do Monstro do Pantano, A Piada Mortal, Grandes Astros Superman, Reino do Amanha, Batman: O Longo Dia das Bruxas, Lanterna Verde: Renascimento, A Noite Mais Densa, Crise Final, LJA e outros classicos.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,dcclopedia,guia-de-leitura,leitura-recomendada,graphic-novels,classicos,porta-de-entrada'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'guia de leitura recomendada da dc comics fandom'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Por onde comecar a ler DC Comics',
    'Com base no guia da DCclopedia/Fandom, uma boa entrada na DC e escolher obras fechadas e influentes antes de tentar seguir toda a cronologia. Para Batman, comece por Batman: Ano Um, Batman: O Longo Dia das Bruxas, A Piada Mortal ou O Cavaleiro das Trevas. Para Superman, Grandes Astros Superman e Reino do Amanha sao boas portas. Para uma visao mais adulta ou autoral, Watchmen, Sandman, V de Vinganca, A Saga do Monstro do Pantano e Y: O Ultimo Homem aparecem como leituras fortes.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,por-onde-comecar,iniciantes,batman,superman,watchmen,sandman,graphic-novels'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'por onde comecar a ler dc comics'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Watchmen como leitura essencial da DC',
    'No guia da DCclopedia/Fandom, Watchmen aparece como uma das leituras essenciais para entender a evolucao dos quadrinhos de super-herois. A obra de Alan Moore e Dave Gibbons usa misterio, politica, paranoia e desconstrucao moral para questionar o papel dos vigilantes e o proprio genero superheroico. E uma leitura fechada, indicada como porta de entrada para narrativas graficas mais maduras.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,watchmen,alan-moore,dave-gibbons,graphic-novel,classico,leitura-essencial'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'watchmen como leitura essencial da dc'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Batman Ano Um como origem moderna',
    'Segundo o guia da DCclopedia/Fandom, Batman: Ano Um e uma das leituras fundamentais do Batman. A historia de Frank Miller e David Mazzucchelli reconta o inicio da carreira de Bruce Wayne como Batman e tambem acompanha a chegada de James Gordon a uma Gotham marcada por corrupcao. Funciona bem antes de outras historias do personagem, especialmente para quem quer uma origem moderna e direta.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,batman,ano-um,frank-miller,david-mazzucchelli,origem,gordon,gotham'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'batman ano um como origem moderna'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Batman O Cavaleiro das Trevas como classico futuro',
    'No guia da DCclopedia/Fandom, Batman: O Cavaleiro das Trevas e tratado como marco do personagem. A obra de Frank Miller mostra um Bruce Wayne envelhecido voltando da aposentadoria em uma Gotham decadente. Ela nao e uma origem tradicional: funciona melhor como leitura de impacto sobre o mito do Batman, sua relacao com violencia, legado e envelhecimento.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,batman,o-cavaleiro-das-trevas,frank-miller,bruce-wayne,gotham,classico'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'batman o cavaleiro das trevas como classico futuro'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Batman O Longo Dia das Bruxas e A Piada Mortal',
    'O guia da DCclopedia/Fandom destaca Batman: O Longo Dia das Bruxas e Batman: A Piada Mortal como leituras importantes do Batman. O Longo Dia das Bruxas, de Jeph Loeb e Tim Sale, funciona como misterio noir no inicio da carreira do heroi. A Piada Mortal, de Alan Moore e Brian Bolland, e uma historia psicologica centrada no Coringa e em seu confronto com Batman e Gordon.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,batman,o-longo-dia-das-bruxas,a-piada-mortal,coringa,jeph-loeb,tim-sale,alan-moore'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'batman o longo dia das bruxas e a piada mortal'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Sandman Preludios e Noturnos como entrada em Sandman',
    'No guia da DCclopedia/Fandom, Sandman: Preludios e Noturnos aparece como o comeco recomendado para a serie de Neil Gaiman. O volume introduz Morfeu, o Senhor dos Sonhos, apos seu aprisionamento e sua tentativa de recuperar poder e dominio. E uma porta de entrada para o lado mitologico, fantastico e literario da DC/Vertigo.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,sandman,preludios-e-noturnos,neil-gaiman,morfeu,vertigo,sonho'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'sandman preludios e noturnos como entrada em sandman'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Grandes Astros Superman e Reino do Amanha',
    'Com base no guia da DCclopedia/Fandom, Grandes Astros Superman e Reino do Amanha sao duas leituras fortes para entender Superman e o ideal heroico da DC. Grandes Astros Superman, de Grant Morrison e Frank Quitely, celebra o legado e a fantasia do personagem. Reino do Amanha, de Mark Waid e Alex Ross, olha para um futuro em crise e discute responsabilidade, heroismo e o papel da Liga da Justica.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,superman,grandes-astros-superman,reino-do-amanha,grant-morrison,frank-quitely,mark-waid,alex-ross'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'grandes astros superman e reino do amanha'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Lanterna Verde Renascimento e A Noite Mais Densa',
    'O guia da DCclopedia/Fandom lista Lanterna Verde: Renascimento e A Noite Mais Densa como leituras importantes ligadas a Hal Jordan e ao lado cosmico da DC. Renascimento, de Geoff Johns e Ethan Van Sciver, recoloca Hal Jordan no centro da mitologia dos Lanternas. A Noite Mais Densa amplia essa mitologia com as tropas emocionais e uma crise envolvendo os Lanternas Negros.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,lanterna-verde,renascimento,a-noite-mais-densa,hal-jordan,geoff-johns,ivan-reis'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'lanterna verde renascimento e a noite mais densa'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Crises da DC como leitura recomendada',
    'A pagina de leitura recomendada da DCclopedia/Fandom inclui crises e eventos como Crise Final e Crise de Identidade entre as obras marcantes. Para o assistente, isso deve ser tratado como recomendacao de historias importantes, nao como ordem completa de todos os eventos da DC. Crise Final envolve Darkseid e a Liga da Justica em escala cosmica; Crise de Identidade e um drama de misterio com impacto pessoal sobre a comunidade heroica.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,crise-final,crise-de-identidade,eventos,crises,darkseid,liga-da-justica'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'crises da dc como leitura recomendada'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'LJA de Grant Morrison como entrada na Liga da Justica',
    'Segundo o guia da DCclopedia/Fandom, LJA: Nova Ordem Mundial, de Grant Morrison, e uma boa porta para a Liga da Justica moderna dos anos 1990. A proposta reune os maiores nomes da DC, como Superman, Batman, Mulher-Maravilha, Flash, Lanterna Verde, Aquaman e Cacador de Marte, em ameacas de escala grande. E uma leitura recomendada para quem quer ver a Liga como principal equipe de herois da editora.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,lja,liga-da-justica,nova-ordem-mundial,grant-morrison,superman,batman,mulher-maravilha'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'lja de grant morrison como entrada na liga da justica'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Vertigo e obras autorais recomendadas da DC',
    'A lista da DCclopedia/Fandom tambem funciona como guia para obras autorais publicadas sob o guarda-chuva DC/Vertigo. Alem de Sandman, ela destaca V de Vinganca, A Saga do Monstro do Pantano, Fabulas, Y: O Ultimo Homem, Vampiro Americano, Planetary e A Liga Extraordinaria. Essas obras sao boas para leitores que querem historias fechadas ou autorais, sem depender tanto da continuidade principal de super-herois.',
    'DCclopedia/Fandom',
    'https://dc.fandom.com/pt-br/wiki/Leitura_Recomendada_da_DC_Comics',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'dc,fandom,vertigo,sandman,v-de-vinganca,monstro-do-pantano,fabulas,y-o-ultimo-homem,planetary'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'vertigo e obras autorais recomendadas da dc'
);
