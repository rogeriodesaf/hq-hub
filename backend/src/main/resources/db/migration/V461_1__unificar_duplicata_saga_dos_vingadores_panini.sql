-- Consolida a duplicata de A Saga dos Vingadores/Panini antes da V462.
-- A V462 encontrou dois cadastros compatíveis e interrompeu o deploy para não
-- aplicar capas sem uma identidade editorial única. Esta migração só prossegue
-- quando os dois registros são comprovadamente da galeria sa011140: Panini,
-- volume 1 (ou volume ainda não informado), título exato e edições 1 a 10.

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_saga_vingadores(
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
    edicoes_invalidas INTEGER;
    edicao_duplicada RECORD;
    edicao_canonica_id BIGINT;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade, serie_canonica_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND coalesce(serie.volume, 1) = 1
       AND serie.id_externo = 'panini|asaga dos vingadores|1'
       AND serie.url_origem LIKE '%/sa011140/%';

    IF quantidade = 0 THEN
        RETURN;
    END IF;
    -- Mais de um registro pode carregar a mesma chave externa. Nesse caso,
    -- preservamos o mais antigo (o ID público já usado no catálogo) e tratamos
    -- os demais como duplicatas somente após as validações editoriais abaixo.

    SELECT count(*), min(serie.id)
      INTO quantidade, serie_duplicada_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE serie.id <> serie_canonica_id
       AND hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND coalesce(serie.volume, 1) = 1
       AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
           hqhub_normalizar_titulo_serie('ASaga dos Vingadores'),
           hqhub_normalizar_titulo_serie('A Saga dos Vingadores'),
           hqhub_normalizar_titulo_serie('Saga dos Vingadores, A')
       );

    IF quantidade = 0 THEN
        RETURN;
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION
            'A Saga dos Vingadores/Panini V1: duplicata ambígua (%)', quantidade;
    END IF;

    SELECT count(*)
      INTO edicoes_invalidas
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_duplicada_id
       AND (
           trim(edicao.numero) !~ '^0*[1-9]$|^0*10$'
           OR (
               nullif(edicao.id_externo, '') IS NOT NULL
               AND edicao.id_externo NOT LIKE 'panini|%saga dos vingadores%'
           )
           OR (
               nullif(edicao.url_origem, '') IS NOT NULL
               AND edicao.url_origem NOT LIKE '%/sa011140/%'
           )
       );

    IF edicoes_invalidas <> 0 THEN
        RAISE EXCEPTION
            'A Saga dos Vingadores/Panini V1: duplicata contém % edições fora da identidade sa011140',
            edicoes_invalidas;
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
            UPDATE edicoes mantida
               SET titulo = coalesce(nullif(mantida.titulo, ''), descartada.titulo),
                   descricao = coalesce(nullif(mantida.descricao, ''), descartada.descricao),
                   data_publicacao = coalesce(mantida.data_publicacao, descartada.data_publicacao),
                   quantidade_paginas = coalesce(mantida.quantidade_paginas, descartada.quantidade_paginas),
                   preco_capa = coalesce(mantida.preco_capa, descartada.preco_capa),
                   formato = coalesce(nullif(mantida.formato, ''), descartada.formato),
                   data_atualizacao = CURRENT_TIMESTAMP
              FROM edicoes descartada
             WHERE mantida.id = edicao_canonica_id
               AND descartada.id = edicao_duplicada.id;

            PERFORM hqhub_mesclar_edicao_saga_vingadores(
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

DROP FUNCTION hqhub_mesclar_edicao_saga_vingadores(BIGINT, BIGINT);
