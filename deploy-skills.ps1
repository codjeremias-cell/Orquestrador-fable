# deploy-skills.ps1
# Sincroniza o catalogo canonico com os runtimes do Claude e do Codex.
# Compativel com Windows PowerShell 5.1. Mantido em ASCII puro.
#
# Exemplos:
#   Global Claude (comportamento historico):
#     .\deploy-skills.ps1
#
#   Claude + Codex em um projeto:
#     .\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos
#
#   Verificar sem escrever e exigir espelho exato:
#     .\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos -Espelhar -SomenteVerificar
#
#   Remover skills orfas no destino sem perguntar:
#     .\deploy-skills.ps1 -ProjectPath "C:\caminho\do\projeto" -Runtime Ambos -Espelhar -Forcar

[CmdletBinding()]
param(
  [string]$ProjectPath = "",

  [ValidateSet("Claude", "Codex", "Ambos")]
  [string]$Runtime = "Claude",

  [switch]$Espelhar,
  [switch]$Forcar,
  [switch]$SomenteVerificar
)

$ErrorActionPreference = "Stop"
$source = Join-Path $PSScriptRoot "skills"
$validator = Join-Path $PSScriptRoot "validar-skills.ps1"

# Pastas do destino que NAO vem deste catalogo e nao podem ser tratadas como
# orfas. Sem esta lista, `-Espelhar -Forcar` executa `Remove-Item -Recurse
# -Force` nelas: o comando que o CLAUDE.md manda rodar apos qualquer mudanca da
# fonte apagaria, em silencio, uma skill implantada por outra frente.
#
# `ceo-maestro` e a porta unica da `Estrutura Final de Skills` (implantada em
# 2026-07-27). As tres pastas seguintes existem porque os caminhos relativos de
# dentro dela apontam para a RAIZ da estrutura, um nivel acima da skill: o
# destino reproduz essa raiz para que `../regras-de-ouro/REGRAS-DE-OURO.md`,
# `../../ORGANOGRAMA.md` e `_compartilhado/` resolvam como no cofre. Nenhuma
# delas tem SKILL.md, entao nenhuma vira skill invocavel.
$preservarSempre = @("ceo-maestro", "planejador-estrutura", "regras-de-ouro", "_compartilhado", "registros")

function Assert-PathUnderRoot {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Root
  )

  $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  $pathFull = [System.IO.Path]::GetFullPath($Path)
  if (-not $pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Caminho fora da raiz autorizada: $pathFull"
  }
}

function Get-SkillDirectories {
  param([Parameter(Mandatory = $true)][string]$Root)

  if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    return @()
  }

  return @(Get-ChildItem -LiteralPath $Root -Directory -Force |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf } |
    Sort-Object Name)
}

function Get-FileMap {
  param([Parameter(Mandatory = $true)][string]$Root)

  $map = @{}
  if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    return $map
  }

  $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
  foreach ($file in Get-ChildItem -LiteralPath $rootFull -Recurse -File -Force) {
    $relative = $file.FullName.Substring($rootFull.Length).TrimStart('\', '/').Replace('\', '/')
    $map[$relative] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
  }
  return $map
}

function Get-Targets {
  $targets = [System.Collections.Generic.List[object]]::new()
  $runtimes = if ($Runtime -eq "Ambos") { @("Claude", "Codex") } else { @($Runtime) }

  if ($ProjectPath -ne "") {
    $base = [System.IO.Path]::GetFullPath($ProjectPath)
  } else {
    $base = [System.IO.Path]::GetFullPath($env:USERPROFILE)
  }

  foreach ($runtimeName in $runtimes) {
    if ($runtimeName -eq "Claude") {
      $relative = ".claude\skills"
    } elseif ($ProjectPath -ne "") {
      $relative = ".agents\skills"
    } else {
      $relative = ".codex\skills"
    }

    $targets.Add([pscustomobject]@{
      Runtime = $runtimeName
      Path = Join-Path $base $relative
    })
  }

  return $targets
}

