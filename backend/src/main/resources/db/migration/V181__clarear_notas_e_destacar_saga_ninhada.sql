-- Notas editoriais diretas e opção completa para a Saga da Ninhada.

UPDATE itens_ordem_leitura item SET posicao = posicao + 1000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante' AND item.posicao >= 25;

UPDATE itens_ordem_leitura item SET posicao = posicao - 999
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id AND ordem.slug = 'ordem-de-leitura-mutante' AND item.posicao >= 1025;

WITH ordem AS (SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante')
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, titulo_referencia, detalhe_referencia,
    status_identificacao, observacao, ano_referencia, secao
)
SELECT ordem.id, 25, 'Os Fabulosos X-Men: Edição Definitiva', 'V1 #9', 'PENDENTE_REVISAO',
    E'OPÇÃO COMPLETA DA SAGA DA NINHADA\nReúne Uncanny X-Men 154-167, X-Men Annual 6 e X-Men Special Edition 1. A Saga da Ninhada está completa neste volume. Se escolher esta edição, não é necessário reler as histórias equivalentes da Coleção Histórica Marvel: Os X-Men #6, #7 e #8.',
    2024, 'Nova Equipe e os anos de Chris Claremont'
FROM ordem;

WITH candidato AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id, min(edicao.url_capa) AS url_capa
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id AND ordem.slug = 'ordem-de-leitura-mutante'
    JOIN editoras editora ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie ON serie.editora_id = editora.id AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Os Fabulosos X-Men: Edição Definitiva')
    JOIN edicoes edicao ON edicao.serie_id = serie.id
      AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') = '9'
    WHERE item.ordem_leitura_id = ordem.id AND item.posicao = 25
    GROUP BY item.id HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id, url_capa_referencia = candidato.url_capa, status_identificacao = 'CONFIRMADO'
FROM candidato WHERE item.id = candidato.item_id;

WITH notas(titulo, detalhe, texto) AS (VALUES
    ('Os Maiores Clássicos da Tropa Alfa', 'V1 #1',
     E'PARTE DAS HISTÓRIAS TAMBÉM ESTÁ EM OUTRAS EDIÇÕES\nUncanny X-Men 109 e 120-121 também aparecem em Os Fabulosos X-Men: Edição Definitiva vols. 5-6 e em X-Men: Magneto Triunfa. Já Alpha Flight 1-6 não aparece em outra edição atual do guia; este volume é necessário para ler essas primeiras histórias solo da Tropa Alfa.'),
    ('Os Maiores Clássicos da Tropa Alfa', 'V1 #2',
     E'HISTÓRIAS EXCLUSIVAS NESTE GUIA\nReúne Alpha Flight 7-12. Essas histórias não aparecem em outra edição atualmente listada no guia.'),
    ('Marvel Essenciais: X-Men — A Saga da Fênix Negra', NULL,
     E'AS MESMAS HISTÓRIAS ESTÃO EM OUTRA EDIÇÃO\nUncanny X-Men 129-137 também aparecem em Os Fabulosos X-Men: Edição Definitiva vol. 7. Escolha uma das duas edições; não é necessário ler ambas.'),
    ('Os Heróis Mais Poderosos da Marvel', 'V1 #15',
     E'PARTE DAS HISTÓRIAS TAMBÉM ESTÁ EM OUTRA EDIÇÃO\nUncanny X-Men 138-142, incluindo Dias de um Futuro Esquecido, também aparecem em Os Fabulosos X-Men: Edição Definitiva vol. 7. A graphic novel Deus Ama, o Homem Mata não aparece em outra edição atual do guia.'),
    ('Coleção Histórica Marvel: Os X-Men', 'V1 #5',
     E'PARTE DAS HISTÓRIAS TAMBÉM ESTÁ EM OUTRA EDIÇÃO\nUncanny X-Men 200 também aparece em A Saga dos X-Men vol. 12. Uncanny X-Men 145-147 e 150 não aparecem em outra edição atual do guia.'),
    ('Coleção Histórica Marvel: Os X-Men', 'V1 #6',
     E'CONTÉM O INÍCIO DA SAGA DA NINHADA\nReúne Uncanny X-Men 154-158. Para ler a saga completa em um único encadernado, escolha Os Fabulosos X-Men: Edição Definitiva vol. 9. Esta edição também contém Uncanny X-Men Annual 5, que não faz parte do volume 9.'),
    ('Coleção Histórica Marvel: Os X-Men', 'V1 #7',
     E'CONTÉM PARTE DA SAGA DA NINHADA\nReúne Uncanny X-Men 161-166. Essas histórias também estão em Os Fabulosos X-Men: Edição Definitiva vol. 9, que inclui a saga completa.'),
    ('Coleção Histórica Marvel: Os X-Men', 'V1 #8',
     E'ESTAS HISTÓRIAS TAMBÉM ESTÃO EM OUTRAS EDIÇÕES\nNew Mutants 1-3 e Uncanny X-Men 167 também aparecem em Marvel Epic Collection vol. 3 — Novos Mutantes: Renovação. Uncanny X-Men 167 também encerra a Saga da Ninhada em Os Fabulosos X-Men: Edição Definitiva vol. 9. Uncanny X-Men 232 aparece em A Saga dos X-Men vol. 22; Uncanny X-Men 233-234 aparecem em A Saga dos X-Men vol. 23. Você pode escolher este volume ou as edições citadas, sem precisar reler as mesmas histórias.'),
    ('Os Novos Mutantes: Entre a Luz e a Escuridão', NULL,
     E'HISTÓRIAS EXCLUSIVAS NESTE GUIA\nEsta edição já faz parte da ordem de leitura e reúne New Mutants 18-25 e New Mutants Annual 1. Essas histórias não aparecem em outra edição atualmente listada no guia.'),
    ('Os Novos Mutantes: Legião', NULL,
     E'HISTÓRIAS EXCLUSIVAS NESTE GUIA\nEsta edição já faz parte da ordem de leitura e reúne New Mutants 26-34. Essas histórias não aparecem em outra edição atualmente listada no guia.')
)
UPDATE itens_ordem_leitura item SET observacao = nota.texto
FROM notas nota JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND lower(trim(item.titulo_referencia)) = lower(nota.titulo)
  AND (nota.detalhe IS NULL OR item.detalhe_referencia = nota.detalhe);
