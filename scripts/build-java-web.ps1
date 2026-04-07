param(
    [switch]$TaskOnly,
    [switch]$PriorityOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$taskModulePath = Join-Path $repoRoot "modules\java-task-manager"
$priorityModulePath = Join-Path $repoRoot "modules\java-priority-calculator"

function Invoke-MavenPackage {
    param([string]$ModulePath)

    Push-Location $ModulePath
    try {
        mvn -DskipTests package
    }
    finally {
        Pop-Location
    }
}

if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    throw "Maven no esta instalado o no esta disponible en PATH."
}

$buildTask = $true
$buildPriority = $true

if ($TaskOnly) {
    $buildPriority = $false
}

if ($PriorityOnly) {
    $buildTask = $false
}

if ($buildTask) {
    Invoke-MavenPackage -ModulePath $taskModulePath
}

if ($buildPriority) {
    Invoke-MavenPackage -ModulePath $priorityModulePath
}

Write-Host "Build Java web finalizado. Revisa assets/generated para los archivos bridge JS." -ForegroundColor Green
