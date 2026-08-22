-- Cadastra a linha brasileira Marvel Deluxe da Panini, conhecida pelas capas pretas.
-- A Panini não numerou os livros; o campo numero abaixo é uma ordem interna de catálogo/leitura.
-- Capas obtidas de acervos editoriais públicos, sem usar imagens do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Marvel Deluxe',
    'Linha original de encadernados Marvel Deluxe da Panini, conhecida pelas capas pretas. Os livros não possuem numeração oficial; a numeração exibida é uma ordem interna do HQ-HUB.',
    1,
    'PANINI',
    'marvel-deluxe-panini-capa-preta-volume-1',
    'https://www.planetagibiblog.com.br/2016/03/guia-planeta-gibi-marvel-deluxe.html',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, subtitulo, url_capa) AS (VALUES
    ('1', 'Demolidor - Revelado', 'https://i.imgur.com/ENmWiKl.jpg'),
    ('2', 'Demolidor - O Rei da Cozinha do Inferno', 'https://i.imgur.com/kfCMnQk.jpg'),
    ('3', 'Demolidor - Decálogo', 'https://i.imgur.com/moE39YZ.jpg'),
    ('4', 'Demolidor - O Demônio do Pavilhão D', 'https://i.imgur.com/8HSgB9a.jpg'),
    ('5', 'Demolidor - Parte do Demônio', 'https://i.imgur.com/3ZNU5VO.jpg'),
    ('6', 'Demolidor - O Retorno do Rei', 'https://i.imgur.com/XZCF8sk.jpg'),
    ('7', 'Vingadores - A Queda', 'https://i.imgur.com/75RJ60o.jpg'),
    ('8', 'Capitão América - Soldado Invernal', 'https://i.imgur.com/FhElLeB.jpg'),
    ('9', 'Homem de Ferro - Extremis', 'https://i.imgur.com/bVWym7d.jpg'),
    ('10', 'Os Novos Vingadores - Motim', 'https://i.imgur.com/WT5Fv5o.jpg'),
    ('11', 'Dinastia M', 'https://i.imgur.com/XhmrgoU.jpg'),
    ('12', 'O Incrível Hulk - Planeta Hulk', 'https://i.imgur.com/kuanfMn.jpg'),
    ('13', 'Capitão América - A Ameaça Vermelha', 'https://i.imgur.com/Xqxh0go.jpg'),
    ('14', 'Guerra Civil', 'https://i.imgur.com/z8wwvsD.jpg'),
    ('15', 'Os Novos Vingadores - Guerra Civil', 'https://i.imgur.com/iz0pNb6.jpg'),
    ('16', 'Capitão América - A Morte do Sonho', 'https://i.imgur.com/SeWUkB3.jpg'),
    ('17', 'Os Novos Vingadores - Revolução', 'https://i.imgur.com/ChT5t8K.jpg'),
    ('18', 'Os Poderosos Vingadores - A Iniciativa Ultron', 'https://i.imgur.com/zDD2Y29.jpg'),
    ('19', 'O Incrível Hulk - Hulk contra o Mundo', 'https://i.imgur.com/fSlWuZ7.jpg'),
    ('20', 'Thor - O Renascer dos Deuses', 'https://i.imgur.com/XqgijZe.jpg'),
    ('21', 'Capitão América - O Homem que Comprou a América', 'https://i.imgur.com/zAF4E3B.jpg'),
    ('22', 'Thor - Em Nome do Pai', 'https://i.imgur.com/CEktvIX.jpg'),
    ('23', 'Capitão Marvel - Invasão Secreta', 'https://i.imgur.com/Nxxw6t2.jpg'),
    ('24', 'Capitão América - A Flecha do Tempo', 'https://i.imgur.com/LIgDOb8.jpg'),
    ('25', 'Invasão Secreta', 'https://i.imgur.com/v7pAdm0.jpg'),
    ('26', 'Os Novos Vingadores - Invasão Secreta', 'https://i.imgur.com/4ZfU6QI.jpg'),
    ('27', 'Os Poderosos Vingadores - Invasão Secreta', 'https://i.imgur.com/5TRhPlG.jpg'),
    ('28', 'Homem de Ferro - O Mais Procurado do Mundo', 'https://i.imgur.com/uVlP7Li.jpg'),
    ('29', 'Os Novos Vingadores - A Busca pelo Mago Supremo', 'https://i.imgur.com/uovodsm.jpg'),
    ('30', 'Vingadores Sombrios - Reinado Sombrio', 'https://i.imgur.com/56rV3pO.jpg'),
    ('31', 'Thor - O Cerco', 'https://i.imgur.com/YSGUVJu.jpg'),
    ('32', 'Os Novos Vingadores - O Cerco', 'https://i.imgur.com/nHJJbcM.jpg'),
    ('33', 'Capitão América - Renascimento', 'https://i.imgur.com/I8Ddx5k.jpg'),
    ('34', 'Homem de Ferro - Stark: A Queda', 'https://i.imgur.com/0sjlB6n.jpg'),
    ('35', 'Homem de Ferro - Essência do Medo', 'https://i.imgur.com/iJW9eVV.jpg'),
    ('36', 'Vingadores - Os Vingadores do Amanhã', 'https://i.imgur.com/Ade6qP4.jpg'),
    ('37', 'Capitão América - O Julgamento do Capitão América', 'https://i.imgur.com/0T6Op2O.jpg'),
    ('38', 'Os Novos Vingadores - A Era Heroica', 'https://i.imgur.com/NduprQs.jpg'),
    ('39', 'A Essência do Medo', 'https://i.imgur.com/5uxiK2X.jpg'),
    ('40', 'Vingadores - A Essência do Medo', 'https://i.imgur.com/eBLsB0w.jpg'),
    ('41', 'Capitão América - Sonhos Americanos', 'https://i.imgur.com/fwJoB07.jpg'),
    ('42', 'Os Novos Vingadores - Novos Vingadores Sombrios', 'https://i.imgur.com/1g4b3t6.jpg'),
    ('43', 'Homem de Ferro - O Futuro', 'https://i.imgur.com/uyvcyan.jpg'),
    ('44', 'Vingadores vs. X-Men', 'https://i.imgur.com/nMNsOhz.jpg'),
    ('45', 'Vingadores & Novos Vingadores - Vingadores vs. X-Men', 'https://i.imgur.com/SsvScsC.jpg'),
    ('46', 'Vingadores & X-Men - Eixo', 'https://i.imgur.com/pVzmA63.jpg'),
    ('47', 'Capitão América - Novas Ordens Mundiais', 'https://ovicio.com.br/wp-content/uploads/2020/08/20200827-51mqjvmrm5l-_sy498_bo1204203200_.jpg'),
    ('48', 'Vingadores & Novos Vingadores - Fim dos Tempos', 'https://ovicio.com.br/wp-content/uploads/2020/08/20200827-51heqgkglhl-_sx346_bo1204203200_.jpg'),
    ('49', 'A Era de Ultron', 'https://i.imgur.com/s5LwSrP.jpg'),
    ('50', 'Justiceiro - No Princípio', 'https://i.imgur.com/YVM9TaR.jpg'),
    ('51', 'Justiceiro - Mãe Rússia', 'https://i.imgur.com/TLiXpwb.jpg'),
    ('52', 'Justiceiro - Barracuda', 'https://i.imgur.com/BCbQVyK.jpg'),
    ('53', 'Justiceiro - Valley Forge', 'https://i.imgur.com/ni3YXNS.jpg')
), serie_marvel_deluxe AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'marvel-deluxe-panini-capa-preta-volume-1'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    capa.subtitulo,
    'Marvel Deluxe da Panini (capa preta). Numeração interna do catálogo; a editora não numerou oficialmente a linha.',
    capa.subtitulo,
    capa.url_capa,
    CASE WHEN capa.url_capa LIKE '%i.imgur.com%' THEN 'IMGUR' ELSE 'OVICIO' END,
    'marvel-deluxe-panini-capa-preta-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_marvel_deluxe serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
