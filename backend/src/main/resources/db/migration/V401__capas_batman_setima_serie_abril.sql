-- Capas das cinco edicoes de Batman 7a Serie (linha Planeta DC), Abril, V7.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjdyOzv_k2WC0QDkv6nKCnx-RwEHsry7cmTCvNpf9-OanaylTQLKr_-8JpVs2NQbKmMIc2ZG3ZPsXP9PEzZEDXasAw2qGhUbjI-WCq7N46MTMGiFE496pfKlxSB4Rc8OdscfNlmgg6D03L4AdWRjbHKQDaHfpIhvRpeVn_q-y8J_n8yQcyZAoN1cIrz/s2400/Batman%20(7%C2%AA%20S%C3%A9rie)%2001%20-%20Planeta%20DC.jpg',
         'https://scandehqs.blogspot.com/2023/05/batman-7-serie-n-1-planeta-dc-editora.html'),
        (2,
         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjHbWTYJs8NQwK-5jMsKSiIqxLri6nkVzw-Mlcq3YWz08lwUO-jI2x9iELK5LCg3M06xYXN8q7c8RbklEo1tvCfOAXc0YfKqcSr0h64junnpO9ApnXGxH7LyQpI0X-W-rgd82eWQCuduChchZW_zvONPd5vP-qAajtLrRRjFBEidlUzGNEb_Ui2erwA/s1553/Batman%20(7%C2%AA%20S%C3%A9rie)%2002%20-%20Planeta%20DC.jpg',
         'https://scandehqs.blogspot.com/2023/05/batman-7-serie-n-2-planeta-dc-editora.html'),
        (3,
         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjh27GChPth2GErW5v0eKDDUbJpysmrup61OduKv2P9nB4MRZAi1dU2htT0jVMtslNPN1IzidvPcIzWiu4X1CLkEof2FgyiRnDtydrU9CksChFvnChmmUmoHEOfYjnRdEHT3jDKWOisysYztC-r6dv5r6YBAIOefYhYLARcJlhe4FEaIVn3ZJBkAJfC/s1546/Batman%20(7%C2%AA%20S%C3%A9rie)%2003%20-%20Planeta%20DC.jpg',
         'https://scandehqs.blogspot.com/2023/05/batman-7-serie-n-3-9planeta-dc-editora.html'),
        (4,
         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiLFkud79HHGyBuC8PGUjjSamq1obfquGrxl7gpsn8qQWwYpkTfcMEXC5Owog67E6bo2SXuVcjWEgmNEJFpGgvtFGSi4SzVKVXSf2CHhrtJCVZ7rtA16Zi_CIZnRI9FCgEWZS7jhj86eS17pBu6P0F40pRf7teds11RQWGsKLO8NZkjD3Uwoz84G1FO/s1538/Batman%20(7%C2%AA%20S%C3%A9rie)%2004%20-%20Planeta%20DC.jpg',
         'https://scandehqs.blogspot.com/2023/05/batman-7-serie-n-4-9planeta-dc-editora.html'),
        (5,
         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi2HKAK9IsBaFGlNKkTvqYa1fki9_ewUZ-QwGoottzw1_hDQd9uX89eXX35vJXVvo-YMM1BJRIWzdonrB-jGMFAYOH9R3R0cAwTFKoYqzh8Rw2pLkD5OhwJGPYF3hypZzokb50O-MIvwbm9O30wgFFcUnZZeSNEL1FIasPonRj4kPRYSlHbE1UNTB1P/s1563/Batman%20(7%C2%AA%20S%C3%A9rie)%2005%20-%20Planeta%20DC.jpg',
         'https://scandehqs.blogspot.com/2023/05/batman-7-serie-n-5-planeta-dc-editora.html')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Batman 7ª Série')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
      AND serie.volume = 7
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'SCANDEHQS',
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
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Batman 7ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
  AND serie.volume = 7
  AND edicao.url_capa IS NOT NULL;
