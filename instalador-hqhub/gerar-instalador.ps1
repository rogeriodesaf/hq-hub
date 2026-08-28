$ErrorActionPreference = 'Stop'

$raiz = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $PSScriptRoot 'dist'
$pacote = Join-Path $dist 'agente'
$inno = Get-Command iscc.exe -ErrorAction SilentlyContinue

if (-not $inno) {
    $candidatos = @(
        "$env:ProgramFiles(x86)\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )
    $caminho = $candidatos | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $caminho) { throw 'Inno Setup 6 não encontrado. Instale-o e execute novamente.' }
    $inno = @{ Source = $caminho }
}

New-Item -ItemType Directory -Force -Path $pacote | Out-Null
Copy-Item -LiteralPath (Join-Path $raiz 'docs\importacao\ferramentas\assistente_local_hqhub.py') -Destination $pacote -Force
Copy-Item -LiteralPath (Join-Path $raiz 'docs\importacao\ferramentas\robo_importador_navegador_interativo.py') -Destination $pacote -Force
Copy-Item -LiteralPath (Join-Path $raiz 'docs\importacao\ferramentas\robo_importador_texto.py') -Destination $pacote -Force
Copy-Item -LiteralPath (Join-Path $raiz 'docs\importacao\ferramentas\robo_enriquecer_capa_telegram.py') -Destination $pacote -Force
Copy-Item -LiteralPath (Join-Path $raiz 'docs\importacao\ferramentas\robo_atualizar_capas_panini_catalogo.py') -Destination $pacote -Force
Copy-Item -LiteralPath (Join-Path $raiz 'docs\importacao\ferramentas\robo_enriquecer_capas_multiplas_fontes.py') -Destination $pacote -Force

$isccPath = if ($inno.Source) { $inno.Source } else { $inno.Path }
& $isccPath (Join-Path $PSScriptRoot 'HQ-HUB-Agente.iss')
if ($LASTEXITCODE -ne 0) { throw 'O Inno Setup não conseguiu gerar o instalador.' }
