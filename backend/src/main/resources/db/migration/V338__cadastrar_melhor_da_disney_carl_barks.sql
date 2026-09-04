-- Cadastra a colecao Abril V1 e suas 41 edicoes com capas da galeria Papersera.
INSERT INTO series (titulo, descricao, ano_inicio, ano_fim, volume, tipo_serie, fonte_externa, id_externo, url_origem, editora_id, data_criacao, data_atualizacao)
SELECT 'Melhor da Disney, O - As Obras Completas de Carl Barks', 'Colecao brasileira em 41 edicoes com as obras completas de Carl Barks.', 2004, 2008, 1, 'BRASILEIRA', 'PAPERSERA', 'PAPERSERA-OMD-CARL-BARKS-V1', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm', editora.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = lower('Abril')
  AND NOT EXISTS (SELECT 1 FROM series existente WHERE existente.editora_id = editora.id AND lower(trim(existente.titulo)) = lower('Melhor da Disney, O - As Obras Completas de Carl Barks') AND coalesce(existente.volume, 1) = 1);

WITH referencias(numero, titulo, url_capa, url_origem) AS (VALUES
+    ('1', 'Melhor da Disney, O - As Obras Completas de Carl Barks #1', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0001a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('2', 'Melhor da Disney, O - As Obras Completas de Carl Barks #2', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0002a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('3', 'Melhor da Disney, O - As Obras Completas de Carl Barks #3', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0003a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('4', 'Melhor da Disney, O - As Obras Completas de Carl Barks #4', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0004a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('5', 'Melhor da Disney, O - As Obras Completas de Carl Barks #5', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0005a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('6', 'Melhor da Disney, O - As Obras Completas de Carl Barks #6', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0006a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('7', 'Melhor da Disney, O - As Obras Completas de Carl Barks #7', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0007a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('8', 'Melhor da Disney, O - As Obras Completas de Carl Barks #8', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0008a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('9', 'Melhor da Disney, O - As Obras Completas de Carl Barks #9', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0009a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('10', 'Melhor da Disney, O - As Obras Completas de Carl Barks #10', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0010a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('11', 'Melhor da Disney, O - As Obras Completas de Carl Barks #11', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0011a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('12', 'Melhor da Disney, O - As Obras Completas de Carl Barks #12', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0012a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('13', 'Melhor da Disney, O - As Obras Completas de Carl Barks #13', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0013a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('14', 'Melhor da Disney, O - As Obras Completas de Carl Barks #14', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0014a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('15', 'Melhor da Disney, O - As Obras Completas de Carl Barks #15', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0015a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('16', 'Melhor da Disney, O - As Obras Completas de Carl Barks #16', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0016a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('17', 'Melhor da Disney, O - As Obras Completas de Carl Barks #17', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0017a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('18', 'Melhor da Disney, O - As Obras Completas de Carl Barks #18', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0018a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('19', 'Melhor da Disney, O - As Obras Completas de Carl Barks #19', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0019a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('20', 'Melhor da Disney, O - As Obras Completas de Carl Barks #20', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0020a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd01_20.htm'),
    ('21', 'Melhor da Disney, O - As Obras Completas de Carl Barks #21', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0021a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('22', 'Melhor da Disney, O - As Obras Completas de Carl Barks #22', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0022a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('23', 'Melhor da Disney, O - As Obras Completas de Carl Barks #23', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0023a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('24', 'Melhor da Disney, O - As Obras Completas de Carl Barks #24', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0024a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('25', 'Melhor da Disney, O - As Obras Completas de Carl Barks #25', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0025a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('26', 'Melhor da Disney, O - As Obras Completas de Carl Barks #26', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0026a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('27', 'Melhor da Disney, O - As Obras Completas de Carl Barks #27', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0027a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('28', 'Melhor da Disney, O - As Obras Completas de Carl Barks #28', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0028a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('29', 'Melhor da Disney, O - As Obras Completas de Carl Barks #29', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0029a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('30', 'Melhor da Disney, O - As Obras Completas de Carl Barks #30', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0030a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('31', 'Melhor da Disney, O - As Obras Completas de Carl Barks #31', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0031a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('32', 'Melhor da Disney, O - As Obras Completas de Carl Barks #32', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0032a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('33', 'Melhor da Disney, O - As Obras Completas de Carl Barks #33', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0033a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('34', 'Melhor da Disney, O - As Obras Completas de Carl Barks #34', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0034a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('35', 'Melhor da Disney, O - As Obras Completas de Carl Barks #35', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0035a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('36', 'Melhor da Disney, O - As Obras Completas de Carl Barks #36', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0036a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('37', 'Melhor da Disney, O - As Obras Completas de Carl Barks #37', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0037a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('38', 'Melhor da Disney, O - As Obras Completas de Carl Barks #38', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0038a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('39', 'Melhor da Disney, O - As Obras Completas de Carl Barks #39', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0039a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('40', 'Melhor da Disney, O - As Obras Completas de Carl Barks #40', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0040a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm'),
    ('41', 'Melhor da Disney, O - As Obras Completas de Carl Barks #41', 'https://www.papersera.net/vilaxurupita/misc/br_omd_0041a.jpg', 'https://www.papersera.net/vilaxurupita/misc/omd21_40.htm')
), serie_alvo AS (
    SELECT serie.id FROM series serie JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = lower('Abril') AND lower(trim(serie.titulo)) = lower('Melhor da Disney, O - As Obras Completas de Carl Barks') AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id LIMIT 1
)
INSERT INTO edicoes (numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id, data_criacao, data_atualizacao)
SELECT referencia.numero, referencia.titulo, referencia.url_capa, 'PAPERSERA', 'PAPERSERA-OMD-CARL-BARKS-' || lpad(referencia.numero, 2, '0'), referencia.url_origem, serie.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM referencias referencia CROSS JOIN serie_alvo serie
WHERE NOT EXISTS (SELECT 1 FROM edicoes existente WHERE existente.serie_id = serie.id AND ltrim(substring(existente.numero FROM '([0-9]+)'), '0') = ltrim(referencia.numero, '0'));
