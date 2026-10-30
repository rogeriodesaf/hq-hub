-- Correcao auditavel das capas ausentes de Peter Parker, The Spectacular Spider-Man (1976).
-- Identidade editorial validada: Marvel Comics, serie iniciada em 1976, numero a numero.
-- A Comic Vine divide a numeracao entre dois volumes editoriais:
--   4050-2870   The Spectacular Spider-Man (1976)
--   4050-139754 Peter Parker, the Spectacular Spider-Man (continua depois da edicao 48)
-- Evidencia: 99 registros sem capa em 2026-10-30; 99 URLs responderam HTTP 2xx com
-- Content-Type image/* e o conjunto completo foi conferido visualmente.
-- Esta migracao nao substitui nenhuma capa existente.

INSERT INTO correspondencias_series_externas
    (fonte_externa, id_volume, titulo_catalogo, editora, ano_inicio, url_fonte)
VALUES
    ('COMICVINE', '2870', 'Peter Parker, The Spectacular Spider-Man (1976)', 'Marvel Comics', 1976,
     'https://comicvine.gamespot.com/the-spectacular-spider-man/4050-2870/'),
    ('COMICVINE', '139754', 'Peter Parker, The Spectacular Spider-Man (1976)', 'Marvel Comics', 1976,
     'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man/4050-139754/')
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE capas_peter_parker_spectacular (
    numero TEXT NOT NULL,
    ano INTEGER NOT NULL,
    volume_comic_vine TEXT NOT NULL,
    id_comic_vine TEXT NOT NULL,
    url_capa TEXT NOT NULL,
    url_comic_vine TEXT NOT NULL,
    PRIMARY KEY (numero, ano)
) ON COMMIT DROP;

INSERT INTO capas_peter_parker_spectacular
    (numero, ano, volume_comic_vine, id_comic_vine, url_capa, url_comic_vine)
VALUES
    ('1', 1976, '2870', '16976', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432028-spectacularspider_man001.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-1-twice-stings-the-tara/4000-16976/'),
    ('2', 1977, '2870', '17119', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432037-spectacularspider_man002.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-2-kraven-is-the-hunter/4000-17119/'),
    ('3', 1977, '2870', '17204', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432058-spectacularspider_man003.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-3-and-there-was-lightma/4000-17204/'),
    ('4', 1977, '2870', '17283', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432066-spectacularspider_man004.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-4-the-vulture-is-a-bird/4000-17283/'),
    ('5', 1977, '2870', '17366', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432069-spectacularspider_man005.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-5-spider-kill/4000-17366/'),
    ('6', 1977, '2870', '17445', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432073-spectacularspider_man006.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-6-the-power-to-purge/4000-17445/'),
    ('7', 1977, '2870', '17520', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432075-spectacularspider_man007.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-7-cry-mayhemcry-morbius/4000-17520/'),
    ('8', 1977, '2870', '17615', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2432083-spectacularspider_man008.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-8-and-only-one-shall-su/4000-17615/'),
    ('9', 1977, '2870', '17700', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437335-spectacularspider_man009.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-9-like-a-tiger-in-the-n/4000-17700/'),
    ('10', 1977, '2870', '17795', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437341-spectacularspider_man010.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-10-showdown/4000-17795/'),
    ('11', 1977, '2870', '17889', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437348-spectacularspider_man011.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-11-a-life-too-far/4000-17889/'),
    ('12', 1977, '2870', '17979', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437361-spectacularspider_man012.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-12-brother-power-sister/4000-17979/'),
    ('13', 1977, '2870', '18059', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4038256-ssm13nm9m052.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-13-the-coming-of-razorb/4000-18059/'),
    ('14', 1978, '2870', '18181', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437385-spectacularspider_man014.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-14-killing-me-softly-wi/4000-18181/'),
    ('15', 1978, '2870', '18262', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4038258-ssm15nm9m052.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-15-the-final-rage/4000-18262/'),
    ('16', 1978, '2870', '18341', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437393-spectacularspider_man016.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-16-the-beetle-and-the-b/4000-18341/'),
    ('17', 1978, '2870', '18429', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437394-spectacularspider_man017.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-17-whatever-happened-to/4000-18429/'),
    ('18', 1978, '2870', '18511', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437398-spectacularspider_man018.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-18-my-friend-my-foe/4000-18511/'),
    ('19', 1978, '2870', '18593', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437408-spectacularspider_man019.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-19-again-the-enforcers/4000-18593/'),
    ('20', 1978, '2870', '109294', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437410-spectacularspider_man020.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-20-where-were-you-when-/4000-109294/'),
    ('21', 1978, '2870', '18751', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2437418-spectacularspider_man021.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-21-still-crazy-after-al/4000-18751/'),
    ('22', 1978, '2870', '18831', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528911-spectacularspider_man022.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-22-by-the-light-of-the-/4000-18831/'),
    ('23', 1978, '2870', '18910', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/3539666-tn.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-23-guess-whos-buried-in/4000-18910/'),
    ('24', 1978, '2870', '18978', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528913-spectacularspider_man024.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-24-spider-man-night-fev/4000-18978/'),
    ('25', 1978, '2870', '19054', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528914-spectacularspider_man025.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-25-carrion-my-wayward-s/4000-19054/'),
    ('26', 1979, '2870', '19205', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528922-spectacularspider_man026.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-26-mine-eyes-have-seen-/4000-19205/'),
    ('27', 1979, '2870', '19310', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528923-spectacularspider_man027.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-27-the-blind-leading-th/4000-19310/'),
    ('29', 1979, '2870', '19448', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528927-spectacularspider_man029.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-29-dust-to-dust/4000-19448/'),
    ('30', 1979, '2870', '19519', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528932-spectacularspider_man030.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-30-secret-as-the-grave/4000-19519/'),
    ('31', 1979, '2870', '19587', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4016771-2528935-spectacularspider_man031.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-31-till-death-do-us-par/4000-19587/'),
    ('32', 1979, '2870', '19653', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372293-8783513582-85779.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-32-a-zoo-story/4000-19653/'),
    ('33', 1979, '2870', '19719', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372294-33.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-33-night-of-the-iguana/4000-19719/'),
    ('34', 1979, '2870', '19789', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372295-34.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-34-lizards-on-a-hot-tin/4000-19789/'),
    ('35', 1979, '2870', '19858', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372296-35.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-35-who-dares-enter-the-/4000-19858/'),
    ('36', 1979, '2870', '19930', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372297-36.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-36-enter-swarm/4000-19930/'),
    ('37', 1979, '2870', '20000', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372298-37.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-37-into-the-hive/4000-20000/'),
    ('38', 1980, '2870', '20110', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372299-38.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-38-curse-of-the-living-/4000-20110/'),
    ('39', 1980, '2870', '20180', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372300-39.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-39-scourge-of-the-schiz/4000-20180/'),
    ('40', 1980, '2870', '20254', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372301-40.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-40-the-terrible-turnabo/4000-20254/'),
    ('41', 1980, '2870', '20326', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/7372302-41.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-41-meteor-madness/4000-20326/'),
    ('42', 1980, '2870', '20398', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2528948-spectacularspider_man042.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-42-give-me-liberty-or-g/4000-20398/'),
    ('52', 1981, '139754', '21122', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529010-spectacularspider_man052.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-52-the-day/4000-21122/'),
    ('53', 1981, '139754', '21192', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529018-spectacularspider_man053.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-53-toys-of/4000-21192/'),
    ('54', 1981, '139754', '21255', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529020-spectacularspider_man054.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-54-to-save/4000-21255/'),
    ('55', 1981, '139754', '109296', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529023-spectacularspider_man055.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-55-the-big/4000-109296/'),
    ('56', 1981, '139754', '21389', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529025-spectacularspider_man056.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-56-the-per/4000-21389/'),
    ('57', 1981, '139754', '21456', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529024-spectacularspider_man057.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-57-these-w/4000-21456/'),
    ('58', 1981, '139754', '21528', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529026-spectacularspider_man058.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-58-ring-ou/4000-21528/'),
    ('59', 1981, '139754', '21609', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529029-spectacularspider_man059.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-59-i-want-/4000-21609/'),
    ('60', 1981, '139754', '21676', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529032-spectacularspider_man060.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-60-beetlem/4000-21676/'),
    ('61', 1981, '139754', '21747', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529448-spectacularspider_man061.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-61-by-the-/4000-21747/'),
    ('62', 1982, '139754', '21872', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/8552631-3654517155-B0B2X.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-62-gold-fe/4000-21872/'),
    ('63', 1982, '139754', '21945', 'https://comicvine.gamespot.com/a/uploads/original/6/67663/8552633-2915384621-B0B2X.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-63-firebug/4000-21945/'),
    ('67', 1982, '139754', '22244', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529460-spectacularspider_man067.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-67-boomera/4000-22244/'),
    ('68', 1982, '139754', '22315', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529461-spectacularspider_man068.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-68-hell-ha/4000-22315/'),
    ('69', 1982, '139754', '22389', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2529462-spectacularspider_man069.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-69-in-dark/4000-22389/'),
    ('70', 1982, '139754', '22459', 'https://comicvine.gamespot.com/a/uploads/original/8/84205/4038261-3539672-tn.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-70-the-gre/4000-22459/'),
    ('71', 1982, '139754', '22533', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2537369-spectacularspider_man071.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-71-with-th/4000-22533/'),
    ('72', 1982, '139754', '22608', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2537385-spectacularspider_man072.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-72-waiting/4000-22608/'),
    ('73', 1982, '139754', '22683', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2537395-spectacularspider_man073.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-73-spider-/4000-22683/'),
    ('74', 1983, '139754', '22805', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2537397-spectacularspider_man074.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-74-fantasi/4000-22805/'),
    ('98', 1984, '139754', '25171', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2446047-spectacularspider_man098.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-98-true-co/4000-25171/'),
    ('108', 1985, '139754', '26099', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430650-spectacularspider_man108.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-108-sin-of/4000-26099/'),
    ('110', 1986, '139754', '26409', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430629-spectacularspider_man110.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-110-all-my/4000-26409/'),
    ('111', 1986, '139754', '26514', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430634-spectacularspider_man111.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-111-and-th/4000-26514/'),
    ('112', 1986, '139754', '26608', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430637-spectacularspider_man112.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-112-you-be/4000-26608/'),
    ('113', 1986, '139754', '26707', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430631-spectacularspider_man113.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-113-mayhem/4000-26707/'),
    ('114', 1986, '139754', '26796', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430635-spectacularspider_man114.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-114-the-ke/4000-26796/'),
    ('115', 1986, '139754', '26898', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430619-spectacularspider_man115.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-115-things/4000-26898/'),
    ('116', 1986, '139754', '26994', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430614-spectacularspider_man116.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-116-102-us/4000-26994/'),
    ('117', 1986, '139754', '27090', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430620-spectacularspider_man117.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-117-dinner/4000-27090/'),
    ('118', 1986, '139754', '27187', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2430625-spectacularspider_man118.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-118-ashes-/4000-27187/'),
    ('120', 1986, '139754', '27392', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2433097-spectacularspider_man120.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-120-a-hous/4000-27392/'),
    ('132', 1987, '139754', '28805', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2461475-spectacularspider_man132.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-132-ascend/4000-28805/'),
    ('134', 1988, '139754', '29152', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2667177-spectacularspider_man134.jpg', 'https://comicvine.gamespot.com/peter-parker-the-spectacular-spider-man-134-sin-ce/4000-29152/'),
    ('135', 1988, '2870', '29269', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2667241-spectacularspider_man135.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-135-sin-thesis/4000-29269/'),
    ('136', 1988, '2870', '29378', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2667296-spectacularspider_man136.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-136-sin-ister/4000-29378/'),
    ('146', 1989, '2870', '30792', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2691461-spectacularspider_man146.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-146-demon-night/4000-30792/'),
    ('152', 1989, '2870', '31448', 'https://comicvine.gamespot.com/a/uploads/original/11/117763/2722806-spectacularspider_man152.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-152-a-wolfs-tale/4000-31448/'),
    ('200', 1993, '2870', '65594', 'https://comicvine.gamespot.com/a/uploads/original/5/56044/1811812-spectacular_spider_man__1976_1st_series__200.jpeg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-200-best-of-enemies/4000-65594/'),
    ('201', 1993, '2870', '65595', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50139-2870-65595-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-201-maximum-carnage-par/4000-65595/'),
    ('202', 1993, '2870', '65596', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50140-2870-65596-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-202-maximum-carnage-par/4000-65596/'),
    ('203', 1993, '2870', '65597', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50141-2870-65597-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-203-maximum-carnage-par/4000-65597/'),
    ('217', 1994, '2870', '65611', 'https://comicvine.gamespot.com/a/uploads/original/11125/111254576/5674619-217-b.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-217-power-and-responsib/4000-65611/'),
    ('219', 1994, '2870', '65614', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50158-2870-65614-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-219-back-from-the-edge-/4000-65614/'),
    ('220', 1995, '2870', '65615', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50159-2870-65615-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-220-web-of-death-part-2/4000-65615/'),
    ('221', 1995, '2870', '65616', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50160-2870-65616-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-221-web-of-death-4-of-4/4000-65616/'),
    ('222', 1995, '2870', '65617', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50161-2870-65617-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-222-players-and-pawns-p/4000-65617/'),
    ('223', 1995, '2870', '65618', 'https://comicvine.gamespot.com/a/uploads/original/11125/111254576/5674614-223.die.cut.gif', 'https://comicvine.gamespot.com/the-spectacular-spider-man-223-aftershocks-part-2-/4000-65618/'),
    ('224', 1995, '2870', '65619', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50163-2870-65619-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-224-the-mark-of-kaine-p/4000-65619/'),
    ('225', 1995, '2870', '65620', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50164-2870-65620-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-225-the-return-of-the-g/4000-65620/'),
    ('226', 1995, '2870', '65621', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50165-2870-65621-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-226-the-trial-of-peter-/4000-65621/'),
    ('227', 1995, '2870', '109299', 'https://comicvine.gamespot.com/a/uploads/original/0/4053/119057-2870-109299-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-227-maximum-clonage-par/4000-109299/'),
    ('228', 1995, '2870', '65623', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50166-2870-65623-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-228-time-bomb-part-1-ru/4000-65623/'),
    ('229', 1995, '2870', '65624', 'https://comicvine.gamespot.com/a/uploads/original/0/4/50167-2870-65624-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-229-the-greatest-respon/4000-65624/'),
    ('249', 1997, '2870', '44088', 'https://comicvine.gamespot.com/a/uploads/original/0/4/39204-2870-44088-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-249-into-the-light/4000-44088/'),
    ('250', 1997, '2870', '44193', 'https://comicvine.gamespot.com/a/uploads/original/0/4/39290-2870-44193-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-250-citizen-osborn/4000-44193/'),
    ('254', 1998, '2870', '44681', 'https://comicvine.gamespot.com/a/uploads/original/0/4/39701-2870-44681-1-spectacular-spider-m.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-254-angst/4000-44681/'),
    ('255', 1998, '2870', '44773', 'https://comicvine.gamespot.com/a/uploads/original/1/15776/613322-spsp255a.jpg', 'https://comicvine.gamespot.com/the-spectacular-spider-man-255-spider-hunt-part-4-/4000-44773/');

DO $$
DECLARE
    serie_alvo BIGINT;
    quantidade_series INTEGER;
    quantidade_invalidas INTEGER;
    quantidade_conflitos INTEGER;
    quantidade_atualizada INTEGER;
BEGIN
    SELECT count(*), min(s.id)
      INTO quantidade_series, serie_alvo
      FROM series s
      JOIN editoras editora ON editora.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('Peter Parker, The Spectacular Spider-Man (1976)')
       AND hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Marvel Comics')
       AND s.ano_inicio = 1976
       AND s.tipo_serie = 'ESTRANGEIRA'
       AND EXISTS (SELECT 1 FROM edicoes existente WHERE existente.serie_id = s.id);

    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Identidade ambigua para Peter Parker, The Spectacular Spider-Man (1976): % series com edicoes',
            quantidade_series;
    END IF;

    IF (SELECT count(*) FROM capas_peter_parker_spectacular) <> 99 THEN
        RAISE EXCEPTION 'Auditoria incompleta: eram esperadas 99 correspondencias de capa';
    END IF;

    SELECT count(*)
      INTO quantidade_invalidas
      FROM capas_peter_parker_spectacular capa
     WHERE (SELECT count(*)
              FROM edicoes edicao
             WHERE edicao.serie_id = serie_alvo
               AND hqhub_normalizar_identidade(edicao.numero) =
                   hqhub_normalizar_identidade(capa.numero)
               AND extract(year FROM coalesce(edicao.data_publicacao, edicao.data_cobertura)) = capa.ano) <> 1;

    IF quantidade_invalidas > 0 THEN
        RAISE EXCEPTION
            'Auditoria recusada: % correspondencias nao identificam uma unica edicao interna',
            quantidade_invalidas;
    END IF;

    SELECT count(*)
      INTO quantidade_conflitos
      FROM capas_peter_parker_spectacular capa
      JOIN edicoes outra
        ON outra.id_comic_vine = capa.id_comic_vine
       AND outra.serie_id <> serie_alvo;

    IF quantidade_conflitos > 0 THEN
        RAISE EXCEPTION
            'Auditoria recusada: % IDs da Comic Vine ja pertencem a outra serie',
            quantidade_conflitos;
    END IF;

    UPDATE edicoes edicao
       SET url_capa = CASE
               WHEN edicao.url_capa IS NULL OR trim(edicao.url_capa) = ''
               THEN capa.url_capa
               ELSE edicao.url_capa
           END,
           id_comic_vine = coalesce(nullif(trim(edicao.id_comic_vine), ''), capa.id_comic_vine),
           url_comic_vine = coalesce(nullif(trim(edicao.url_comic_vine), ''), capa.url_comic_vine),
           data_atualizacao = CURRENT_TIMESTAMP
      FROM capas_peter_parker_spectacular capa
     WHERE edicao.serie_id = serie_alvo
       AND hqhub_normalizar_identidade(edicao.numero) =
           hqhub_normalizar_identidade(capa.numero)
       AND extract(year FROM coalesce(edicao.data_publicacao, edicao.data_cobertura)) = capa.ano;

    GET DIAGNOSTICS quantidade_atualizada = ROW_COUNT;
    IF quantidade_atualizada <> 99 THEN
        RAISE EXCEPTION
            'Auditoria incompleta: esperadas 99 edicoes atualizadas, obtidas %',
            quantidade_atualizada;
    END IF;
END $$;

