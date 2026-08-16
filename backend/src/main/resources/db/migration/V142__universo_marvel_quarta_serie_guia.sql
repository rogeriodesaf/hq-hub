-- Cadastra a quarta serie brasileira de Universo Marvel (Panini), adiciona
-- as capas das edicoes usadas na ordem mutante e vincula os itens do guia.
-- As imagens foram publicadas nos checklists da Panini do Planeta Gibi.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Universo Marvel',
    'Quarta serie brasileira de Universo Marvel, publicada pela Panini em 19 edicoes.',
    2016,
    2018,
    4,
    'GCD',
    'GCD-SERIES-111853',
    'https://www.comics.org/series/111853/',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, url_capa, url_origem) AS (VALUES
    (11, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj8my4emtXwo_VWd9woiJov7p29WPJh3skqrk-82nzTAJyLZ-dTaArqchtTEHuseWEtpq3_1Uz5NTDPPZPmgKFrMb7MTfkuz8aTsaqG2OZgdpt7kn2J-u5h8Ip0-eNHCLwXW9cJmLCpHK2R/s1600/Universo-Marvel-11-capa-669x1024.jpg', 'https://www.planetagibiblog.com.br/2017/09/checklist-marvel-panini-comics-setembro.html'),
    (12, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEizE_35X6wD2TmKN_Xd1zn_0pjXR_aA3vqQ4Wp1wpTIBxbtjxLLt7hHocIQe0fmF11jUadcVLwDLhNPOEjZb4r6oHHum6hIb8inB7Z6J7BKi-CaWlXDvFZ1sG0M3CFGgwUg2eRb9UNe7afv/s1600/UNIVERSO+MARVEL+42+012+C1+PANINI+2017+10.jpg', 'https://www.planetagibiblog.com.br/2017/10/checklist-marvel-panini-comics-outubro.html'),
    (13, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiQjU8hFBqUvxluDpQ3KLbevenPHsXTrFOrxApYwjPA3EXu99lSqmqHxZXVk2i6SD43K4XN78U3ycNb8Sz7llZKZPcdj9sSNIBfpgkCeR6uJ6jaOSd-vy4lx6nC9iJ8SVV_vDRJJFeXtwsd/s1600/Universo+Marvel+13+capa+1.jpg', 'https://www.planetagibiblog.com.br/2017/11/checklist-marvel-panini-comics-novembro.html'),
    (14, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiRzinOQUXvuEh4kMpQHpAW7QSft4WgTy0jeGb1IfHXfbhf-S04Tq-0dkuZq0NeVKb8CKZidbdOp0ywwEAXT0m4OKoYsAEoV4UjDs4r8ShUhYNoMWkpAcsT11XRqAxoIMAmizsp6xZgfzNc/s1600/UNIVERSO-MARVEL-14-669x1024.jpg', 'https://www.planetagibiblog.com.br/2017/12/checklist-marvel-panini-comics-dezembro.html'),
    (15, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj-5IN25jZJ17jOuwP7px61WgKS6k2Pwd1klEQqVyRk78LIfY9mQ-t6KWvpYbi7guU81POgsXFXJrelVu8eVroNv053yYoQRlBqshX_Y9vR9U0bSTXrWb22kZGusQmqNNayRPZUFWXxxQQw/s1600/UNIVERSO-MARVEL-15-669x1024.jpg', 'https://www.planetagibiblog.com.br/2018/01/checklist-marvel-panini-comics-janeiro.html'),
    (16, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEggHUS78HdPvqiURhugOFtuAHA78RIg942z9cFbFNE-djkh6LVw-AOAdZOH_QHGOhD-gqTvwlvo6KM2XaYH3irSVkeqfXEtoYjg1dErQR9MvuazsfwUyNrhKJAnKmjssUKjB38nFGsNNLc/s1600/UNIVERSO-MARVEL-16-669x1024.jpg', 'https://www.planetagibiblog.com.br/2018/02/checklist-marvel-panini-comics.html'),
    (17, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiRbBHJJW05IbFFA1HRzsyU9MfEh54lyFuBSnq-CZ2wLrJsIt0Q7jQqaMsudihh776xnGQ2krV0g0R3V9K9_dxhgmnnsP2OQkx6ES99f4rQoszFAsx0aLb5G3ugtxVc0UlH8mQzPWxSWBE/s1600/UNIVERSO+MARVEL+PAN+4S+017+c1.jpg', 'https://www.planetagibiblog.com.br/2018/04/checklist-marvel-panini-comics-marco.html'),
    (18, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhMOxdZZ0Yy20qqaZ4-vWslkWcEKRInuLe0xP2Y537A137N8ngVSmgSJ9PdghXd_mUsnSF1tOIVDoE4WKuqjxXIsqcbP7VRZ0BvG6ooltXRQgQUey0PP_FU_S9lQgME8d87cT5V4fs6Zbk/s1600/UNIVERSO+MARVEL+PAN+4S+018+c1.jpg', 'https://www.planetagibiblog.com.br/2018/04/checklist-marvel-panini-comics-abril.html'),
    (19, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhmButVamjBMNKy_1rKmY7Woh5RlJv6iFEGn8eZ2edTuRNpGtybBtbRuPhtEPFbpECPJIhvDFRNljd6HWh4M5yIWh_IxTI5aFquf04OOTl4O01NraQEuelSFM1331Gb6CoNDhS6SbE6Wjs/s1600/UNIVERSO+MARVEL+PAN+4S+019+C1.jpg', 'https://www.planetagibiblog.com.br/2018/05/checklist-marvel-panini-comics-maio-2018.html')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Universo Marvel')
      AND coalesce(serie.volume, 0) = 4
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    capa.numero::text,
    'Universo Marvel Vol. ' || lpad(capa.numero::text, 2, '0'),
    capa.url_capa,
    'PLANETA_GIBI',
    'PLANETA-GIBI-UNIVERSO-MARVEL-V4-' || lpad(capa.numero::text, 3, '0'),
    capa.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH vinculos(posicao, numero) AS (VALUES
    (330, '11'), (331, '12'), (332, '13'), (333, '14'), (334, '15'),
    (380, '16'), (381, '17'), (382, '18'), (383, '19')
), candidatos AS (
    SELECT vinculo.posicao, vinculo.numero, edicao.id AS edicao_id, edicao.url_capa,
           row_number() OVER (PARTITION BY vinculo.posicao ORDER BY edicao.id) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON trim(edicao.numero) = vinculo.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Universo Marvel')
      AND coalesce(serie.volume, 0) = 4
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id,
    url_capa_referencia = candidato.url_capa,
    detalhe_referencia = 'V4 #' || candidato.numero
FROM candidatos candidato
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = candidato.posicao
  AND candidato.prioridade = 1;
