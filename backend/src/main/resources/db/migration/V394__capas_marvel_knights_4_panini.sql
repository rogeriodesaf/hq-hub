-- Capas dos dois volumes de Marvel Knights: 4 publicados pela Panini em 2014.
WITH capas(numero, url_capa) AS (
    VALUES
        ('1', 'https://rika.vtexassets.com/arquivos/ids/418380-800-auto/https---www.artesequencial.com.br-imagens-bruno-marvel-knights-4-1-jogados-aos-lobos.jpg'),
        ('2', 'https://rika.vtexassets.com/arquivos/ids/271104-800-auto/marvel-knights-encadernado-2.jpg')
)
UPDATE edicoes edicao
   SET url_capa = capa.url_capa,
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas capa, series serie, editoras editora
 WHERE edicao.serie_id = serie.id
   AND serie.editora_id = editora.id
   AND hqhub_normalizar_titulo_serie(serie.titulo) =
       hqhub_normalizar_titulo_serie('Marvel Knights: 4')
   AND coalesce(serie.volume, 1) = 1
   AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
   AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
