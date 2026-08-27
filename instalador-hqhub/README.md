# Agente HQ-HUB para Windows

Este pacote cria o instalador do agente local usado pelo robô de importação do
Guia dos Quadrinhos. O colaborador instala uma vez e depois inicia o robô pelo
botão do HQ-HUB, sem abrir o PowerShell.

## Gerar o instalador

1. Instale o [Inno Setup 6](https://jrsoftware.org/isinfo.php).
2. Abra o PowerShell na raiz do projeto apenas para gerar o instalador:

```powershell
./instalador-hqhub/gerar-instalador.ps1
```

O arquivo será criado em `instalador-hqhub/dist/HQ-HUB-Agente-Setup.exe`.

O instalador copia os scripts do assistente, cria atalhos e prepara o Python,
Playwright, Chromium e demais dependências na primeira execução. O computador
precisa ter conexão com a internet e o Windows Package Manager (`winget`),
disponível por padrão no Windows 10/11 atualizado.
