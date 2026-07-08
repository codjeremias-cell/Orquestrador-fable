# deploy-skills.ps1
# Copia as skills deste catalogo (fonte da verdade) para o local que o Claude Code le.
#
# Uso:
#   - Global (todos os projetos no VS Code):   .\deploy-skills.ps1
#   - Para um projeto especifico:               .\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto"
#   - Espelhar (remove skills orfas no destino): .\deploy-skills.ps1 -Espelhar
#     (lista as pastas do destino que nao existem mais no catalogo e pede confirmacao
#      uma a uma; use -Forcar junto com -Espelhar para remover sem perguntar)
#
# Se o Windows bloquear a execucao, rode:
#   powershell -ExecutionPolicy Bypass -File .\deploy-skills.ps1
#
# Observacao: o modo padrao usa robocopy /E (adiciona e atualiza) e NAO remove nada do
# destino. O modo -Espelhar detecta skills orfas (existem no destino, nao no catalogo)
# e as remove com confirmacao - cuidado: skills que voce mantem SO no destino (fora do
# catalogo) aparecerao como orfas; responda "n" para preserva-las.

param(
  [string]$ProjectPath = "",
  [switch]$Espelhar,
  [switch]$Forcar
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

if ($code -ge 8) {
  Write-Host ("ERRO no robocopy (codigo {0})." -f $code) -ForegroundColor Red
  exit $code
}

# --- Modo Espelhar: remover do destino skills que nao existem mais no catalogo ---
if ($Espelhar) {
  $sourceNames = (Get-ChildItem $source -Directory).Name
  $orfas = Get-ChildItem $dest -Directory -ErrorAction SilentlyContinue |
    Where-Object { $sourceNames -notcontains $_.Name }

  if ($orfas.Count -eq 0) {
    Write-Host "Espelhar: nenhuma skill orfa no destino." -ForegroundColor Green
  } else {
    Write-Host ("Espelhar: {0} pasta(s) no destino que nao existem no catalogo:" -f $orfas.Count) -ForegroundColor Yellow
    foreach ($orfa in $orfas) {
      if ($Forcar) {
        Remove-Item -Recurse -Force $orfa.FullName
        Write-Host ("  removida: {0}" -f $orfa.Name) -ForegroundColor Yellow
      } else {
        $resp = Read-Host ("  remover '{0}'? (s/n)" -f $orfa.Name)
        if ($resp -eq "s" -or $resp -eq "S") {
          Remove-Item -Recurse -Force $orfa.FullName
          Write-Host ("  removida: {0}" -f $orfa.Name) -ForegroundColor Yellow
        } else {
          Write-Host ("  preservada: {0}" -f $orfa.Name) -ForegroundColor Green
        }
      }
    }
  }
  Write-Host ""
}

$count = (Get-ChildItem $dest -Directory -ErrorAction SilentlyContinue).Count
Write-Host ("OK - deploy concluido. {0} skills no destino." -f $count) -ForegroundColor Green
Write-Host "Reabra/reinicie a sessao do Claude no VS Code para ele reler as skills." -ForegroundColor Yellow
