-- Capas da segunda série brasileira de X-Men Extra, publicada pela Panini.
-- As imagens e páginas de referência são do volume Panini Brasil no Comic Vine;
-- nenhuma URL do Guia dos Quadrinhos é usada.

WITH capas(numero, id_comic_vine, url_capa) AS (VALUES
    ('1',  '441339', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3555138-chelist14-1.jpg'),
    ('2',  '445011', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3626907-x-menextra2.jpg'),
    ('3',  '447228', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3682619-x-men%20extra%203.jpg'),
    ('4',  '449727', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3735986-x-menextra4.jpg'),
    ('5',  '453641', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3838603-x-men%20extra%205.jpg'),
    ('6',  '456875', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3903915-x-menextra6.jpg'),
    ('7',  '459936', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/3970030-x-menextra7.jpg'),
    ('8',  '463857', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/4068298-x-menextra8.jpg'),
    ('9',  '466593', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/4120768-x-men%20extra%209.jpg'),
    ('10', '609918', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/5969111-x-menextra10.jpg'),
    ('11', '609924', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/5969192-x-men%20extra%2011.jpg'),
    ('12', '635149', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6128934-showimage.jpg'),
    ('13', '635150', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6128993-showimage.jpg'),
    ('14', '635151', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6129036-showimage.jpg'),
    ('15', '635152', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6129103-showimage.jpg'),
    ('16', '635158', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6129163-showimage.jpg'),
    ('17', '635162', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6129209-showimage.jpg'),
    ('18', '635163', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6129223-showimage.jpg'),
    ('19', '635165', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6129259-showimage.jpg'),
    ('20', '635497', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6130344-showimage.jpg'),
    ('21', '635506', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6130453-showimage.jpg'),
    ('22', '635526', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6130532-showimage.jpg'),
    ('23', '635543', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6130582-showimage.jpg'),
    ('24', '635579', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6130733-showimage.jpg'),
    ('25', '704291', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6858861-showimage.jpg'),
    ('26', '704297', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6858933-showimage.jpg'),
    ('27', '704310', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6859152-showimage.jpg'),
    ('28', '704326', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6859286-showimage.jpg'),
    ('29', '704328', 'https://comicvine.gamespot.com/a/uploads/scale_large/9/96747/6859313-showimage.jpg')
), edicoes_alvo AS (
    SELECT edicao.id, capas.id_comic_vine, capas.url_capa
    FROM capas
    JOIN edicoes edicao ON trim(edicao.numero) = capas.numero
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(serie.titulo)) = lower('X-Men Extra')
      AND serie.volume = 2
      AND lower(trim(editora.nome)) = 'panini'
)
UPDATE edicoes edicao
SET url_capa = alvo.url_capa,
    id_comic_vine = alvo.id_comic_vine,
    url_comic_vine = 'https://comicvine.gamespot.com/x-men-extra-' || trim(edicao.numero)
        || '/4000-' || alvo.id_comic_vine || '/',
    fonte_externa = 'COMIC_VINE',
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.edicao_id = edicao.id
  AND lower(trim(serie.titulo)) = lower('X-Men Extra')
  AND serie.volume = 2;
