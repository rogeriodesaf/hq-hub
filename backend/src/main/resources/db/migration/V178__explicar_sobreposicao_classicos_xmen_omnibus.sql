-- Explica que o omnibus de Classic X-Men complementa, mas não substitui, as
-- histórias principais já representadas por outros encadernados do guia.

UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        'Leitura complementar e opcional. Este omnibus reúne as histórias de apoio e as páginas novas ou alteradas de Classic X-Men 1-44, criadas para acompanhar as reedições de Giant-Size X-Men 1 e Uncanny X-Men 94-138, além de material de Marvel Fanfare 60. As histórias principais desse período já estão contempladas sobretudo em Os Fabulosos X-Men: Edição Definitiva vols. 5-7 e também parcialmente em X-Men: Magneto Triunfa e Marvel Essenciais: X-Men — A Saga da Fênix Negra. O omnibus acrescenta cenas e contexto, mas não substitui esses encadernados e não precisa ser lido como repetição integral.'
    )
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('Clássicos X-Men Omnibus');
