-- Explicita quais histórias destes encadernados aparecem em outras opções do
-- guia e quais permanecem exclusivas de cada edição.

WITH referencias(titulo, detalhe, explicacao) AS (VALUES
    (
        'Os Maiores Clássicos da Tropa Alfa',
        'V1 #1',
        'Sobreposição parcial: Uncanny X-Men 109 e 120-121 também estão em Os Fabulosos X-Men: Edição Definitiva vols. 5-6 e em X-Men: Magneto Triunfa. Alpha Flight 1-6 não aparece em outra edição atual do guia, portanto este volume continua necessário para as primeiras histórias solo da Tropa Alfa.'
    ),
    (
        'Os Maiores Clássicos da Tropa Alfa',
        'V1 #2',
        'Sem sobreposição direta no guia: reúne Alpha Flight 7-12, histórias que não aparecem nas demais edições atualmente listadas.'
    ),
    (
        'Marvel Essenciais: X-Men — A Saga da Fênix Negra',
        NULL,
        'Sobreposição integral: Uncanny X-Men 129-137 também está em Os Fabulosos X-Men: Edição Definitiva vol. 7. Escolha uma das duas opções; não é necessário ler ambas.'
    ),
    (
        'Os Heróis Mais Poderosos da Marvel',
        'V1 #15',
        'Sobreposição parcial: Uncanny X-Men 138-142, incluindo Dias de um Futuro Esquecido em 141-142, também está em Os Fabulosos X-Men: Edição Definitiva vol. 7. A graphic novel Deus Ama, o Homem Mata não aparece em outra edição atual do guia, por isso este volume ainda oferece material exclusivo.'
    ),
    (
        'Coleção Histórica Marvel: Os X-Men',
        'V1 #5',
        'Sobreposição parcial: Uncanny X-Men 200 também está em A Saga dos X-Men vol. 12. Uncanny X-Men 145-147 e 150 não aparecem em outra edição atual do guia.'
    ),
    (
        'Coleção Histórica Marvel: Os X-Men',
        'V1 #6',
        'Sem sobreposição direta no guia: reúne Uncanny X-Men 154-158 e Uncanny X-Men Annual 5, material que não aparece nas demais edições atualmente listadas.'
    ),
    (
        'Coleção Histórica Marvel: Os X-Men',
        'V1 #7',
        'Sem sobreposição direta no guia: reúne Uncanny X-Men 161-166, material que não aparece nas demais edições atualmente listadas.'
    ),
    (
        'Coleção Histórica Marvel: Os X-Men',
        'V1 #8',
        'Sobreposição integral distribuída entre outras opções: New Mutants 1-3 e Uncanny X-Men 167 também estão em Marvel Epic Collection vol. 3 — Novos Mutantes: Renovação; Uncanny X-Men 232 está em A Saga dos X-Men vol. 22, e Uncanny X-Men 233-234 estão em A Saga dos X-Men vol. 23. Este volume pode ser tratado como alternativa compacta.'
    )
)
UPDATE itens_ordem_leitura item
SET observacao = concat_ws(
        ' ',
        nullif(trim(item.observacao), ''),
        referencia.explicacao
    )
FROM referencias referencia
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND lower(trim(item.titulo_referencia)) = lower(referencia.titulo)
  AND (
      referencia.detalhe IS NULL
      OR item.detalhe_referencia = referencia.detalhe
  );
