-- Capas da colecao Dragao Brasil, Trama Editorial, volume 1.
-- Fonte unica: https://archive.org/details/colecao-dragao-brasil
-- Metadados auditados em https://archive.org/metadata/colecao-dragao-brasil.
-- Foram conferidos visualmente os arquivos regulares "Dragao Brasil 001.pdf"
-- a "Dragao Brasil 119.pdf"; a primeira pagina de cada PDF e a capa.
-- Os numeros 120 a 123 foram deliberadamente excluidos: as capas identificam
-- respectivamente as editoras Talisma e Melody, portanto nao pertencem ao alvo
-- editorial Trama Editorial. Especiais, encartes, Games e Manuais tambem foram
-- excluidos por nao serem edicoes regulares da colecao alvo.
-- As URLs apontam para a primeira pagina (leaf0) do PDF correspondente no
-- Internet Archive e foram validadas como imagem JPEG durante a auditoria.

DO $$
DECLARE
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
    serie_alvo BIGINT;
BEGIN
    SELECT count(*), min(s.id)
      INTO quantidade_series, serie_alvo
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('Dragão Brasil')
       AND hqhub_normalizar_titulo_serie(e.nome) =
           hqhub_normalizar_titulo_serie('Trama Editorial')
       AND coalesce(s.volume, 1) = 1;

    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Identidade editorial ambigua para Dragao Brasil/Trama Editorial volume 1: % series',
            quantidade_series;
    END IF;

    SELECT count(*)
      INTO quantidade_edicoes
      FROM edicoes e
     WHERE e.serie_id = serie_alvo
       AND (hqhub_normalizar_identidade(e.numero))::integer BETWEEN 1 AND 119;

    IF quantidade_edicoes <> 119 THEN
        RAISE EXCEPTION
            'Auditoria recusada: esperadas 119 edicoes regulares de Dragao Brasil, encontradas %',
            quantidade_edicoes;
    END IF;

    UPDATE edicoes edicao
       SET url_capa = 'https://ia601901.us.archive.org/BookReader/BookReaderPreview.php?id=colecao-dragao-brasil&subPrefix=Drag%C3%A3o%20Brasil%20'
                    || lpad(hqhub_normalizar_identidade(edicao.numero), 3, '0')
                    || CASE WHEN (hqhub_normalizar_identidade(edicao.numero))::integer = 15
                            THEN '%20-%20Editora%20Trama' ELSE '' END
                    || '&itemPath=/1/items/colecao-dragao-brasil&server=ia601901.us.archive.org&page=leaf0',
           url_origem = 'https://archive.org/details/colecao-dragao-brasil',
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao.serie_id = serie_alvo
       AND (hqhub_normalizar_identidade(edicao.numero))::integer BETWEEN 1 AND 119;
END $$;
