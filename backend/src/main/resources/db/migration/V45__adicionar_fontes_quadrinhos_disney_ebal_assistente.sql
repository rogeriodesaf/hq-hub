INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Como comecar a ler quadrinhos segundo Sociedade Geek',
    'O guia da Sociedade Geek para iniciantes recomenda entrar nos quadrinhos sem tentar dominar toda a cronologia de uma vez. A melhor estrategia e comecar por historias fechadas, graphic novels ou arcos com inicio, meio e fim; escolher personagens ou generos de interesse; ler no proprio ritmo; e evitar eventos grandes e complexos logo de cara. O texto tambem diferencia formatos como revistas mensais, encadernados, graphic novels e mangas.',
    'Sociedade Geek',
    'https://sociedadegeek.com.br/como-comecar-a-ler-quadrinhos/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'quadrinhos,iniciantes,como-comecar,hq,encadernados,graphic-novel,manga,guia-de-leitura,sociedade-geek'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como comecar a ler quadrinhos segundo sociedade geek'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CONCEITO',
    'Formatos de quadrinhos para novos leitores',
    'Para novos leitores, a Sociedade Geek diferencia alguns formatos importantes: revistas mensais costumam ser publicacoes curtas e seriadas; encadernados ou TPBs reúnem varias edicoes em um volume; graphic novels tendem a oferecer experiencias mais fechadas; e mangas sao quadrinhos japoneses publicados em volumes, com leitura geralmente da direita para a esquerda. No HQ-HUB, esses conceitos ajudam a entender por que uma edicao pode representar uma revista avulsa, um volume encadernado ou uma colecao.',
    'Sociedade Geek',
    'https://sociedadegeek.com.br/como-comecar-a-ler-quadrinhos/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'quadrinhos,formatos,revista-mensal,floppy,encadernado,tpb,graphic-novel,manga,iniciantes'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'formatos de quadrinhos para novos leitores'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Historias fechadas recomendadas para iniciar em HQs',
    'Como porta de entrada, a Sociedade Geek sugere evitar sagas gigantescas e experimentar obras fechadas ou arcos bem conhecidos. Entre exemplos citados estao Batman: O Cavaleiro das Trevas, Homem-Aranha: A Ultima Cacada de Kraven, X-Men: Deus Ama, o Homem Mata, Demolidor: O Diabo da Guarda e Superman: Entre a Foice e o Martelo. A recomendacao geral e testar estilos antes de investir em colecoes longas.',
    'Sociedade Geek',
    'https://sociedadegeek.com.br/como-comecar-a-ler-quadrinhos/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'quadrinhos,iniciantes,historias-fechadas,batman,homem-aranha,x-men,demolidor,superman,graphic-novel'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'historias fechadas recomendadas para iniciar em hqs'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'REFERENCIA',
    'Guia Ebal como indice de publicacoes antigas',
    'O Guia Ebal e uma fonte de consulta sobre publicacoes da Editora Brasil-America, reunindo um indice amplo de series, personagens e revistas antigas. A pagina principal lista entradas como Aquaman, Batman, Superman, Flash, Capitao America, Homem-Aranha, Thor, Quarteto Fantastico, Mulher-Maravilha, Shazam, Turok, Tarzan, Zorro, Popeye, Pernalonga e muitos outros titulos. Para o assistente, essa fonte deve ser usada como referencia de catalogacao historica, nao como ordem de leitura moderna.',
    'Guia Ebal',
    'https://guiaebal.com/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'ebal,guia-ebal,editora-brasil-america,catalogo,hq-brasil,publicacoes-antigas,indice,colecionismo'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'guia ebal como indice de publicacoes antigas'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'REFERENCIA',
    'Como usar o Guia Ebal no HQ-HUB',
    'No contexto do HQ-HUB, o Guia Ebal ajuda a identificar titulos, series e familias de publicacoes antigas brasileiras. Ele pode orientar pesquisas sobre revistas da Ebal, nomes usados no Brasil, series completas ou incompletas e personagens publicados por essa editora. Por ser uma fonte de acervo e indice, a resposta do assistente deve evitar tratar o site como sinopse editorial completa e indicar que a confirmacao final deve vir do cadastro interno ou de uma pagina especifica da publicacao.',
    'Guia Ebal',
    'https://guiaebal.com/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'ebal,guia-ebal,hq-hub,catalogacao,fonte-externa,serie,edicao,colecionismo,revistas-antigas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como usar o guia ebal no hq-hub'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CHECKLIST',
    'Checklist Disney abril de 2024 Planeta Gibi',
    'O checklist Disney de abril de 2024 do Planeta Gibi Blog registra lancamentos e reprogramacoes de quadrinhos Disney no mes, separando editoras como Culturama, Panini e Universo dos Livros. A pagina destaca mensais como Pato Donald, Mickey, Tio Patinhas, Aventuras Disney e Historias Curtas, alem de lancamentos como Grandes Sagas Disney: A Espada de Gelo, Colecao Carl Barks Definitiva: Tio Patinhas - O Navio de Ouro e Disney Viloes: Scar.',
    'Planeta Gibi Blog',
    'https://www.planetagibiblog.com.br/2024/04/checklist-disney-abril-de-2024.html',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'disney,planeta-gibi,checklist,abril-2024,culturama,panini,universo-dos-livros,pato-donald,mickey,tio-patinhas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'checklist disney abril de 2024 planeta gibi'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CHECKLIST',
    'Mensais Disney da Culturama em abril de 2024',
    'No checklist Disney de abril de 2024, o Planeta Gibi registra a linha mensal da Culturama com Pato Donald #61, Mickey #61, Tio Patinhas #61, Aventuras Disney #61 e Historias Curtas #57. A pagina tambem informa continuidades de numeracao historica herdadas da Abril e da fase Culturama, alem de creditos de traducao e dados fisicos como formato, paginas, acabamento e preco de capa.',
    'Planeta Gibi Blog',
    'https://www.planetagibiblog.com.br/2024/04/checklist-disney-abril-de-2024.html',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'disney,culturama,planeta-gibi,pato-donald,mickey,tio-patinhas,aventuras-disney,historias-curtas,numeracao'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'mensais disney da culturama em abril de 2024'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CHECKLIST',
    'Panini Disney em abril de 2024',
    'Segundo o checklist do Planeta Gibi, a Panini teve em abril de 2024 destaques Disney como Grandes Sagas Disney #1: A Espada de Gelo - Parte 1 e Colecao Carl Barks Definitiva #26: Tio Patinhas - O Navio de Ouro. A entrada de Grandes Sagas Disney e descrita como uma colecao bimensal em 22 volumes; ja o volume de Carl Barks Definitiva segue a linha de capa dura dedicada ao Homem dos Patos.',
    'Planeta Gibi Blog',
    'https://www.planetagibiblog.com.br/2024/04/checklist-disney-abril-de-2024.html',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'disney,panini,planeta-gibi,grandes-sagas-disney,a-espada-de-gelo,carl-barks,tio-patinhas,o-navio-de-ouro'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'panini disney em abril de 2024'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'REFERENCIA',
    'Wiki dos Quadrinhos Disney como referencia de pesquisa',
    'A Wiki dos Quadrinhos Disney organiza conteudo sobre personagens, artistas, publicacoes, historias, tirinhas, capas e outros materiais ligados aos quadrinhos Disney. Para o assistente do HQ-HUB, ela pode servir como pista de pesquisa e contextualizacao de personagens, criadores e publicacoes, mas deve ser tratada como fonte comunitaria e confirmada com o catalogo interno ou fontes editoriais quando a pergunta exigir precisao.',
    'Wiki dos Quadrinhos Disney/Fandom',
    'https://wikidosquadrinhosdisney.fandom.com/pt-br/wiki/Biblioteca_da_Wiki_dos_Quadrinhos_Disney',
    'COMUNITARIA',
    'CURADORIA_EXTERNA',
    'disney,wiki-dos-quadrinhos-disney,fandom,personagens,artistas,publicacoes,historias,tirinhas,capas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'wiki dos quadrinhos disney como referencia de pesquisa'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'REFERENCIA',
    'Biblioteca da Wiki dos Quadrinhos Disney',
    'A Biblioteca da Wiki dos Quadrinhos Disney e apresentada pela propria pagina como um espaco para leitura online de scans de revistas Disney do Brasil e de outros paises, com finalidade de pesquisa ou entretenimento. No HQ-HUB, essa informacao deve ser usada apenas como contexto de acervo e pesquisa: o assistente nao deve orientar copia indevida de material protegido, e pode lembrar que direitos sobre historias, personagens e nomes Disney pertencem a The Walt Disney Company.',
    'Wiki dos Quadrinhos Disney/Fandom',
    'https://wikidosquadrinhosdisney.fandom.com/pt-br/wiki/Biblioteca_da_Wiki_dos_Quadrinhos_Disney',
    'COMUNITARIA',
    'CURADORIA_EXTERNA',
    'disney,biblioteca,wiki-dos-quadrinhos-disney,scans,pesquisa,acervo,revistas-brasileiras,revistas-eua,revistas-italianas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'biblioteca da wiki dos quadrinhos disney'
);
