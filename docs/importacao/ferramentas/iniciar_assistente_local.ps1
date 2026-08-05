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

& $comandoPython @prefixoPython -c 'import playwright' 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Instalando a dependência Playwright para o assistente local...' -ForegroundColor Yellow
    & $comandoPython @prefixoPython -m pip install --user 'playwright>=1.40,<2'
    if ($LASTEXITCODE -ne 0) {
        throw 'Não foi possível instalar o Playwright. Execute: python -m pip install playwright'
    }
}

$argumentos = @($prefixoPython) + @($assistente, '--porta', [string]$Porta)
if (-not $NaoAbrirSite) {
    $argumentos += '--abrir-hqhub'
}

Write-Host 'Iniciando o assistente local do HQ-HUB...' -ForegroundColor Green
Write-Host 'Mantenha esta janela aberta. Para encerrar, pressione Ctrl+C.' -ForegroundColor DarkGray
& $comandoPython @argumentos
