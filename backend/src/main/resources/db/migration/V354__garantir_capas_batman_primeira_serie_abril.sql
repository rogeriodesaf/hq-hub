-- Garante a aplicacao das capas quando a editora esta cadastrada como
-- "Editora Abril" e quando "1a Serie" faz ou nao parte do titulo.

WITH capas(numero, url_capa) AS (
    VALUES
        ('1', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhT_dDXNojjDNclGx20TaxnUrVUjTe1XXpCFh1-7SPinNdCPKXZmqUlvKWBajEd8HruXXrmLL_E5-MnEwDvZwqtUXxDZMdake20SiXTHWaqbVf61JuEMfzfJTtZHg7nzmHYyVP7c05sJy8/s1600/Batman+01.jpg'),
        ('2', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhlXGHQdwlAKe9AIhGtRpt5HbqeZ_QkyOuq58fmrJz2rIw8BwWtajojJtrz_Cmlbs_HMzxkNZx1e0h2IRXs2vvli4SgpGLWHpDu-g9LDhDhF-iWer5nfOL7mlxbp_HXKzIlrLpIfGuU4E4/s1600/Batman+02.jpg'),
        ('3', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiyfbfbroKg5_FFvk3V5XoH0ZCLMw6ypUTY5S_cvNrCP4IsJ2u5jFMCfrr3YBzT5MSUKwZPnGTBsFCgG_kvZQrOxVcxsfrZzFl0FWZqsdakp-bQArcayZrE0dZygpZi6iqIWyA8dpV3-EEM/s1600/001.jpg'),
        ('4', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgWZzNPHbMhpjUI1TzF26hyphenhyphen9TH8aGzCwnBW9dgn2brRvlhbxqG_JvSEkLCSnmg5PZQeyGFZYiTftjSwgFP4vPmPL6Zev0c4qflE4kg2hW2OlMiqJleVOGoEqMtTe51qAGfp9KbfM3oBVLjc/s1600/Bat1+4.jpg'),
        ('5', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEih3JRJBIHjkdEU_ftkl8KdRrr8FRSo23cUQfoBms-6ki1i5LVVLH0Uzgbp7Ckk-0Tz9tuTmTHNl5J0dgaIojIAhuj_Oj1K8-CoNZYA9B4lraF3teKz1v9q9ww4ZYQNUeAPvq0ujQcG3Ej8/s1600/Batman_05+01.jpg'),
        ('6', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEidJo_aboQ0BaddV1fVVVSb1eBV2G_zvVCBQe5HJ51GmPmk2dNnAy3owXP9MXyri7frG11dpdTsMeU_TQWFl0qiiO_dVhSw3LRn_tQchamGdQhy8iBU8c3_g3njy2KwcGbAyAY5XTDfI3A/s1600/Batman+06.jpg'),
        ('7', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgdF9R2bejNCyZ_7jmU87dSMeeMcHcwSgwgmlvyAi9zmX8PS9spMtRfPxX5fmiNvlrXPRS2NLgNg8zWXfhCD1OVB1MEkSdzdYu0By0t5nAzQN37PzWwxhnICB3utapwbaO044iDwc1-kQNa/s1600/Bat+07.jpg'),
        ('8', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjRBgeiGIqx6rOI3zFVvh20fNkLheJ-4-o1gY6-q4jUI6Guyqqm5rWpGHdbtC5iOziwmFOSWO2beEneznq6RWX8Cf7PHrpMvHNWUdRHoraXFtAsxHRL-R8XQlPtpbBKgcqhjYSWEYI57fCG/s1600/BAT+08+-+01.jpg'),
        ('9', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi1qe0K02qULU_L_zJJjOaJT_Jy0uVAmtJ3c33iRCitJYp2wsD72bc-yCsvAoDh5KhyphenhyphenUwoMiQ0HXwN8grM9cpmnqohXjR7SXAc1FhhEC9QTgV3O4CzpUBV_MfREiG7SKX0sXnsZ1OKk9SbV/s1600/Bat+%23+09+001.jpg'),
        ('10', 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0idcXhhATYAqx5UVkXpmOW5WrHcJX_mKQAh_EY0CVx2hkx72eFvQ73oSKhgDVXRx8XzXaQlhNOBViGEeB34kWoQJ1EasG4H52CKMrpw-ru3dK-PyOdwrEz-iC7dpIZK3a3s1BUquWmOyX/s1600/Batman+-+Abril+-+1%25C2%25AA+S%25C3%25A9rie+%2523+10.jpg')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          'batman',
          'batman 1 serie',
          'batman primeira serie'
      )
      AND coalesce(serie.volume, 1) = 1
    ORDER BY
        CASE
            WHEN serie.ano_inicio BETWEEN 1984 AND 1985 THEN 0
            ELSE 1
        END,
        serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'QUADRIKOMICS',
    url_origem = 'https://quadrikomics.blogspot.com/2012/03/batman-1a-serie-abril.html',
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero)
      = hqhub_normalizar_identidade(capa.numero);
