-- Corrige a consolidação evitando conflito de números repetidos entre V1/V2/V3.
DO $$
DECLARE canonico BIGINT;
BEGIN
  SELECT s.id INTO canonico FROM series s JOIN editoras e ON e.id=s.editora_id
   WHERE hqhub_normalizar_titulo_serie(s.titulo)=hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva')
     AND lower(trim(e.nome)) LIKE 'panini%' ORDER BY CASE WHEN coalesce(s.volume,1)=1 THEN 0 ELSE 1 END,s.id LIMIT 1;
  IF canonico IS NULL THEN RETURN; END IF;
  DELETE FROM edicoes d USING edicoes c
   WHERE d.serie_id<>canonico AND c.serie_id=canonico
     AND hqhub_normalizar_identidade(d.numero::text)=hqhub_normalizar_identidade(c.numero::text);
  UPDATE edicoes SET serie_id=canonico,data_atualizacao=CURRENT_TIMESTAMP
   WHERE serie_id<>canonico AND serie_id IN (SELECT s.id FROM series s JOIN editoras e ON e.id=s.editora_id WHERE hqhub_normalizar_titulo_serie(s.titulo)=hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva') AND lower(trim(e.nome)) LIKE 'panini%');
  DELETE FROM series s WHERE s.id<>canonico AND hqhub_normalizar_titulo_serie(s.titulo)=hqhub_normalizar_titulo_serie('Coleção Carl Barks Definitiva') AND s.editora_id IN (SELECT id FROM editoras WHERE lower(trim(nome)) LIKE 'panini%');
END $$;
