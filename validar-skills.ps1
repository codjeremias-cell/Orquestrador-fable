# validar-skills.ps1
# Lint automatizado do catalogo - checa cada skill contra o DoD do PADRAO-DE-AUTORIA secao 9.
# Rode antes do deploy-skills.ps1. Sai com codigo 1 se houver ERRO (AVISO nao bloqueia).
#
# Arquivo propositalmente em ASCII puro: o Windows PowerShell 5.1 le .ps1 sem BOM
# como ANSI e caracteres especiais (acentos, travessao) quebram o parser.
#
# Checagens (E = erro, A = aviso):
#   E1  SKILL.md existe na pasta da skill
#   E2  frontmatter presente (--- ... ---) com name: e description:
#   E3  name em kebab-case (minusculas, sem acento) e igual ao nome da pasta
#   E4  description com ate 1024 caracteres
#   E5  arquivo termina em quebra de linha e a ultima linha nao aparenta truncamento
#   E6  sem caractere de substituicao U+FFFD (corrupcao de encoding)
#   E7  bloco "Rede da skill" presente
#   A1  description sem "Acione"/"Use" (frases-gatilho - secao 4)
#   A2  referencia da Rede a skill inexistente no catalogo (links quebrados)
#   A3  pasta de referencia com nome fora do padrao ("references" em vez de "referencia")
#   A4  subpasta (referencia/, scripts/, assets/, evals/) vazia
#
# Uso: powershell -ExecutionPolicy Bypass -File .\validar-skills.ps1

$ErrorActionPreference = "Stop"
$skillsDir = Join-Path $PSScriptRoot "skills"

if (-not (Test-Path $skillsDir)) {
  Write-Host "ERRO: pasta skills/ nao encontrada em $PSScriptRoot" -ForegroundColor Red
  exit 1
}

$erros = 0
$avisos = 0
$pastas = Get-ChildItem $skillsDir -Directory | Sort-Object Name
$nomesValidos = $pastas.Name

function Erro([string]$skill, [string]$msg) {
  Write-Host ("  [ERRO ] {0}: {1}" -f $skill, $msg) -ForegroundColor Red
  $script:erros++
}
function Aviso([string]$skill, [string]$msg) {
  Write-Host ("  [AVISO] {0}: {1}" -f $skill, $msg) -ForegroundColor Yellow
  $script:avisos++
}

Write-Host ""
Write-Host ("Validando {0} skills em {1}" -f $pastas.Count, $skillsDir) -ForegroundColor Cyan
Write-Host ""

