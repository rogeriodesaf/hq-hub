-- Capas brasileiras das seis edicoes de Guerras Secretas: X-Men (Panini).
-- A ordem divide as edicoes 1 a 3 em duas etapas; por isso essas capas se
-- repetem em dois itens. A URL e gravada diretamente no item para que a capa
-- apareca mesmo quando a edicao correspondente ainda nao existe no catalogo.

WITH capas(titulo_referencia, url_capa) AS (VALUES
    ('Guerras Secretas: X-Men — A Era do Apocalipse',
     'https://rika.vtexassets.com/arquivos/ids/284192/guerras-secretas-x-men-01.jpg'),
    ('Guerras Secretas: X-Men — Dinastia M',
     'https://rika.vtexassets.com/arquivos/ids/285423/guerras-secretas-x-men-02.jpg'),
    ('Guerras Secretas: X-Men — E de Extinção',
     'https://rika.vtexassets.com/arquivos/ids/334005/Guerras-Secretas---X-Men-3---E-de-Extincao.jpg'),
    ('Guerras Secretas: X-Men — Programa de Extermínio',
     'https://rika.vtexassets.com/arquivos/ids/334006/Guerras-Secretas---X-Men-4---Programa-de-Exterminio.jpg'),
    ('Guerras Secretas: X-Men — Dias de um Futuro Esquecido',
     'https://rika.vtexassets.com/arquivos/ids/334007/Guerras-Secretas---X-Men-5---Tempos-de-um-Futuro-Esquecido.jpg'),
    ('Guerras Secretas: X-Men — Inferno',
     'https://rika.vtexassets.com/arquivos/ids/334008/Guerras-Secretas---X-Men-6-Inferno.jpg')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = capa.url_capa
FROM capas capa
WHERE lower(trim(item.titulo_referencia)) = lower(capa.titulo_referencia);
