-- Mantem a serie de Demolidor por Mark Waid que possui as capas e mescla
-- nela eventuais referencias da serie duplicada sem capas.

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_duplicada(descartada_id BIGINT, mantida_id BIGINT)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncios anuncio SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE anuncio.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    DELETE FROM itens_colecao descartado USING itens_colecao mantido
     WHERE descartado.edicao_id = descartada_id
       AND mantido.edicao_id = mantida_id
       AND descartado.usuario_id = mantido.usuario_id;
    UPDATE itens_colecao SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM compras_planejadas descartada USING compras_planejadas mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.usuario_id = mantida.usuario_id
       AND descartada.mes = mantida.mes AND descartada.ano = mantida.ano;
    UPDATE compras_planejadas SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM creditos_edicoes descartada USING creditos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.criador_id = mantida.criador_id AND descartada.papel = mantida.papel;
    UPDATE creditos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM links_edicoes descartada USING links_edicoes mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.url = mantida.url;
    UPDATE links_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM conteudos_edicoes descartada USING conteudos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.ordem = mantida.ordem;
    UPDATE conteudos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM publicacoes_historias
     WHERE (edicao_original_id = descartada_id AND edicao_publicada_id = mantida_id)
        OR (edicao_original_id = mantida_id AND edicao_publicada_id = descartada_id);
    UPDATE publicacoes_historias SET edicao_original_id = mantida_id WHERE edicao_original_id = descartada_id;
    DELETE FROM publicacoes_historias descartada USING publicacoes_historias mantida
     WHERE descartada.edicao_publicada_id = descartada_id
       AND mantida.edicao_publicada_id = mantida_id
       AND descartada.historia_id = mantida.historia_id;
    UPDATE publicacoes_historias SET edicao_publicada_id = mantida_id WHERE edicao_publicada_id = descartada_id;

    DELETE FROM publicacoes_relacionadas
     WHERE (edicao_origem_id = descartada_id AND edicao_destino_id = mantida_id)
        OR (edicao_origem_id = mantida_id AND edicao_destino_id = descartada_id);
    UPDATE publicacoes_relacionadas SET edicao_origem_id = mantida_id WHERE edicao_origem_id = descartada_id;
    DELETE FROM publicacoes_relacionadas duplicada USING publicacoes_relacionadas mantida
     WHERE duplicada.id > mantida.id
       AND duplicada.edicao_origem_id = mantida.edicao_origem_id
       AND duplicada.edicao_destino_id = mantida.edicao_destino_id
       AND duplicada.tipo = mantida.tipo;
    UPDATE publicacoes_relacionadas SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;
    DELETE FROM publicacoes_relacionadas duplicada USING publicacoes_relacionadas mantida
     WHERE duplicada.id > mantida.id
       AND duplicada.edicao_origem_id = mantida.edicao_origem_id
       AND duplicada.edicao_destino_id = mantida.edicao_destino_id
       AND duplicada.tipo = mantida.tipo;

    UPDATE contribuicoes_catalogo SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    UPDATE contribuicoes_catalogo SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;
    UPDATE itens_ordem_leitura SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    DELETE FROM edicoes_atividades_estante descartada USING edicoes_atividades_estante mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.postagem_id = mantida.postagem_id;
    UPDATE edicoes_atividades_estante SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    DELETE FROM capas_edicao WHERE edicao_id = descartada_id;
    DELETE FROM edicoes WHERE id = descartada_id;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    mantida_id BIGINT;
    descartada RECORD;
    edicao_descartada RECORD;
    edicao_mantida_id BIGINT;
