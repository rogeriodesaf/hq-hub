# FAQ base do Assistente (HQ-HUB)

Este arquivo traz 30 perguntas e respostas prontas para orientar o uso do assistente em https://hqhub-frontend.onrender.com/assistente.

Importante:
- As respostas abaixo estao alinhadas ao comportamento atual do backend.
- O assistente hoje responde sobre: resumo da colecao, faltantes por serie, completude por serie, compras planejadas, creditos por criador e relacionamento entre series.
- Quando possivel, use o titulo da serie exatamente como cadastrado ou informe serieId.

## 1) Resumo da colecao

1. Pergunta: Qual e o resumo da minha colecao?
   Resposta: Sua colecao tem X item(ns), Y serie(s), Z editora(s) e valor pago total de R$ N.

2. Pergunta: Me mostre a visao geral da minha colecao.
   Resposta: Resumo geral: total de itens, total de series, total de editoras e valor total pago.

3. Pergunta: Quantas series eu tenho cadastradas?
   Resposta: No seu resumo da colecao, o campo total de series mostra exatamente isso.

4. Pergunta: Qual o valor total que ja paguei?
   Resposta: O assistente retorna esse dado no resumo da colecao como valor pago total.

5. Pergunta: Quantas editoras aparecem na minha colecao?
   Resposta: Esse numero tambem vem no resumo da colecao, no campo total de editoras.

## 2) Edicoes faltantes por serie

6. Pergunta: Quais edicoes faltam na minha colecao da Saga do Homem-Aranha 2 serie?
   Resposta: Vou buscar as faltantes dessa serie. Se eu nao localizar o titulo com precisao, informe serieId=NN para busca direta.

7. Pergunta: Quais faltantes da serieId=1?
   Resposta: Encontrei N edicao(oes) faltante(s) para essa serie.

8. Pergunta: Tenho alguma falta na serie X?
   Resposta: Se houver registros, listo as faltantes. Se nao houver, respondo que nao ha edicoes faltantes cadastradas.

9. Pergunta: Lista so as que faltam da serie Y.
   Resposta: Retorno apenas as edicoes faltantes da serie informada.

10. Pergunta: Nao achou a serie. O que faco?
    Resposta: Informe o titulo exatamente como cadastrado ou use serieId=NN (exemplo: serieId=1).

## 3) Completude por serie

11. Pergunta: Qual a completude da serieId=1?
    Resposta: A serie esta com P% de completude: A de B edicao(oes), faltando C.

12. Pergunta: Minha serie X esta completa?
    Resposta: Vou calcular a completude da serie e informar percentual, total possuido, total de edicoes e faltantes.

13. Pergunta: Quanto falta para fechar a serie Y?
    Resposta: Retorno o numero de faltantes e a porcentagem atual de conclusao da serie.

14. Pergunta: Me passe percentual de conclusao da serie Z.
    Resposta: Entrego o percentual de completude com base no que esta catalogado no HQ-HUB.

15. Pergunta: Quero saber o progresso da serie X.
    Resposta: O progresso inclui: possuidas, total previsto, faltantes e percentual.

## 4) Compras planejadas

16. Pergunta: Quais compras tenho planejadas para junho de 2026?
    Resposta: Encontrei N compra(s) planejada(s) para 06/2026.

17. Pergunta: Mostre minhas compras planejadas para 08/2026.
    Resposta: Filtro o planejamento por mes e ano informados e retorno as compras encontradas.

18. Pergunta: O que tenho de compra planejada este mes?
    Resposta: Posso listar as compras planejadas do mes atual quando o periodo estiver explicito na pergunta.

19. Pergunta: Nao tenho nada planejado. Confere?
    Resposta: Se nao houver registros no periodo consultado, respondo que nao ha compras planejadas.

20. Pergunta: Como eu pergunto compras por mes de forma segura?
    Resposta: Use formato como: "Quais compras tenho planejadas para junho de 2026?" ou "... para 06/2026?".

## 5) Criadores e creditos

21. Pergunta: Quais publicacoes do criador Alan Moore existem no catalogo?
    Resposta: Encontrei N credito(s) para Alan Moore, ordenados por data de publicacao das edicoes.

22. Pergunta: Quais edicoes com creditos do criador X?
    Resposta: Retorno as edicoes associadas ao criador informado com base nos creditos cadastrados.

23. Pergunta: Pode listar trabalhos do roteirista Y?
    Resposta: Sim. Para isso, preciso que o criador esteja cadastrado e com creditos vinculados as edicoes.

24. Pergunta: Procure obras do desenhista Z.
    Resposta: Vou consultar por criador/artista e retornar os creditos encontrados no catalogo local.

25. Pergunta: Nao encontrou o criador. Qual o proximo passo?
    Resposta: Cadastre o criador e os creditos das edicoes; depois disso consigo listar em ordem cronologica.

## 6) Relacionamento entre series (continuidade, v2, relancamento)

26. Pergunta: A serieId=1 continua em alguma v2 ou relancamento?
    Resposta: Encontrei N relacionamento(s) de continuidade ou ligacao para essa serie.

27. Pergunta: Essa serie tem continuacao?
    Resposta: Consulto os relacionamentos cadastrados e informo se existe continuidade.

28. Pergunta: Existe reboot ligado a serie X?
    Resposta: Se houver relacionamento registrado, retorno os vinculos entre as series relacionadas.

29. Pergunta: Quais series se conectam com a serie Y?
    Resposta: Listo os relacionamentos de ligacao/continuidade da serie consultada.

30. Pergunta: Como consultar relacionamento sem erro?
    Resposta: Informe serieId=NN para maior precisao ou use o titulo exatamente como cadastrado.

## Prompt curto recomendado para a UI

Use este texto como referencia no assistente para melhorar a orientacao ao usuario:

"Eu respondo com base nos dados cadastrados no HQ-HUB. Posso ajudar com: resumo da colecao, faltantes e completude por serie, compras planejadas por mes/ano, creditos por criador e relacionamento entre series (continuidade/v2/reboot/relancamento). Se eu nao encontrar a serie, informe serieId=NN ou o titulo exato cadastrado."
