-- Auditoria das capas em 2026-11-02.
-- Identidade editorial validada: "Coleção Clássica Marvel: Nova Fase", Panini, volume 2.
-- Fonte única: páginas oficiais dos produtos Panini encontradas no sitemap oficial.
-- Quantidade esperada e conferida: 32 edições já cadastradas, números 1 a 32.
-- Evidência número a número: cada linha abaixo registra número, SKU Panini, URL da
-- imagem principal (Product.image) e página do produto. As 32 URLs responderam com
-- imagem e o conjunto completo foi conferido visualmente antes desta migração.
DO $$
DECLARE
    quantidade_atualizada INTEGER;
BEGIN
    WITH capas(numero, sku_panini, url_capa, url_produto) AS (
        VALUES
            ('1',  'ACCMA001R', 'https://panini.com.br/media/catalog/product/a/c/accma001r_0.jpg', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-01-homem-aranha-12'),
            ('2',  'ACCMA002',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_48su3u5qet75l1d8vj5ts2fk67/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-02-quarteto-fantastico-14'),
            ('3',  'ACCMA003',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_sbtlsu1od552dbiun9qmbkt95m/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-03-demolidor-6'),
            ('4',  'ACCMA004',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_pc2be4n8s102p9liej746s3m1f/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-04-x-men-5-divididos-perderemos'),
            ('5',  'ACCMA005',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lma6e6rsa53sf8q9d5g3u3kn3s/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-05-hulk-5-aqui-esta-o-abominavel'),
            ('6',  'ACCMA006',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_r9bnf8vc8h0a154orjc4v61d2f/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-06-homem-de-ferro-7-poder-contra-poder'),
            ('7',  'ACCMA007',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_mpo1e3e94d7h92e6hnq24eu90u/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-07-os-vingadores-08-ate-os-valentes-morrem'),
            ('8',  'ACCMA008',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1mmfmi1kcp7392m5biliok486s/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-08-capitao-america-5-quando-adormecido-desperta'),
            ('9',  'ACCMA009',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_hn90jgspvd1ah70ohdl4kf737c/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-09-thor-11-campo-de-batalha-terra'),
            ('10', 'ACCMA010',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_b476r5let90hv714uai5q4sp03/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-10-homem-aranha-13-mate-o-homem-aranha'),
            ('11', 'ACCMA011',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_3q2v5mdmtl3tjcp13hsbkis074/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-11-quarteto-fantastico-15-dividir-e-conquistar'),
            ('12', 'ACCMA012',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_knpbudi2a57if4ecm9prrtmg2i/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-12-demolidor-electro-e-os-emissarios-do-mal'),
            ('13', 'ACCMA013',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vp75tqtogp3udd6nrhq9ie8m0e/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-13-x-men-quando-titas-colidem'),
            ('14', 'ACCMA014',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_pi4obqp5ph68leasvt2g9g000m/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-14-hulk-confronto-de-titas'),
            ('15', 'ACCMA015',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fi5ngcesgl3o50lc6tmqntte2v/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-15-homem-de-ferro-8-a-chegada-da-ima'),
            ('16', 'ACCMA016',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_geseppbk657htfkq5ndkjus261/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-16-vingadores-9-o-diabolico-plano-do-mandarim'),
            ('17', 'ACCMA017',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_35hdeek43d6l705dhg4achvm42/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-17-capitao-america-6-se-o-passado-nao-estiver-morto'),
            ('18', 'ACCMA018',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_h3a48ivs3l30f5s70t6dpq3k7o/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-18-thor-12-a-ira-de-odin'),
            ('19', 'ACCMA019',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7th8nft3cd5u52qpkrvmkocf1a/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-19-homem-aranha-14-asas-da-noite'),
            ('20', 'ACCMA020',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_kv677mnbv12cn4lvo8b9778112/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-20-quarteto-fantastico-16-no-caminho-do-surfista-prateado'),
            ('21', 'ACCMA021',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_clv5f69rt166db8eldlbfk793p/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-21-demolidor-8-nao-olhe-agora-mas-e-o-doutor-destino'),
            ('22', 'ACCMA022',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_r60kvol83t2qb6qt4uiorhu367/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-22-x-men-7-o-homem-de-cobalto'),
            ('23', 'ACCMA023',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_u3uh86khu90ir8vl8khlucir2g/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-23-hulk-7-o-monstro-libertado'),
            ('24', 'ACCMA024',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rg278llncp1256bhsqhvcfan7t/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-24-homem-de-ferro-9-furor-num-futuro-longinquo'),
            ('25', 'ACCMA025',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_tsni4efnvl0gv7773qf1ec6e5e/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-25-os-vingadores-10-a-morte-clama-pelos-herois'),
            ('26', 'ACCMA026',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_b5l1buj8793rj0fvl0u5fj3m44/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-26-capitao-america-7-esta-noite-eu-morro'),
            ('27', 'ACCMA027',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_blqqe0ovth0c1e84hst0b8b620/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-27-thor-13-agora-e-o-fim-do-universo'),
            ('28', 'ACCMA028',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_6c3ms95c6d2854fmr1rcl0tb7s/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-28-homem-aranha-15-a-presa-do-abutre'),
            ('29', 'ACCMA029',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8o3m2tqkut0dhfiupshgpsk114/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-29-quarteto-fantastico-17-quando-galactus-chama'),
            ('30', 'ACCMA030',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_p27f0rpe9l5hp28if1ot9bs55f/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-30-demolidor-9-a-morte-de-mike-murdock'),
            ('31', 'ACCMA031',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7r6k3fbl853tp707navhsf8b3s/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-31-x-men-8-a-sombra-sinistra-do-apocalipse'),
            ('32', 'ACCMA032',  'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_2j8v3o0kjd30p0lkvkvsulte5j/-S897-f.webp', 'https://panini.com.br/colecao-classica-marvel-nova-fase-vol-32-hulk-8-um-refugio-dividido')
    )
    UPDATE edicoes edicao
       SET url_capa = capas.url_capa,
           url_origem = capas.url_produto,
           data_atualizacao = CURRENT_TIMESTAMP
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
      CROSS JOIN capas
     WHERE edicao.serie_id = serie.id
       AND serie.titulo = 'Coleção Clássica Marvel: Nova Fase'
       AND serie.volume = 2
       AND editora.nome = 'Panini'
       AND capas.numero = ltrim(edicao.numero, '0');

    GET DIAGNOSTICS quantidade_atualizada = ROW_COUNT;
    IF quantidade_atualizada <> 32 THEN
        RAISE EXCEPTION
            'Auditoria de capas abortada: esperadas 32 edições da Coleção Clássica Marvel: Nova Fase, Panini, V2; encontradas %.',
            quantidade_atualizada;
    END IF;
END $$;
