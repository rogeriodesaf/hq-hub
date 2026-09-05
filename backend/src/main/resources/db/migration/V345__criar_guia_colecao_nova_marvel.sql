-- Guia editorial baseado na lista do Planeta Gibi: 71 volumes regulares e 6 Deluxe.
INSERT INTO ordens_leitura (slug,titulo,descricao,url_capa,publicada,data_criacao,data_atualizacao)
VALUES (
  'colecao-nova-marvel',
  'Coleção Nova Marvel — Guia Editorial',
  'Ordem editorial dos 71 encadernados da Coleção Nova Marvel e dos 6 volumes Nova Marvel Deluxe publicados pela Panini, conforme a numeração referencial do Planeta Gibi.',
  NULL,TRUE,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
)
ON CONFLICT (slug) DO UPDATE SET titulo=EXCLUDED.titulo,descricao=EXCLUDED.descricao,publicada=TRUE,data_atualizacao=CURRENT_TIMESTAMP;

WITH referencias(posicao,titulo,detalhe,secao) AS (VALUES
    (1, 'A Ascensão de Thanos', 'Coleção Nova Marvel #1', 'Coleção Nova Marvel'),
    (2, 'Fabulosos Vingadores #1: A Sombra Vermelha', 'Coleção Nova Marvel #2', 'Coleção Nova Marvel'),
    (3, 'Thor: O Deus do Trovão #1: O Carniceiro dos Deuses', 'Coleção Nova Marvel #3', 'Coleção Nova Marvel'),
    (4, 'Os Vingadores #1: Mundo de Vingadores', 'Coleção Nova Marvel #4', 'Coleção Nova Marvel'),
    (5, 'Novos Vingadores #1: Tudo Morre', 'Coleção Nova Marvel #5', 'Coleção Nova Marvel'),
    (6, 'Fabulosos X-Men #1: Revolução', 'Coleção Nova Marvel #6', 'Coleção Nova Marvel'),
    (7, 'Ms. Marvel #1: Nada Normal', 'Coleção Nova Marvel #7', 'Coleção Nova Marvel'),
    (8, 'Novíssimos X-Men #1: X-Men de Ontem', 'Coleção Nova Marvel #8', 'Coleção Nova Marvel'),
    (9, 'Deadpool #1: Meus Queridos Presidentes', 'Coleção Nova Marvel #9', 'Coleção Nova Marvel'),
    (10, 'Fabulosos Vingadores #2: Os Gêmeos do Apocalipse', 'Coleção Nova Marvel #10', 'Coleção Nova Marvel'),
    (11, 'Gavião Arqueiro #1: Minha Vida como uma Arma', 'Coleção Nova Marvel #11', 'Coleção Nova Marvel'),
    (12, 'Homem-Aranha Superior #1: Meu Pior Inimigo', 'Coleção Nova Marvel #12', 'Coleção Nova Marvel'),
    (13, 'Thor: O Deus do Trovão #2: Bomba Divina', 'Coleção Nova Marvel #13', 'Coleção Nova Marvel'),
    (14, 'Homem-Aranha Superior #2: Mente Conturbada', 'Coleção Nova Marvel #14', 'Coleção Nova Marvel'),
    (15, 'Novíssimos X-Men #2: Criando Raízes', 'Coleção Nova Marvel #15', 'Coleção Nova Marvel'),
    (16, 'Os Vingadores #2: O Último Evento Branco', 'Coleção Nova Marvel #16', 'Coleção Nova Marvel'),
    (17, 'Gavião Arqueiro #2: Pequenos Acertos', 'Coleção Nova Marvel #17', 'Coleção Nova Marvel'),
    (18, 'Deadpool #2: Caçador de Almas', 'Coleção Nova Marvel #18', 'Coleção Nova Marvel'),
    (19, 'Homem-Aranha Superior #3: Sem Saída', 'Coleção Nova Marvel #19', 'Coleção Nova Marvel'),
    (20, 'Ms. Marvel #2: Questões Mil', 'Coleção Nova Marvel #20', 'Coleção Nova Marvel'),
    (21, 'Thor: O Deus do Trovão #3: O Amaldiçoado', 'Coleção Nova Marvel #21', 'Coleção Nova Marvel'),
    (22, 'Fabulosos Vingadores #3: Ragnarok', 'Coleção Nova Marvel #22', 'Coleção Nova Marvel'),
    (23, 'Fabulosos X-Men #2: Destroçados', 'Coleção Nova Marvel #23', 'Coleção Nova Marvel'),
    (24, 'Novíssimos X-Men #3: Deslocados', 'Coleção Nova Marvel #24', 'Coleção Nova Marvel'),
    (25, 'Guardiões da Galáxia #1: Vingadores Cósmicos', 'Coleção Nova Marvel #25', 'Coleção Nova Marvel'),
    (26, 'Gaviã Arqueira: Vingadora da Costa Oeste', 'Coleção Nova Marvel #26', 'Coleção Nova Marvel'),
    (27, 'Os Vingadores #3: Prelúdio para Infinito', 'Coleção Nova Marvel #27', 'Coleção Nova Marvel'),
    (28, 'Fabulosos Vingadores #4: Vingar a Terra', 'Coleção Nova Marvel #28', 'Coleção Nova Marvel'),
    (29, 'Guardiões da Galáxia #2: Angela', 'Coleção Nova Marvel #29', 'Coleção Nova Marvel'),
    (30, 'Ms. Marvel #3: Apaixonada', 'Coleção Nova Marvel #30', 'Coleção Nova Marvel'),
    (31, 'Novos Vingadores #2: Infinito', 'Coleção Nova Marvel #31', 'Coleção Nova Marvel'),
    (32, 'Agentes da S.H.I.E.L.D. #1: Tiro Perfeito', 'Coleção Nova Marvel #32', 'Coleção Nova Marvel'),
    (33, 'Fabulosos X-Men #3: O Bom, o Mau e o Inumano', 'Coleção Nova Marvel #33', 'Coleção Nova Marvel'),
    (34, 'Deadpool #3: Três Homens em Conflito', 'Coleção Nova Marvel #34', 'Coleção Nova Marvel'),
    (35, 'Thor: O Deus do Trovão #4: Os Últimos Dias de Midgard', 'Coleção Nova Marvel #35', 'Coleção Nova Marvel'),
    (36, 'Os Vingadores #4: Infinito', 'Coleção Nova Marvel #36', 'Coleção Nova Marvel'),
    (37, 'Magneto #1: Infame', 'Coleção Nova Marvel #37', 'Coleção Nova Marvel'),
    (38, 'Homem-Aranha Superior #4: Mal Necessário', 'Coleção Nova Marvel #38', 'Coleção Nova Marvel'),
    (39, 'Novos Vingadores #3: Mundos Paralelos', 'Coleção Nova Marvel #39', 'Coleção Nova Marvel'),
    (40, 'Loki: Agente de Asgard #1: Confie em Mim', 'Coleção Nova Marvel #40', 'Coleção Nova Marvel'),
    (41, 'Guardiões da Galáxia #3: A Queda', 'Coleção Nova Marvel #41', 'Coleção Nova Marvel'),
    (42, 'Guardiões da Galáxia / Novíssimos X-Men: O Julgamento de Jean Grey', 'Coleção Nova Marvel #42', 'Coleção Nova Marvel'),
    (43, 'Novíssimos X-Men #4: Novos Rumos', 'Coleção Nova Marvel #43', 'Coleção Nova Marvel'),
    (44, 'Ms. Marvel #4: Últimos Dias', 'Coleção Nova Marvel #44', 'Coleção Nova Marvel'),
    (45, 'Agentes da S.H.I.E.L.D. #2: O Homem Chamado L.E.T.A.L.', 'Coleção Nova Marvel #45', 'Coleção Nova Marvel'),
    (46, 'Os Vingadores #5: Adapte-se ou Morra', 'Coleção Nova Marvel #46', 'Coleção Nova Marvel'),
    (47, 'Fabulosos Vingadores #5: Rumo ao Eixo', 'Coleção Nova Marvel #47', 'Coleção Nova Marvel'),
    (48, 'Homem-Aranha Superior #5: Venom Superior', 'Coleção Nova Marvel #48', 'Coleção Nova Marvel'),
    (49, 'Novos Vingadores #4: Um Mundo Perfeito', 'Coleção Nova Marvel #49', 'Coleção Nova Marvel'),
    (50, 'Fabulosos X-Men #4: Vs. SHIELD', 'Coleção Nova Marvel #50', 'Coleção Nova Marvel'),
    (51, 'Os Vingadores #6: Vingadores Infinitos', 'Coleção Nova Marvel #51', 'Coleção Nova Marvel'),
    (52, 'Deadpool #4: Deadpool Vs. S.H.I.E.L.D.', 'Coleção Nova Marvel #52', 'Coleção Nova Marvel'),
    (53, 'Guardiões da Galáxia #4: Pecado Original', 'Coleção Nova Marvel #53', 'Coleção Nova Marvel'),
    (54, 'Os Vingadores: Tempo Esgotado #1', 'Coleção Nova Marvel #54', 'Coleção Nova Marvel'),
    (55, 'Os Vingadores: Tempo Esgotado #2', 'Coleção Nova Marvel #55', 'Coleção Nova Marvel'),
    (56, 'Os Vingadores: Tempo Esgotado #3', 'Coleção Nova Marvel #56', 'Coleção Nova Marvel'),
    (57, 'Os Vingadores: Tempo Esgotado #4', 'Coleção Nova Marvel #57', 'Coleção Nova Marvel'),
    (58, 'Fabulosos Vingadores: Contraevolucionário', 'Coleção Nova Marvel #58', 'Coleção Nova Marvel'),
    (59, 'Novíssimos X-Men #5: Um a Menos', 'Coleção Nova Marvel #59', 'Coleção Nova Marvel'),
    (60, 'Gavião Arqueiro #4: Rio Bravo', 'Coleção Nova Marvel #60', 'Coleção Nova Marvel'),
    (61, 'Deadpool #5: O Casamento de Deadpool', 'Coleção Nova Marvel #61', 'Coleção Nova Marvel'),
    (62, 'Fabulosos X-Men #5: O Mutante Ômega', 'Coleção Nova Marvel #62', 'Coleção Nova Marvel'),
    (63, 'Magneto #2: Inversão', 'Coleção Nova Marvel #63', 'Coleção Nova Marvel'),
    (64, 'Homem-Aranha Superior #6: Nação Duende', 'Coleção Nova Marvel #64', 'Coleção Nova Marvel'),
    (65, 'Novíssimos X-Men #6: A Aventura Suprema', 'Coleção Nova Marvel #65', 'Coleção Nova Marvel'),
    (66, 'Surfista Prateado #1: Novo Alvorecer', 'Coleção Nova Marvel #66', 'Coleção Nova Marvel'),
    (67, 'Espetacular Homem-Aranha #1: A Sorte dos Parker', 'Coleção Nova Marvel #67', 'Coleção Nova Marvel'),
    (68, 'Capitã Marvel #1: Mais Alto, Mais Longe, Mais Rápido e Mais', 'Coleção Nova Marvel #68', 'Coleção Nova Marvel'),
    (69, 'Loki: Agente de Asgard #2: Não Posso Mentir', 'Coleção Nova Marvel #69', 'Coleção Nova Marvel'),
    (70, 'Deadpool #6: Pecado Original', 'Coleção Nova Marvel #70', 'Coleção Nova Marvel'),
    (71, 'Espetacular Homem-Aranha #2: Primeiros Passos', 'Coleção Nova Marvel #71', 'Coleção Nova Marvel'),
    (72, 'X-Men: A Batalha do Átomo', 'Coleção Nova Marvel Deluxe #1', 'Coleção Nova Marvel Deluxe'),
    (73, 'Indestrutível Hulk: Agente da SHIELD', 'Coleção Nova Marvel Deluxe #2', 'Coleção Nova Marvel Deluxe'),
    (74, 'Infinito', 'Coleção Nova Marvel Deluxe #3', 'Coleção Nova Marvel Deluxe'),
    (75, 'Guardiões da Galáxia & X-Men: O Vórtice Negro', 'Coleção Nova Marvel Deluxe #4', 'Coleção Nova Marvel Deluxe'),
    (76, 'Pecado Original', 'Coleção Nova Marvel Deluxe #5', 'Coleção Nova Marvel Deluxe'),
    (77, 'Capitão América: Náufrago na Dimensão Z', 'Coleção Nova Marvel Deluxe #6', 'Coleção Nova Marvel Deluxe')
), ordem AS (SELECT id FROM ordens_leitura WHERE slug='colecao-nova-marvel')
INSERT INTO itens_ordem_leitura (
  ordem_leitura_id,posicao,titulo_referencia,detalhe_referencia,secao,
  status_identificacao,observacao
)
SELECT ordem.id,r.posicao,r.titulo,r.detalhe,r.secao,'PENDENTE_REVISAO',
       'Ordem editorial conforme https://www.planetagibiblog.com.br/2016/06/guia-planeta-gibi-colecao-nova-marvel.html'
