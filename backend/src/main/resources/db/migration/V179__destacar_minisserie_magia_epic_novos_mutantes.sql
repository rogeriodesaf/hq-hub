-- Identifica no guia onde está reunida a minissérie clássica de Illyana.

UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        'Esta edição é Novos Mutantes: Renovação (Marvel Epic Collection vol. 3) e reúne integralmente Magik (1983) 1-4. A minissérie acompanha os anos de Illyana Rasputin no Limbo ao lado de versões alternativas de Ororo e Kitty Pryde, explicando como a irmã mais nova de Colossus cresce e se transforma em Magia. O volume também reúne Marvel Graphic Novel 4, New Mutants 1-12, Uncanny X-Men 167, Marvel Team-Up Annual 6 e Marvel Team-Up 100.'
    )
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('Marvel Epic Collection')
  AND item.detalhe_referencia = 'V1 #3';
