-- Setimo lote de Tex da Mythos: garante as edicoes 551 a 600 e suas capas.
-- Fonte das capas: catalogo publico da Rika.
WITH capas(numero, url_capa) AS (VALUES
    ('551', 'https://rika.vteximg.com.br/arquivos/ids/318736/Tex-551.jpg?v=636855940867630000'),
    ('552', 'https://rika.vteximg.com.br/arquivos/ids/319311/Tex-552.jpg?v=636893833589730000'),
    ('553', 'https://rika.vteximg.com.br/arquivos/ids/319312/Tex-553.jpg?v=636893834536130000'),
    ('554', 'https://rika.vteximg.com.br/arquivos/ids/319313/Tex-554.jpg?v=636893834972970000'),
    ('555', 'https://rika.vteximg.com.br/arquivos/ids/319314/Tex-555.jpg?v=636893835457530000'),
    ('556', 'https://rika.vteximg.com.br/arquivos/ids/319315/Tex-556.jpg?v=636893838189330000'),
    ('557', 'https://rika.vteximg.com.br/arquivos/ids/319316/Tex-557.jpg?v=636893839614400000'),
    ('558', 'https://rika.vteximg.com.br/arquivos/ids/319317/Tex-558.jpg?v=636893840550130000'),
    ('559', 'https://rika.vteximg.com.br/arquivos/ids/319318/Tex-559.jpg?v=636893841267600000'),
    ('560', 'https://rika.vteximg.com.br/arquivos/ids/291958/imagem_indisponivel.jpg?v=636508349087500000'),
    ('561', 'https://rika.vteximg.com.br/arquivos/ids/319319/Tex-561.jpg?v=636893841774370000'),
    ('562', 'https://rika.vteximg.com.br/arquivos/ids/405833/https---www.artesequencial.com.br-imagens-bonelli-Tex_562.jpg?v=637593802173270000'),
    ('563', 'https://rika.vteximg.com.br/arquivos/ids/319320/Tex-563.jpg?v=636893846384200000'),
    ('564', 'https://rika.vteximg.com.br/arquivos/ids/319321/Tex-564.jpg?v=636893847646700000'),
    ('565', 'https://rika.vteximg.com.br/arquivos/ids/291963/imagem_indisponivel.jpg?v=636508349137930000'),
    ('566', 'https://rika.vteximg.com.br/arquivos/ids/319322/Tex-566.jpg?v=636893850803470000'),
    ('567', 'https://rika.vteximg.com.br/arquivos/ids/405835/https---www.artesequencial.com.br-imagens-bonelli-Tex_567.jpg?v=637593802210670000'),
    ('568', 'https://rika.vteximg.com.br/arquivos/ids/319323/Tex-568.jpg?v=636893851843700000'),
    ('569', 'https://rika.vteximg.com.br/arquivos/ids/319324/Tex-569.jpg?v=636893852727230000'),
    ('570', 'https://rika.vteximg.com.br/arquivos/ids/319325/Tex-570.jpg?v=636893916045770000'),
    ('571', 'https://rika.vteximg.com.br/arquivos/ids/319326/Tex-571.jpg?v=636893916814800000'),
    ('572', 'https://rika.vteximg.com.br/arquivos/ids/319327/Tex-572.jpg?v=636893917553000000'),
    ('573', 'https://rika.vteximg.com.br/arquivos/ids/319328/Tex-573.jpg?v=636893917976500000'),
    ('574', 'https://rika.vteximg.com.br/arquivos/ids/319329/Tex-574.jpg?v=636893918402200000'),
    ('575', 'https://rika.vteximg.com.br/arquivos/ids/319330/Tex-575.jpg?v=636893919493870000'),
    ('576', 'https://rika.vteximg.com.br/arquivos/ids/318737/Tex-576.jpg?v=636855941239730000'),
    ('577', 'https://rika.vteximg.com.br/arquivos/ids/319331/Tex-577.jpg?v=636893919932400000'),
    ('578', 'https://rika.vteximg.com.br/arquivos/ids/405837/https---www.artesequencial.com.br-imagens-bonelli-Tex_578.jpg?v=637593802250400000'),
    ('579', 'https://rika.vteximg.com.br/arquivos/ids/333182/Tex-579.jpg?v=637019072548600000'),
    ('580', 'https://rika.vteximg.com.br/arquivos/ids/333183/Tex-580.jpg?v=637019072559770000'),
    ('581', 'https://rika.vteximg.com.br/arquivos/ids/333184/Tex-581.jpg?v=637019072571200000'),
    ('582', 'https://rika.vteximg.com.br/arquivos/ids/333185/Tex-582.jpg?v=637019072585000000'),
    ('583', 'https://rika.vteximg.com.br/arquivos/ids/333186/Tex-583.jpg?v=637019072592000000'),
    ('584', 'https://rika.vteximg.com.br/arquivos/ids/333187/Tex-584.jpg?v=637019072602570000'),
    ('585', 'https://rika.vteximg.com.br/arquivos/ids/333188/Tex-585.jpg?v=637019072611270000'),
    ('586', 'https://rika.vteximg.com.br/arquivos/ids/333189/Tex-586.jpg?v=637019072626600000'),
    ('587', 'https://rika.vteximg.com.br/arquivos/ids/333190/Tex-587.jpg?v=637019072638600000'),
    ('588', 'https://rika.vteximg.com.br/arquivos/ids/333191/Tex-588.jpg?v=637019072649500000'),
    ('589', 'https://rika.vteximg.com.br/arquivos/ids/333192/Tex-589.jpg?v=637019072663730000'),
    ('590', 'https://rika.vteximg.com.br/arquivos/ids/333193/Tex-590.jpg?v=637019072670500000'),
    ('591', 'https://rika.vteximg.com.br/arquivos/ids/333194/Tex-591.jpg?v=637019072679700000'),
    ('592', 'https://rika.vteximg.com.br/arquivos/ids/405955/https---www.artesequencial.com.br-imagens-bonelli-Tex_592.jpg?v=637593804777000000'),
    ('593', 'https://rika.vteximg.com.br/arquivos/ids/405957/https---www.artesequencial.com.br-imagens-bonelli-Tex_593.jpg?v=637593804813730000'),
    ('594', 'https://rika.vteximg.com.br/arquivos/ids/333197/imagem_indisponivel.jpg?v=637019072703270000'),
    ('595', 'https://rika.vteximg.com.br/arquivos/ids/333198/imagem_indisponivel.jpg?v=637019072711600000'),
    ('596', 'https://rika.vteximg.com.br/arquivos/ids/405959/https---www.artesequencial.com.br-imagens-bonelli-Tex_596.jpg?v=637593804851300000'),
    ('597', 'https://rika.vteximg.com.br/arquivos/ids/405961/https---www.artesequencial.com.br-imagens-bonelli-Tex_597.jpg?v=637593804891170000'),
    ('598', 'https://rika.vteximg.com.br/arquivos/ids/333201/imagem_indisponivel.jpg?v=637019072734930000'),
    ('599', 'https://rika.vteximg.com.br/arquivos/ids/406031/https---www.artesequencial.com.br-imagens-bonelli-Tex_599.jpg?v=637593806355200000'),
    ('600', 'https://rika.vteximg.com.br/arquivos/ids/345548/Tex-600.jpg?v=637234521467800000')
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
    'RIKA',
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
