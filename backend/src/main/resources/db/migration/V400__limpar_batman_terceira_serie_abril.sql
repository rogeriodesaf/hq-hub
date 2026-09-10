-- Mantem somente uma edicao para cada numero de 1 a 29 em
-- Batman 3a Serie, Abril, volume 3. Remove referencias internas capturadas
-- como edicoes (por exemplo, numeros da serie americana) e duplicatas.

CREATE TEMP TABLE hqhub_batman_terceira_serie_abril_classificacao ON COMMIT DROP AS
SELECT edicao.id,
       substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico,
       row_number() OVER (
           PARTITION BY substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer
           ORDER BY
               (edicao.url_capa IS NOT NULL AND trim(edicao.url_capa) <> '') DESC,
               (edicao.titulo IS NOT NULL AND trim(edicao.titulo) <> '') DESC,
               edicao.id
       ) AS ordem_no_numero
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Batman 3ª Série')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
  AND serie.volume = 3;

CREATE TEMP TABLE hqhub_batman_terceira_serie_abril_excluir ON COMMIT DROP AS
SELECT id
FROM hqhub_batman_terceira_serie_abril_classificacao
WHERE numero_numerico IS NULL
   OR numero_numerico NOT BETWEEN 1 AND 29
   OR ordem_no_numero > 1;

-- Remove primeiro os classificados associados a exemplares descartados.
CREATE TEMP TABLE hqhub_itens_batman_terceira_serie_excluir ON COMMIT DROP AS
SELECT id
FROM itens_colecao
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

CREATE TEMP TABLE hqhub_anuncios_batman_terceira_serie_excluir ON COMMIT DROP AS
SELECT id
FROM anuncios
WHERE item_colecao_id IN (SELECT id FROM hqhub_itens_batman_terceira_serie_excluir);

DELETE FROM denuncias_anuncios
WHERE anuncio_id IN (SELECT id FROM hqhub_anuncios_batman_terceira_serie_excluir);

DELETE FROM fotos_anuncios
WHERE anuncio_id IN (SELECT id FROM hqhub_anuncios_batman_terceira_serie_excluir);

DELETE FROM anuncios
WHERE id IN (SELECT id FROM hqhub_anuncios_batman_terceira_serie_excluir);

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir)
   OR edicao_destino_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir)
   OR edicao_destino_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM itens_colecao
WHERE id IN (SELECT id FROM hqhub_itens_batman_terceira_serie_excluir);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_batman_terceira_serie_abril_excluir);

-- Falha a implantacao se a limpeza deixar qualquer lixo ou duplicata.
DO $$
DECLARE
    total_restante INTEGER;
    total_numeros INTEGER;
BEGIN
    SELECT count(*), count(DISTINCT substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer)
      INTO total_restante, total_numeros
      FROM edicoes edicao
      JOIN series serie ON serie.id = edicao.serie_id
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Batman 3ª Série')
       AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
       AND serie.volume = 3;

    IF total_restante <> 29 OR total_numeros <> 29 THEN
        RAISE EXCEPTION
            'Batman 3a Serie, Abril V3 deveria conter 29 edicoes unicas; restaram % edicoes e % numeros.',
            total_restante, total_numeros;
    END IF;
END $$;
