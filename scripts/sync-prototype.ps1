[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoPath = Split-Path -Parent $PSScriptRoot
$gitPath = Join-Path $repoPath ".git"
$logPath = Join-Path $gitPath "prototype-sync.log"
$mutex = New-Object System.Threading.Mutex($false, "Local\MarketingAntiCheatPrototypeSync")
$hasLock = $false

function Write-SyncLog {
    param([string]$Message)

    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
}

function Invoke-GitCommand {
    param([string[]]$Arguments)

    $output = & git @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($output) {
        Add-Content -LiteralPath $logPath -Value ($output | Out-String) -Encoding UTF8
    }
    if ($exitCode -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $exitCode"
    }
}

try {
    $hasLock = $mutex.WaitOne(0)
    if (-not $hasLock) {
        exit 0
    }

    if (-not (Test-Path -LiteralPath $gitPath)) {
        throw "Git repository not found: $repoPath"
    }

    Set-Location -LiteralPath $repoPath
    Write-SyncLog "Sync check started."

    $trackedFiles = @(
        ".gitignore",
        "README.md",
        "index.html",
        "营销反作弊系统原型.html",
        "scripts/sync-prototype.ps1",
        "scripts/install-auto-sync.ps1"
    )

    Invoke-GitCommand -Arguments (@("add", "--") + $trackedFiles)

    & git diff --cached --quiet --
    $diffExitCode = $LASTEXITCODE
    if ($diffExitCode -eq 0) {
        Write-SyncLog "No changes detected."
        exit 0
    }
    if ($diffExitCode -ne 1) {
        throw "Unable to inspect staged changes (exit code $diffExitCode)."
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Invoke-GitCommand -Arguments @("commit", "-m", "chore: sync prototype $timestamp")
    Invoke-GitCommand -Arguments @("pull", "--rebase", "origin", "main")
    Invoke-GitCommand -Arguments @("push", "origin", "main")
    Write-SyncLog "Changes pushed successfully."
}
catch {
    if (Test-Path -LiteralPath $gitPath) {
        Write-SyncLog "ERROR: $($_.Exception.Message)"
    }
    exit 1
}
finally {
    if ($hasLock) {
        $mutex.ReleaseMutex()
    }
    $mutex.Dispose()
}

