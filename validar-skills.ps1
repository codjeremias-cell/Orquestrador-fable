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
#   E8  indices atuais cobrem todas as skills canonicas
#   E9  guia de chamadas existe somente dentro do catalogo
#   E10 agents/openai.yaml existe e cumpre o contrato de interface
#   E11 uso de 'allowed-tools' - a chave nao restringe (medido 2026-08-08, T68)
#   E12 'disallowed-tools' bloqueando escrita em skill cujo corpo manda gravar arquivo
#   E13 frontmatter sem '<' e '>' (o frontmatter entra no system prompt - vetor de injecao)
#   E14 sem README.md dentro da pasta da skill (documentacao vai em SKILL.md ou referencia/)
#   E16 entrada de Historico a partir de 2026-08-19 declara "N = <numero>" de
#       modificadores de obrigatoriedade auditados (PADRAO secao 12; T32)
#   A1  description sem "Acione"/"Use" (frases-gatilho - secao 4)
#   A2  referencia da Rede a skill inexistente no catalogo (links quebrados)
#   A3  pasta de referencia com nome fora do padrao ("references" em vez de "referencia")
#   A4  subpasta (referencia/, scripts/, assets/, evals/) vazia
#   A5  description a 90% ou mais do teto de 1024 (avisa antes de estourar o E4)
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