function Compare-Target {
  param(
    [Parameter(Mandatory = $true)][string]$TargetRoot,
    [Parameter(Mandatory = $true)][bool]$Strict
  )

  $errors = [System.Collections.Generic.List[string]]::new()
  $warnings = [System.Collections.Generic.List[string]]::new()
  $sourceSkills = @(Get-SkillDirectories -Root $source)
  $targetSkills = @(Get-SkillDirectories -Root $TargetRoot)
  $sourceNames = @($sourceSkills | ForEach-Object { $_.Name })
  $targetNames = @($targetSkills | ForEach-Object { $_.Name })

  foreach ($sourceSkill in $sourceSkills) {
    $targetSkillPath = Join-Path $TargetRoot $sourceSkill.Name
    if (-not (Test-Path -LiteralPath $targetSkillPath -PathType Container)) {
      $errors.Add("skill ausente: $($sourceSkill.Name)")
      continue
    }

    $sourceMap = Get-FileMap -Root $sourceSkill.FullName
    $targetMap = Get-FileMap -Root $targetSkillPath

    foreach ($relative in $sourceMap.Keys) {
      if (-not $targetMap.ContainsKey($relative)) {
        $errors.Add("arquivo ausente: $($sourceSkill.Name)/$relative")
      } elseif ($sourceMap[$relative] -ne $targetMap[$relative]) {
        $errors.Add("hash divergente: $($sourceSkill.Name)/$relative")
      }
    }

    foreach ($relative in $targetMap.Keys) {
      if (-not $sourceMap.ContainsKey($relative)) {
        $errors.Add("arquivo extra: $($sourceSkill.Name)/$relative")
      }
    }
  }

  $extraSkills = @($targetNames | Where-Object {
    $sourceNames -notcontains $_ -and $preservarSempre -notcontains $_
  })
  foreach ($extraSkill in $extraSkills) {
    if ($Strict) {
      $errors.Add("skill orfa: $extraSkill")
    } else {
      $warnings.Add("skill local preservada: $extraSkill")
    }
  }

  foreach ($guardada in @($targetNames | Where-Object { $preservarSempre -contains $_ })) {
    $warnings.Add("preservada por contrato (fonte externa a este catalogo): $guardada")
  }

  return [pscustomobject]@{
    SourceCount = $sourceSkills.Count
    TargetCount = $targetSkills.Count
    Errors = @($errors)
    Warnings = @($warnings)
  }
}

function Write-Comparison {
  param(
    [Parameter(Mandatory = $true)]$Target,
    [Parameter(Mandatory = $true)]$Comparison
  )

  foreach ($warning in $Comparison.Warnings) {
    Write-Host ("  [AVISO] {0}: {1}" -f $Target.Runtime, $warning) -ForegroundColor Yellow
  }
  foreach ($errorMessage in $Comparison.Errors) {
    Write-Host ("  [ERRO ] {0}: {1}" -f $Target.Runtime, $errorMessage) -ForegroundColor Red
  }

  if ($Comparison.Errors.Count -eq 0) {
    Write-Host ("  [OK] {0}: {1} skills verificadas em {2}" -f $Target.Runtime, $Comparison.SourceCount, $Target.Path) -ForegroundColor Green
  }
}

if (-not (Test-Path -LiteralPath $source -PathType Container)) {
  throw "Pasta de origem nao encontrada: $source"
}
if (-not (Test-Path -LiteralPath $validator -PathType Leaf)) {
  throw "Validador nao encontrado: $validator"
}

# --- roteamento-global -> ~/.claude/CLAUDE.md ---------------------------------
#
# Acrescentado em 2026-08-20. Ate aqui o deploy NAO tocava este arquivo -- zero
# ocorrencias de "roteamento-global" no script inteiro. A derivacao era manual e
# ninguem sabia: numa sessao de 2026-08-20 o deploy rodou DUAS vezes e o aviso de
# divergencia continuou aparecendo, porque o deploy nunca teve nada a ver com isso.
#
# POR QUE IMPORTA: o modelo le o DESTINO (~/.claude/CLAUDE.md), nunca a fonte.
# Rota acrescentada no catalogo e nao derivada la e rota que NAO EXISTE em sessao
# nenhuma -- e este arquivo e o unico canal de acionamento por gatilho de 56 das
# 79 entradas da listagem de skills (medido em 2026-08-20).
#
# POR QUE ANTES DA VALIDACAO, e nao depois: o validar-skills.ps1 REPROVA quando o
# destino diverge (endurecido no mesmo dia). Com a derivacao depois, as duas
# travas se anulavam -- o deploy era bloqueado pela divergencia que ele mesmo
# existe para corrigir. Deadlock medido e desfeito: derivar primeiro, validar
# depois, e a validacao passa a CONFERIR o resultado da derivacao.
#
# O destino e GLOBAL por natureza, entao a derivacao acontece nas duas formas de
# invocacao (com e sem -ProjectPath). E idempotente: so escreve quando o conteudo
# normalizado difere, e sempre com backup do anterior.
$roteamentoFonte = Join-Path $PSScriptRoot "roteamento-global.md"
if (Test-Path $roteamentoFonte) {
  $roteamentoDestino = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
  Write-Host ""
  Write-Host "Roteamento global" -ForegroundColor Cyan
  Write-Host ("  Fonte  : {0}" -f $roteamentoFonte)
  Write-Host ("  Destino: {0}" -f $roteamentoDestino)

  # Comparacao pelo conteudo NORMALIZADO (CRLF -> LF), no mesmo criterio do
  # validar-skills.ps1: EOL de checkout nao e divergencia de conteudo.
  $textoFonte = [System.IO.File]::ReadAllText($roteamentoFonte).Replace("`r`n", "`n")
  $existe = Test-Path $roteamentoDestino
  $iguais = $false
  if ($existe) {
    $textoDestino = [System.IO.File]::ReadAllText($roteamentoDestino).Replace("`r`n", "`n")
    $iguais = ($textoFonte -eq $textoDestino)
  }

  if ($iguais) {
    Write-Host "  ja em paridade" -ForegroundColor Green
  } elseif ($SomenteVerificar) {
    if ($existe) {
      Write-Host "  DIVERGENTE - rode sem -SomenteVerificar para derivar" -ForegroundColor Yellow
    } else {
      Write-Host "  AUSENTE - rode sem -SomenteVerificar para derivar" -ForegroundColor Yellow
    }
  } else {
    if ($existe) {
      $backup = "$roteamentoDestino.bak"
      Copy-Item -LiteralPath $roteamentoDestino -Destination $backup -Force
      Write-Host ("  backup do anterior: {0}" -f $backup)
    } else {
      $pastaDestino = Split-Path $roteamentoDestino -Parent
      if (-not (Test-Path $pastaDestino)) {
        New-Item -ItemType Directory -Path $pastaDestino -Force | Out-Null
      }
    }
    Copy-Item -LiteralPath $roteamentoFonte -Destination $roteamentoDestino -Force
    $conferido = [System.IO.File]::ReadAllText($roteamentoDestino).Replace("`r`n", "`n")
    if ($conferido -eq $textoFonte) {
      Write-Host ("  derivado ({0} bytes)" -f (Get-Item $roteamentoDestino).Length) -ForegroundColor Green
    } else {
      Write-Host "  FALHOU: destino nao confere com a fonte apos a copia" -ForegroundColor Red
      exit 1
    }
  }
}

