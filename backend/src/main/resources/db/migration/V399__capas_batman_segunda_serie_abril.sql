-- Cadastra as 16 capas de Batman - 2a Serie, publicada pela Abril entre
-- setembro de 1987 e dezembro de 1988.
--
-- O numero e comparado pelo sufixo numerico para abranger cadastros como
-- "1", "01" e "n. 1", sem alterar os demais metadados das edicoes.

WITH capas(numero, url_capa) AS (
    VALUES
        (1,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgY_9aiAYUhk9SFz2PZZdmcVujMV7GsQCIhs7KLk_uNWllsQ0BmV0RThA2_v9VyV7wWsytWX3nnBjK5sfVuAUvD_PuKwP2u-OgiS6DeKzR2O3ii7o2DVLDAsmkXG-eJ4KsDgBEj-oWW_GsX/s1600/01.jpg'),
        (2,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEheqie5TcZThjLVdduQJBlSWycX14LRWUeE4oDmwyh2Ce3422BfDLD2y12psXTiSrkfVGuLpqpvXo9ZWaNc21_jcK17R5npMteoOCvHQ0Kn_qffYAHN4YEEAiSYFxCmy4U7CRn2UmopvdmS/s1600/02.jpg'),
        (3,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh8wWVr9kaAOkIO8nqGgyhyphenhyphene8G0Q_iLj8ZDmrIb1wSbx312IIRJmL_RZwwxxS_buLhbU1etjI_tsl7ZvMdFYs2SHE5zTwWmBDtKsfn2YNlcSkS6nWEB0xeoNctyRC6eqLfhZY2RckRsufGF/s1600/03.jpg'),
        (4,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhnEtMVAgtzymos6Rj69vC_6oN4PKU_XhZHMcR8qIHXyCppWf98xDIjYuA52XhZZkR2LbhHAu3ke7CRDVwbPlpY-R8-imCaSgPT5-IUbGx-wV_U7z5K00RAAt7k3q21njduWOiocXoCx0rJ/s1600/04.jpg'),
        (5,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhlOHYzI7ZRspYRpIjmYp3wgg5Dd2MgDk1Iv4Gh9vE2umGXCOSwOzujCdaZQOIIRQjtIrLvcisoeULI7uTU7xd3b29-Sb-dsavCG2xxELfs3fKgewxLXiy50GBESm1Ov_bEn24zhHSwC0Y/s1600/bt00302005t.jpg'),
        (6,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgh1W21W5_4kcI0F_PozBCklykRqz9NMH0gI6yVXjvLMiqbgZNLlOXNTHuwYD5Kj6XtOleSkJg-Wri6uINNNVfC7p1P3qIdEddCPe_bGKZSbsKVTbch6SnfkddhIKvJfT5N3CSL8_iFQjhr/s1600/06.jpg'),
        (7,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgsk1l82Xi77heAQIoFrNtZ0mZ6ARwVVOb7djIUJnea4tX-T1RdqV5g6Ab0e7qVGX8HhU77U5XhuSFQJslrCpq9VPTbAl4BHY1ZxlHdtl1zkzhiWzRgIVPQ3SwMKcj5_6rH-o2i7IBWj_22/s1600/07.jpg'),
        (8,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgoTPAiGpwN_ud3qXHl3NRs59Nko4jb3OTr3BBl7nBWz6z5KDcMWWQFgdvb1Dxut72bkshLHdCMf97gmbaU42F2yNshjvpxDtZpnOL4O_2M7teVbMWM1ePMvkfsys-cD_9SNy7FZ83PozU/s1600/bt0030208t.jpg'),
        (9,  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhpaO1uZf8N97uQlAKxUm83Pi1o5i4y4SwRjDzexhWRITTuUlQE7cBxFZ_V7rX9_jpVwSihUIGkjswu5qmgGYfwuuGZM-KLExHnDxkuOiirqepM-aY7ja35ku0BwhZ-BcGA5xbeZ3vM2SSU/s1600/09.jpg'),
        (10, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgSQO1ZoPRbl2yOKAGAIofJaEuL4-CcnQKtWucygcG8fsUU0iEUwhEE4hvHLA2z6gir7Oek-fX8HvTzimZ3jSrKjThY2KdsAzqPEPsXFkVFn57nufWo5aBZ9iSchzufr3RR_8Adn2tvezc/s1600/bt00302010t.jpg'),
        (11, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg4QRWF3k-iLfkwLb8zqv8_9Urfd1Y0Pso4u9jub68M8scdEqXhrgjzT2uc_oUHJB-E2rugk4u8nnZsNHuabVl4-lnYkpm-g0Tgy98Gh3VmwIFjjde20UwIg2P_jH6O4bmYJO4kfqfuCQA/s1600/bt00302011t.jpg'),
        (12, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiffsWVmdZVYkMQE_G-AfyuWzP_2LzMoNVHbr3D70bv0-ssENardfTQsW3iMeEc444uJznjVTASECPMxbCmcgZ8b4GVnMbUL_unjC8OaD4gL-rGgfQ0aPHDiZ5jPOhsc25TZZtYlFzAr6x5/s1600/12.jpg'),
        (13, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgWyn4_PA6-ufZoKFrml7E0yqa7XG96xBIkcw527YH8BJupok6Qs-dEqakxWGdMLl1lQVTNhDQc8iMyC0PegCSaKTeAmxdMPC8Od2rfnJMpdeE7R_z48MRnwDpVfsb1Ne3rFyHxRNkJwdo/s1600/bt00302013t.jpg'),
        (14, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiaYQgoZWHRc1iC2JFDgC_dAA9Yr8tRMB7Lx-h7XLYcmLsiek94WP9eMVrOg-_CpE95c7TGwEAlMjPMDYhj3hceGH3AkcG9Eq6mlWJTA_s-6_DQ2xixNx5-PEExBbGmGmYfabm85mYwZhs/s1600/bt00302014t.jpg'),
        (15, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj7soQGg4GiVhxtvGKCy72eSsH8bhA1wDwGYsJ2F8BmGgl0OEM8iwDDZVGd53GOPUnSmP8fdgLcSqUWQqSdRzp0Esbc6ENeR-NWysu1zVDf42_PqXrLPqLeB7RRs8Qj7tR86OJADzCqsRc/s1600/bt00302015t.jpg'),
        (16, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjYkK2Z4zZb71CY177v8gJs6S6vWciEAMuczIfU6MA6dY-L8L2klRezTTLjnlIKs0R9q_yfVzfOwliiIpehgzr1NeYj6T5z16amrGT0eGf9XHESPzh3gtPqelh52rFvyT4_0ra1QRJ20Wc/s1600/bt00302016t.jpg')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Batman 2ª Série')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
      AND coalesce(serie.volume, 2) = 2
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'GUIA_ABRIL',
    url_origem = 'https://guiabril.blogspot.com/2019/01/batman-2-serie-colecao.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

-- Mantem as capas exibidas nos guias de leitura sincronizadas.
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Batman 2ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
  AND coalesce(serie.volume, 2) = 2
  AND edicao.url_capa IS NOT NULL;