# E0 - o catalogo deve pertencer somente ao repositorio Git do cofre
$nestedGit = Join-Path $PSScriptRoot ".git"
if (Test-Path -LiteralPath $nestedGit) {
  Erro "Catalogo-Skills-Unificado" "repositorio .git interno detectado; use somente o .git da raiz do cofre"
}

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
    # A5 - banda de proximidade: avisa a partir de 90% do teto, antes de estourar.
    #      O E4 so fala depois que estourou, e estourar bloqueia o deploy.
    elseif ($descLimpa.Length -ge 922) {
      $folga = 1024 - $descLimpa.Length
      Aviso $nome ("description com {0} caracteres ({1}% do teto de 1024; folga de {2}) - PADRAO secao 4.6: proxima frase-gatilho so entra se abrir ramo novo" -f $descLimpa.Length, [Math]::Round($descLimpa.Length / 1024 * 100), $folga)
    }
    # A1 - frases-gatilho
    if ($descLimpa -notmatch '(Acione|Use |Usar |use sempre)') {
      Aviso $nome "description sem 'Acione'/'Use' (frases-gatilho da secao 4)"
    }
  }

  # E13 - colchete angular no frontmatter (restricao de seguranca da plataforma).
  #       O frontmatter e injetado no system prompt; '<' e '>' ali sao vetor de
  #       injecao, e a plataforma recusa (guia oficial Anthropic, Security
  #       restrictions). A proibicao vale SO no frontmatter - no corpo o padrao
  #       literal e obrigatorio (ex.: nome de migracao Flyway no springboot-entity).
  #       Achado com defeito real em producao (garimpo cienciaedados 2026-08-08, G03a).
  if ($fm -match '[<>]') {
    $trechos = [regex]::Matches($fm, '.{0,20}[<>].{0,20}') | ForEach-Object { $_.Value.Trim() } | Select-Object -First 2
    Erro $nome ("frontmatter contem '<' ou '>' (proibido - PADRAO secao 4.7; use prosa ou chaves): " + ($trechos -join ' | '))
  }

  # E14 - README.md dentro da pasta da skill. Toda documentacao vive em SKILL.md
  #       ou referencia/ (guia oficial Anthropic). Hoje o catalogo esta conforme;
  #       a checagem existe para nao regredir.
  $readmeSkill = Get-ChildItem $pasta.FullName -File | Where-Object { $_.Name -ieq "README.md" }
  if ($readmeSkill) {
    Erro $nome "README.md dentro da pasta da skill (proibido); mova o conteudo para SKILL.md ou referencia/"
  }

  # E16 - modificadores de obrigatoriedade auditados (PADRAO secao 12, T32).
  #       Toda entrada de Historico datada a partir do corte declara "N = <numero>":
  #       quantos modificadores de obrigatoriedade ("opcional", "se quiser", "pode")
  #       foram auditados naquela edicao. N = 0 e resposta valida e comum.
  #       POR QUE EXISTE: a regra estava no PADRAO desde 2026-07-12 e, medido na T25
  #       em 2026-08-18, NENHUMA skill a cumpria - o gatilho ("a proxima edicao de
  #       skill") disparou dezenas de vezes e a pratica nao aconteceu uma. Era prosa;
  #       aviso em prosa nao previne erro, entao virou trava.
  #       CORTE em 2026-08-19, e nao "hoje": em 2026-08-18 existiam 9 entradas de
  #       outras frentes escritas ANTES desta trava. Reprova-las seria regra
  #       retroativa - a trava vale para o futuro, que e o que ela pode mudar.
  #       Cobre tambem referencia/historico.md, porque 16 skills guardam o Historico la.
  $corteModificadores = '2026-08-19'
  $arquivosHistorico = @($skillMd)
  $historicoRef = Join-Path (Join-Path $pasta.FullName "referencia") "historico.md"
  if (Test-Path -LiteralPath $historicoRef) { $arquivosHistorico += $historicoRef }
  foreach ($arqHist in $arquivosHistorico) {
    foreach ($linhaHist in [System.IO.File]::ReadAllLines($arqHist, [System.Text.Encoding]::UTF8)) {
      if ($linhaHist -match '^\s*-\s+\*\*(\d{4}-\d{2}-\d{2})') {
        $dataEntrada = $Matches[1]
        # datas ISO comparam bem como texto - sem parse, sem cultura, sem surpresa
        if (($dataEntrada -ge $corteModificadores) -and ($linhaHist -notmatch 'N\s*=\s*\d')) {
          Erro $nome ("entrada de Historico de {0} sem 'N = <numero>' de modificadores auditados (PADRAO secao 12; em {1})" -f $dataEntrada, (Split-Path $arqHist -Leaf))
        }
      }
    }
  }

  # E11 - 'allowed-tools' NAO restringe. Medido em 2026-08-08 (T68), tres bracos
  #       com --allowedTools Write ligada igualmente: a skill com 'allowed-tools:
  #       Read' escreveu o arquivo, exatamente como a skill sem restricao nenhuma.
  #       So 'disallowed-tools' negou. Quem usar esta chave para exprimir fronteira
  #       publica uma trava que nao trava - e o defeito mais repetido desta casa.
  if ($fm -match '(?m)^allowed-tools:') {
    Erro $nome "usa 'allowed-tools', que NAO restringe (e auto-aprovacao, medido em 2026-08-08); para fronteira executavel use 'disallowed-tools'"
  }

  # E12 - 'disallowed-tools' bloqueando escrita nao pode conviver com corpo que
  #       manda gravar arquivo. Seria skill que passa no lint e morre em runtime,
  #       e a morte apareceria como recusa do modelo, nao como erro de autoria.
  #       Alcance honesto: rede heuristica de linha (verbo de gravacao + alvo com
  #       extensao), nao prova. Pega o caso que existe hoje - os tres testadores,
  #       que declaram "nao commita nada" E gravam relatorio + TSV.
  #       O verbo vai com fronteira de palavra de proposito: a primeira versao
  #       usava a raiz 'salv' e acusou o auditor pela secao "Salvaguardas". Falso
  #       positivo se disfarca de rigor - raiz de palavra nao e verbo.
  $dis = $null
  if ($fm -match '(?m)^disallowed-tools:\s*(.+)$') { $dis = $Matches[1].Trim() }
  if (($null -ne $dis) -and ($dis -match '(Write|Edit)')) {
    $conflito = @()
    foreach ($l in ($texto -split "`r?`n")) {
      if (($l -match '\b(gravar|gravado|gravados|gravada|gravadas|grave|salvar|salvo|salvos|salve)\b') -and ($l -match '(\.md|\.json|\.tsv|\.csv|ONDE_SAI|docs/)')) {
        $conflito += $l.Trim()
      }
    }
    if ($conflito.Count -gt 0) {
      $amostra = $conflito[0]
      if ($amostra.Length -gt 90) { $amostra = $amostra.Substring(0, 90) }
      Erro $nome ("declara 'disallowed-tools' com Write/Edit mas o corpo manda gravar arquivo em {0} linha(s) - a skill falharia em runtime. Primeira: '{1}'" -f $conflito.Count, $amostra)
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
        $foraDoCatalogo = @("testador-sigcot", "sentinela-testador", "escalaoper-testador", "gradup-testador")
        # gradup-testador entrou aqui em 2026-08-11 (T34): saiu do catalogo para
        # Portal-Treinamentos/.claude/skills/, onde e descoberta ao trabalhar no projeto.
        # Mesmo padrao das tres acima -- instancia de testador por projeto.
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

  # E10 - metadata de interface do Codex
  $openaiYaml = Join-Path $pasta.FullName "agents\openai.yaml"
  if (-not (Test-Path -LiteralPath $openaiYaml -PathType Leaf)) {
    Erro $nome "agents/openai.yaml ausente"
  } else {
    $metadata = [System.IO.File]::ReadAllText($openaiYaml, [System.Text.Encoding]::UTF8)
    if ($metadata -notmatch '(?m)^interface:\s*$') {
      Erro $nome "agents/openai.yaml sem bloco interface"
    }
    if ($metadata -notmatch '(?m)^\s{2}display_name:\s+"([^"]+)"\s*$') {
      Erro $nome "agents/openai.yaml sem display_name entre aspas"
    }
    if ($metadata -notmatch '(?m)^\s{2}short_description:\s+"([^"]+)"\s*$') {
      Erro $nome "agents/openai.yaml sem short_description entre aspas"
    } else {
      $shortDescription = $Matches[1]
      if ($shortDescription.Length -lt 25 -or $shortDescription.Length -gt 64) {
        Erro $nome ("short_description com {0} caracteres; esperado 25-64" -f $shortDescription.Length)
      }
    }
    if ($metadata -notmatch '(?m)^\s{2}default_prompt:\s+"([^"]+)"\s*$') {
      Erro $nome "agents/openai.yaml sem default_prompt entre aspas"
    } else {
      $defaultPrompt = $Matches[1]
      if (-not $defaultPrompt.Contains('$' + $nome)) {
        Erro $nome ("default_prompt nao menciona '${0}'" -f $nome)
      }
    }
  }
}

# E8 - mapas atuais devem acompanhar automaticamente as pastas canonicas
$catalogoReadme = Join-Path $PSScriptRoot "README.md"
$guiaChamadas = Join-Path $PSScriptRoot "GUIA-DE-CHAMADAS-SKILLS.md"
$textoReadme = [System.IO.File]::ReadAllText($catalogoReadme, [System.Text.Encoding]::UTF8)
$textoGuia = [System.IO.File]::ReadAllText($guiaChamadas, [System.Text.Encoding]::UTF8)
foreach ($nome in $nomesValidos) {
  $linkEsperado = "skills/{0}/SKILL" -f $nome
  if (-not $textoReadme.Contains($linkEsperado)) {
    Erro "README.md" ("indice nao referencia a skill '{0}'" -f $nome)
  }
  $linhaEsperada = "| **{0}** |" -f $nome
  if (-not $textoGuia.Contains($linhaEsperada)) {
    Erro "GUIA-DE-CHAMADAS-SKILLS.md" ("guia nao possui linha para a skill '{0}'" -f $nome)
  }
}
if ($textoReadme -match 'Indice clicavel \(as [0-9]+ skills\)') {
  Erro "README.md" "titulo do indice possui contagem operacional fixa"
}
if ($textoGuia -match 'Guia de Chamadas .+ [0-9]+ Skills') {
  Erro "GUIA-DE-CHAMADAS-SKILLS.md" "titulo possui contagem operacional fixa"
}

# E9 - a copia canonica do guia vive no catalogo; duplicata na raiz volta a divergir
$raizCofre = Split-Path $PSScriptRoot -Parent
foreach ($duplicata in @("GUIA-DE-CHAMADAS-SKILLS.md", "GUIA-DE-CHAMADAS-SKILLS.xlsx")) {
  if (Test-Path -LiteralPath (Join-Path $raizCofre $duplicata)) {
    Erro $duplicata "duplicata na raiz do cofre; mantenha somente a copia do Catalogo-Skills-Unificado"
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

# E15 - teto executavel do roteamento global.
#       A vertente empresa condicionou o acordo a que o teto de 2 KB seja TRAVA, nao prosa
#       (2026-08-09): "aviso em prosa nao previne erro". Vale para a fonte e para o destino.
#       CEGO A FIM DE LINHA desde 2026-08-09. A versao anterior media
#       (Get-Item).Length e comparava Get-FileHash dos bytes crus: o MESMO commit dava
#       1957 bytes numa arvore e 2000 em outra (43 linhas x CR), porque so o checkout
#       com eol=lf entrega LF. Resultado: o teto marcava 96% aqui e 98% ali, e a
#       conferencia de digest acusava divergencia sem um caractere ter mudado. O CR e
#       artefato de checkout, nao conteudo - entao normaliza-se antes de medir, e o
#       .gitattributes fixa eol=lf para o arquivo nao chegar torto.
function Get-ConteudoNormalizado([string]$Caminho) {
  $texto = [System.IO.File]::ReadAllText($Caminho)
  return $texto -replace "`r`n", "`n" -replace "`r", "`n"
}
function Get-DigestNormalizado([string]$Caminho) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes((Get-ConteudoNormalizado $Caminho))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { return ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "" }
  finally { $sha.Dispose() }
}

$roteamento = Join-Path $PSScriptRoot "roteamento-global.md"
if (Test-Path $roteamento) {
  $brutos = (Get-Item $roteamento).Length
  $bytes  = [System.Text.Encoding]::UTF8.GetByteCount((Get-ConteudoNormalizado $roteamento))
  if ($brutos -ne $bytes) {
    Aviso "roteamento-global" ("roteamento-global.md esta com CRLF neste checkout ({0} bytes em disco, {1} normalizados) - o teto usa o normalizado; confira eol=lf no .gitattributes" -f $brutos, $bytes)
  }
  if ($bytes -gt 2048) {
    Erro "roteamento-global" ("roteamento-global.md com {0} bytes normalizados (maximo 2048) - ele entra em TODO turno de TODA sessao; corte rota, nao aumente o teto" -f $bytes)
  } elseif ($bytes -gt 1843) {
    Aviso "roteamento-global" ("roteamento-global.md com {0} bytes ({1}% do teto de 2048) - proxima rota so entra se abrir ramo novo" -f $bytes, [Math]::Round($bytes / 2048 * 100))
  }
  # Paridade fonte -> destino. Endurecida em 2026-08-20, e os dois ramos existem
  # porque AUSENTE e DIVERGENTE significam coisas diferentes:
  #
  #   ausente    = estado inicial legitimo (maquina nova, CI, checkout limpo).
  #                Avisa, nao reprova -- reprovar puniria quem ainda nao derivou
  #                pela primeira vez.
  #   divergente = a fonte NAO VALE NA PRATICA. O modelo le o destino, nunca esta
  #                fonte; rota acrescentada aqui e nao derivada la e rota que nao
  #                existe. Isso e ERRO, e antes era so aviso.
  #
  # O `if` sem `else` era o pior dos dois: destino ausente passava sem uma linha,
  # e "validador verde" convivia com o canal de 56 skills inexistente na maquina.
  #
  # E o deploy NAO cobre isto: `deploy-skills.ps1` tem ZERO ocorrencias de
  # `roteamento-global` (medido em 2026-08-20). A derivacao e manual, e e por ser
  # manual que ela precisa de trava com dente.
  $destino = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
  if (-not (Test-Path $destino)) {
    Aviso "roteamento-global" ("~/.claude/CLAUDE.md NAO EXISTE - o roteamento nao chega a nenhuma sessao; derive copiando {0} para {1}" -f $roteamento, $destino)
  } elseif ((Get-DigestNormalizado $roteamento) -ne (Get-DigestNormalizado $destino)) {
    Erro "roteamento-global" ("~/.claude/CLAUDE.md divergente da fonte roteamento-global.md - o modelo le o DESTINO, entao rota que esta so na fonte nao existe; derive copiando {0} para {1}" -f $roteamento, $destino)
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
