-- Organiza visualmente o guia mutante em etapas sem alterar itens, posicoes,
-- vinculos com o catalogo ou progresso dos usuarios.

ALTER TABLE itens_ordem_leitura
    ADD COLUMN secao VARCHAR(180);

WITH secoes(inicio, fim, titulo) AS (VALUES
    (1,   29,  'Era clássica e primeiras histórias'),
    (30,  123, 'A Saga dos X-Men, Wolverine e títulos relacionados'),
    (124, 169, 'Massacre e fase dos anos 1990'),
    (170, 184, 'Dinastia M, Gênese Mortal e Complexo de Messias'),
    (185, 206, 'Guerra dos Reis, Segundo Advento e Cisma'),
    (207, 293, 'Era Marvel NOW!, Batalha do Átomo e Eixo'),
    (294, 311, 'Guerras Secretas'),
    (312, 406, 'Velho Logan, Guerra Civil II e Universo Marvel'),
    (407, 436, 'Retorno de Wolverine e Era do X-Man'),
    (437, 586, 'Era de Krakoa'),
    (587, 600, 'Fase atual — Doze Destinos e Além das Cinzas')
)
UPDATE itens_ordem_leitura item
SET secao = secao.titulo
FROM secoes secao
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao BETWEEN secao.inicio AND secao.fim;