FROM referencias r CROSS JOIN ordem
ON CONFLICT (ordem_leitura_id,posicao) DO UPDATE
SET titulo_referencia=EXCLUDED.titulo_referencia,
    detalhe_referencia=EXCLUDED.detalhe_referencia,
    secao=EXCLUDED.secao,
    observacao=EXCLUDED.observacao;

-- Vincula automaticamente os títulos que já existirem no catálogo Panini.
WITH candidatos AS (
  SELECT item.id AS item_id,ed.id AS edicao_id,ed.url_capa,
         row_number() OVER (PARTITION BY item.id ORDER BY ed.id) AS ordem
  FROM itens_ordem_leitura item
  JOIN ordens_leitura guia ON guia.id=item.ordem_leitura_id AND guia.slug='colecao-nova-marvel'
  JOIN edicoes ed ON hqhub_normalizar_titulo_serie(ed.titulo)=hqhub_normalizar_titulo_serie(item.titulo_referencia)
  JOIN series serie ON serie.id=ed.serie_id
  JOIN editoras editora ON editora.id=serie.editora_id AND lower(trim(editora.nome)) LIKE 'panini%'
)
UPDATE itens_ordem_leitura item
SET edicao_id=candidato.edicao_id,
    url_capa_referencia=coalesce(item.url_capa_referencia,candidato.url_capa),
    status_identificacao='CONFIRMADO'
FROM candidatos candidato
WHERE item.id=candidato.item_id AND candidato.ordem=1;
