-- Corrige as capas de Superman 2a Serie (Panini, Os Novos 52), edicoes 0 a 52.
-- A edicao 39 usa a variante do Flash indicada pelo Guia dos Quadrinhos.
WITH capas(numero, url_capa, url_origem, fonte_externa) AS (
    VALUES
        (0, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2018/09/superman-00-poster.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (1, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2014/01/IMG_0158.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (2, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2014/01/IMG_0159.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (3, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2014/01/IMG_0160.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (4, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2014/01/IMG_0161.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (5, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2014/01/IMG_0162.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (6, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-6.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (7, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-7.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (8, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-8.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (9, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-9.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (10, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-10.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (11, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-11.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (12, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-12.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (13, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-13.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (14, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-14.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (15, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-15.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (16, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-16.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (17, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-17.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (18, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-18.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (19, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/07/superman-panini-2a-serie-19.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (20, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-20.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (21, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-21.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (22, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-22.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (23, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-23.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (24, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-24.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (25, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/11/superman-panini-2aserie-25-danif.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (26, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/07/superman-panini-2a-serie-26.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (27, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2a-serie-27.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (28, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/04/superman-2aserie-28-variante-ccxp0.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (29, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/03/superman-panini-2aserie-29-variante.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (30, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-30.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (31, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/11/superman-panini-2a-serie-31.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (32, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/11/superman-panini-2a-serie-32.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (33, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/11/superman-panini-2a-serie-33.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (34, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/11/superman-panini-2a-serie-34.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (35, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-35.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (36, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-36.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (37, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-37.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (38, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2022/01/superman-panini-2a-serie-38.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (39, 'https://rika.vtexassets.com/arquivos/ids/406433/Superman-2-Serie-39-Capa-Variante.jpg', 'https://www.rika.com.br/superman---2a-serie--39--capa-variante--15007703/p', 'RIKA'),
        (40, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2018/11/superman-novos52-40.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (41, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-41.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (42, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-42.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (43, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-43.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (44, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-44.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (45, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2020/01/superman-panini-2a-serie-45.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (46, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/06/superman-panini-2a-serie-46.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (47, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/06/superman-panini-2a-serie-47.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (48, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2017/05/superman-2serie-48.jpg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (49, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/06/superman-panini-2a-serie-49.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (50, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/06/superman-panini-2a-serie-50.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (51, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/06/superman-panini-2a-serie-51.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR'),
        (52, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2021/06/superman-panini-2a-serie-52.jpeg', 'https://excelsiorcomics.com.br/serie/superman-panini-2a-serie/', 'EXCELSIOR')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = capa.fonte_externa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Superman 2ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) =
      hqhub_normalizar_titulo_serie('Panini')
  AND coalesce(serie.volume, 1) = 1
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND edicao.url_capa IS DISTINCT FROM capa.url_capa;
