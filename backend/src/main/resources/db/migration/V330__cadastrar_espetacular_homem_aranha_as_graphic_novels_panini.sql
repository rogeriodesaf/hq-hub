-- Cadastra a edição única de O Espetacular Homem-Aranha: As Graphic Novels (Panini).

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Espetacular Homem-Aranha, O: As Graphic Novels (Marvel Graphic Novels)'),
          hqhub_normalizar_titulo_serie('O Espetacular Homem-Aranha: As Graphic Novels')
      )
    ORDER BY serie.id
    LIMIT 1
), volume(numero, titulo, url_capa, quantidade_paginas,
           id_externo, url_origem) AS (VALUES
    ('UNICA', 'O Espetacular Homem-Aranha: As Graphic Novels',
     'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/c/o/comix_capa_homem-aranha-as-graphic-novels_1.jpg',
     272, 'o-espetacular-homem-aranha-as-graphic-novels-panini',
     'https://www.comix.com.br/homem-aranha-as-graphic-novels.html')
)
INSERT INTO edicoes (
    numero, titulo, url_capa, quantidade_paginas, formato, fonte_externa,
    id_externo, url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT volume.numero, volume.titulo, volume.url_capa, volume.quantidade_paginas,
       '18,3 x 27,7 cm, colorido, capa dura', 'LOJISTAS_BRASILEIROS',
       volume.id_externo, volume.url_origem, serie.id,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM volume
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
