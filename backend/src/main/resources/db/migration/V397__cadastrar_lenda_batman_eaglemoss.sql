-- Cadastra a coleção brasileira completa DC Comics - A Lenda do Batman,
-- encerrada pela Eaglemoss no volume 79, e associa uma capa brasileira a cada edição.
-- Fonte de conferência e das imagens: guia da coleção publicado pelo Spider145.
-- A migração é idempotente e também completa uma série/edição já existente.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES (
    'Eaglemoss',
    'Editora de coleções e encadernados em capa dura.',
    'Reino Unido',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'DC Comics - A Lenda do Batman',
    'Coleção brasileira em capa dura dedicada às principais histórias do Batman, publicada em 79 volumes.',
    2018,
    2022,
    1,
    'GUIA_DOS_QUADRINHOS',
    'dc12511',
    'https://www.guiadosquadrinhos.com/edicao/dc-comics-a-lenda-do-batman-n-42/dc12511/157579',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Eaglemoss')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      WHERE existente.editora_id = editora.id
        AND coalesce(existente.volume, 0) = 1
        AND hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
  );

UPDATE series serie
SET descricao = 'Coleção brasileira em capa dura dedicada às principais histórias do Batman, publicada em 79 volumes.',
    ano_inicio = 2018,
    ano_fim = 2022,
    url_origem = 'https://www.guiadosquadrinhos.com/edicao/dc-comics-a-lenda-do-batman-n-42/dc12511/157579',
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE serie.editora_id = editora.id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Eaglemoss')
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
  AND coalesce(serie.volume, 1) = 1;

