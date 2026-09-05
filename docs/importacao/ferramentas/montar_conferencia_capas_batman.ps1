Add-Type -AssemblyName System.Drawing
$pastaCapas = Join-Path $PSScriptRoot '../rascunhos/batman-capas-20260905'
$dadosCapas = Get-Content (Join-Path $pastaCapas 'capas-revisadas.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$jpgCapas = @($dadosCapas | Where-Object { $_.contentType -eq 'image/jpeg' })
$fonteCapa = New-Object System.Drawing.Font('Arial', 10)
$clienteCapa = New-Object System.Net.WebClient
for ($paginaCapa = 0; $paginaCapa -lt [Math]::Ceiling($jpgCapas.Count / 24); $paginaCapa++) {
    $folhaCapa = New-Object System.Drawing.Bitmap(960, 1000)
    $desenhoCapa = [System.Drawing.Graphics]::FromImage($folhaCapa)
    $desenhoCapa.Clear([System.Drawing.Color]::White)
    for ($indiceCapa = 0; $indiceCapa -lt 24; $indiceCapa++) {
        $indiceGeralCapa = $paginaCapa * 24 + $indiceCapa
        if ($indiceGeralCapa -ge $jpgCapas.Count) { break }
        $registroCapa = $jpgCapas[$indiceGeralCapa]
        $bytesCapa = $clienteCapa.DownloadData($registroCapa.produto.urlCapa)
        $streamCapa = New-Object System.IO.MemoryStream(,$bytesCapa)
        $imagemCapa = [System.Drawing.Image]::FromStream($streamCapa)
        $xCapa = ($indiceCapa % 6) * 160
        $yCapa = [Math]::Floor($indiceCapa / 6) * 250
        $desenhoCapa.DrawImage($imagemCapa, [int]$xCapa, [int]$yCapa, 145, 220)
        $desenhoCapa.DrawString(('Pos. ' + $registroCapa.posicao), $fonteCapa, [System.Drawing.Brushes]::Black, [single]$xCapa, [single]($yCapa + 225))
        $imagemCapa.Dispose()
        $streamCapa.Dispose()
    }
    $folhaCapa.Save((Join-Path $pastaCapas ('conferencia-' + $paginaCapa + '.png')), [System.Drawing.Imaging.ImageFormat]::Png)
    $desenhoCapa.Dispose()
    $folhaCapa.Dispose()
}
$clienteCapa.Dispose()
$fonteCapa.Dispose()
