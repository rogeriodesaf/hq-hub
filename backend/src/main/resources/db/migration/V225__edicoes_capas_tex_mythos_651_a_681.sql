-- Ultimo lote capturado de Tex da Mythos: garante as edicoes 651 a 681 e suas capas.
-- Fontes das capas: catalogos publicos da Rika e Martins Fontes Paulista.
WITH capas(numero, url_capa) AS (VALUES
    ('651', 'https://rika.vteximg.com.br/arquivos/ids/454776/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285179370000'),
    ('652', 'https://rika.vteximg.com.br/arquivos/ids/454778/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285202500000'),
    ('653', 'https://rika.vteximg.com.br/arquivos/ids/454780/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285224000000'),
    ('654', 'https://rika.vteximg.com.br/arquivos/ids/454782/https---www.artesequencial.com.br-imagens-imagem_indisponivel.jpg?v=638506285245370000'),
    ('655', 'https://rika.vteximg.com.br/arquivos/ids/492955/https---www.artesequencial.com.br-imagens-sku-yuri-2025-05-12003941.jpg?v=638834612679100000'),
    ('656', 'https://rika.vteximg.com.br/arquivos/ids/492957/https---www.artesequencial.com.br-imagens-sku-yuri-2025-05-12003942.jpg?v=638834612702300000'),
    ('657', 'https://rika.vteximg.com.br/arquivos/ids/492959/https---www.artesequencial.com.br-imagens-sku-yuri-2025-05-12003943.jpg?v=638834612726800000'),
    ('658', 'https://rika.vteximg.com.br/arquivos/ids/492961/https---www.artesequencial.com.br-imagens-sku-yuri-2025-05-12003944.jpg?v=638834612750930000'),
    ('659', 'https://rika.vteximg.com.br/arquivos/ids/492963/https---www.artesequencial.com.br-imagens-sku-yuri-2025-05-12003945.jpg?v=638834612772970000'),
    ('660', 'https://rika.vteximg.com.br/arquivos/ids/494757/12003946.jpg?v=638841336667070000'),
    ('661', 'https://rika.vteximg.com.br/arquivos/ids/494758/12003947.jpg?v=638841337345500000'),
    ('662', 'https://rika.vteximg.com.br/arquivos/ids/494759/12003948.jpg?v=638841338440700000'),
    ('663', 'https://rika.vteximg.com.br/arquivos/ids/494760/12003949.jpg?v=638841339137900000'),
    ('664', 'https://rika.vteximg.com.br/arquivos/ids/494761/12003950.jpg?v=638841339988030000'),
    ('665', 'https://rika.vteximg.com.br/arquivos/ids/494762/12003951.jpg?v=638841340594830000'),
    ('666', 'https://rika.vteximg.com.br/arquivos/ids/494763/12003952.jpg?v=638841341071570000'),
    ('667', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1701803/1142003.jpg?v=638827780386100000'),
    ('668', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1708243/1146755.jpg?v=638852806327030000'),
    ('669', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1720584/1154663.jpg?v=638900014457170000'),
    ('670', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1729052/1160481.jpg?v=638931086659670000'),
    ('671', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1739787/1170742.jpg?v=638953581094930000'),
    ('672', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1766286/1189539.jpg?v=639032179446730000'),
    ('673', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1756357/1183507.jpg?v=638985799410200000'),
    ('674', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1779382/1197445.jpg?v=639082327658000000'),
    ('675', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1781437/1198771.jpg?v=639090284577570000'),
    ('676', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1779375/1197446.jpg?v=639082321851100000'),
    ('677', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1780860/1198390.jpg?v=639088375411800000'),
    ('678', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1789711/1203607.jpg.jpg?v=639126532276400000'),
    ('679', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1798876/1209630.jpg?v=639165379103330000'),
    ('680', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1804182/1213672.jpg.jpg?v=639181359965670000'),
    ('681', 'https://martinsfontespaulista.vteximg.com.br/arquivos/ids/1811103/1217565.jpg.jpg?v=639208632990200000')
), series_tex AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Mythos'),
          hqhub_normalizar_titulo_serie('Mythos Editora')
      )
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
)
INSERT INTO edicoes (
    numero,
    titulo,
    descricao,
    url_capa,
    fonte_externa,
    id_externo,
    serie_id,
    data_criacao,
    data_atualizacao
)
SELECT
    capa.numero,
    'Tex #' || capa.numero,
    'Tex - nº ' || capa.numero,
    capa.url_capa,
    'CATALOGO_LIVRARIA',
    'tex-mythos-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN series_tex serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    url_capa = EXCLUDED.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP;
