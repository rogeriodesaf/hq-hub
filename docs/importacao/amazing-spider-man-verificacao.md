# Correspondências de Amazing Spider-Man (1963)

Verificado em 2026-10-02. A auditoria número a número está em
`amazing-spider-man-vinculos-2026-10-02.json`; as migrações são V457 e V458.

- 71 correspondências da Saga conferidas nas fichas da Panini, usando os títulos das histórias dos arquivos de importação existentes.
- O Guia confirmou mais oito correspondências: Saga, volume 2, nº 18 (originais 280–282), e Superalmanaque Marvel nº 2, Abril (275, 276, 279–281).
- A fonte indicada pelo usuário para Amazing Spider-Man nº 280 confirmou Saga, segunda série, nº 18 (setembro de 2026), e Superalmanaque nº 2 (dezembro de 1990).
- A ficha Panini da Saga nº 5 diverge dos arquivos de importação; excluída do lote. A ficha Panini nº 18 contém o erro `2780–282`; o Guia confirmou os três números individualmente.
- As correspondências das edições brasileiras já cadastradas são reaproveitadas. Apenas as duas edições da referência nº 280 podem ser criadas se ausentes. Identidades brasileiras ambíguas interrompem a migração.
- A reexecução não duplica histórias, vínculos ou conteúdos. Não altera capas nem migrações anteriores. Conteúdo completo e ausência de cortes não são inferidos.

## Validação

- Build Angular de produção aprovado (avisos de orçamento de bundle).
- Testes Java de `HistoriaPublicacoesBrasilTest`, `CompartilhamentoResourceTest`, `SerieRepositoryTest` e `EdicaoMapperTest` aprovados.
- PostgreSQL isolado via PGlite: 79 vínculos, nº 280 nas duas publicações corretas, reexecução idempotente e rejeição de volume/ano diferentes.
- Navegador Chrome com API simulada: celular sem transbordamento horizontal; atalho com foco, modal/Escape, estado vazio, contribuição e recuperação de erro. Fluxo Comic Vine: busca do volume, abertura da nº 280, exibição das brasileiras e navegação ao catálogo.
- A suíte geral apresenta falha em `AssistenteServiceTest.contaTodasAsEdicoesDoHeroiEDistribuiPorTitulo`. A mesma falha foi reproduzida em checkout isolado do commit anterior `35b2c60`.

As migrações são executadas pelo Flyway na inicialização do backend após a implantação.
