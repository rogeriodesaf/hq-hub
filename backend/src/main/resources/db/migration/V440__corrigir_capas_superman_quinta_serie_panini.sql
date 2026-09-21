-- Superman 5a Serie/Panini (2022): numeros 1/59 a 19/77.
-- Capas e paginas de produto correspondentes, conferidas na serie da Excelsior.
-- A edicao 1 usa a capa regular; a loja tambem lista uma capa variante.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/03/superman-panini-3a-serie-universo-dc-renascimento-59-2.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-1-59/'),
        (2, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/04/superman-panini-3a-serie-universo-dc-renascimento-60.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-2-60/'),
        (3, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/04/superman-panini-3a-serie-universo-dc-renascimento-3-61.png', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-3-61/'),
        (4, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/04/superman-panini-3a-serie-universo-dc-renascimento-62.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-4-62/'),
        (5, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-5.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-5-63/'),
        (6, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-6.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-6-64/'),
        (7, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-7.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-7-65/'),
        (8, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-8.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-8-66/'),
        (9, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/03/superman-panini-3a-serie-universo-dc-renascimento-67.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-9-67/'),
        (10, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-10.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-10-68/'),
        (11, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-11.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-11-69/'),
        (12, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-12.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-12-70/'),
        (13, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/05/superman-panini-3a-serie-universo-dc-renascimento-71.jpg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-13-71/'),
        (14, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/05/superman-panini-3a-serie-universo-dc-renascimento-72.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-14-72/'),
        (15, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/05/superman-panini-3a-serie-universo-dc-renascimento-73.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-15-73/'),
        (16, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2026/06/superman-panini-5a-serie-16.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-16-74-2/'),
        (17, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/05/superman-panini-3a-serie-universo-dc-renascimento-75.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-17-75/'),
        (18, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2023/11/superman-panini-3a-serie-universo-dc-renascimento-76.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-18-76/'),
        (19, 'https://excelsiorcomics.com.br/loja/wp-content/uploads/2024/05/superman-panini-3a-serie-universo-dc-renascimento-77.jpeg', 'https://excelsiorcomics.com.br/produto/superman-panini-5a-serie-19-77/')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = 'EXCELSIOR',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Superman 5ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) =
      hqhub_normalizar_titulo_serie('Panini')
  AND CASE
        WHEN trim(edicao.numero) ~ '^[0-9]+$' THEN
            CASE WHEN trim(edicao.numero)::integer BETWEEN 59 AND 77
                 THEN trim(edicao.numero)::integer - 58
                 ELSE trim(edicao.numero)::integer END
        WHEN trim(edicao.numero) ~ '^[0-9]+[[:space:]]*[/-][[:space:]]*[0-9]+$' THEN
            substring(trim(edicao.numero) from '^[0-9]+')::integer
      END = capa.numero
  AND (edicao.url_capa IS DISTINCT FROM capa.url_capa
       OR edicao.url_origem IS DISTINCT FROM capa.url_origem);
