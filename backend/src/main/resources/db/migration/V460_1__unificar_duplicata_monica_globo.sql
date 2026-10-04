-- Prepara a identidade única de Mônica/Globo antes da correção de capas V461.
-- Em produção, a série canônica (volume 1, 246 edições) coexistia com uma
-- duplicata de volume nulo contendo apenas os números 12 e 119. A ambiguidade
-- fazia a V461 interromper o deploy de forma segura, sem alterar capas.

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_monica_globo(
    descartada_id BIGINT,
    mantida_id BIGINT
)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncios anuncio
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE anuncio.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    DELETE FROM itens_colecao item_descartado
     USING itens_colecao item_mantido
     WHERE item_descartado.edicao_id = descartada_id
       AND item_mantido.edicao_id = mantida_id
       AND item_descartado.usuario_id = item_mantido.usuario_id;
    UPDATE itens_colecao SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM compras_planejadas descartada
     USING compras_planejadas mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.usuario_id = mantida.usuario_id
       AND descartada.mes = mantida.mes
       AND descartada.ano = mantida.ano;
    UPDATE compras_planejadas SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM creditos_edicoes descartada
     USING creditos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.criador_id = mantida.criador_id
       AND descartada.papel = mantida.papel;
    UPDATE creditos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM links_edicoes descartada
     USING links_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.url = mantida.url;
    UPDATE links_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM conteudos_edicoes descartada
     USING conteudos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.ordem = mantida.ordem;
    UPDATE conteudos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM publicacoes_historias
     WHERE (edicao_original_id = descartada_id AND edicao_publicada_id = mantida_id)
        OR (edicao_original_id = mantida_id AND edicao_publicada_id = descartada_id);
    DELETE FROM publicacoes_historias descartada
     USING publicacoes_historias mantida
     WHERE descartada.edicao_publicada_id = descartada_id
       AND mantida.edicao_publicada_id = mantida_id
       AND descartada.historia_id = mantida.historia_id;
    UPDATE publicacoes_historias SET edicao_original_id = mantida_id WHERE edicao_original_id = descartada_id;
    UPDATE publicacoes_historias SET edicao_publicada_id = mantida_id WHERE edicao_publicada_id = descartada_id;

    DELETE FROM publicacoes_relacionadas
     WHERE (edicao_origem_id = descartada_id AND edicao_destino_id = mantida_id)
        OR (edicao_origem_id = mantida_id AND edicao_destino_id = descartada_id);
    DELETE FROM publicacoes_relacionadas descartada
     USING publicacoes_relacionadas mantida
     WHERE descartada.edicao_origem_id = descartada_id
       AND mantida.edicao_origem_id = mantida_id
       AND descartada.edicao_destino_id = mantida.edicao_destino_id
       AND descartada.tipo = mantida.tipo;
    UPDATE publicacoes_relacionadas SET edicao_origem_id = mantida_id WHERE edicao_origem_id = descartada_id;
    DELETE FROM publicacoes_relacionadas descartada
     USING publicacoes_relacionadas mantida
     WHERE descartada.edicao_destino_id = descartada_id
       AND mantida.edicao_destino_id = mantida_id
       AND descartada.edicao_origem_id = mantida.edicao_origem_id
       AND descartada.tipo = mantida.tipo;
    UPDATE publicacoes_relacionadas SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;

    UPDATE contribuicoes_catalogo SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    UPDATE contribuicoes_catalogo SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;
    UPDATE capas_edicao SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    UPDATE itens_ordem_leitura SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM edicoes_atividades_estante descartada
     USING edicoes_atividades_estante mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.postagem_id = mantida.postagem_id;
    UPDATE edicoes_atividades_estante SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM edicoes WHERE id = descartada_id;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    serie_canonica_id BIGINT;
    serie_duplicada_id BIGINT;
    quantidade INTEGER;
    edicao_duplicada RECORD;
    edicao_canonica_id BIGINT;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade, serie_canonica_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Mônica')
       AND serie.volume = 1
       AND serie.id_externo = 'globo|mônica|1';

    IF quantidade = 0 THEN
        RETURN;
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Mônica/Globo V1: série canônica ambígua (%)', quantidade;
    END IF;

    SELECT count(*), min(serie.id)
      INTO quantidade, serie_duplicada_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Globo')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Mônica')
       AND serie.volume IS NULL
       AND serie.id_externo = 'globo|mônica';

    IF quantidade = 0 THEN
        RETURN;
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Mônica/Globo: cadastro duplicado ambíguo (%)', quantidade;
    END IF;

    FOR edicao_duplicada IN
        SELECT id, numero
          FROM edicoes
         WHERE serie_id = serie_duplicada_id
         ORDER BY id
    LOOP
        SELECT id
          INTO edicao_canonica_id
          FROM edicoes
         WHERE serie_id = serie_canonica_id
           AND hqhub_normalizar_identidade(numero) =
               hqhub_normalizar_identidade(edicao_duplicada.numero)
         ORDER BY id
         LIMIT 1;

        IF edicao_canonica_id IS NULL THEN
            UPDATE edicoes
               SET serie_id = serie_canonica_id,
                   data_atualizacao = CURRENT_TIMESTAMP
             WHERE id = edicao_duplicada.id;
        ELSE
            PERFORM hqhub_mesclar_edicao_monica_globo(
                edicao_duplicada.id,
                edicao_canonica_id
            );
        END IF;
    END LOOP;

    DELETE FROM colecoes_series descartada
     USING colecoes_series mantida
     WHERE descartada.serie_id = serie_duplicada_id
       AND mantida.serie_id = serie_canonica_id
       AND descartada.usuario_id = mantida.usuario_id;
    UPDATE colecoes_series
       SET serie_id = serie_canonica_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = serie_duplicada_id;

    UPDATE postagens_feed
       SET serie_catalogo_id = serie_canonica_id
     WHERE serie_catalogo_id = serie_duplicada_id;

    DELETE FROM relacionamentos_series
     WHERE (serie_origem_id = serie_duplicada_id AND serie_destino_id = serie_canonica_id)
        OR (serie_origem_id = serie_canonica_id AND serie_destino_id = serie_duplicada_id);
    UPDATE relacionamentos_series SET serie_origem_id = serie_canonica_id WHERE serie_origem_id = serie_duplicada_id;
    UPDATE relacionamentos_series SET serie_destino_id = serie_canonica_id WHERE serie_destino_id = serie_duplicada_id;
    DELETE FROM relacionamentos_series duplicado
     USING relacionamentos_series mantido
     WHERE duplicado.id > mantido.id
       AND duplicado.serie_origem_id = mantido.serie_origem_id
       AND duplicado.serie_destino_id = mantido.serie_destino_id
       AND duplicado.tipo = mantido.tipo;

    DELETE FROM series WHERE id = serie_duplicada_id;
END
$$;

DROP FUNCTION hqhub_mesclar_edicao_monica_globo(BIGINT, BIGINT);
