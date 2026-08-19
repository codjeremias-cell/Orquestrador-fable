# deploy-skills.ps1
# Copia as skills deste catalogo (fonte da verdade) para o local que o Claude Code le.
#
# Uso:
#   - Global (todos os projetos no VS Code):   .\deploy-skills.ps1
#   - Para um projeto especifico:               .\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto"
#
# Se o Windows bloquear a execucao, rode:
#   powershell -ExecutionPolicy Bypass -File .\deploy-skills.ps1
#
# Observacao: usa robocopy /E (adiciona e atualiza). Nao remove do destino skills que
# voce apagou no catalogo nem mexe em outras skills globais que voce tenha. Para limpeza
# total de uma skill removida, apague a pasta dela no destino manualmente.

param(
  [string]$ProjectPath = ""
)

$ErrorActionPreference = "Stop"
$source = Join-Path $PSScriptRoot "skills"

if ($ProjectPath -ne "") {
  $dest = Join-Path $ProjectPath ".claude\skills"
} else {
  $dest = Join-Path $env:USERPROFILE ".claude\skills"
}

Write-Host ""
Write-Host "Deploy de skills do catalogo" -ForegroundColor Cyan
Write-Host "  Origem : $source"
Write-Host "  Destino: $dest"
Write-Host ""

if (-not (Test-Path $source)) {
  Write-Host "ERRO: pasta de origem nao encontrada: $source" -ForegroundColor Red
  exit 1
}

robocopy $source $dest /E /NFL /NDL /NJH /NJS | Out-Null
$code = $LASTEXITCODE

$count = (Get-ChildItem $dest -Directory -ErrorAction SilentlyContinue).Count

if ($code -lt 8) {
  Write-Host ("OK - deploy concluido. {0} skills no destino." -f $count) -ForegroundColor Green
  Write-Host "Reabra/reinicie a sessao do Claude no VS Code para ele reler as skills." -ForegroundColor Yellow
} else {
  Write-Host ("ERRO no robocopy (codigo {0})." -f $code) -ForegroundColor Red
  exit $code
}