Write-Host ""
Write-Host "Validacao pre-deploy do catalogo" -ForegroundColor Cyan
& $validator
if ($LASTEXITCODE -ne 0) {
  throw "Catalogo reprovado. Deploy bloqueado."
}

$targets = @(Get-Targets)
$sourceSkills = @(Get-SkillDirectories -Root $source)

if (-not $SomenteVerificar) {
  $robocopy = Get-Command robocopy -ErrorAction SilentlyContinue
  if ($null -eq $robocopy) {
    throw "robocopy nao encontrado. O deploy requer Windows; use -SomenteVerificar em outros sistemas."
  }

  foreach ($target in $targets) {
    Write-Host ""
    Write-Host ("Deploy {0}" -f $target.Runtime) -ForegroundColor Cyan
    Write-Host ("  Origem : {0}" -f $source)
    Write-Host ("  Destino: {0}" -f $target.Path)
    New-Item -ItemType Directory -Path $target.Path -Force | Out-Null

    foreach ($sourceSkill in $sourceSkills) {
      $destinationSkill = Join-Path $target.Path $sourceSkill.Name
      Assert-PathUnderRoot -Path $destinationSkill -Root $target.Path
      robocopy $sourceSkill.FullName $destinationSkill /MIR /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
      $code = $LASTEXITCODE
      if ($code -ge 8) {
        throw "Falha ao copiar '$($sourceSkill.Name)' para '$($target.Path)' (robocopy $code)."
      }
    }

    if ($Espelhar) {
      $sourceNames = @($sourceSkills | ForEach-Object { $_.Name })
      $orphans = @(Get-SkillDirectories -Root $target.Path | Where-Object {
        $sourceNames -notcontains $_.Name -and $preservarSempre -notcontains $_.Name
      })
      foreach ($guardada in @(Get-SkillDirectories -Root $target.Path | Where-Object { $preservarSempre -contains $_.Name })) {
        Write-Host ("  preservada por contrato: {0} (fonte externa a este catalogo)" -f $guardada.Name) -ForegroundColor Cyan
      }
      foreach ($orphan in $orphans) {
        Assert-PathUnderRoot -Path $orphan.FullName -Root $target.Path
        $remove = $Forcar
        if (-not $Forcar) {
          $answer = Read-Host ("  remover skill orfa '{0}' de {1}? (s/n)" -f $orphan.Name, $target.Runtime)
          $remove = $answer -eq "s" -or $answer -eq "S"
        }

        if ($remove) {
          Remove-Item -LiteralPath $orphan.FullName -Recurse -Force
          Write-Host ("  removida: {0}" -f $orphan.Name) -ForegroundColor Yellow
        } else {
          Write-Host ("  preservada: {0}" -f $orphan.Name) -ForegroundColor Green
        }
      }
    }
  }
}

Write-Host ""
Write-Host "Verificacao de paridade por SHA-256" -ForegroundColor Cyan
$totalErrors = 0
foreach ($target in $targets) {
  $comparison = Compare-Target -TargetRoot $target.Path -Strict ([bool]$Espelhar)
  Write-Comparison -Target $target -Comparison $comparison
  $totalErrors += $comparison.Errors.Count
}

if ($totalErrors -gt 0) {
  Write-Host ""
  Write-Host ("REPROVADO: {0} divergencia(s) entre fonte e runtime." -f $totalErrors) -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host ("APROVADO: {0} skills do catalogo estao sincronizadas nos runtimes selecionados." -f $sourceSkills.Count) -ForegroundColor Green
if (-not $SomenteVerificar) {
  Write-Host "Reabra/reinicie as sessoes para recarregar as skills." -ForegroundColor Yellow
}
exit 0
