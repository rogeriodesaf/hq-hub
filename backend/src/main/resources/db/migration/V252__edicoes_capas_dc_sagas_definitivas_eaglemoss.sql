-- Cadastra os 43 volumes brasileiros de DC Comics - Colecao de Graphic Novels: Sagas Definitivas.
-- Capas obtidas em acervos de lojistas brasileiros; nenhuma imagem vem do Guia dos Quadrinhos.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Eaglemoss', 'Editora de colecoes e graphic novels em capa dura.', 'Reino Unido', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'DC Comics - Coleção de Graphic Novels: Sagas Definitivas',
    'Coleção brasileira da Eaglemoss em 43 volumes, publicada a partir de junho de 2018.',
    1,
    'EAGLEMOSS',
    'dc-comics-graphic-novels-sagas-definitivas-eaglemoss-volume-1',
    'https://www.rika.com.br/dc-comics---colecao-de-graphic-novels---sagas-definitivas--01---crise-nas-infinitas-terras-15006742/p',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Eaglemoss')
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, subtitulo, url_capa) AS (VALUES
    ('1', 'Crise nas Infinitas Terras', 'https://rika.vteximg.com.br/arquivos/ids/321084/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-01.jpg?v=636909592005770000'),
    ('2', 'Crise Infinita', 'https://rika.vteximg.com.br/arquivos/ids/443025/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-02-crise-infinita.jpg?v=638214856908430000'),
    ('3', 'Crise Final', 'https://www.comix.com.br/media/catalog/product/cache/368852526d07b47f9ba19ccfaea17e2a/c/r/crisefinal123456.jpg'),
    ('4', 'Crise de Identidade', 'https://rika.vteximg.com.br/arquivos/ids/321087/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-04.jpg?v=636909592038200000'),
    ('5', 'Universo DC - Legados', 'https://rika.vteximg.com.br/arquivos/ids/321088/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-05.jpg?v=636909592049470000'),
    ('6', 'Um Milhão - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/321089/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-06.jpg?v=636909592063730000'),
    ('7', 'Um Milhão - Parte Dois', 'https://rika.vteximg.com.br/arquivos/ids/321090/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-07.jpg?v=636909592073370000'),
    ('8', 'SJA - Reino do Amanhã - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/321091/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-08.jpg?v=636909592083070000'),
    ('9', 'SJA - Reino do Amanhã - Parte Dois', 'https://rika.vteximg.com.br/arquivos/ids/443027/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-09-sja-reino-do-amanha-parte-2.jpg?v=638214856934230000'),
    ('10', 'Solo - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/321093/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-10.jpg?v=636909592103600000'),
    ('11', 'Solo - Parte Dois', 'https://rika.vteximg.com.br/arquivos/ids/321094/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-11.jpg?v=636909592116670000'),
    ('12', 'Xeque-Mate - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/443029/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-12-xeque-mate-parte-1.jpg?v=638214856959230000'),
    ('13', 'Xeque-Mate - Parte Dois', 'https://rika.vteximg.com.br/arquivos/ids/443031/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-13-xeque-mate-parte-2.jpg?v=638214856984530000'),
    ('14', 'O Reinado de Apocalypse', 'https://rika.vteximg.com.br/arquivos/ids/443212/dc-comics-colecao-de-graphic-novels-sagas-definitivas-14-superman-o-reinado-de-apocalypse.jpg?v=638214864419030000'),
    ('15', 'Mundos em Guerra - Parte Um', 'https://down-br.img.susercontent.com/file/sg-11134201-7rblm-lmdm0qqsh0l599'),
    ('16', 'Mundos em Guerra - Parte Dois', 'https://rika.vteximg.com.br/arquivos/ids/443055/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-superman-mundos-em-guerra-parte-dois.jpg?v=638214857297230000'),
    ('17', 'Convergência', 'https://acdn-us.mitiendanube.com/stores/003/791/470/products/a67860419dd760b2f8e813e2dfaef197awsaccesskeyidakiatclmsgfx4j7tu445expires1704542667signaturera1uetschbzemnrfoykyrimhek83d-8f0205419761dec0f817019506714724-1024-1024.webp'),
    ('18', 'Sereias de Gotham - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/443213/dc-comics-colecao-de-graphic-novels-sagas-definitivas-18-sereias-de-gotham-parte-1.jpg?v=638214865050800000'),
    ('19', 'Sereias de Gotham - Parte Dois', 'https://down-br.img.susercontent.com/file/sg-11134201-7qvdh-lia67tp8pudpc3'),
    ('20', 'Guerra dos Deuses', 'https://img.assinaja.com/assets/tZ/003/img/170009_900x1120.png'),
    ('21', 'O Dia Mais Claro - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/345884/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-21-O-Dia-Mais-Claro-Parte-Um.jpg?v=637235314086400000'),
    ('22', 'O Dia Mais Claro - Parte Dois', 'https://cdn.awsli.com.br/2500x2500/1181/1181256/produto/17421390229083b5ab8.jpg'),
    ('23', 'Invasão', 'https://acdn-us.mitiendanube.com/stores/003/791/470/products/e0da87db7d03b4c5d47267723ab9efa4awsaccesskeyidakiatclmsgfx4j7tu445expires1704542459signatureu22fjodiy5otkgwomdkbr8ffnnms3d-fa9ab6fce1237e208417019504640165-1024-1024.webp'),
    ('24', 'Batman - Segundas Chances', 'https://rika.vteximg.com.br/arquivos/ids/443105/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-24-batman-segundas-chances.jpg?v=638214858042400000'),
    ('25', 'DPGC - Parte Um', 'https://rika.vteximg.com.br/arquivos/ids/398692/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-25-DPGC-Parte-Um.jpg?v=637558374524700000'),
    ('26', 'DPGC - Parte Dois', 'https://rika.vteximg.com.br/arquivos/ids/398693/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-26-DPGC-Parte-Dois.jpg?v=637558374530170000'),
    ('27', 'DPGC - Parte Três', 'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/p/a/parte3_3_1.jpg'),
    ('28', 'DPGC - Parte Quatro', 'https://down-br.img.susercontent.com/file/br-11134207-7qukw-lfho9mkk8et929'),
    ('29', 'Superman - Terra Um', 'https://rika.vteximg.com.br/arquivos/ids/406906/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-29-Superman-Terra-Um.jpg?v=637598298779100000'),
    ('30', 'Batman - Gotham Depois da Meia Noite', 'https://rika.vteximg.com.br/arquivos/ids/406907/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-30-Batman-Gotham-Depois-da-Meia-Noite.jpg?v=637598298789230000'),
    ('31', 'Os Maiores Heróis do Mundo', 'https://rika.vteximg.com.br/arquivos/ids/443121/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-31-os-maiores-super-herois-do-mundo.jpg?v=638214858260330000'),
    ('32', 'Superman e Batman - A Saga dos Super Filhos', 'https://down-br.img.susercontent.com/file/sg-11134201-7qve1-lk885xwafbsb3e'),
    ('33', 'Superman - O Reino dos Supermen', 'https://rika.vteximg.com.br/arquivos/ids/443123/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-33-superman-o-reino-dos-supermen.jpg?v=638214858285830000'),
    ('34', 'Superman - O Retorno de Superman', 'https://rika.vteximg.com.br/arquivos/ids/443214/dc-comics-colecao-de-graphic-novels-sagas-definitivas-34-superman-o-retorno-do-superman.jpg?v=638214865879430000'),
    ('35', 'Superman - A Revanche do Apocalypse', 'https://rika.vteximg.com.br/arquivos/ids/443215/dc-comics-colecao-de-graphic-novels-sagas-definitivas-35-superman-a-revanche-do-apocalypse.jpg?v=638214866380700000'),
    ('36', 'Batman - Cidade do Crime', 'https://rika.vteximg.com.br/arquivos/ids/443125/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-36-batman-cidade-do-crime.jpg?v=638214858311600000'),
    ('37', 'Batman - Gordon - Lei e Ordem', 'https://down-br.img.susercontent.com/file/sg-11134201-7qvdq-lihebjlwlr7qfa'),
    ('38', 'Batman - Transferência', 'https://rika.vteximg.com.br/arquivos/ids/411154/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-38.jpg?v=637840185932430000'),
    ('39', 'Flash - Parada de Emergência e Corrida Pela Humanidade', 'https://rika.vteximg.com.br/arquivos/ids/443141/https---www.artesequencial.com.br-imagens-herois_panini-dc-comics-colecao-de-graphic-novels-sagas-definitivas-39-flash-parada-de-emergencia-e-corrida-pela-humanidade.jpg?v=638214858534630000'),
    ('40', 'Superman - Laços', 'https://down-br.img.susercontent.com/file/sg-11134201-7rasn-mawri2hv9v9s43'),
    ('41', 'Superman - As Quatro Estações e Kryptonita', 'https://rika.vteximg.com.br/arquivos/ids/411157/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-41.jpg?v=637840185968230000'),
    ('42', 'Mulher-Maravilha - A Última Heroína - Parte 1', 'https://rika.vteximg.com.br/arquivos/ids/443216/dc-comics-colecao-de-graphic-novels-sagas-definitivas-42-mulher-maravilha-a-ultima-heroina-parte-1.jpg?v=638214866823630000'),
    ('43', 'Mulher-Maravilha - A Última Heroína - Parte 2', 'https://rika.vteximg.com.br/arquivos/ids/411159/DC-Comics-Colecao-de-Graphic-Novels-Sagas-Definitivas-43.jpg?v=637840185995130000')
), serie_sagas AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'dc-comics-graphic-novels-sagas-definitivas-eaglemoss-volume-1'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Eaglemoss')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'DC Comics - Sagas Definitivas #' || capa.numero,
    capa.subtitulo,
    capa.subtitulo,
    CASE capa.numero
        WHEN '1' THEN DATE '2018-06-01'
        WHEN '2' THEN DATE '2018-08-01'
        WHEN '3' THEN DATE '2018-09-01'
        WHEN '4' THEN DATE '2018-10-01'
        WHEN '5' THEN DATE '2018-10-01'
        ELSE NULL
    END,
    capa.url_capa,
    CASE WHEN capa.url_capa LIKE '%rika.vteximg.com.br%' THEN 'RIKA' ELSE 'LOJISTAS_BRASILEIROS' END,
    'dc-sagas-definitivas-eaglemoss-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_sagas serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = coalesce(EXCLUDED.data_publicacao, edicoes.data_publicacao),
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
