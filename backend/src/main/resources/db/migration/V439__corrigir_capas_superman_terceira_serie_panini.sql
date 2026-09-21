-- Capas brasileiras verificadas por numero, serie e editora na Rika.
-- As edicoes 16 a 23 ja usam capas brasileiras numeradas da mesma serie
-- e nao sao substituidas por imagens sem confirmacao adicional.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1, 'https://rika.vtexassets.com/arquivos/ids/304642/Superman-3ª-Serie-Panini-1.jpg',
         'https://www.rika.com.br/superman---3a-serie--01-15006036/p'),
        (2, 'https://rika.vtexassets.com/arquivos/ids/304643/Superman-3ª-Serie-Panini-2.jpg',
         'https://www.rika.com.br/superman---3a-serie--02-15006037/p'),
        (3, 'https://rika.vtexassets.com/arquivos/ids/304644/Superman-3ª-Serie-Panini-3.jpg',
         'https://www.rika.com.br/superman---3a-serie--03-15006038/p'),
        (4, 'https://rika.vtexassets.com/arquivos/ids/304645/Superman-3ª-Serie-Panini-4.jpg',
         'https://www.rika.com.br/superman---3a-serie--04-15006039/p'),
        (5, 'https://rika.vtexassets.com/arquivos/ids/304646/Superman-3ª-Serie-Panini-5.jpg',
         'https://www.rika.com.br/superman---3a-serie--05-15006040/p'),
        (6, 'https://rika.vtexassets.com/arquivos/ids/304647/Superman-3ª-Serie-Panini-6.jpg',
         'https://www.rika.com.br/superman---3a-serie--06-15006041/p'),
        (7, 'https://rika.vtexassets.com/arquivos/ids/321254/Superman-7.jpg',
         'https://www.rika.com.br/superman---3a-serie--07-15006042/p'),
        (8, 'https://rika.vtexassets.com/arquivos/ids/321255/Superman-8.jpg',
         'https://www.rika.com.br/superman---3a-serie--08-15006043/p'),
        (9, 'https://rika.vtexassets.com/arquivos/ids/304650/Superman-3ª-Serie-Panini-9.jpg',
         'https://www.rika.com.br/superman---3a-serie--09-15006044/p'),
        (10, 'https://rika.vtexassets.com/arquivos/ids/304651/Superman-3ª-Serie-Panini-10.jpg',
         'https://www.rika.com.br/superman---3a-serie--10-15006045/p'),
        (11, 'https://rika.vtexassets.com/arquivos/ids/321256/Superman-11.jpg',
         'https://www.rika.com.br/superman---3a-serie--11-15006046/p'),
        (12, 'https://rika.vtexassets.com/arquivos/ids/321257/Superman-12.jpg',
         'https://www.rika.com.br/superman---3a-serie--12-15006047/p'),
        (13, 'https://rika.vtexassets.com/arquivos/ids/321258/Superman-13.jpg',
         'https://www.rika.com.br/superman---3a-serie--13-15006048/p'),
        (14, 'https://rika.vtexassets.com/arquivos/ids/321259/Superman-14.jpg',
         'https://www.rika.com.br/superman---3a-serie--14-15006049/p'),
        (15, 'https://rika.vtexassets.com/arquivos/ids/321260/Superman-15.jpg',
         'https://www.rika.com.br/superman---3a-serie--15-15006050/p')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = 'RIKA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Superman 3ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) =
      hqhub_normalizar_titulo_serie('Panini')
  AND serie.volume = 3
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND (edicao.url_capa IS DISTINCT FROM capa.url_capa
       OR edicao.url_origem IS DISTINCT FROM capa.url_origem);
