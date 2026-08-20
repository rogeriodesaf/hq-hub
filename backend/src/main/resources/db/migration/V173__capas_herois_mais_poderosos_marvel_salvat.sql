-- Capas brasileiras da colecao Salvat, obtidas dos catalogos publicos da Rika
-- e, para o volume 13, da Guararapes HQ.
-- A migracao substitui as imagens legadas do Guia dos Quadrinhos sem alterar
-- a identidade externa ou os demais metadados editoriais das edicoes.
WITH capas(numero, url_capa) AS (VALUES
    ('1', 'https://rika.vteximg.com.br/arquivos/ids/347358/Herois-Mais-Poderosos-da-Marvel---01---Os-Vingadores.jpg'),
    ('2', 'https://rika.vteximg.com.br/arquivos/ids/347360/Herois-Mais-Poderosos-da-Marvel---02---Homem-Aranha.jpg'),
    ('3', 'https://rika.vteximg.com.br/arquivos/ids/347362/Herois-Mais-Poderosos-da-Marvel---03---Wolverine.jpg'),
    ('4', 'https://rika.vteximg.com.br/arquivos/ids/347364/Herois-Mais-Poderosos-da-Marvel---04---Hulk.jpg'),
    ('5', 'https://rika.vteximg.com.br/arquivos/ids/347366/Herois-Mais-Poderosos-da-Marvel---05---Homem-de-Ferro.jpg'),
    ('6', 'https://rika.vteximg.com.br/arquivos/ids/347368/Herois-Mais-Poderosos-da-Marvel---06---Viuva-Negra.jpg'),
    ('7', 'https://rika.vteximg.com.br/arquivos/ids/347370/Herois-Mais-Poderosos-da-Marvel---07---Capitao-America.jpg'),
    ('8', 'https://rika.vteximg.com.br/arquivos/ids/347371/Herois-Mais-Poderosos-da-Marvel---08---Tocha-Humana.jpg'),
    ('9', 'https://rika.vteximg.com.br/arquivos/ids/347373/Herois-Mais-Poderosos-da-Marvel---09---Gaviao-Arqueiro.jpg'),
    ('10', 'https://rika.vteximg.com.br/arquivos/ids/347375/Herois-Mais-Poderosos-da-Marvel---10---X-Men.jpg'),
    ('11', 'https://rika.vteximg.com.br/arquivos/ids/347377/Herois-Mais-Poderosos-da-Marvel---11---Luke-Cage.jpg'),
    ('12', 'https://rika.vteximg.com.br/arquivos/ids/347379/Herois-Mais-Poderosos-da-Marvel---12---Os-Tres-Guerreiros.jpg'),
    ('13', 'https://acdn-us.mitiendanube.com/stores/003/870/408/products/ciclope-f5450b423b2785871017246429530916-640-0.webp'),
    ('14', 'https://rika.vteximg.com.br/arquivos/ids/347385/Herois-Mais-Poderosos-da-Marvel---14---Capitao-Marvel.jpg'),
    ('15', 'https://rika.vteximg.com.br/arquivos/ids/347389/Herois-Mais-Poderosos-da-Marvel---15---Os-Fabulosos-X-Men.jpg'),
    ('16', 'https://rika.vteximg.com.br/arquivos/ids/347392/Herois-Mais-Poderosos-da-Marvel---16---A-Mulher-Invisivel.jpg'),
    ('17', 'https://rika.vteximg.com.br/arquivos/ids/398714/Herois-Mais-Poderosos-da-Marvel-17-Visao.jpg'),
    ('18', 'https://rika.vteximg.com.br/arquivos/ids/398715/Herois-Mais-Poderosos-da-Marvel-18-Guardioes-da-Galaxia.jpg'),
    ('19', 'https://rika.vteximg.com.br/arquivos/ids/398716/Herois-Mais-Poderosos-da-Marvel-19-Falcao.jpg'),
    ('20', 'https://rika.vteximg.com.br/arquivos/ids/398717/Herois-Mais-Poderosos-da-Marvel-20-Namor.jpg'),
    ('21', 'https://rika.vteximg.com.br/arquivos/ids/398718/Herois-Mais-Poderosos-da-Marvel-21-Valquiria.jpg'),
    ('22', 'https://rika.vteximg.com.br/arquivos/ids/398719/Herois-Mais-Poderosos-da-Marvel-22-Professor-X.jpg'),
    ('23', 'https://rika.vteximg.com.br/arquivos/ids/347596/Herois-Mais-Poderosos-da-Marvel---23---Defensores.jpg'),
    ('24', 'https://rika.vteximg.com.br/arquivos/ids/347601/Herois-Mais-Poderosos-da-Marvel---24---Justiceiro.jpg'),
    ('25', 'https://rika.vteximg.com.br/arquivos/ids/398720/Herois-Mais-Poderosos-da-Marvel-25-Nick-Fury.jpg'),
    ('26', 'https://rika.vteximg.com.br/arquivos/ids/398721/Herois-Mais-Poderosos-da-Marvel-26-Pantera-Negra.jpg'),
    ('27', 'https://rika.vteximg.com.br/arquivos/ids/347611/Herois-Mais-Poderosos-da-Marvel---27---Madrox---O-Homem-Multiplo.jpg'),
    ('28', 'https://rika.vteximg.com.br/arquivos/ids/347615/Herois-Mais-Poderosos-da-Marvel---28---Harpia.jpg'),
    ('29', 'https://rika.vteximg.com.br/arquivos/ids/413110/15005318.jpg'),
    ('30', 'https://rika.vteximg.com.br/arquivos/ids/347623/Herois-Mais-Poderosos-da-Marvel---30---Quarteto-Fantastico.jpg'),
    ('31', 'https://rika.vteximg.com.br/arquivos/ids/347627/Herois-Mais-Poderosos-da-Marvel---31---Doutor-Estranho.jpg'),
    ('32', 'https://rika.vteximg.com.br/arquivos/ids/347631/Herois-Mais-Poderosos-da-Marvel---32---O-Coisa.jpg'),
    ('33', 'https://rika.vteximg.com.br/arquivos/ids/347633/Herois-Mais-Poderosos-da-Marvel---33---Destrutor.jpg'),
    ('34', 'https://rika.vteximg.com.br/arquivos/ids/347636/Herois-Mais-Poderosos-da-Marvel---34---Feiticeira-Escalarte.jpg'),
    ('35', 'https://rika.vteximg.com.br/arquivos/ids/347641/Herois-Mais-Poderosos-da-Marvel---35---O-Anjo.jpg'),
    ('36', 'https://rika.vteximg.com.br/arquivos/ids/398722/Herois-Mais-Poderosos-da-Marvel-36-Punho-de-Ferro.jpg'),
    ('37', 'https://rika.vteximg.com.br/arquivos/ids/347648/Herois-Mais-Poderosos-da-Marvel---37---Mercurio.jpg'),
    ('38', 'https://rika.vteximg.com.br/arquivos/ids/404941/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-38-Blade.jpg'),
    ('39', 'https://rika.vteximg.com.br/arquivos/ids/347655/Herois-Mais-Poderosos-da-Marvel---39---Inumanos.jpg'),
    ('40', 'https://rika.vteximg.com.br/arquivos/ids/398723/Herois-Mais-Poderosos-da-Marvel-40-Fera.jpg'),
    ('41', 'https://rika.vteximg.com.br/arquivos/ids/404943/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-41-Thor.jpg'),
    ('42', 'https://rika.vteximg.com.br/arquivos/ids/398724/Herois-Mais-Poderosos-da-Marvel-42-Shang-Chi.jpg'),
    ('43', 'https://rika.vteximg.com.br/arquivos/ids/404945/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-43-Polaris.jpg'),
    ('44', 'https://rika.vteximg.com.br/arquivos/ids/404947/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-44-Adam-Warlock.jpg'),
    ('45', 'https://rika.vteximg.com.br/arquivos/ids/398725/Herois-Mais-Poderosos-da-Marvel-45-Hank-Pym.jpg'),
    ('46', 'https://rika.vteximg.com.br/arquivos/ids/398726/Herois-Mais-Poderosos-da-Marvel-46-Hercules.jpg'),
    ('47', 'https://rika.vteximg.com.br/arquivos/ids/398727/Herois-Mais-Poderosos-da-Marvel-47-Homem-de-Gelo.jpg'),
    ('48', 'https://rika.vteximg.com.br/arquivos/ids/405003/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-48-Vespa.jpg'),
    ('49', 'https://rika.vteximg.com.br/arquivos/ids/405005/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-49-Motoqueiro-Fantasma.jpg'),
    ('50', 'https://rika.vteximg.com.br/arquivos/ids/398728/Herois-Mais-Poderosos-da-Marvel-50-Magnum.jpg'),
    ('51', 'https://rika.vteximg.com.br/arquivos/ids/398729/Herois-Mais-Poderosos-da-Marvel-51-Surfista-Prateado.jpg'),
    ('52', 'https://rika.vteximg.com.br/arquivos/ids/398730/Herois-Mais-Poderosos-da-Marvel-52-Banshee.jpg'),
    ('53', 'https://rika.vteximg.com.br/arquivos/ids/398731/Herois-Mais-Poderosos-da-Marvel-53-Cavaleiro-Negro.jpg'),
    ('54', 'https://rika.vteximg.com.br/arquivos/ids/405007/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-54-Tempestade.jpg'),
    ('55', 'https://rika.vteximg.com.br/arquivos/ids/398732/Herois-Mais-Poderosos-da-Marvel-55-Tocha-Humana.jpg'),
    ('56', 'https://rika.vteximg.com.br/arquivos/ids/398733/Herois-Mais-Poderosos-da-Marvel-56-Colossus.jpg'),
    ('57', 'https://rika.vteximg.com.br/arquivos/ids/398734/Herois-Mais-Poderosos-da-Marvel-57-Senhor-Fantastico.jpg'),
    ('58', 'https://rika.vteximg.com.br/arquivos/ids/405009/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-58-Noturno.jpg'),
    ('59', 'https://rika.vteximg.com.br/arquivos/ids/405011/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-59-Jean-Grey.jpg'),
    ('60', 'https://rika.vteximg.com.br/arquivos/ids/405013/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-60-Miss-Marvel.jpg'),
    ('61', 'https://rika.vteximg.com.br/arquivos/ids/398735/Herois-Mais-Poderosos-da-Marvel-61-Deadpool.jpg'),
    ('62', 'https://rika.vteximg.com.br/arquivos/ids/398736/Herois-Mais-Poderosos-da-Marvel-62-Soldado-Invernal.jpg'),
    ('63', 'https://rika.vteximg.com.br/arquivos/ids/413109/15005317.jpg'),
    ('64', 'https://rika.vteximg.com.br/arquivos/ids/405015/https---www.artesequencial.com.br-imagens-herois_panini-Herois-Mais-Poderosos-da-Marvel-64-Jessica-Jones.jpg'),
    ('65', 'https://rika.vteximg.com.br/arquivos/ids/442989/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-065-maquina-de-combate.jpg'),
    ('66', 'https://rika.vteximg.com.br/arquivos/ids/413108/15005316.jpg'),
    ('67', 'https://rika.vteximg.com.br/arquivos/ids/348361/Herois-Mais-Poderosos-da-Marvel---67---Os-Invasores.jpg'),
    ('68', 'https://rika.vteximg.com.br/arquivos/ids/348363/Herois-Mais-Poderosos-da-Marvel---68---Hulk-Vermelho.jpg'),
    ('69', 'https://rika.vteximg.com.br/arquivos/ids/348365/Herois-Mais-Poderosos-da-Marvel---69---Garota-Aranha.jpg'),
    ('70', 'https://rika.vteximg.com.br/arquivos/ids/442991/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-070-fugitivos.jpg'),
    ('71', 'https://rika.vteximg.com.br/arquivos/ids/348369/Herois-Mais-Poderosos-da-Marvel---71---Rocky-Racum.jpg'),
    ('72', 'https://rika.vteximg.com.br/arquivos/ids/348371/Herois-Mais-Poderosos-da-Marvel---72---Capitao-Bretanha.jpg'),
    ('73', 'https://rika.vteximg.com.br/arquivos/ids/348373/Herois-Mais-Poderosos-da-Marvel---73---Vingadores-da-Costa-Oeste.jpg'),
    ('74', 'https://rika.vteximg.com.br/arquivos/ids/348375/Herois-Mais-Poderosos-da-Marvel---74---O-Sentinela.jpg'),
    ('75', 'https://rika.vteximg.com.br/arquivos/ids/442993/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-075-academia-de-vingadores.jpg'),
    ('76', 'https://rika.vteximg.com.br/arquivos/ids/348379/Herois-Mais-Poderosos-da-Marvel---76---Nova.jpg'),
    ('77', 'https://rika.vteximg.com.br/arquivos/ids/443013/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-077-vingadores-centrais.jpg'),
    ('78', 'https://rika.vteximg.com.br/arquivos/ids/349400/Herois-Mais-Poderosos-da-Marvel---78---Mulher-Aranha.jpg'),
    ('79', 'https://rika.vteximg.com.br/arquivos/ids/349404/Herois-Mais-Poderosos-da-Marvel---79---Jovens-Vingadores.jpg'),
    ('80', 'https://rika.vteximg.com.br/arquivos/ids/349408/Herois-Mais-Poderosos-da-Marvel---80---Mulher-Hulk-.jpg'),
    ('81', 'https://rika.vteximg.com.br/arquivos/ids/349412/Herois-Mais-Poderosos-da-Marvel---81---Vingadores-De-Estimacao.jpg'),
    ('82', 'https://rika.vteximg.com.br/arquivos/ids/443015/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-082-manto-e-adaga.jpg'),
    ('83', 'https://rika.vteximg.com.br/arquivos/ids/443017/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-083-union-jack.jpg'),
    ('84', 'https://rika.vteximg.com.br/arquivos/ids/349424/Herois-Mais-Poderosos-da-Marvel---84---Novos-Guerreiros.jpg'),
    ('85', 'https://rika.vteximg.com.br/arquivos/ids/349428/Herois-Mais-Poderosos-da-Marvel---85---Excalibur.jpg'),
    ('86', 'https://rika.vteximg.com.br/arquivos/ids/398737/Herois-Mais-Poderosos-da-Marvel-86-Agente-Venom.jpg'),
    ('87', 'https://rika.vteximg.com.br/arquivos/ids/443019/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-087-tropa-alfa.jpg'),
    ('88', 'https://rika.vteximg.com.br/arquivos/ids/349441/Herois-Mais-Poderosos-da-Marvel---88---Miles-Morales-Homem-Aranha-Ultimate.jpg'),
    ('89', 'https://rika.vteximg.com.br/arquivos/ids/349445/Herois-Mais-Poderosos-da-Marvel---89---Marvel-Boy.jpg'),
    ('90', 'https://rika.vteximg.com.br/arquivos/ids/349449/Herois-Mais-Poderosos-da-Marvel---90---Ben-Reilly-Aranha-Escalarte.jpg'),
    ('91', 'https://rika.vteximg.com.br/arquivos/ids/398738/Herois-Mais-Poderosos-da-Marvel-91-Quasar.jpg'),
    ('92', 'https://rika.vteximg.com.br/arquivos/ids/349457/Herois-Mais-Poderosos-da-Marvel---92---Thunderbolts.jpg'),
    ('93', 'https://rika.vteximg.com.br/arquivos/ids/443021/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-093-bill-raio-beta.jpg'),
    ('94', 'https://rika.vteximg.com.br/arquivos/ids/398739/Herois-Mais-Poderosos-da-Marvel-94-Garota-Esquilo.jpg'),
    ('95', 'https://rika.vteximg.com.br/arquivos/ids/349468/Herois-Mais-Poderosos-da-Marvel---95---Homem-Maquina.jpg'),
    ('96', 'https://rika.vteximg.com.br/arquivos/ids/398740/Herois-Mais-Poderosos-da-Marvel-96-Vingadores-Secretos.jpg'),
    ('97', 'https://rika.vteximg.com.br/arquivos/ids/349478/Herois-Mais-Poderosos-da-Marvel---97---Deathlok.jpg'),
    ('98', 'https://rika.vteximg.com.br/arquivos/ids/443023/https---www.artesequencial.com.br-imagens-herois_panini-herois-mais-poderosos-da-marvel-098-scott-lang-homem-formiga.jpg'),
    ('99', 'https://rika.vteximg.com.br/arquivos/ids/349485/Herois-Mais-Poderosos-da-Marvel---99---Novos-Mutantes.jpg'),
    ('100', 'https://rika.vteximg.com.br/arquivos/ids/422172/herois-mais-poderosos-da-marvel-100-cavaleiro-da-lua.jpg')
), alvos AS (
    SELECT edicao.id, capas.url_capa
    FROM capas
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Salvat')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Os Heróis Mais Poderosos da Marvel')
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(regexp_replace(edicao.numero, '[^0-9]', '', 'g'), '0') = capas.numero
)
UPDATE edicoes edicao
SET url_capa = alvo.url_capa
FROM alvos alvo
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND lower(trim(editora.nome)) = lower('Salvat')
  AND lower(trim(serie.titulo)) = lower('Os Heróis Mais Poderosos da Marvel')
  AND coalesce(serie.volume, 1) = 1;
