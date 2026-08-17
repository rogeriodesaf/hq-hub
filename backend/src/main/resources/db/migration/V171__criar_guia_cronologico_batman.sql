-- Cria a lista-base do guia do Batman. Neste primeiro lote, as referencias
-- permanecem pendentes ate que uma edicao brasileira seja confirmada.

INSERT INTO ordens_leitura (slug, titulo, descricao, publicada, data_criacao, data_atualizacao)
VALUES (
    'batman-ordem-cronologica',
    'Batman — Ordem Cronológica 🦇',
    'Guia cronológico de leitura do Batman, acompanhando a trajetória de Bruce Wayne desde os primeiros anos de Gotham e o início de sua carreira como Batman até fases mais modernas do personagem.',
    TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
)
ON CONFLICT (slug) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    publicada = EXCLUDED.publicada,
    data_atualizacao = CURRENT_TIMESTAMP;

CREATE TEMP TABLE hqhub_batman_guia_base (
    ordem_fonte INTEGER NOT NULL,
    subordem INTEGER NOT NULL DEFAULT 1,
    titulo VARCHAR(300) NOT NULL,
    detalhe VARCHAR(300),
    secao VARCHAR(180) NOT NULL,
    observacao VARCHAR(1000)
) ON COMMIT DROP;

INSERT INTO hqhub_batman_guia_base (ordem_fonte, subordem, titulo, detalhe, secao, observacao) VALUES
    (1, 1, 'Gotham City: Ano Um', NULL, 'Primeiros anos de Gotham', NULL),
    (2, 1, 'Batman: O Cavaleiro', 'Volume 1', 'Primeiros anos de Gotham', 'Desmembrado da entrada 2 da lista original.'),
    (2, 2, 'Batman: O Cavaleiro', 'Volume 2', 'Primeiros anos de Gotham', 'Desmembrado da entrada 2 da lista original.'),
    (3, 1, 'Batman: Ano Um', NULL, 'Primeiros anos de Gotham', NULL),
    (4, 1, 'Mulher-Gato: Ano Um', NULL, 'Primeiros anos de Gotham', NULL),
    (5, 1, 'Batman: Xamã', NULL, 'Primeiros anos de Gotham', NULL),
    (6, 1, 'Batman e os Homens-Monstros', NULL, 'Primeiros anos de Gotham', NULL),
    (7, 1, 'Batman: O Monge Louco', NULL, 'Primeiros anos de Gotham', NULL),
    (8, 1, 'Batman: Acossado e Terror', NULL, 'Primeiros anos de Gotham', 'Verificar se a edição brasileira corresponde a um ou a dois encadernados.'),
    (9, 1, 'Batman: Gótico', NULL, 'Primeiros anos de Gotham', NULL),
    (10, 1, 'Batman: Padrões Sombrios', NULL, 'Primeiros anos de Gotham', NULL),
    (11, 1, 'Batman: O Homem que Ri', NULL, 'Primeiros anos de Gotham', NULL),
    (12, 1, 'Batman: Asas e Devoção', NULL, 'Primeiros anos de Gotham', NULL),
    (13, 1, 'Batman: Máscara e Outras Lendas das Trevas', NULL, 'Primeiros anos de Gotham', NULL),
    (14, 1, 'Batman: Dia das Bruxas', NULL, 'Primeiros anos de Gotham', NULL),
    (15, 1, 'Batman: O Longo Dia das Bruxas', NULL, 'Primeiros anos de Gotham', NULL),
    (16, 1, 'Mulher-Gato: Cidade Eterna', NULL, 'Primeiros anos de Gotham', NULL),
    (17, 1, 'Batman: Veneno', NULL, 'Primeiros anos de Gotham', NULL),
    (18, 1, 'Batman: Contos', NULL, 'Primeiros anos de Gotham', NULL),
    (19, 1, 'Batman: Gritos na Noite', NULL, 'Primeiros anos de Gotham', NULL),
    (20, 1, 'Batman: Vitória Sombria', NULL, 'Primeiros anos de Gotham', NULL),
    (21, 1, 'Espantalho: Ano Um', NULL, 'Primeiros anos de Gotham', NULL),
    (22, 1, 'Duas-Caras: Ano Um', NULL, 'Primeiros anos de Gotham', NULL),
    (23, 1, 'Charada: Ano Um', NULL, 'Primeiros anos de Gotham', 'Desmembrado da entrada 23 da lista original.'),
    (23, 2, 'Charada: Um Dia Ruim', NULL, 'Primeiros anos de Gotham', 'Desmembrado da entrada 23 da lista original.'),
    (24, 1, 'Batman: Neve', NULL, 'Primeiros anos de Gotham', 'Desmembrado da entrada 24 da lista original.'),
    (24, 2, 'Sr. Frio: Um Dia Ruim', NULL, 'Primeiros anos de Gotham', 'Desmembrado da entrada 24 da lista original.'),
    (25, 1, 'Cara de Barro: Um Dia Ruim', NULL, 'Primeiros anos de Gotham', NULL),
    (26, 1, 'Batman & Robin: Ano Um', NULL, 'A formação da Família Batman', 'A obra reaparece na entrada 32 da lista original; manter até revisão da intenção cronológica.'),
    (27, 1, 'Batman: Asilo do Coringa', NULL, 'A formação da Família Batman', NULL),
    (28, 1, 'Batman: Ano Dois', NULL, 'A formação da Família Batman', NULL),
    (29, 1, 'Robin: Ano Um', NULL, 'A formação da Família Batman', NULL),
    (30, 1, 'Batgirl: Ano Um', NULL, 'A formação da Família Batman', NULL),
    (31, 1, 'Robin & Batman', NULL, 'A formação da Família Batman', NULL),
    (32, 1, 'Batman & Robin: Ano Um', NULL, 'A formação da Família Batman', 'Possível duplicidade da entrada 26; mantida para preservar a lista recebida.'),
    (33, 1, 'Batman: A Trilogia do Demônio', NULL, 'A formação da Família Batman', NULL),
    (34, 1, 'Batman/Caçadora: Sede de Sangue', NULL, 'A formação da Família Batman', NULL),
    (35, 1, 'Batman: Estranhas Aparições', NULL, 'A formação da Família Batman', NULL),
    (36, 1, 'Asa Noturna: Ano Um', NULL, 'A formação da Família Batman', NULL),
    (37, 1, 'Batman: Ódio', NULL, 'A formação da Família Batman', NULL),
    (38, 1, 'Batman e os Renegados', NULL, 'A formação da Família Batman', NULL),
    (39, 1, 'Mulher-Gato: A Trilha da Mulher-Gato', NULL, 'A formação da Família Batman', NULL),
    (40, 1, 'Coringa: A Piada Mortal', NULL, 'A formação da Família Batman', NULL),
    (41, 1, 'Batman: Segundas Chances', NULL, 'A formação da Família Batman', NULL),
    (42, 1, 'Batman: O Messias', NULL, 'A formação da Família Batman', NULL),
    (43, 1, 'Batman: As Dez Noites da Besta', NULL, 'A formação da Família Batman', NULL),
    (44, 1, 'Batman: Morte em Família', NULL, 'A formação da Família Batman', NULL),
    (45, 1, 'Batman: Ego', NULL, 'A formação da Família Batman', NULL),
    (46, 1, 'Batman: Gotham Depois da Meia-Noite', NULL, 'A formação da Família Batman', NULL),
    (47, 1, 'Batman: Justiça Cega', NULL, 'A formação da Família Batman', NULL),
    (48, 1, 'Batman: As Muitas Mortes de Batman', NULL, 'A formação da Família Batman', NULL),
    (49, 1, 'Batman: Asilo Arkham', NULL, 'A formação da Família Batman', NULL),
    (50, 1, 'Batman: Um Cavaleiro das Trevas', NULL, 'A formação da Família Batman', NULL),
    (51, 1, 'Batman: Guerra ao Crime', NULL, 'A formação da Família Batman', NULL),
    (52, 1, 'Batman: Um Lugar Solitário para Morrer', NULL, 'A formação da Família Batman', NULL),
    (53, 1, 'Batman: O Último Arkham', NULL, 'A formação da Família Batman', NULL),
    (54, 1, 'Batman: A Queda do Morcego', NULL, 'Queda do Morcego e Terra de Ninguém', 'Saga com múltiplas partes; requer expansão após confirmação das edições brasileiras.'),
    (55, 1, 'Batman: A Cruzada do Morcego', NULL, 'Queda do Morcego e Terra de Ninguém', 'Saga com múltiplas partes; requer expansão após confirmação das edições brasileiras.'),
    (56, 1, 'Batman: O Crepúsculo do Morcego', NULL, 'Queda do Morcego e Terra de Ninguém', 'Saga com múltiplas partes; requer expansão após confirmação das edições brasileiras.'),
    (57, 1, 'Batman: O Filho Pródigo', NULL, 'Queda do Morcego e Terra de Ninguém', 'Desmembrado da entrada 57 da lista original.'),
    (57, 2, 'Batman: Troika', NULL, 'Queda do Morcego e Terra de Ninguém', 'Desmembrado da entrada 57 da lista original.'),
    (58, 1, 'Batman: Contágio', NULL, 'Queda do Morcego e Terra de Ninguém', NULL),
    (59, 1, 'Batman: Legado do Demônio', NULL, 'Queda do Morcego e Terra de Ninguém', NULL),
    (60, 1, 'Batman: Harleen', NULL, 'Queda do Morcego e Terra de Ninguém', NULL),
    (61, 1, 'Batman: Cataclismo', NULL, 'Queda do Morcego e Terra de Ninguém', NULL),
    (62, 1, 'Batman: Caminho para a Terra de Ninguém', NULL, 'Queda do Morcego e Terra de Ninguém', NULL),
    (63, 1, 'Batman: Terra de Ninguém', NULL, 'Queda do Morcego e Terra de Ninguém', 'Saga com múltiplos volumes; requer expansão após confirmação das edições brasileiras.'),
    (64, 1, 'Batman: Transferência', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (65, 1, 'Batman: Nova Gotham', NULL, 'Nova Gotham e Jogos de Guerra', 'Verificar quantidade de volumes da edição brasileira selecionada.'),
    (66, 1, 'Batman: Foragidos', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (67, 1, 'Batman: Cidade do Crime', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (68, 1, 'Batman: Guarda-Costas', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (69, 1, 'Batman: Policial Ferido', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (70, 1, 'Batman: Bruce Wayne — Assassino?', NULL, 'Nova Gotham e Jogos de Guerra', 'Desmembrado da entrada 70 da lista original.'),
    (70, 2, 'Batman: Bruce Wayne — Fugitivo', NULL, 'Nova Gotham e Jogos de Guerra', 'Desmembrado da entrada 70 da lista original.'),
    (71, 1, 'Batman: Consequências', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (72, 1, 'Batman: Silêncio', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (73, 1, 'Batman: Cidade Castigada', NULL, 'Nova Gotham e Jogos de Guerra', NULL),
    (74, 1, 'Batman: Jogos de Guerra', NULL, 'Nova Gotham e Jogos de Guerra', 'Saga com múltiplas partes; requer expansão após confirmação das edições brasileiras.'),
    (75, 1, 'Gotham: DPGC', NULL, 'Nova Gotham e Jogos de Guerra', 'Série com múltiplos volumes; requer definição da edição brasileira.'),
    (76, 1, 'Batman e os Renegados: A Crisálida', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (77, 1, 'Batwoman', NULL, 'Era Morrison e o retorno de Bruce Wayne', 'Título amplo; requer definição do volume ou fase brasileira.'),
    (78, 1, 'Batman: Por Trás da Máscara', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (79, 1, 'Batman: Cara a Cara', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (80, 1, 'Batman e Filho', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (81, 1, 'Batman: Nascido para Matar', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (82, 1, 'Batman: A Ressurreição de Ra''s Al Ghul', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (83, 1, 'Batman: A Luva Negra', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (84, 1, 'Batman: Descanse em Paz', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (85, 1, 'Batman: O Tempo e o Batman', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (86, 1, 'Batman: O Coração do Silêncio', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (87, 1, 'Batman: Batalha pelo Capuz', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (88, 1, 'Robin Vermelho', NULL, 'Era Morrison e o retorno de Bruce Wayne', 'Série com múltiplos volumes; requer definição da edição brasileira.'),
    (89, 1, 'Sereias de Gotham', NULL, 'Era Morrison e o retorno de Bruce Wayne', 'Série com múltiplos volumes; requer definição da edição brasileira.'),
    (90, 1, 'Batman & Robin', NULL, 'Era Morrison e o retorno de Bruce Wayne', 'Série com múltiplos volumes; requer definição da edição brasileira.'),
    (91, 1, 'Batman: As Ruas de Gotham', NULL, 'Era Morrison e o retorno de Bruce Wayne', 'Série com múltiplos volumes; requer definição da edição brasileira.'),
    (92, 1, 'Batman e Robin: Cavaleiro das Trevas vs. Cavaleiro Branco', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (93, 1, 'Batman: Os Portões de Gotham', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (94, 1, 'Batman: A Casa do Silêncio', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (95, 1, 'Batman: O Retorno de Bruce Wayne', NULL, 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (96, 1, 'Corporação Batman', 'Volume 1', 'Era Morrison e o retorno de Bruce Wayne', NULL),
    (97, 1, 'Batman: Ciclo de Violência', NULL, 'Novos 52 e fases modernas', NULL),
    (98, 1, 'Batman: A Corte das Corujas', NULL, 'Novos 52 e fases modernas', NULL),
    (99, 1, 'Batman: A Noite das Corujas', NULL, 'Novos 52 e fases modernas', NULL),
    (100, 1, 'Batman: Terrores Noturnos', NULL, 'Novos 52 e fases modernas', NULL),
    (101, 1, 'Batman: Morte da Família', NULL, 'Novos 52 e fases modernas', NULL),
    (102, 1, 'Batman: Louco', NULL, 'Novos 52 e fases modernas', NULL),
    (103, 1, 'Batman: Aurora Dourada', NULL, 'Novos 52 e fases modernas', NULL),
    (104, 1, 'Batman: Espelho Sombrio', NULL, 'Novos 52 e fases modernas', NULL),
    (105, 1, 'Batman: O Imperador Pinguim', NULL, 'Novos 52 e fases modernas', NULL),
    (106, 1, 'Corporação Batman', 'Volume 2', 'Novos 52 e fases modernas', NULL),
    (107, 1, 'Batman & Robin: Réquiem', NULL, 'Novos 52 e fases modernas', NULL),
    (108, 1, 'Batman & Robin: A Busca por Robin', NULL, 'Novos 52 e fases modernas', NULL),
    (109, 1, 'Batman — Cavaleiro das Trevas', 'Volume 1', 'Novos 52 e fases modernas', NULL),
    (110, 1, 'Batman & Mulher-Gato', 'Volume 1', 'Novos 52 e fases modernas', 'Desmembrado da entrada 110 da lista original.'),
    (110, 2, 'Batman & Mulher-Gato', 'Volume 2', 'Novos 52 e fases modernas', 'Desmembrado da entrada 110 da lista original.'),
    (110, 3, 'Batman & Mulher-Gato', 'Volume 3', 'Novos 52 e fases modernas', 'Desmembrado da entrada 110 da lista original.'),
    (111, 1, 'Mulher-Gato: Cidade Solitária', NULL, 'Novos 52 e fases modernas', NULL);

WITH itens_ordenados AS (
    SELECT row_number() OVER (ORDER BY ordem_fonte, subordem)::integer AS posicao, base.*
    FROM hqhub_batman_guia_base base
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT
    ordem.id, item.posicao, item.secao, NULL, item.titulo,
    item.detalhe, NULL, 'PENDENTE_REVISAO', item.observacao, NULL
FROM itens_ordenados item
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
ON CONFLICT (ordem_leitura_id, posicao) DO UPDATE SET
    secao = EXCLUDED.secao,
    titulo_referencia = EXCLUDED.titulo_referencia,
    detalhe_referencia = EXCLUDED.detalhe_referencia,
    observacao = EXCLUDED.observacao,
    status_identificacao = CASE
        WHEN itens_ordem_leitura.edicao_id IS NULL THEN 'PENDENTE_REVISAO'
        ELSE itens_ordem_leitura.status_identificacao
    END;
