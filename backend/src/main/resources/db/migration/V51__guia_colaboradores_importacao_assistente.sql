INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'SISTEMA',
    'Guia de colaboradores para editar e importar edicoes',
    'Para editar uma edicao no HQ-HUB, abra Catalogo, pesquise pelo titulo no campo de busca, clique na serie interna e use Ver detalhes na edicao correta. Nos detalhes, edite os campos basicos e informe uma URL de capa que carregue fora do site de origem. Nunca use URL direta de imagem do Guia dos Quadrinhos, porque o Guia costuma bloquear o acesso externo; prefira capa da Panini, Amazon ou outro site confiavel. Se a edicao tiver historias e publicacoes originais, use Importacao. No Cadastro visual do JSON, preencha origem.url com uma fonte como Amazon, Panini ou Guia dos Quadrinhos, informe serieBrasileira.titulo, fase, editora e volume. O volume diferencia temporadas ou fases com o mesmo nome, como uma serie V1 e outra V2. Total de edicoes e total de historias sao calculados pelo formulario. Para cada edicao, preencha numero, data, editora, licenciador, categoria, genero, status, paginas, formato, preco, urlCapa e descricao quando disponiveis. Em Historias, preencha uma entrada para cada historia publicada na edicao; use + Historia para adicionar outras. Cada historia deve ter titulo em portugues, paginas, resumo/creditos, serie original, numero original, ano original e texto da publicacao quando houver. Depois clique em Atualizar JSON pelo formulario, revise o JSON gerado e clique em Importar para o catalogo. O sistema entende esse JSON e cria ou atualiza edicoes, historias e vinculos no catalogo.',
    'Manual HQ-HUB',
    null,
    'VERIFICADA',
    'SEED',
    'hq-hub,sistema,colaboradores,importacao,json,cadastro-visual,catalogo,edicao,historias,url-capa,guia-dos-quadrinhos,panini,amazon'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'guia de colaboradores para editar e importar edicoes'
);
