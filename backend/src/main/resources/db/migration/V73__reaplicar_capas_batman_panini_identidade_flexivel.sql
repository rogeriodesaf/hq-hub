-- Reaplica as capas aceitando as duas identidades usadas no catalogo:
-- titulo Batman + volume 1, ou fase Primeira Serie incorporada ao titulo.
WITH capas(numero, url_capa) AS (
    VALUES
        (5,   'https://rika.vteximg.com.br/arquivos/ids/221239/-herois_panini-batman-005.jpg'),
        (6,   'https://rika.vteximg.com.br/arquivos/ids/221240/-herois_panini-batman-006.jpg'),
        (7,   'https://rika.vteximg.com.br/arquivos/ids/221241/-herois_panini-batman-007.jpg'),
        (8,   'https://rika.vteximg.com.br/arquivos/ids/221242/-herois_panini-batman-008.jpg'),
        (17,  'https://rika.vteximg.com.br/arquivos/ids/221251/-herois_panini-batman-017.jpg'),
        (23,  'https://rika.vteximg.com.br/arquivos/ids/221248/-herois_panini-batman-023.jpg'),
        (33,  'https://rika.vteximg.com.br/arquivos/ids/221267/-herois_panini-batman-033.jpg'),
        (46,  'https://rika.vteximg.com.br/arquivos/ids/221280/-herois_panini-batman-046.jpg'),
        (78,  'https://rika.vteximg.com.br/arquivos/ids/221303/-herois_panini-batman-078.jpg'),
        (84,  'https://rika.vteximg.com.br/arquivos/ids/221318/-herois_panini-batman-084.jpg'),
        (86,  'https://rika.vteximg.com.br/arquivos/ids/221320/-herois_panini-batman-086.jpg'),
        (87,  'https://rika.vteximg.com.br/arquivos/ids/221321/-herois_panini-batman-087.jpg'),
        (100, 'https://rika.vteximg.com.br/arquivos/ids/221334/-herois_panini-batman-100.jpg'),
        (102, 'https://rika.vteximg.com.br/arquivos/ids/221336/-herois_panini-batman-102.jpg'),
        (103, 'https://rika.vteximg.com.br/arquivos/ids/221337/-herois_panini-batman-103.jpg'),
        (104, 'https://rika.vteximg.com.br/arquivos/ids/221329/-herois_panini-batman-104.jpg'),
        (105, 'https://rika.vteximg.com.br/arquivos/ids/221330/-herois_panini-batman-105.jpg'),
        (106, 'https://rika.vteximg.com.br/arquivos/ids/221340/-herois_panini-batman-106.jpg'),
        (107, 'https://rika.vteximg.com.br/arquivos/ids/221341/-herois_panini-batman-107.jpg'),
        (108, 'https://rika.vteximg.com.br/arquivos/ids/221342/-herois_panini-batman-108.jpg'),
        (109, 'https://rika.vteximg.com.br/arquivos/ids/221343/-herois_panini-batman-109.jpg'),
        (110, 'https://rika.vteximg.com.br/arquivos/ids/221344/-herois_panini-batman-110.jpg'),
        (111, 'https://rika.vteximg.com.br/arquivos/ids/221345/-herois_panini-batman-111.jpg'),
        (112, 'https://rika.vteximg.com.br/arquivos/ids/221346/-herois_panini-batman-112.jpg'),
        (113, 'https://rika.vteximg.com.br/arquivos/ids/221347/-herois_panini-batman-113.jpg'),
        (114, 'https://rika.vteximg.com.br/arquivos/ids/221348/-herois_panini-batman-114.jpg')
)
UPDATE edicoes edicao
   SET url_capa = capas.url_capa,
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas,
       series serie,
       editoras editora
 WHERE edicao.serie_id = serie.id
   AND serie.editora_id = editora.id
   AND lower(trim(editora.nome)) = 'panini'
   AND (
       (lower(trim(serie.titulo)) = 'batman' AND serie.volume = 1)
       OR regexp_replace(
           translate(
               lower(coalesce(serie.titulo, '')),
               'áàâãäéèêëíìîïóòôõöúùûüçª',
               'aaaaaeeeeiiiiooooouuuuca'),
           '[^a-z0-9]+', '', 'g'
       ) IN ('batman1aserie', 'batmanprimeiraserie')
   )
   AND edicao.numero ~ '^0*[0-9]+$'
   AND CAST(edicao.numero AS INTEGER) = capas.numero;
