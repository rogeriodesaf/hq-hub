-- Capas das seis edicoes de Batman/Fortnite: Ponto Zero, Panini, 2021.
WITH capas(numero, isbn, url_capa, url_origem) AS (
    VALUES
        (1, '9786555126983',
         'https://img.assinaja.com/assets/tZ/004/img/263833_520x520.png',
         'https://mundosinfinitos.com.br/geek/produto/Comics-DC-BatmanFortnite-Vol-01-117719.aspx'),
        (2, '9786555128529',
         'https://img.assinaja.com/assets/tZ/004/img/282387_520x520.jpg',
         'https://mundosinfinitos.com.br/geek/produto/Comics-DC-Batmanfortnite-Vol-02-116945.aspx'),
        (3, '9786555128666',
         'https://img.assinaja.com/assets/tZ/099/img/340078_520x520.png',
         'https://mundosinfinitos.com.br/geek/produto/Comics-DC-Batmanfortnite-vol-03-110293.aspx'),
        (4, '9786559822201',
         'https://img.assinaja.com/assets/tZ/099/img/346150_520x520.png',
         'https://mundosinfinitos.com.br/geek/produto/Comics-DC-BatmanFortnite-vol-04-110917.aspx'),
        (5, '9786559822171',
         'https://img.assinaja.com/assets/tZ/099/img/346162_520x520.png',
         'https://mundosinfinitos.com.br/geek/produto/Comics-DC-BatmanFortnite-vol-05-110918.aspx'),
        (6, '9786559822096',
         'https://img.assinaja.com/assets/tZ/099/img/346168_520x520.png',
         'https://mundosinfinitos.com.br/geek/produto/Comics-DC-BatmanFortnite-Vol-06-110919.aspx')
), edicoes_alvo AS (
    SELECT
        edicao.id,
        substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman/Fortnite: Ponto Zero'),
              hqhub_normalizar_titulo_serie('Batman Fortnite: Ponto Zero'),
              hqhub_normalizar_titulo_serie('Batman/Fortnite - Ponto Zero')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND coalesce(serie.ano_inicio, 2021) = 2021
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'MUNDOS_INFINITOS',
    id_externo = coalesce(edicao.id_externo, capa.isbn),
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman/Fortnite: Ponto Zero'),
          hqhub_normalizar_titulo_serie('Batman Fortnite: Ponto Zero'),
          hqhub_normalizar_titulo_serie('Batman/Fortnite - Ponto Zero')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2021) = 2021
  AND edicao.url_capa IS NOT NULL;
