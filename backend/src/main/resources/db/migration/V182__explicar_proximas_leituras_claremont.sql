-- Continua a revisão editorial nas posições seguintes da fase de Claremont.

UPDATE itens_ordem_leitura item SET posicao = posicao + 1000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante' AND item.posicao >= 26;

UPDATE itens_ordem_leitura item SET posicao = posicao - 999
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante' AND item.posicao >= 1026;

WITH ordem AS (SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante')
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT ordem.id, 26, 'Os Fabulosos X-Men: Edição Definitiva', 'V1 #10', 'PENDENTE_REVISAO',
    E'OPÇÃO COMPLETA PARA ESTE TRECHO DA CRONOLOGIA\nReúne Uncanny X-Men 168-175, Wolverine 1-4, X-Men Annual 7, a graphic novel Deus Ama, o Homem Mata e histórias especiais. Este volume substitui integralmente A Saga dos X-Men vols. 1-2 e também reúne o material principal de Eu, Wolverine. Escolha a edição que preferir; não é necessário ler novamente as mesmas histórias.',
    2025, 'Nova Equipe e os anos de Chris Claremont'
FROM ordem;

WITH candidato AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id, min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie ON serie.editora_id = editora.id AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Os Fabulosos X-Men: Edição Definitiva')
    JOIN edicoes edicao ON edicao.serie_id = serie.id
      AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') = '10'
    WHERE item.ordem_leitura_id = ordem.id AND item.posicao = 26
    GROUP BY item.id HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id, url_capa_referencia = candidato.url_capa, status_identificacao = 'CONFIRMADO'
FROM candidato WHERE item.id = candidato.item_id;

WITH notas(titulo, detalhe, texto) AS (VALUES
    ('Coleção Oficial de Graphic Novels Marvel', 'V1 #4 — Eu, Wolverine',
     E'AS MESMAS HISTÓRIAS ESTÃO EM OUTRAS EDIÇÕES\nA minissérie Wolverine 1-4 também aparece em Os Fabulosos X-Men: Edição Definitiva vol. 10. Uncanny X-Men 172-173 também está nesse volume e em A Saga dos X-Men vol. 1. Escolha uma dessas opções; não é necessário ler as histórias novamente.'),
    ('A Saga dos X-Men', 'V1 #1',
     E'AS MESMAS HISTÓRIAS ESTÃO EM OUTRA EDIÇÃO\nReúne Uncanny X-Men 168-173. Todas essas histórias também aparecem em Os Fabulosos X-Men: Edição Definitiva vol. 10. Escolha um dos dois encadernados para este trecho.'),
    ('A Saga dos X-Men', 'V1 #2',
     E'AS MESMAS HISTÓRIAS ESTÃO EM OUTRA EDIÇÃO\nReúne Uncanny X-Men 174-175, X-Men Annual 7, X-Men Unlimited 39 e X-Men Gold 1. Todo esse conteúdo também aparece em Os Fabulosos X-Men: Edição Definitiva vol. 10. Escolha um dos dois encadernados para este trecho.'),
    ('A Saga dos X-Men', 'V1 #3',
     E'HISTÓRIAS EXCLUSIVAS NESTE GUIA\nReúne Uncanny X-Men 176-181. Essas histórias não aparecem em outra edição atualmente listada no guia.'),
    ('A Saga dos X-Men', 'V1 #4',
     E'HISTÓRIAS EXCLUSIVAS NESTE GUIA\nReúne Uncanny X-Men 182-186 e Marvel Treasury Edition 27. Essas histórias não aparecem em outra edição atualmente listada no guia.')
)
UPDATE itens_ordem_leitura item SET observacao = nota.texto
FROM notas nota JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND lower(trim(item.titulo_referencia)) = lower(nota.titulo)
  AND item.detalhe_referencia = nota.detalhe;
