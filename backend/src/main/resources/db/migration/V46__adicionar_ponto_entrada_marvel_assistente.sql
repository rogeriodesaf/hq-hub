INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Por onde comecar a ler Marvel',
    'Para conhecer o universo Marvel, nao tente comecar pela cronologia inteira. Comece por historias fechadas ou fases com bom ponto de entrada: Homem-Aranha: A Ultima Cacada de Kraven, X-Men: Deus Ama, o Homem Mata, Marvels, Demolidor: O Diabo da Guarda, Demolidor de Frank Miller, Vingadores de Jonathan Hickman ou uma fase recente da Panini como Nova Marvel/Fresh Start. Depois escolha um personagem que voce goste e avance para eventos maiores quando ja estiver familiarizado.',
    'Curadoria HQ-HUB com base nas fontes editoriais cadastradas',
    null,
    'VERIFICADA',
    'SEED',
    'marvel,universo-marvel,por-onde-comecar,comecar,comeco,hq,guia-de-leitura,homem-aranha,x-men,demolidor,vingadores,nova-marvel,fresh-start'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'por onde comecar a ler marvel'
);
