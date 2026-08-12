-- Separa os números das revistas originais que foram importados indevidamente
-- como volumes da coleção. A série auxiliar preserva eventuais relacionamentos.
INSERT INTO series (titulo, descricao, volume, editora_id, data_criacao, data_atualizacao)
SELECT
    'Wolverine — referências originais a revisar',
    'Registros separados da Coleção Histórica Marvel Wolverine durante saneamento do catálogo.',
    1,
    serie.editora_id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM series serie
WHERE serie.id = 974
  AND NOT EXISTS (
      SELECT 1 FROM series existente
      WHERE existente.titulo = 'Wolverine — referências originais a revisar'
        AND existente.editora_id = serie.editora_id
  );

UPDATE edicoes
SET serie_id = (
        SELECT id FROM series
        WHERE titulo = 'Wolverine — referências originais a revisar'
          AND editora_id = (SELECT editora_id FROM series WHERE id = 974)
        ORDER BY id
        LIMIT 1
    ),
    data_atualizacao = CURRENT_TIMESTAMP
WHERE id IN (9745, 9747, 9749, 9751, 9753, 9755, 9756)
  AND serie_id = 974;

-- Reaplica as capas diretamente aos sete volumes legítimos já auditados.
UPDATE edicoes
SET url_capa = CASE id
        WHEN 9743 THEN 'https://www.comix.com.br/media/catalog/product/1/5/152320-CAPANOVA.PANINI.png'
        WHEN 9744 THEN 'https://www.comix.com.br/media/catalog/product/w/o/wolvwrine.capa.02.png'
        WHEN 9746 THEN 'https://www.comix.com.br/media/catalog/product/C/H/CHM_WOLVERINE_VOL_3_zpsywy1bqhc.jpg'
        WHEN 9748 THEN 'https://www.comix.com.br/media/catalog/product/c/o/colhistmarvel_wolverine04_22052017_1_.jpg'
        WHEN 9750 THEN 'https://www.comix.com.br/media/catalog/product/1/0/102641_900x900.jpg'
        ELSE url_capa
    END,
    fonte_externa = CASE WHEN id IN (9743, 9744, 9746, 9748, 9750) THEN 'COMIX' ELSE fonte_externa END,
    url_origem = CASE WHEN id IN (9743, 9744, 9746, 9748, 9750)
        THEN 'https://www.comix.com.br/colec-o-historica-marvel-wolverine-vol-'
            || numero || '.html'
        ELSE url_origem
    END,
    data_atualizacao = CURRENT_TIMESTAMP
WHERE serie_id = 974
  AND id IN (9743, 9744, 9746, 9748, 9750, 9752, 9754);

-- Cria o oitavo volume real, agora que o registro espúrio nº 8 foi separado.
INSERT INTO edicoes (numero, titulo, serie_id, data_criacao, data_atualizacao)
SELECT '8', 'Coleção Histórica Marvel Wolverine Vol. 8', 974, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM series WHERE id = 974)
  AND NOT EXISTS (SELECT 1 FROM edicoes WHERE serie_id = 974 AND numero = '8');

-- Vincula as posições 1 a 5 da ordem aos volumes corretos e suas capas.
WITH vinculos(numero, edicao_id) AS (VALUES
    ('1', 9743::BIGINT), ('2', 9744::BIGINT), ('3', 9746::BIGINT),
    ('4', 9748::BIGINT), ('5', 9750::BIGINT)
)
UPDATE itens_ordem_leitura item
SET edicao_id = vinculos.edicao_id
FROM vinculos
WHERE lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine')
  AND substring(item.detalhe_referencia FROM '#([0-9]+)') = vinculos.numero;
