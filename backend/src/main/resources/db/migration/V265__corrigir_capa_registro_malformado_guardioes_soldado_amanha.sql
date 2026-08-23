-- Corrige o registro legado cujo importador concatenou Guardiões da Galáxia
-- e O Soldado do Amanhã no mesmo título. Aplica a capa do segundo título.

UPDATE edicoes edicao
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_jmpm6jnhgp2j1eehi92j8fe63g/-S897-f.webp',
    fonte_externa = 'PANINI',
    descricao = coalesce(nullif(edicao.descricao, ''), 'Capitão América: O Soldado do Amanhã, da linha Nova Marvel Deluxe.'),
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%guardioes da galaxia%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%soldado do amanha%';

UPDATE series serie
SET descricao = 'Registro legado importado com os títulos Guardiões da Galáxia e O Soldado do Amanhã concatenados. Capa correspondente a Capitão América: O Soldado do Amanhã.',
    fonte_externa = 'PANINI',
    url_origem = 'https://panini.com.br/capitao-america-o-soldado-do-amanha',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%guardioes da galaxia%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%soldado do amanha%';
