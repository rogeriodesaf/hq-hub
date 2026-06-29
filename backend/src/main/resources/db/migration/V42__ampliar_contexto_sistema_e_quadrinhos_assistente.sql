INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como preencher importacao visual de catalogo',
    'Na area Importacao, administradores e colaboradores podem usar o cadastro visual do JSON para informar serie brasileira, total de edicoes calculado, dados da edicao, capa, descricao e historias. O formulario gera o mesmo JSON aceito pelo importador tecnico, mantendo a opcao de colar ou revisar o JSON manualmente.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,importacao,json,cadastro-visual,catalogo,historias,edicoes'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como preencher importacao visual de catalogo'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como revisar contribuicoes de catalogo',
    'A area Revisao mostra pendencias enviadas por usuarios ou cadastros criados pela estante. O revisor pode conferir dados da serie, edicao, capa e historias, salvar dados editoriais, importar edicao e historias ou marcar a pendencia como checada.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,revisao,contribuicoes,catalogo,pendencias,colaborador,administrador'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como revisar contribuicoes de catalogo'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como usar amigos e mensagens',
    'Em Amigos, o usuario pode buscar outros colecionadores, enviar convites, aceitar solicitacoes e abrir conversa por mensagem. Em Meus amigos, clicar no nome abre o perfil do amigo, enquanto o link Mensagem inicia ou abre o direct.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,amigos,mensagens,direct,perfil,convites,solicitacoes'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como usar amigos e mensagens'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como funciona a lista de compras',
    'Compras no HQ-HUB funciona como uma wishlist. A lista exibe edicoes planejadas para compra futura. Quando uma edicao e marcada como comprada, cancelada ou adiada, ela deixa de aparecer na lista principal de planejadas.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,compras,wishlist,planejadas,comprada,cancelada,adiada'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como funciona a lista de compras'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Como funciona login no celular',
    'No celular, o HQ-HUB pode lembrar o e-mail usado no ultimo acesso e usa atributos de autocomplete para ajudar o navegador ou gerenciador de senhas a preencher a senha. Por seguranca, a senha nao deve ser salva diretamente pelo app.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,login,celular,senha,email,autocomplete,pwa'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'como funciona login no celular'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CONCEITO',
    'O que e uma edicao encadernada',
    'Uma edicao encadernada reune uma ou mais historias que podem ter sido publicadas originalmente em revistas avulsas. No catalogo, isso permite relacionar a publicacao brasileira com as edicoes originais e entender quais historias estao incluídas.',
    'Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'quadrinhos,encadernado,edicao,historias,publicacao-original,catalogo'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'o que e uma edicao encadernada'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CONCEITO',
    'O que e retcon nos quadrinhos',
    'Retcon e uma alteracao retroativa de continuidade. Uma historia nova muda, explica ou reorganiza eventos anteriores, criando outra leitura para fatos que ja pareciam estabelecidos.',
    'Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'quadrinhos,retcon,continuidade,cronologia,conceito'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'o que e retcon nos quadrinhos'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'CONCEITO',
    'O que e splash page',
    'Splash page e uma pagina de impacto visual, normalmente com uma unica imagem grande ou composicao dominante. Ela costuma marcar uma entrada dramatica, uma revelacao, uma cena de acao ou a abertura de uma historia.',
    'Guia Editorial HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'quadrinhos,splash-page,pagina,arte,narrativa,curiosidade'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'o que e splash page'
);
