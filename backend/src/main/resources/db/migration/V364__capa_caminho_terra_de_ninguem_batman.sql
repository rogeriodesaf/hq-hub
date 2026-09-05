-- Anexa a capa oficial da edição que corresponde a
-- Batman: Caminho para a Terra de Ninguém (Road to No Man's Land Vol. 1).
UPDATE itens_ordem_leitura item
SET detalhe_referencia = 'Batman: The Road to No Man''s Land Vol. 1 · DC Comics · EUA',
    url_capa_referencia = 'https://static.dc.com/dc/files/default_images/batman_roadnomansland_vol1_5b031dc7dc34f3.15140332.jpg?w=160',
    status_identificacao = 'PENDENTE_REVISAO',
    observacao = 'Capa oficial da DC; edição americana correspondente ao arco Caminho para a Terra de Ninguém. Não foi localizada edição brasileira equivalente no catálogo.',
    ano_referencia = 2015
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'batman-ordem-cronologica'
  AND item.titulo_referencia = 'Batman: Caminho para a Terra de Ninguém';
