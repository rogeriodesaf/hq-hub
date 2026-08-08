param(
    [ValidateRange(1024, 65535)]
    [int]$Porta = 8765,
    [switch]$NaoAbrirSite
)

$ErrorActionPreference = 'Stop'
$pastaFerramentas = Split-Path -Parent $MyInvocation.MyCommand.Path
$assistente = Join-Path $pastaFerramentas 'assistente_local_hqhub.py'

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw 'Python 3 não foi encontrado. Instale o Python e tente novamente.'
}

$comandoPython = $python.Source
$prefixoPython = @()
if ($python.Name -eq 'py.exe' -or $python.Name -eq 'py') {
    $prefixoPython = @('-3')
}

$tratamentoErroAnterior = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& $comandoPython @prefixoPython -c 'import playwright' 2>$null
$playwrightDisponivel = $LASTEXITCODE -eq 0
$ErrorActionPreference = $tratamentoErroAnterior
if (-not $playwrightDisponivel) {
    Write-Host 'Instalando a dependência Playwright para o assistente local...' -ForegroundColor Yellow
    $ErrorActionPreference = 'Continue'
    & $comandoPython @prefixoPython -m pip install --user 'playwright>=1.40,<2'
    $instalacaoPlaywrightOk = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $tratamentoErroAnterior
    if (-not $instalacaoPlaywrightOk) {
        throw 'Não foi possível instalar o Playwright. Execute: python -m pip install playwright'
    }
}

$ErrorActionPreference = 'Continue'
& $comandoPython @prefixoPython -c 'import telethon, pymupdf' 2>$null
$telegramDisponivel = $LASTEXITCODE -eq 0
$ErrorActionPreference = $tratamentoErroAnterior
if (-not $telegramDisponivel) {
    Write-Host 'Instalando dependencias do importador de capas do Telegram...' -ForegroundColor Yellow
    $ErrorActionPreference = 'Continue'
    & $comandoPython @prefixoPython -m pip install --user 'telethon>=1.36,<2' 'pymupdf>=1.24,<2'
    $instalacaoTelegramOk = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $tratamentoErroAnterior
    if (-not $instalacaoTelegramOk) {
        throw 'Nao foi possivel instalar Telethon/PyMuPDF. Execute: python -m pip install telethon pymupdf'
    }
}

$argumentos = @($prefixoPython) + @($assistente, '--porta', [string]$Porta)
if (-not $NaoAbrirSite) {
    $argumentos += '--abrir-hqhub'
}

Write-Host 'Iniciando o assistente local do HQ-HUB...' -ForegroundColor Green
Write-Host 'Mantenha esta janela aberta. Para encerrar, pressione Ctrl+C.' -ForegroundColor DarkGray
& $comandoPython @argumentos
