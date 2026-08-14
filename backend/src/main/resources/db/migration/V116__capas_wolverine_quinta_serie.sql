-- Capas da quinta serie brasileira de Wolverine, publicada pela Panini como
-- Wolverine (2025). Atualiza o catalogo, grava um fallback direto no guia e
-- vincula as doze entradas da Ordem de Leitura Mutante as respectivas edicoes.

WITH referencias(numero, url_capa, url_origem) AS (VALUES
    ('1',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2213343/LV534402.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--1-lv534402/p'),
    ('2',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2217686/LV536763.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--2-lv536763/p'),
    ('3',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2219183/LV537587.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--3-lv537587/p'),
    ('4',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2221698/LV539122.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--4-lv539122/p'),
    ('5',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2225742/LV540571.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--5-lv540571/p'),
    ('6',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2229453/LV542348.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--6-lv542348/p'),
    ('7',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2233281/LV544040.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--7-lv544040/p'),
    ('8',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2234932/LV544829.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--8-lv544829/p'),
    ('9',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2241019/LV547230.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--9-lv547230/p'),
    ('10', 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2243608/LV548507.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--10-lv548507/p'),
    ('11', 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2246334/LV550057.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--11-lv550057/p'),
    ('12', 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2248589/LV551919.jpg', 'https://www.livrariascuritiba.com.br/wolverine--2025--12-lv551919/p')
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'LIVRARIAS_CURITIBA',
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND lower(trim(editora.nome)) = lower('Panini')
  AND lower(trim(serie.titulo)) = lower('Wolverine')
  AND serie.volume = 5
  AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero;

WITH referencias(numero, url_capa) AS (VALUES
    ('1',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2213343/LV534402.jpg'),
    ('2',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2217686/LV536763.jpg'),
    ('3',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2219183/LV537587.jpg'),
    ('4',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2221698/LV539122.jpg'),
    ('5',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2225742/LV540571.jpg'),
    ('6',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2229453/LV542348.jpg'),
    ('7',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2233281/LV544040.jpg'),
    ('8',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2234932/LV544829.jpg'),
    ('9',  'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2241019/LV547230.jpg'),
    ('10', 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2243608/LV548507.jpg'),
    ('11', 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2246334/LV550057.jpg'),
    ('12', 'https://livrariascuritiba.vteximg.com.br/arquivos/ids/2248589/LV551919.jpg')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = referencia.url_capa
FROM referencias referencia
WHERE lower(trim(item.titulo_referencia)) = lower('Wolverine')
  AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '5'
  AND ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0') = referencia.numero;

WITH candidatos AS (
    SELECT
        item.id AS item_id,
        edicao.id AS edicao_id,
        row_number() OVER (PARTITION BY item.id ORDER BY edicao.id) AS prioridade
    FROM itens_ordem_leitura item
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Wolverine')
     AND serie.volume = 5
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0')
    WHERE lower(trim(item.titulo_referencia)) = lower('Wolverine')
      AND substring(item.detalhe_referencia FROM 'V([0-9]+)') = '5'
      AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer BETWEEN 1 AND 12
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidatos candidato
WHERE item.id = candidato.item_id
  AND candidato.prioridade = 1;
