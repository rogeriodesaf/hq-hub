-- Atualiza somente dados institucionais persistidos. Identificadores tecnicos,
-- URLs e conteudo escrito por usuarios permanecem inalterados por compatibilidade.

UPDATE usuarios
SET nome = replace(replace(replace(nome, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    data_atualizacao = CURRENT_TIMESTAMP
WHERE nome LIKE '%HQ-HUB%'
   OR nome LIKE '%HQ-Hub%'
   OR nome LIKE '%HQ Hub%';

UPDATE usuarios
SET bio = replace(replace(replace(bio, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    data_atualizacao = CURRENT_TIMESTAMP
WHERE bio LIKE '%HQ-HUB%'
   OR bio LIKE '%HQ-Hub%'
   OR bio LIKE '%HQ Hub%';

UPDATE conhecimentos_editoriais
SET titulo = replace(replace(replace(titulo, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    conteudo = replace(replace(replace(conteudo, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    fonte = replace(replace(replace(fonte, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    data_atualizacao = CURRENT_TIMESTAMP
WHERE titulo LIKE '%HQ-HUB%' OR titulo LIKE '%HQ-Hub%' OR titulo LIKE '%HQ Hub%'
   OR conteudo LIKE '%HQ-HUB%' OR conteudo LIKE '%HQ-Hub%' OR conteudo LIKE '%HQ Hub%'
   OR fonte LIKE '%HQ-HUB%' OR fonte LIKE '%HQ-Hub%' OR fonte LIKE '%HQ Hub%';

UPDATE ordens_leitura
SET descricao = replace(replace(replace(descricao, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    data_atualizacao = CURRENT_TIMESTAMP
WHERE descricao LIKE '%HQ-HUB%'
   OR descricao LIKE '%HQ-Hub%'
   OR descricao LIKE '%HQ Hub%';

UPDATE series
SET descricao = replace(replace(replace(descricao, 'HQ-HUB', 'Coleciona HQ'), 'HQ-Hub', 'Coleciona HQ'), 'HQ Hub', 'Coleciona HQ'),
    data_atualizacao = CURRENT_TIMESTAMP
WHERE descricao LIKE '%HQ-HUB%'
   OR descricao LIKE '%HQ-Hub%'
   OR descricao LIKE '%HQ Hub%';