BEGIN
    SELECT serie.id INTO mantida_id
      FROM series serie
     WHERE serie.id_externo = 'demolidor-por-mark-waid-marvel-saga'
     ORDER BY (SELECT count(*) FROM edicoes e WHERE e.serie_id = serie.id AND e.url_capa IS NOT NULL) DESC,
              serie.id
     LIMIT 1;

    IF mantida_id IS NULL THEN
        SELECT serie.id INTO mantida_id
          FROM series serie
         WHERE regexp_replace(hqhub_normalizar_titulo_serie(serie.titulo), 'marvelsaga', '', 'g')
                   IN ('demolidorpormarkwaid', 'demolidorpormarkweid')
         ORDER BY (SELECT count(*) FROM edicoes e WHERE e.serie_id = serie.id AND e.url_capa IS NOT NULL) DESC,
                  serie.id
         LIMIT 1;
    END IF;

    FOR descartada IN
        SELECT serie.id
          FROM series serie
         WHERE serie.id <> mantida_id
           AND regexp_replace(hqhub_normalizar_titulo_serie(serie.titulo), 'marvelsaga', '', 'g')
                   IN ('demolidorpormarkwaid', 'demolidorpormarkweid')
    LOOP
        FOR edicao_descartada IN SELECT id, numero FROM edicoes WHERE serie_id = descartada.id LOOP
            SELECT id INTO edicao_mantida_id
              FROM edicoes
             WHERE serie_id = mantida_id
               AND hqhub_normalizar_identidade(numero) = hqhub_normalizar_identidade(edicao_descartada.numero)
             ORDER BY (url_capa IS NOT NULL) DESC, id
             LIMIT 1;

            IF edicao_mantida_id IS NULL THEN
                UPDATE edicoes SET serie_id = mantida_id WHERE id = edicao_descartada.id;
            ELSE
                PERFORM hqhub_mesclar_edicao_duplicada(edicao_descartada.id, edicao_mantida_id);
            END IF;
        END LOOP;

        DELETE FROM colecoes_series duplicada USING colecoes_series mantida
         WHERE duplicada.serie_id = descartada.id AND mantida.serie_id = mantida_id
           AND duplicada.usuario_id = mantida.usuario_id;
        UPDATE colecoes_series SET serie_id = mantida_id WHERE serie_id = descartada.id;
        UPDATE postagens_feed SET serie_catalogo_id = mantida_id WHERE serie_catalogo_id = descartada.id;
        DELETE FROM relacionamentos_series
         WHERE (serie_origem_id = descartada.id AND serie_destino_id = mantida_id)
            OR (serie_origem_id = mantida_id AND serie_destino_id = descartada.id);
        UPDATE relacionamentos_series SET serie_origem_id = mantida_id WHERE serie_origem_id = descartada.id;
        UPDATE relacionamentos_series SET serie_destino_id = mantida_id WHERE serie_destino_id = descartada.id;
        DELETE FROM relacionamentos_series duplicada USING relacionamentos_series mantida
         WHERE duplicada.id > mantida.id
           AND duplicada.serie_origem_id = mantida.serie_origem_id
           AND duplicada.serie_destino_id = mantida.serie_destino_id
           AND duplicada.tipo = mantida.tipo;
        DELETE FROM series WHERE id = descartada.id;
    END LOOP;
END $$;

DROP FUNCTION hqhub_mesclar_edicao_duplicada(BIGINT, BIGINT);

-- O backend usa a mesma regra antes de persistir. Este gatilho fecha a janela de
-- concorrencia e tambem protege insercoes feitas fora da API.
CREATE OR REPLACE FUNCTION hqhub_bloquear_serie_duplicada()
RETURNS TRIGGER AS $$
DECLARE
    titulo_novo TEXT;
BEGIN
    titulo_novo := regexp_replace(hqhub_normalizar_titulo_serie(NEW.titulo), 'marvelsaga', '', 'g');
    IF EXISTS (
        SELECT 1 FROM series existente
         WHERE existente.id <> coalesce(NEW.id, -1)
           AND existente.editora_id = NEW.editora_id
           AND coalesce(existente.volume, 0) = coalesce(NEW.volume, 0)
           AND regexp_replace(hqhub_normalizar_titulo_serie(existente.titulo), 'marvelsaga', '', 'g') = titulo_novo
    ) THEN
        RAISE EXCEPTION 'Ja existe uma serie cadastrada com este titulo, editora e volume.'
            USING ERRCODE = '23505';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_bloquear_serie_duplicada ON series;
CREATE TRIGGER trg_bloquear_serie_duplicada
BEFORE INSERT OR UPDATE OF titulo, editora_id, volume ON series
FOR EACH ROW EXECUTE FUNCTION hqhub_bloquear_serie_duplicada();
