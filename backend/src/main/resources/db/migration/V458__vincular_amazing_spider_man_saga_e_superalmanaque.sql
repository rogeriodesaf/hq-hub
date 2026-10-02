-- Correspondências editoriais conferidas contra Panini e Guia dos Quadrinhos.
-- Auditoria número a número: docs/importacao/amazing-spider-man-vinculos-2026-10-02.json
-- Somente edições da Saga (Panini, volumes 1 e 2) e Superalmanaque Marvel (Abril).
-- Não altera capas. Não infere páginas/cortes nem completude de uma edição original.
CREATE TEMP TABLE asm_vinculos (
    colecao TEXT, editora TEXT, volume INTEGER, numero TEXT, original TEXT, ano INTEGER,
    titulo TEXT, titulo_original TEXT, paginas INTEGER, url TEXT
) ON COMMIT DROP;
INSERT INTO asm_vinculos VALUES
    ('Saga do Homem-Aranha, A', 'Panini', 1, '1', '206', 1980, 'Há método nessa loucura!', 'A Method in His Madness!', 17, 'https://panini.com.br/a-saga-do-homem-aranha-01'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '1', '207', 1980, 'A vingança de Mesmero!', 'Mesmero''s Revenge!', 17, 'https://panini.com.br/a-saga-do-homem-aranha-01'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '1', '208', 1980, 'Fusão!', 'Fusion!', 17, 'https://panini.com.br/a-saga-do-homem-aranha-01'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '2', '209', 1980, 'Em nome do pai!', 'To Salvage my Honor!', 17, 'https://panini.com.br/a-saga-do-homem-aranha-02'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '3', '210', 1980, 'A profecia da Madame Teia!', 'The Prophecy of Madam Web', 22, 'https://panini.com.br/a-saga-do-homem-aranha-03'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '3', '211', 1980, 'O Aranha e o flagelo dos mares!', 'The Spider and the Sea-Scourge', 22, 'https://panini.com.br/a-saga-do-homem-aranha-03'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '3', '212', 1981, 'Entra em cena: O Homem Hídrico!', 'The Coming of Hydroman!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-03'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '6', '216', 1981, 'Maratona!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-06'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '6', '217', 1981, 'Um mar de lama!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-06'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '6', '218', 1981, 'Beleza nos olhos de quem vê!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-06'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '7', '219', 1981, 'Peter Parker... criminoso!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-07'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '7', '220', 1981, 'O mistério da casa de repouso', NULL, 5, 'https://panini.com.br/a-saga-do-homem-aranha-07'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '8', '220', 1981, 'Um caixão para o Homem-Aranha!', 'A Coffin for Spider-Man!', 17, 'https://panini.com.br/a-saga-do-homem-aranha-08'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '8', '221', 1981, 'O sofrimento do Pinky Solitário!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-08'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '9', '222', 1981, 'Mais rápido que os olhos!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-09'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '9', '223', 1981, 'A noite dos macacos!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-09'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '10', '224', 1982, 'Que estas velhas asas voltem a voar!', 'Let Fly These Aged Wings!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-10'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '10', '225', 1982, 'Somos todos idiotas!', NULL, 21, 'https://panini.com.br/a-saga-do-homem-aranha-10'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '11', '226', 1982, 'Duelo de máscaras', 'But the Cat Came Back...', 22, 'https://panini.com.br/a-saga-do-homem-aranha-11'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '11', '227', 1982, 'Beco sem saída', 'Goin'' Straight!', NULL, 'https://panini.com.br/a-saga-do-homem-aranha-11'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '11', '228', 1982, 'As aranhas assassinas', 'Murder by Spider', NULL, 'https://panini.com.br/a-saga-do-homem-aranha-11'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '11', '229', 1982, 'Ninguém pode deter o Fanático!', 'Nothing Can Stop the Juggernaut!', NULL, 'https://panini.com.br/a-saga-do-homem-aranha-11'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '12', '230', 1982, '...Um inimigo invencível!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-12'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '13', '231', 1982, 'Com a boca na botija', NULL, 23, 'https://panini.com.br/a-saga-do-homem-aranha-13'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '13', '232', 1982, 'O médico e o monstro', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-13'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '14', '233', 1982, 'Onde está o Nariz Norton, @$%#?', 'Where the @¢%# Is Nose Norton?', 22, 'https://panini.com.br/a-saga-do-homem-aranha-14'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '14', '234', 1982, 'É hora do Fogo Fátuo ter sua vingança!', 'Now Shall Will-O''-The-Wisp Have His Revenge!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-14'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '15', '235', 1982, 'Cuidado, lá vem um monstro', 'Look Out, There''s a Monster Coming!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-15'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '15', '236', 1983, 'Sentença de morte!', 'Death Knell!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-15'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '17', '237', 1983, 'Alto e poderoso!', 'Shadow of Evils Past', 22, 'https://panini.com.br/a-saga-do-homem-aranha-17'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '17', '238', 1983, 'Sombras do passado!', 'Shadow of Evils Past', 24, 'https://panini.com.br/a-saga-do-homem-aranha-17'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '17', '239', 1983, 'O ataque do Duende Macabro!', 'Now Strikes the Hobgoblin!', 24, 'https://panini.com.br/a-saga-do-homem-aranha-17'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '18', '240', 1983, 'Asas da vingança!', 'Wings of Vengeance!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-18'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '18', '241', 1983, 'No início...', 'In the Beginning...', 22, 'https://panini.com.br/a-saga-do-homem-aranha-18'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '19', '242', 1983, 'Confrontos!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-19'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '19', '243', 1983, 'Escolhas!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-19'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '1', '252', 1984, 'De volta ao lar!', 'Homecoming!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-1-25'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '1', '253', 1984, 'Traído por mim!', 'By Myself Betrayed!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-1-25'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '1', '254', 1984, 'Com grandes poderes...', 'With Great Power...', 22, 'https://panini.com.br/a-saga-do-homem-aranha-1-25'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '10', '268', 1985, 'O ouro é meu!', NULL, 23, 'https://panini.com.br/a-saga-do-homem-aranha-10-34'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '10', '269', 1985, 'O poder do fogo', 'Burn, Spider, Burn!', 23, 'https://panini.com.br/a-saga-do-homem-aranha-10-34'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '10', '270', 1985, 'O herói e o holocausto!', 'The Hero and the Holocaust', 23, 'https://panini.com.br/a-saga-do-homem-aranha-10-34'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '11', '271', 1985, 'O que aconteceu com o Esmagador Hogan?', 'Whatever Happened to Crusher Hogan?', 22, 'https://panini.com.br/a-saga-do-homem-aranha-11-35'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '11', '272', 1986, 'Abram alas pro Esquivo!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-11-35'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '14', '273', 1986, 'Desafiando o Beyonder!', 'To Challenge The Beyonder!', 23, 'https://panini.com.br/a-saga-do-homem-aranha-14-38'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '14', '274', 1986, 'Eis que surge o campeão!', 'Lo, There Shall Come a Champion!', 28, 'https://panini.com.br/a-saga-do-homem-aranha-14-38'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '14', '275', 1986, 'A escolha e o desafio', 'The Choice and the Challenger!', 41, 'https://panini.com.br/a-saga-do-homem-aranha-14-38'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '15', '276', 1986, 'Desmascarado', 'Unmasked!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-15-39'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '15', '277', 1986, 'As regras do jogo', 'Rules of the game!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-15-39'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '2', '255', 1984, 'Até os fantasmas temem a noite!', 'Even a Ghost Can Fear the Night!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-2-26'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '3', '256', 1984, 'Apresentando... o Puma!', 'Introducing... Puma!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-3-27'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '4', '257', 1984, 'Nas garras do... Puma!', 'Beware the Claws of Puma!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-4-28'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '4', '258', 1984, 'O segredo sinistro do novo traje do Homem-Aranha!', 'The Sinister Secret of Spider-Man''s New Costume!', 23, 'https://panini.com.br/a-saga-do-homem-aranha-4-28'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '4', '259', 1984, 'Relembrando todos os meus passados!', NULL, 24, 'https://panini.com.br/a-saga-do-homem-aranha-4-28'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '6', '260', 1985, 'O desafio do Duende Macabro', 'The Challenge of Hobgoblin!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-6-30'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '6', '261', 1985, 'Os pecados do meu pai', 'The Sins of my Father!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-6-30'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '6', '262', 1985, 'Segredo profissional', 'Trade Secret', 22, 'https://panini.com.br/a-saga-do-homem-aranha-6-30'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '7', '263', 1985, 'O espetacular Menino-Aranha!', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-7-31'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '8', '264', 1985, 'Burrice e burocracia', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-8-32'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '8', '265', 1985, 'Caça ao Raposa', NULL, 22, 'https://panini.com.br/a-saga-do-homem-aranha-8-32'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '9', '266', 1985, 'Pulinhos de amor ou... engolindo sapos!', NULL, 23, 'https://panini.com.br/a-saga-do-homem-aranha-9-33'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '9', '267', 1985, 'A aranha suburbana!', 'The Commuter Cometh!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-9-33'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '20', '244', 1983, 'Provações!', 'Ordeals!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-20'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '20', '245', 1983, 'Jogada do sacrifício!', 'Sacrifice Play!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-20'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '21', '246', 1983, 'Os Sonhadores', 'The Daydreamers!', 22, 'https://panini.com.br/a-saga-do-homem-aranha-21'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '21', '247', 1983, 'Interrupções', 'Interruptions', 22, 'https://panini.com.br/a-saga-do-homem-aranha-21'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '21', '248', 1984, 'Ele chega como uma bola de demolição!', NULL, 11, 'https://panini.com.br/a-saga-do-homem-aranha-21'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '21', '248', 1984, 'O menino que colecionava Homem-Aranha!', 'The Kid Who Collects Spider-Man!', 11, 'https://panini.com.br/a-saga-do-homem-aranha-21'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '23', '249', 1984, 'Segredos', 'Secrets!', NULL, 'https://panini.com.br/a-saga-do-homem-aranha-23'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '23', '250', 1984, 'Confissões!', 'Confessions!', NULL, 'https://panini.com.br/a-saga-do-homem-aranha-23'),
    ('Saga do Homem-Aranha, A', 'Panini', 1, '23', '251', 1984, 'Finais!', 'Endings!', NULL, 'https://panini.com.br/a-saga-do-homem-aranha-23'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '18', '280', 1986, 'O Sindicato Sinistro!', 'The Sinister Syndicate!', NULL, 'https://www.guiadosquadrinhos.com/edicao/saga-do-homem-aranha-a-2-serie-n-18/sa011202/191175'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '18', '281', 1986, 'Quando guerreiros colidem!', 'When Warriors Clash...!', NULL, 'https://www.guiadosquadrinhos.com/edicao/saga-do-homem-aranha-a-2-serie-n-18/sa011202/191175'),
    ('Saga do Homem-Aranha, A', 'Panini', 2, '18', '282', 1986, 'A fúria do X-Factor', NULL, NULL, 'https://www.guiadosquadrinhos.com/edicao/saga-do-homem-aranha-a-2-serie-n-18/sa011202/191175'),
    ('Superalmanaque Marvel', 'Abril', 1, '2', '275', 1986, 'Decisões e desafios', 'The Choice and the Challenger!', NULL, 'https://www.guiadosquadrinhos.com/edicao/superalmanaque-marvel-n-2/slm0301/7870'),
    ('Superalmanaque Marvel', 'Abril', 1, '2', '276', 1986, 'Desmascarado', 'Unmasked!', NULL, 'https://www.guiadosquadrinhos.com/edicao/superalmanaque-marvel-n-2/slm0301/7870'),
    ('Superalmanaque Marvel', 'Abril', 1, '2', '279', 1986, 'Sable, a selvagem', 'Savage Is the Sable!', NULL, 'https://www.guiadosquadrinhos.com/edicao/superalmanaque-marvel-n-2/slm0301/7870'),
    ('Superalmanaque Marvel', 'Abril', 1, '2', '280', 1986, 'O Sindicato Sinistro', 'The Sinister Syndicate!', NULL, 'https://www.guiadosquadrinhos.com/edicao/superalmanaque-marvel-n-2/slm0301/7870'),
    ('Superalmanaque Marvel', 'Abril', 1, '2', '281', 1986, 'O Sindicato Sinistro', 'When Warriors Clash...!', NULL, 'https://www.guiadosquadrinhos.com/edicao/superalmanaque-marvel-n-2/slm0301/7870');

DO $$
DECLARE
    dado RECORD;
    original_serie BIGINT;
    original_id BIGINT;
    brasileira_id BIGINT;
    historia_id_alvo BIGINT;
    editora_id_alvo BIGINT;
    serie_id_alvo BIGINT;
    chave_historia TEXT;
    total INTEGER := 0;
    ausentes INTEGER := 0;
    candidatos INTEGER;
BEGIN
    -- Reaproveita a identidade original verificada; nunca usa apenas personagem/número.
    SELECT s.id INTO original_serie FROM series s JOIN editoras e ON e.id = s.editora_id
    JOIN correspondencias_series_externas c
      ON c.fonte_externa = 'COMICVINE' AND c.id_volume = '2127'
     AND hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(c.titulo_catalogo)
     AND hqhub_normalizar_titulo_serie(e.nome) = hqhub_normalizar_titulo_serie(c.editora)
     AND s.ano_inicio = c.ano_inicio
    WHERE s.tipo_serie = 'ESTRANGEIRA'
    ORDER BY (SELECT count(*) FROM publicacoes_historias p JOIN edicoes o ON o.id = p.edicao_original_id WHERE o.serie_id = s.id) DESC, s.id
    LIMIT 1;
    IF original_serie IS NULL THEN
        INSERT INTO editoras (nome, pais_origem, data_criacao, data_atualizacao)
        VALUES ('Marvel Comics', 'Estados Unidos da America', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (nome) DO NOTHING;
        SELECT id INTO editora_id_alvo FROM editoras
        WHERE hqhub_normalizar_titulo_serie(nome) = hqhub_normalizar_titulo_serie('Marvel Comics') ORDER BY id LIMIT 1;
        INSERT INTO series (titulo, ano_inicio, volume, editora_id, tipo_serie, fonte_externa, id_externo, url_origem, data_criacao, data_atualizacao)
        VALUES ('Amazing Spider-Man, The (1963)', 1963, NULL, editora_id_alvo, 'ESTRANGEIRA',
                'GUIA_DOS_QUADRINHOS', 'amazing-spider-man-1963-vinculos', 'https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/',
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id INTO original_serie;
    END IF;

    FOR dado IN SELECT * FROM asm_vinculos LOOP
        SELECT count(*), min(e.id) INTO candidatos, brasileira_id
        FROM edicoes e JOIN series s ON s.id = e.serie_id JOIN editoras editora ON editora.id = s.editora_id
        WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(dado.colecao)
          AND coalesce(s.volume, 1) = dado.volume AND s.tipo_serie = 'BRASILEIRA'
          AND (hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie(dado.editora)
               OR (dado.editora = 'Panini' AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')))
          AND hqhub_normalizar_identidade(e.numero) = hqhub_normalizar_identidade(dado.numero);
        IF candidatos > 1 THEN
            RAISE EXCEPTION 'Identidade brasileira ambigua: %, volume %, numero %', dado.colecao, dado.volume, dado.numero;
        END IF;

        -- As duas edições da referência #280 têm identidade e datas verificadas.
        IF brasileira_id IS NULL AND ((dado.colecao = 'Saga do Homem-Aranha, A' AND dado.volume = 2 AND dado.numero = '18')
                                     OR dado.colecao = 'Superalmanaque Marvel') THEN
            SELECT count(*), min(s.id) INTO candidatos, serie_id_alvo FROM series s JOIN editoras e ON e.id = s.editora_id
            WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(dado.colecao)
              AND coalesce(s.volume, 1) = dado.volume AND s.tipo_serie = 'BRASILEIRA'
              AND (hqhub_normalizar_titulo_serie(e.nome) = hqhub_normalizar_titulo_serie(dado.editora)
                   OR (dado.editora = 'Panini' AND hqhub_normalizar_titulo_serie(e.nome) = hqhub_normalizar_titulo_serie('Panini Comics')));
            IF candidatos > 1 THEN RAISE EXCEPTION 'Serie brasileira ambigua: % volume %', dado.colecao, dado.volume; END IF;
            IF serie_id_alvo IS NULL THEN
                INSERT INTO editoras (nome, pais_origem, data_criacao, data_atualizacao)
                VALUES (dado.editora, 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) ON CONFLICT (nome) DO NOTHING;
                SELECT id INTO editora_id_alvo FROM editoras WHERE nome = dado.editora;
                INSERT INTO series (titulo, volume, editora_id, tipo_serie, data_criacao, data_atualizacao)
                VALUES (dado.colecao, dado.volume, editora_id_alvo, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                RETURNING id INTO serie_id_alvo;
            END IF;
            INSERT INTO edicoes (serie_id, numero, titulo, data_publicacao, fonte_externa, id_externo, url_origem, data_criacao, data_atualizacao)
            VALUES (serie_id_alvo, dado.numero, dado.colecao || ' #' || dado.numero,
                    CASE WHEN dado.editora = 'Abril' THEN DATE '1990-12-01' ELSE DATE '2026-09-01' END,
                    'GUIA_DOS_QUADRINHOS', 'asm-vinculos|' || dado.editora || '|' || dado.volume || '|' || dado.numero, dado.url,
                    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id INTO brasileira_id;
        END IF;
        IF brasileira_id IS NULL THEN
            ausentes := ausentes + 1;
            CONTINUE; -- Não cria uma edição brasileira sem dados editoriais conferidos.
        END IF;
        IF (dado.colecao = 'Saga do Homem-Aranha, A' AND dado.volume = 2 AND dado.numero = '18')
           OR dado.colecao = 'Superalmanaque Marvel' THEN
            UPDATE edicoes SET data_publicacao = coalesce(data_publicacao,
                CASE WHEN dado.editora = 'Abril' THEN DATE '1990-12-01' ELSE DATE '2026-09-01' END)
            WHERE id = brasileira_id;
        END IF;

        SELECT o.id INTO original_id FROM edicoes o JOIN series s ON s.id = o.serie_id
        JOIN editoras e ON e.id = s.editora_id JOIN correspondencias_series_externas c
          ON c.fonte_externa = 'COMICVINE' AND c.id_volume = '2127'
         AND hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(c.titulo_catalogo)
         AND hqhub_normalizar_titulo_serie(e.nome) = hqhub_normalizar_titulo_serie(c.editora)
         AND s.ano_inicio = c.ano_inicio
        WHERE s.tipo_serie = 'ESTRANGEIRA' AND hqhub_normalizar_identidade(o.numero) = hqhub_normalizar_identidade(dado.original)
        ORDER BY (SELECT count(*) FROM publicacoes_historias p WHERE p.edicao_original_id = o.id) DESC, o.id LIMIT 1;
        IF original_id IS NULL THEN
            INSERT INTO edicoes (serie_id, numero, titulo, fonte_externa, id_externo, data_publicacao, data_criacao, data_atualizacao)
            VALUES (original_serie, dado.original, 'Amazing Spider-Man (1963) #' || dado.original,
                    'GUIA_DOS_QUADRINHOS', 'amazing-spider-man-1963|' || dado.original,
                    make_date(dado.ano, 1, 1), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            RETURNING id INTO original_id;
        END IF;

        chave_historia := 'asm1963|' || dado.original || '|' || md5(coalesce(dado.titulo_original, dado.titulo));
        SELECT h.id INTO historia_id_alvo FROM historias h
        WHERE h.id_externo = chave_historia
           OR ((EXISTS (SELECT 1 FROM publicacoes_historias p WHERE p.historia_id = h.id AND p.edicao_original_id = original_id)
                OR (EXISTS (SELECT 1 FROM conteudos_edicoes c WHERE c.historia_id = h.id AND c.edicao_id = brasileira_id)
                    AND NOT EXISTS (SELECT 1 FROM publicacoes_historias p JOIN edicoes o ON o.id = p.edicao_original_id
                                    WHERE p.historia_id = h.id AND hqhub_normalizar_identidade(o.numero) <> hqhub_normalizar_identidade(dado.original))))
               AND ((dado.titulo_original IS NOT NULL AND hqhub_normalizar_identidade(h.titulo_original) = hqhub_normalizar_identidade(dado.titulo_original))
                    OR ((dado.titulo_original IS NULL OR h.titulo_original IS NULL)
                        AND hqhub_normalizar_identidade(coalesce(h.titulo_portugues, h.titulo)) = hqhub_normalizar_identidade(dado.titulo))))
        ORDER BY h.id LIMIT 1;
        IF historia_id_alvo IS NULL THEN
            INSERT INTO historias (titulo, titulo_portugues, titulo_original, quantidade_paginas, tipo, fonte_externa, id_externo, url_origem, data_criacao, data_atualizacao)
            VALUES (dado.titulo, dado.titulo, dado.titulo_original, dado.paginas, 'HISTORIA', 'GUIA_DOS_QUADRINHOS',
                    chave_historia, dado.url, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id INTO historia_id_alvo;
        END IF;
        INSERT INTO publicacoes_historias (historia_id, edicao_original_id, edicao_publicada_id, status, tipo_publicacao_historia,
                titulo_usado, paginas_publicadas, fonte_externa, url_origem, fonte_informacao, url_fonte_informacao,
                status_validacao, data_criacao, data_atualizacao)
        VALUES (historia_id_alvo, original_id, brasileira_id, 'DESCONHECIDA', 'PUBLICACAO_BRASILEIRA',
                dado.titulo, dado.paginas, 'GUIA_DOS_QUADRINHOS', dado.url, 'Conferencia editorial Panini/Guia', dado.url,
                'APROVADA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (historia_id, edicao_publicada_id) DO UPDATE SET
            edicao_original_id = EXCLUDED.edicao_original_id,
            url_fonte_informacao = EXCLUDED.url_fonte_informacao,
            data_atualizacao = CURRENT_TIMESTAMP;
        IF NOT EXISTS (SELECT 1 FROM conteudos_edicoes WHERE edicao_id = brasileira_id AND historia_id = historia_id_alvo) THEN
            INSERT INTO conteudos_edicoes (edicao_id, historia_id, ordem, titulo_usado, quantidade_paginas, tipo, data_criacao, data_atualizacao)
            SELECT brasileira_id, historia_id_alvo, coalesce(max(ordem), 0) + 1, dado.titulo, dado.paginas, 'HISTORIA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            FROM conteudos_edicoes WHERE edicao_id = brasileira_id;
        END IF;
        total := total + 1;
    END LOOP;
    RAISE NOTICE 'ASM1963: % correspondencias processadas, % sem edicao brasileira cadastrada.', total, ausentes;
END $$;