CREATE TEMP TABLE hqhub_lenda_batman_capas ON COMMIT DROP AS
SELECT * FROM (VALUES
    ('1', 'Batman e Filho', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol01_batmanefilho_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('2', 'Batman: Detetive', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol02_batmandetetive_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('3', 'Portões de Gotham', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol03_portoesdegotham_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('4', 'Aurora Dourada', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol04_auroradourada_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('5', 'O Homem Que Ri / A Piada Mortal', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol05_ohomemqueri_e_apiadamortal_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('6', 'Batman Renascido', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol06_batmanrenascido_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('7', 'Corporação Batman', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol07_corporacaobatman_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('8', 'Imperador Pinguim - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol08_imperadorpinguim_parte01_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('9', 'Imperador Pinguim - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol09_imperadorpinguim_parte02_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('10', 'Faces da Morte', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol10_facesdamorte_eaglemoss_01062022.jpg', 'https://spider145hqs.com/2022/06/01/a-lenda-do-batman-volumes-1-a-10/'),
    ('11', 'Por Trás da Máscara - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol11_portrasdamascara_parte1_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('12', 'Por Trás da Máscara - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol12_portrasdamascara_parte2_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('13', 'O Coração do Silêncio', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol13_ocoracaodosilencio_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('14', 'A Ressurreição de Ra''s Al Ghul - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol14_aressurreicaoderasalghul_parte1_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('15', 'A Ressurreição de Ra''s Al Ghul - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol15_aressurreicaoderasalghul_parte2_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('16', 'Ano Um', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol16_anoum_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('17', 'Nascido Para Matar', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol17_nascidoparamatar_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('18', 'Vitória Sombria - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol18_vitoriasombria_parte1_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('19', 'Vitória Sombria - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol19_vitoriasombria_parte2_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('20', 'A Queda do Morcego - Prólogo', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol20_aquedadomorcego_prologo_eaglemoss_06062022.jpg', 'https://spider145hqs.com/2022/06/06/a-lenda-do-batman-volumes-11-a-20/'),
    ('21', 'A Queda do Morcego - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol21_aquedadomorcego_parte1_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('22', 'A Queda do Morcego - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol22_aquedadomorcego_parte2_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('23', 'A Queda do Morcego - Parte 3', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol23_aquedadomorcego_parte3_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('24', 'Terrores Noturnos', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol24_terroresnoturnos_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('25', 'O Livro dos Casos Secretos', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol25_olivrodoscasossecretos_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('26', 'Batman e os Homens-Monstros', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol26_batmaneoshomensmonstro_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('27', 'A Casa do Silêncio', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol27_acasadosilencio_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('28', 'A Cruzada do Morcego - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol28_acruzadadomorcego_parte1_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('29', 'A Cruzada do Morcego - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol29_acruzadadomorcego_parte2_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('30', 'A Cruzada do Morcego - Parte 3', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol30_acruzadadomorcego_parte3_eaglemoss_09062022.jpg', 'https://spider145hqs.com/2022/06/09/a-lenda-do-batman-volumes-21-a-30/'),
    ('31', 'O Mais Procurado de Gotham', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol31_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('32', 'Neal Adams - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol32_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('33', 'Ódio', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol33_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('34', 'Ciclo de Violência', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol34_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('35', 'O Crepúsculo do Morcego - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol35_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('36', 'O Crepúsculo do Morcego - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol36_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('37', 'O Tempo e o Batman', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol37_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('38', 'O Retorno de Bruce Wayne', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol38_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('39', 'Corporação Batman - Volume 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol39_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('40', 'Morte em Família', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol40_eaglemoss_13062022.jpg', 'https://spider145hqs.com/2022/06/13/a-lenda-do-batman-volumes-31-a-40/'),
    ('41', 'Mulher-Gato: Cidade Eterna', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol41_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('42', 'Neal Adams - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol42_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('43', 'Ruas de Gotham - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol43_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('44', 'O Filho Pródigo - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol44_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('45', 'O Filho Pródigo - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol45_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('46', 'O Filho Pródigo - Parte 3', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol46_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('47', 'Dia das Bruxas', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol47_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('48', 'O Cavaleiro das Trevas', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol48_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('49', 'Cataclismo - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol49_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('50', 'Cataclismo - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol50_eaglemoss_16062022.jpg', 'https://spider145hqs.com/2022/06/16/a-lenda-do-batman-volumes-41-a-50/'),
    ('51', 'Cataclismo - Parte 3', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol51_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('52', 'Acossado', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol52_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('53', 'Terror', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol53_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('54', 'Louco', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol54_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('55', 'Asa Noturna: Ano Um', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol55_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('56', 'Um Lugar Para Morrer', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol56_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('57', 'A Morte e a Cidade', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol57_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('58', 'Terra de Ninguém - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol58_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('59', 'Terra de Ninguém - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol59_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('60', 'Terra de Ninguém - Parte 3', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol60_eaglemoss_22062022.jpg', 'https://spider145hqs.com/2022/06/22/a-lenda-do-batman-volumes-51-a-60/'),
    ('61', 'Batman e o Monge Louco', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol61_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('62', 'Barro', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol62_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('63', 'Cara a Cara', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol63_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('64', 'Cavaleiro das Trevas em Metrópolis', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol64_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('65', 'Espelho Sombrio - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol65_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('66', 'Espelho Sombrio - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol66_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('67', 'Detetive Sombrio', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol67_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('68', 'Evolução - Parte 1', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol68_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('69', 'Evolução - Parte 2', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol69_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('70', 'Asa Noturna: Blüdhaven', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol70_eaglemoss_24062022.jpg', 'https://spider145hqs.com/2022/06/24/a-lenda-do-batman-volumes-61-a-70/'),
    ('71', 'Neal Adams - Parte 3', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol71_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('72', 'Ponto de Vista', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol72_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('73', 'Policial Ferido', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol73_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('74', 'Guarda-Costas', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol74_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('75', 'Jogos de Guerra - Ato Um: Ignição', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol75_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('76', 'Jogos de Guerra - Ato Dois: Contracorrente', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol76_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('77', 'Jogos de Guerra - Ato Três: A Última Batalha', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol77_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('78', 'A Luva Negra', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol78_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/'),
    ('79', 'Descanse em Paz', 'https://spider145hqs.com/wp-content/uploads/2022/06/alendadobatman_vol79_eaglemoss_27062022.jpg', 'https://spider145hqs.com/2022/06/27/a-lenda-do-batman-volumes-71-a-79/')
) AS dados(numero, nome_volume, url_capa, url_origem);

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
      AND hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Eaglemoss')
      AND coalesce(serie.volume, 1) = 1
), edicoes_alvo AS (
    SELECT
        edicao.id,
        dado.nome_volume,
        dado.url_capa,
        dado.url_origem
    FROM serie_alvo serie
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    JOIN hqhub_lenda_batman_capas dado
      ON substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer = dado.numero::integer
    WHERE substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = alvo.url_capa,
    nome_volume = coalesce(nullif(trim(edicao.nome_volume), ''), alvo.nome_volume),
    url_origem = coalesce(nullif(trim(edicao.url_origem), ''), alvo.url_origem),
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
WHERE edicao.id = alvo.id;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('DC Comics - A Lenda do Batman')
      AND hqhub_normalizar_titulo_serie(editora.nome) =
          hqhub_normalizar_titulo_serie('Eaglemoss')
      AND coalesce(serie.volume, 1) = 1
)
INSERT INTO edicoes (
    numero, titulo, nome_volume, url_capa, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    dado.numero,
    'DC Comics - A Lenda do Batman #' || dado.numero || ': ' || dado.nome_volume,
    dado.nome_volume,
    dado.url_capa,
    'SPIDER145',
    'a-lenda-do-batman-' || lpad(dado.numero, 2, '0'),
    dado.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
CROSS JOIN hqhub_lenda_batman_capas dado
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes existente
    WHERE existente.serie_id = serie.id
      AND substring(trim(existente.numero) from '([0-9]+)\s*$') IS NOT NULL
      AND substring(trim(existente.numero) from '([0-9]+)\s*$')::integer = dado.numero::integer
)
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    nome_volume = EXCLUDED.nome_volume,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