foreach ($pasta in $pastas) {
  $nome = $pasta.Name
  $skillMd = Join-Path $pasta.FullName "SKILL.md"

  # E1 - SKILL.md existe
  if (-not (Test-Path $skillMd)) {
    Erro $nome "SKILL.md nao encontrado"
    continue
  }

  $texto = [System.IO.File]::ReadAllText($skillMd, [System.Text.Encoding]::UTF8)

  # E6 - corrupcao de encoding
  if ($texto.Contains([string][char]0xFFFD)) {
    Erro $nome "caractere de substituicao U+FFFD encontrado (encoding corrompido)"
  }

  # E5 - truncamento: arquivo deve terminar em quebra de linha
  if (-not ($texto.EndsWith("`n"))) {
    Erro $nome "arquivo nao termina em quebra de linha (possivel truncamento)"
  }
  # E5b - ultima linha nao-vazia terminando em ':', ',', '(', travessao (U+2014)
  #       ou crase + 1 letra = suspeita de corte
  $linhas = $texto -split "`r?`n" | Where-Object { $_.Trim() -ne "" }
  if ($linhas.Count -gt 0) {
    $ultima = $linhas[-1].TrimEnd()
    if ($ultima -match ('(:|,|\(|' + [char]0x2014 + '|`[a-z])$')) {
      $trecho = $ultima.Substring([Math]::Max(0, $ultima.Length - 40))
      Aviso $nome ("ultima linha suspeita de truncamento: '..." + $trecho + "'")
    }
  }

  # E2 - frontmatter
  $fm = $null
  if ($texto -match '(?s)^---\r?\n(.*?)\r?\n---') { $fm = $Matches[1] }
  if ($null -eq $fm) {
    Erro $nome "frontmatter (--- ... ---) nao encontrado"
    continue
  }

  # name:
  $fmName = $null
  if ($fm -match '(?m)^name:\s*(.+)$') { $fmName = $Matches[1].Trim() }
  if ($null -eq $fmName) {
    Erro $nome "frontmatter sem 'name:'"
  } else {
    # E3 - kebab-case e igual a pasta
    if ($fmName -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
      Erro $nome ("name '{0}' nao esta em kebab-case minusculo sem acento" -f $fmName)
    }
    if ($fmName -ne $nome) {
      Erro $nome ("name '{0}' diferente do nome da pasta '{1}'" -f $fmName, $nome)
    }
  }

  # description:
  $desc = $null
  if ($fm -match '(?s)description:\s*(.*?)(?=\r?\n[a-z_-]+:|\z)') { $desc = $Matches[1].Trim() }
  if ($null -eq $desc -or $desc -eq "") {
    Erro $nome "frontmatter sem 'description:'"
  } else {
    # remove aspas envolventes para contagem justa
    $descLimpa = $desc.Trim('"')
    # E4 - ate 1024 caracteres
    if ($descLimpa.Length -gt 1024) {
      Erro $nome ("description com {0} caracteres (maximo 1024 - PADRAO secao 4.6: divida a skill)" -f $descLimpa.Length)
    }
    # A1 - frases-gatilho
    if ($descLimpa -notmatch '(Acione|Use |Usar |use sempre)') {
      Aviso $nome "description sem 'Acione'/'Use' (frases-gatilho da secao 4)"
    }
  }

  # E7 - bloco Rede da skill
  if ($texto -notmatch 'Rede da skill') {
    Erro $nome "bloco 'Rede da skill' ausente (Selo Lendario, PADRAO secao 10.2)"
  } else {
    # A2 - links da Rede para skills inexistentes
    $blocoRede = ($texto -split 'Rede da skill', 2)[1]
    $refs = [regex]::Matches($blocoRede, '`([a-z0-9]+(?:-[a-z0-9]+)+)`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    foreach ($ref in $refs) {
      if ($nomesValidos -notcontains $ref) {
        # instancias project-local conhecidas ficam fora do catalogo - so avisa se nao for uma delas
        $foraDoCatalogo = @("testador-sigcot", "sentinela-testador", "escalaoper-testador")
        if ($foraDoCatalogo -notcontains $ref -and $ref -match '^(java|javafx|spec|spring|springboot|web|mobile|desktop|design|frontend|orquestrador|testador|qa|dev|arquiteto|auditor|consultor|especialista|inovacao|memoria|docs|estado|requisitos|assistente|gradup)') {
          Aviso $nome ("Rede referencia '{0}', que nao existe no catalogo" -f $ref)
        }
      }
    }
  }

  # A3 - pasta references em vez de referencia
  if (Test-Path (Join-Path $pasta.FullName "references")) {
    Aviso $nome "pasta 'references/' fora do padrao - renomear para 'referencia/' (PADRAO secao 7)"
  }

  # A4 - subpastas vazias
  foreach ($sub in @("referencia", "scripts", "assets", "evals")) {
    $subPath = Join-Path $pasta.FullName $sub
    if ((Test-Path $subPath) -and ((Get-ChildItem $subPath -Recurse -File).Count -eq 0)) {
      Aviso $nome ("subpasta '{0}/' existe mas esta vazia (PADRAO secao 6: armadilhas)" -f $sub)
    }
  }
}

# --- Validacao dos documentos-raiz: fim de arquivo integro ---
Write-Host ""
foreach ($doc in @("README.md", "PADRAO-DE-AUTORIA.md", "REGRAS-DE-OURO.md", "ROADMAP.md")) {
  $docPath = Join-Path $PSScriptRoot $doc
  if (Test-Path $docPath) {
    $t = [System.IO.File]::ReadAllText($docPath, [System.Text.Encoding]::UTF8)
    if (-not ($t.EndsWith("`n"))) {
      Aviso $doc "nao termina em quebra de linha (conferir truncamento)"
    }
    if ($t.Contains([string][char]0xFFFD)) {
      Erro $doc "caractere U+FFFD (encoding corrompido)"
    }
  }
}

Write-Host ""
if ($erros -gt 0) {
  Write-Host ("REPROVADO: {0} erro(s), {1} aviso(s)." -f $erros, $avisos) -ForegroundColor Red
  exit 1
} elseif ($avisos -gt 0) {
  Write-Host ("APROVADO COM RESSALVAS: 0 erros, {0} aviso(s)." -f $avisos) -ForegroundColor Yellow
  exit 0
} else {
  Write-Host "APROVADO: catalogo integro - todas as checagens passaram." -ForegroundColor Green
  exit 0
}
