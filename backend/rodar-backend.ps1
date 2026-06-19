$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot
Set-Location 'target/quarkus-app'

$env:HQHUB_DB_HOST = '127.0.0.1'
$env:HQHUB_DB_PORT = '5433'
$env:HQHUB_DB_USUARIO = 'postgres'
$env:HQHUB_DB_SENHA = 'postgres'
$env:HQHUB_COMICVINE_CHAVE_API = [Environment]::GetEnvironmentVariable('HQHUB_COMICVINE_CHAVE_API', 'User')

if ([string]::IsNullOrWhiteSpace($env:HQHUB_COMICVINE_CHAVE_API)) {
    throw 'A variavel HQHUB_COMICVINE_CHAVE_API nao foi encontrada no perfil do usuario.'
}

& java.exe -jar .\quarkus-run.jar
