-- Cadastra a fase de Tex publicada pela Globo e suas capas, das edicoes 207 a 350.
-- Fonte das capas: catalogo publico da Rika (VTEX). Nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Globo',
    'Editora brasileira que publicou Tex do numero 207 ao 350.',
    'Brasil',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (nome) DO UPDATE SET
    data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Tex',
    'Serie brasileira de Tex publicada pela Editora Globo, do numero 207 ao 350.',
    1987,
    1998,
    1,
    'RIKA',
    'tex-globo-volume-1',
    'https://www.rika.com.br/tex--20712000207/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
    hqhub_normalizar_titulo_serie('Globo'),
    hqhub_normalizar_titulo_serie('Editora Globo')
)
ORDER BY CASE
    WHEN hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Globo') THEN 0
    ELSE 1
END, editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, url_capa) AS (VALUES
    ('207', 'https://rika.vteximg.com.br/arquivos/ids/156991/-bonelli-tex-207.jpg?v=635312865044900000'),
    ('208', 'https://rika.vteximg.com.br/arquivos/ids/156992/-bonelli-tex-208.jpg?v=635312865060530000'),
    ('209', 'https://rika.vteximg.com.br/arquivos/ids/156993/-bonelli-tex-209.jpg?v=635312865089400000'),
    ('210', 'https://rika.vteximg.com.br/arquivos/ids/156994/-bonelli-tex-210.jpg?v=635312865142370000'),
    ('211', 'https://rika.vteximg.com.br/arquivos/ids/156995/-bonelli-tex-211.jpg?v=635312865162000000'),
    ('212', 'https://rika.vteximg.com.br/arquivos/ids/156996/-bonelli-tex-212.jpg?v=635312865176370000'),
    ('213', 'https://rika.vteximg.com.br/arquivos/ids/156997/-bonelli-tex-213.jpg?v=635312865191930000'),
    ('214', 'https://rika.vteximg.com.br/arquivos/ids/156998/-bonelli-tex-214.jpg?v=635312865207870000'),
    ('215', 'https://rika.vteximg.com.br/arquivos/ids/156999/-bonelli-tex-215.jpg?v=635312865225000000'),
    ('216', 'https://rika.vteximg.com.br/arquivos/ids/157000/-bonelli-tex-216.jpg?v=635312865242370000'),
    ('217', 'https://rika.vteximg.com.br/arquivos/ids/157001/-bonelli-tex-217.jpg?v=635312865257530000'),
    ('218', 'https://rika.vteximg.com.br/arquivos/ids/157002/-bonelli-tex-218.jpg?v=635312865275900000'),
    ('219', 'https://rika.vteximg.com.br/arquivos/ids/157003/-bonelli-tex-219.jpg?v=635312865298700000'),
    ('220', 'https://rika.vteximg.com.br/arquivos/ids/157004/-bonelli-tex-221.jpg?v=635312865322100000'),
    ('221', 'https://rika.vteximg.com.br/arquivos/ids/157005/-bonelli-tex-222.jpg?v=635312865336830000'),
    ('222', 'https://rika.vteximg.com.br/arquivos/ids/157006/-bonelli-tex-220.jpg?v=635312865356300000'),
    ('223', 'https://rika.vteximg.com.br/arquivos/ids/157007/-bonelli-tex-223.jpg?v=635312865371600000'),
    ('224', 'https://rika.vteximg.com.br/arquivos/ids/157008/-bonelli-tex-224.jpg?v=635312865386900000'),
    ('225', 'https://rika.vteximg.com.br/arquivos/ids/157009/-bonelli-tex-225.jpg?v=635312865402970000'),
    ('226', 'https://rika.vteximg.com.br/arquivos/ids/157010/-bonelli-tex-226.jpg?v=635312865456400000'),
    ('227', 'https://rika.vteximg.com.br/arquivos/ids/157011/-bonelli-tex-227.jpg?v=635312865505870000'),
    ('228', 'https://rika.vteximg.com.br/arquivos/ids/157012/-bonelli-tex-228.jpg?v=635312865522900000'),
    ('229', 'https://rika.vteximg.com.br/arquivos/ids/157013/-bonelli-tex-229.jpg?v=635312865543730000'),
    ('230', 'https://rika.vteximg.com.br/arquivos/ids/157014/-bonelli-tex-230.jpg?v=635312865560300000'),
    ('231', 'https://rika.vteximg.com.br/arquivos/ids/157015/-bonelli-tex-231.jpg?v=635312865582300000'),
    ('232', 'https://rika.vteximg.com.br/arquivos/ids/157016/-bonelli-tex-232.jpg?v=635312865593770000'),
    ('233', 'https://rika.vteximg.com.br/arquivos/ids/157017/-bonelli-tex-233.jpg?v=635312865606830000'),
    ('234', 'https://rika.vteximg.com.br/arquivos/ids/157018/-bonelli-tex-234.jpg?v=635312865623700000'),
    ('235', 'https://rika.vteximg.com.br/arquivos/ids/157019/-bonelli-tex-235.jpg?v=635312865645730000'),
    ('236', 'https://rika.vteximg.com.br/arquivos/ids/285645/tex-236.jpg?v=636195813205500000'),
    ('237', 'https://rika.vteximg.com.br/arquivos/ids/157020/-bonelli-tex-237.jpg?v=635312865667770000'),
    ('238', 'https://rika.vteximg.com.br/arquivos/ids/157021/-bonelli-tex-238.jpg?v=635312865680770000'),
    ('239', 'https://rika.vteximg.com.br/arquivos/ids/157022/-bonelli-tex-239.jpg?v=635312865693570000'),
    ('240', 'https://rika.vteximg.com.br/arquivos/ids/157023/-bonelli-tex-240.jpg?v=635312865707070000'),
    ('241', 'https://rika.vteximg.com.br/arquivos/ids/157024/-bonelli-tex-241.jpg?v=635312865720270000'),
    ('242', 'https://rika.vteximg.com.br/arquivos/ids/157025/-bonelli-tex-242.jpg?v=635312865732800000'),
    ('243', 'https://rika.vteximg.com.br/arquivos/ids/157026/-bonelli-tex-243.jpg?v=635312865745970000'),
    ('244', 'https://rika.vteximg.com.br/arquivos/ids/157027/-bonelli-tex-244.jpg?v=635312865762070000'),
    ('245', 'https://rika.vteximg.com.br/arquivos/ids/157028/-bonelli-tex-245.jpg?v=635312865779000000'),
    ('246', 'https://rika.vteximg.com.br/arquivos/ids/157029/-bonelli-tex-246.jpg?v=635312865795900000'),
    ('247', 'https://rika.vteximg.com.br/arquivos/ids/157030/-bonelli-tex-247.jpg?v=635312865813400000'),
    ('248', 'https://rika.vteximg.com.br/arquivos/ids/157031/-bonelli-tex-248.jpg?v=635312865830430000'),
    ('249', 'https://rika.vteximg.com.br/arquivos/ids/157032/-bonelli-tex-249.jpg?v=635312865850400000'),
    ('250', 'https://rika.vteximg.com.br/arquivos/ids/157033/-bonelli-tex-250.jpg?v=635312865865100000'),
    ('251', 'https://rika.vteximg.com.br/arquivos/ids/157034/-bonelli-tex-251.jpg?v=635312865880600000'),
    ('252', 'https://rika.vteximg.com.br/arquivos/ids/157035/-bonelli-tex-252.jpg?v=635312865896600000'),
    ('253', 'https://rika.vteximg.com.br/arquivos/ids/157038/-bonelli-tex-253.jpg?v=635312865988500000'),
    ('254', 'https://rika.vteximg.com.br/arquivos/ids/157039/-bonelli-tex-254.jpg?v=635312866002500000'),
    ('255', 'https://rika.vteximg.com.br/arquivos/ids/157036/-bonelli-tex-255.jpg?v=635312865914030000'),
    ('256', 'https://rika.vteximg.com.br/arquivos/ids/157037/-bonelli-tex-256.jpg?v=635312865931170000'),
    ('257', 'https://rika.vteximg.com.br/arquivos/ids/157040/-bonelli-tex-257.jpg?v=635312866019100000'),
    ('258', 'https://rika.vteximg.com.br/arquivos/ids/157041/-bonelli-tex-258.jpg?v=635312866032600000'),
    ('259', 'https://rika.vteximg.com.br/arquivos/ids/157042/-bonelli-tex-259.jpg?v=635312866063000000'),
    ('260', 'https://rika.vteximg.com.br/arquivos/ids/157043/-bonelli-tex-260.jpg?v=635312866076600000'),
    ('261', 'https://rika.vteximg.com.br/arquivos/ids/157044/-bonelli-tex-261.jpg?v=635312866095670000'),
    ('262', 'https://rika.vteximg.com.br/arquivos/ids/157045/-bonelli-tex-262.jpg?v=635312866112630000'),
    ('263', 'https://rika.vteximg.com.br/arquivos/ids/157046/-bonelli-tex-263.jpg?v=635312866130670000'),
    ('264', 'https://rika.vteximg.com.br/arquivos/ids/157047/-bonelli-tex-264.jpg?v=635312866147530000'),
    ('265', 'https://rika.vteximg.com.br/arquivos/ids/157048/-bonelli-tex-265.jpg?v=635312866166070000'),
    ('266', 'https://rika.vteximg.com.br/arquivos/ids/157049/-bonelli-tex-266.jpg?v=635312866183030000'),
    ('267', 'https://rika.vteximg.com.br/arquivos/ids/157050/-bonelli-tex-267.jpg?v=635312866200370000'),
    ('268', 'https://rika.vteximg.com.br/arquivos/ids/157051/-bonelli-tex-268.jpg?v=635312866220000000'),
    ('269', 'https://rika.vteximg.com.br/arquivos/ids/157052/-bonelli-tex-269.jpg?v=635312866237000000'),
    ('270', 'https://rika.vteximg.com.br/arquivos/ids/157053/-bonelli-tex-270.jpg?v=635312866255700000'),
    ('271', 'https://rika.vteximg.com.br/arquivos/ids/157054/-bonelli-tex-271.jpg?v=635312866271900000'),
    ('272', 'https://rika.vteximg.com.br/arquivos/ids/157055/-bonelli-tex-272.jpg?v=635312866291900000'),
    ('273', 'https://rika.vteximg.com.br/arquivos/ids/157056/-bonelli-tex-273.jpg?v=635312866310270000'),
    ('274', 'https://rika.vteximg.com.br/arquivos/ids/157057/-bonelli-tex-274.jpg?v=635312866322370000'),
    ('275', 'https://rika.vteximg.com.br/arquivos/ids/157058/-bonelli-tex-275.jpg?v=635312866335830000'),
    ('276', 'https://rika.vteximg.com.br/arquivos/ids/157059/-bonelli-tex-276.jpg?v=635312866353100000'),
    ('277', 'https://rika.vteximg.com.br/arquivos/ids/157060/-bonelli-tex-277.jpg?v=635312866369400000'),
    ('278', 'https://rika.vteximg.com.br/arquivos/ids/157061/-bonelli-tex-278.jpg?v=635312866386100000'),
    ('279', 'https://rika.vteximg.com.br/arquivos/ids/157062/-bonelli-tex-279.jpg?v=635312866404030000'),
    ('280', 'https://rika.vteximg.com.br/arquivos/ids/157063/-bonelli-tex-280.jpg?v=635312866442230000'),
    ('281', 'https://rika.vteximg.com.br/arquivos/ids/157064/-bonelli-tex-281.jpg?v=635312866456800000'),
    ('282', 'https://rika.vteximg.com.br/arquivos/ids/157065/-bonelli-tex-282.jpg?v=635312866474900000'),
    ('283', 'https://rika.vteximg.com.br/arquivos/ids/157066/-bonelli-tex-283.jpg?v=635312866494700000'),
    ('284', 'https://rika.vteximg.com.br/arquivos/ids/157067/-bonelli-tex-284.jpg?v=635312866511030000'),
    ('285', 'https://rika.vteximg.com.br/arquivos/ids/157068/-bonelli-tex-285.jpg?v=635312866568730000'),
    ('286', 'https://rika.vteximg.com.br/arquivos/ids/157069/-bonelli-tex-286.jpg?v=635312866590070000'),
    ('287', 'https://rika.vteximg.com.br/arquivos/ids/157070/-bonelli-tex-287.jpg?v=635312866606830000'),
    ('288', 'https://rika.vteximg.com.br/arquivos/ids/157071/-bonelli-tex-288.jpg?v=635312866626600000'),
    ('289', 'https://rika.vteximg.com.br/arquivos/ids/157072/-bonelli-tex-289.jpg?v=635312866645870000'),
    ('290', 'https://rika.vteximg.com.br/arquivos/ids/157073/-bonelli-tex-290.jpg?v=635312866663330000'),
    ('291', 'https://rika.vteximg.com.br/arquivos/ids/157074/-bonelli-tex-291.jpg?v=635312866680770000'),
    ('292', 'https://rika.vteximg.com.br/arquivos/ids/157075/-bonelli-tex-292.jpg?v=635312866696170000'),
    ('293', 'https://rika.vteximg.com.br/arquivos/ids/157076/-bonelli-tex-293.jpg?v=635312866713270000'),
    ('294', 'https://rika.vteximg.com.br/arquivos/ids/157077/-bonelli-tex-294.jpg?v=635312866731030000'),
    ('295', 'https://rika.vteximg.com.br/arquivos/ids/157078/-bonelli-tex-295.jpg?v=635312866746730000'),
    ('296', 'https://rika.vteximg.com.br/arquivos/ids/157079/-bonelli-tex-296.jpg?v=635312866765900000'),
    ('297', 'https://rika.vteximg.com.br/arquivos/ids/157080/-bonelli-tex-297.jpg?v=635312866781700000'),
    ('298', 'https://rika.vteximg.com.br/arquivos/ids/157081/-bonelli-tex-298.jpg?v=635312866801070000'),
    ('299', 'https://rika.vteximg.com.br/arquivos/ids/157082/-bonelli-tex-299.jpg?v=635312866819530000'),
    ('300', 'https://rika.vteximg.com.br/arquivos/ids/157083/-bonelli-tex-300.jpg?v=635312866834930000'),
    ('301', 'https://rika.vteximg.com.br/arquivos/ids/157084/-bonelli-tex-301.jpg?v=635312866852000000'),
    ('302', 'https://rika.vteximg.com.br/arquivos/ids/157085/-bonelli-tex-302.jpg?v=635312866871000000'),
    ('303', 'https://rika.vteximg.com.br/arquivos/ids/157086/-bonelli-tex-303.jpg?v=635312866890370000'),
    ('304', 'https://rika.vteximg.com.br/arquivos/ids/157087/-bonelli-tex-304.jpg?v=635312866907670000'),
    ('305', 'https://rika.vteximg.com.br/arquivos/ids/157088/-bonelli-tex-305.jpg?v=635312866922600000'),
    ('306', 'https://rika.vteximg.com.br/arquivos/ids/157089/-bonelli-tex-306.jpg?v=635312866956630000'),
    ('307', 'https://rika.vteximg.com.br/arquivos/ids/157090/-bonelli-tex-307.jpg?v=635312866974870000'),
    ('308', 'https://rika.vteximg.com.br/arquivos/ids/157091/-bonelli-tex-308.jpg?v=635312866992730000'),
    ('309', 'https://rika.vteximg.com.br/arquivos/ids/157092/-bonelli-tex-309.jpg?v=635312867006270000'),
    ('310', 'https://rika.vteximg.com.br/arquivos/ids/157093/-bonelli-tex-310.jpg?v=635312867023270000'),
    ('311', 'https://rika.vteximg.com.br/arquivos/ids/157094/-bonelli-tex-311.jpg?v=635312867039570000'),
    ('312', 'https://rika.vteximg.com.br/arquivos/ids/157095/-bonelli-tex-312.jpg?v=635312867057930000'),
    ('313', 'https://rika.vteximg.com.br/arquivos/ids/157096/-bonelli-tex-313.jpg?v=635312867123100000'),
    ('314', 'https://rika.vteximg.com.br/arquivos/ids/157097/-bonelli-tex-314.jpg?v=635312867144270000'),
    ('315', 'https://rika.vteximg.com.br/arquivos/ids/157098/-bonelli-tex-315.jpg?v=635312867163470000'),
    ('316', 'https://rika.vteximg.com.br/arquivos/ids/157099/-bonelli-tex-316.jpg?v=635312867179500000'),
    ('317', 'https://rika.vteximg.com.br/arquivos/ids/157100/-bonelli-tex-317.jpg?v=635312867197870000'),
    ('318', 'https://rika.vteximg.com.br/arquivos/ids/157101/-bonelli-tex-318.jpg?v=635312867217300000'),
    ('319', 'https://rika.vteximg.com.br/arquivos/ids/157102/-bonelli-tex-319.jpg?v=635312867233770000'),
    ('320', 'https://rika.vteximg.com.br/arquivos/ids/157103/-bonelli-tex-320.jpg?v=635312867254330000'),
    ('321', 'https://rika.vteximg.com.br/arquivos/ids/157104/-bonelli-tex-321.jpg?v=635312867274070000'),
    ('322', 'https://rika.vteximg.com.br/arquivos/ids/157105/-bonelli-tex-322.jpg?v=635312867288070000'),
    ('323', 'https://rika.vteximg.com.br/arquivos/ids/157106/-bonelli-tex-323.jpg?v=635312867308100000'),
    ('324', 'https://rika.vteximg.com.br/arquivos/ids/157107/-bonelli-tex-324.jpg?v=635312867328700000'),
    ('325', 'https://rika.vteximg.com.br/arquivos/ids/157108/-bonelli-tex-325.jpg?v=635312867344370000'),
    ('326', 'https://rika.vteximg.com.br/arquivos/ids/157109/-bonelli-tex-326.jpg?v=635312867363330000'),
    ('327', 'https://rika.vteximg.com.br/arquivos/ids/157110/-bonelli-tex-327.jpg?v=635312867382730000'),
    ('328', 'https://rika.vteximg.com.br/arquivos/ids/157111/-bonelli-tex-328.jpg?v=635312867398700000'),
    ('329', 'https://rika.vteximg.com.br/arquivos/ids/157112/-bonelli-tex-329.jpg?v=635312867412570000'),
    ('330', 'https://rika.vteximg.com.br/arquivos/ids/157113/-bonelli-tex-330.jpg?v=635312867426400000'),
    ('331', 'https://rika.vteximg.com.br/arquivos/ids/157114/-bonelli-tex-331.jpg?v=635312867440670000'),
    ('332', 'https://rika.vteximg.com.br/arquivos/ids/157115/-bonelli-tex-332.jpg?v=635312867457170000'),
    ('333', 'https://rika.vteximg.com.br/arquivos/ids/157116/-bonelli-tex-333.jpg?v=635312867474200000'),
    ('334', 'https://rika.vteximg.com.br/arquivos/ids/157117/-bonelli-tex-334.jpg?v=635312867489400000'),
    ('335', 'https://rika.vteximg.com.br/arquivos/ids/157118/-bonelli-tex-335.jpg?v=635312867509370000'),
    ('336', 'https://rika.vteximg.com.br/arquivos/ids/157119/-bonelli-tex-336.jpg?v=635312867528500000'),
    ('337', 'https://rika.vteximg.com.br/arquivos/ids/157120/-bonelli-tex-337.jpg?v=635312867543930000'),
    ('338', 'https://rika.vteximg.com.br/arquivos/ids/157121/-bonelli-tex-338.jpg?v=635312867561170000'),
    ('339', 'https://rika.vteximg.com.br/arquivos/ids/157122/-bonelli-tex-339.jpg?v=635312867601800000'),
    ('340', 'https://rika.vteximg.com.br/arquivos/ids/157123/-bonelli-tex-340.jpg?v=635312867648700000'),
    ('341', 'https://rika.vteximg.com.br/arquivos/ids/157124/-bonelli-tex-341.jpg?v=635312867673770000'),
    ('342', 'https://rika.vteximg.com.br/arquivos/ids/157125/-bonelli-tex-342.jpg?v=635312867694270000'),
    ('343', 'https://rika.vteximg.com.br/arquivos/ids/157126/-bonelli-tex-343.jpg?v=635312867714970000'),
    ('344', 'https://rika.vteximg.com.br/arquivos/ids/157127/-bonelli-tex-344.jpg?v=635312867735570000'),
    ('345', 'https://rika.vteximg.com.br/arquivos/ids/157128/-bonelli-tex-345.jpg?v=635312867757570000'),
    ('346', 'https://rika.vteximg.com.br/arquivos/ids/157129/-bonelli-tex-346.jpg?v=635312867776500000'),
    ('347', 'https://rika.vteximg.com.br/arquivos/ids/157130/-bonelli-tex-347.jpg?v=635312867791730000'),
    ('348', 'https://rika.vteximg.com.br/arquivos/ids/157131/-bonelli-tex-348.jpg?v=635312867810230000'),
    ('349', 'https://rika.vteximg.com.br/arquivos/ids/157132/-bonelli-tex-349.jpg?v=635312867828570000'),
    ('350', 'https://rika.vteximg.com.br/arquivos/ids/285646/tex-350.jpg?v=636195813960400000')
), serie_tex_globo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Tex')
      AND hqhub_normalizar_titulo_serie(editora.nome) IN (
          hqhub_normalizar_titulo_serie('Globo'),
          hqhub_normalizar_titulo_serie('Editora Globo')
      )
      AND coalesce(serie.volume, 1) = 1
      AND serie.tipo_serie = 'BRASILEIRA'
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, url_capa, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Tex #' || capa.numero,
    'Tex - numero ' || capa.numero,
    capa.url_capa,
    'RIKA',
    'tex-globo-' || capa.numero,
    'https://www.rika.com.br/tex--' || capa.numero || '12000' || capa.numero || '/p',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_tex_globo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;

