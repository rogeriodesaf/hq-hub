-- A série 974 não possuía a edição 5; as migrações anteriores apenas
-- atualizavam registros existentes. Cria a edição antes de aplicar a capa.
INSERT INTO edicoes (
    numero,
    titulo,
    url_capa,
    fonte_externa,
    url_origem,
    serie_id,
    data_criacao,
    data_atualizacao
)
SELECT
    '5',
    'Coleção Histórica Marvel: Wolverine Vol. 5',
    'https://www.comix.com.br/media/catalog/product/1/0/102641_900x900.jpg',
    'COMIX',
    'https://www.comix.com.br/colec-o-historica-marvel-wolverine-vol-5.html',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE serie.id = 974
  AND lower(trim(serie.titulo)) = lower('Coleção Histórica Marvel: Wolverine')
  AND coalesce(serie.volume, 1) = 1
  AND lower(trim(editora.nome)) = lower('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM edicoes existente
      WHERE existente.serie_id = serie.id
        AND ltrim(substring(existente.numero FROM '([0-9]+)'), '0') = '5'
  );

WITH candidato AS (
    SELECT edicao.id AS edicao_id
    FROM edicoes edicao
    WHERE edicao.serie_id = 974
      AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '5'
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidato
WHERE lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine')
  AND item.detalhe_referencia = 'V1 #5'
  AND (SELECT count(*) FROM candidato) = 1;
