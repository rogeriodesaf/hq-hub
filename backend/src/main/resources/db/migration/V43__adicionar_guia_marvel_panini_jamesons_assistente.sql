INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Guia de leitura Marvel Panini por Jamesons',
    'O guia do Jamesons organiza colecoes de encadernados Marvel publicados pela Panini para ajudar o leitor a entender continuidade, ordem aproximada de leitura, republicacoes e fases editoriais. Ele cobre sagas como Era do Apocalipse, Inferno e Massacre, republicacoes como Colecoes Historicas, fases como Nova Marvel, Totalmente Nova e Diferente Marvel e Fresh Start, alem de observacoes quando a ordem de encadernados exige sincronizar tie-ins ou ler revistas em paralelo.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,guia-de-leitura,encadernados,ordem-de-leitura,cronologia,colecoes,sagas'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'guia de leitura marvel panini por jamesons'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Colecoes Historicas Marvel da Panini',
    'Segundo o guia do Jamesons, as Colecoes Historicas da Panini geralmente nao devem ser tratadas como leitura linear. Muitas edicoes funcionam como recortes tematicos por heroi, vilao ou periodo: Homem-Aranha pode reunir confrontos contra um inimigo especifico, Quarteto Fantastico pode focar Dr. Destino ou Galactus, Vingadores pode reunir historias classicas de integrantes e viloes, e Paladinos Marvel compila aventuras urbanas de personagens como Demolidor, Punho de Ferro, Luke Cage, Justiceiro e Cavaleiro da Lua.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,colecao-historica,colecoes-historicas,homem-aranha,quarteto-fantastico,vingadores,paladinos'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'colecoes historicas marvel da panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'X-Men de Chris Claremont em encadernados Panini',
    'No guia do Jamesons, a fase de Chris Claremont nos X-Men e tratada como uma leitura extensa e cronologica. Os encadernados iniciais cobrem a entrada de Wolverine, Tempestade, Noturno e outros mutantes na equipe; a continuacao aparece em blocos posteriores. Para os mutantes, o guia tambem destaca que algumas colecoes alinham eventos de 1986 e 1987, como Massacre de Mutantes, Vingadores vs X-Men, Quarteto Fantastico vs X-Men e A Queda dos Mutantes, mas ainda podem existir edicoes mensais avulsas fora dos encadernados.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,x-men,chris-claremont,wolverine,tempestade,noturno,massacre-de-mutantes,queda-dos-mutantes'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'x-men de chris claremont em encadernados panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Excalibur e Capitao Britania na leitura mutante Panini',
    'O guia do Jamesons observa que, na organizacao de Excalibur, o material de Capitao Britania pode aparecer antes da equipe propriamente dita por introduzir conceitos importantes. Ele se encaixa cronologicamente antes de Massacre de Mutantes, enquanto os encadernados de Excalibur compilam as primeiras edicoes da equipe em uma fase ligada a Chris Claremont e Alan Davis.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,excalibur,capitao-britania,chris-claremont,alan-davis,x-men,mutantes'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'excalibur e capitao britania na leitura mutante panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Novissimos X-Men e Fabulosos X-Men de Brian Michael Bendis',
    'Segundo o guia do Jamesons, a fase de Brian Michael Bendis nos X-Men envolve duas revistas que se complementam: Novissimos X-Men e Fabulosos X-Men. Para nao se perder, a leitura ideal e alinhar as duas series em conjunto, alternando os encadernados conforme a ordem sugerida pelo guia, em vez de ler cada linha isoladamente do inicio ao fim.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,x-men,brian-michael-bendis,bendis,novissimos-x-men,fabulosos-x-men,nova-marvel'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'novissimos x-men e fabulosos x-men de brian michael bendis'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Vingadores de Jonathan Hickman e saga Infinito Panini',
    'O guia do Jamesons alerta que, na fase de Jonathan Hickman, a saga Infinito exige mais cuidado que uma leitura simples volume a volume. A publicacao brasileira em encadernados pode obrigar o leitor a alternar historias entre volumes diferentes para acompanhar a ordem planejada pelo autor e os tie-ins. Depois desse trecho, a leitura volta a seguir a ordem dos encadernados com mais normalidade.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,vingadores,jonathan-hickman,hickman,infinito,nova-marvel,tie-ins,ordem-de-leitura'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'vingadores de jonathan hickman e saga infinito panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Homem-Aranha de Dan Slott em encadernados Panini',
    'No guia do Jamesons, a fase de Dan Slott no Homem-Aranha e apresentada como uma publicacao ainda incompleta no recorte analisado. O guia ressalta que a passagem de Slott comecou antes de Ultimo Desejo, mas a Panini passou a encadernar de forma mais estruturada a partir da Nova Marvel, especialmente na fase Superior Homem-Aranha.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,homem-aranha,spider-man,dan-slott,superior-homem-aranha,ultimo-desejo,nova-marvel'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'homem-aranha de dan slott em encadernados panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Demolidor de Frank Miller e Klaus Janson em encadernados Panini',
    'O guia do Jamesons diferencia os encadernados do Demolidor ligados a Frank Miller e Klaus Janson do restante da revista do personagem. Esses volumes compilam materiais escritos por Miller ou relacionados a ele, principalmente das decadas de 1980 e 1990; outras historias publicadas no mesmo periodo podem nao fazer parte desses encadernados.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,demolidor,daredevil,frank-miller,klaus-janson,encadernados'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'demolidor de frank miller e klaus janson em encadernados panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Thor de Jason Aaron em encadernados Panini',
    'No recorte do guia do Jamesons, a fase de Jason Aaron no Thor ainda nao estava completa em encadernados pela Panini. Portanto, perguntas sobre essa fase devem considerar que a ordem pode depender de volumes ainda nao publicados no momento do guia e de atualizacoes posteriores da editora.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,thor,jason-aaron,encadernados,nova-marvel'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'thor de jason aaron em encadernados panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Miles Morales em encadernados Panini',
    'Segundo o guia do Jamesons, a colecao de Miles Morales republica as historias do personagem desde sua origem em ordem cronologica. No recorte do artigo, a colecao ainda nao estava completa, entao a resposta ideal deve tratar a informacao como guia de ordem e conferir o catalogo atual do HQ-HUB ou lancamentos posteriores para saber quais volumes ja sairam.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,miles-morales,homem-aranha,spider-man,ordem-cronologica'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'miles morales em encadernados panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Venom e cosmos Marvel de Donny Cates em encadernados Panini',
    'O guia do Jamesons organiza algumas revistas escritas por Donny Cates em ordem cronologica por comporem uma trama maior no lado cosmico da Marvel. Para esse bloco, ele recomenda considerar tambem materiais como Thanos e Motoqueiro Fantasma Cosmico antes de certos encadernados de Venom, porque os conceitos e personagens se conectam.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,donny-cates,venom,thanos,motoqueiro-fantasma-cosmico,cosmos-marvel'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'venom e cosmos marvel de donny cates em encadernados panini'
);

INSERT INTO conhecimentos_editoriais (tipo, titulo, conteudo, fonte, url_fonte, confianca, origem_dados, tags)
SELECT
    'GUIA_LEITURA',
    'Fresh Start e fases recentes Marvel Panini',
    'O guia do Jamesons usa fases editoriais como Nova Marvel, Totalmente Nova e Diferente Marvel e Fresh Start como marcos para organizar encadernados recentes da Panini. Essas etiquetas ajudam a localizar quando uma serie foi publicada e quais outras revistas ou sagas podem estar acontecendo em paralelo, mas nem sempre significam que cada colecao possa ser lida isoladamente sem atencao a eventos e tie-ins.',
    'Jamesons',
    'https://jamesons.com.br/guia-de-leitura-para-todas-as-colecoes-de-encadernados-da-marvel-lancados-pela-panini/',
    'VERIFICADA',
    'CURADORIA_EXTERNA',
    'marvel,panini,jamesons,nova-marvel,totalmente-nova-e-diferente-marvel,fresh-start,fases-editoriais,tie-ins'
WHERE NOT EXISTS (
    SELECT 1 FROM conhecimentos_editoriais WHERE LOWER(titulo) = 'fresh start e fases recentes marvel panini'
);
