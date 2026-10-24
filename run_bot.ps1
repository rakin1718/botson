$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$botDir = Join-Path $root "bots\telegram-bot"
$envFile = Join-Path $botDir ".env.local"
$exampleFile = Join-Path $botDir ".env.local.example"
$venvPython = Join-Path $root ".venv\Scripts\python.exe"

Set-Location $root

if (-not (Get-Command "py.exe" -ErrorAction SilentlyContinue)) {
    Write-Error "Python 3.13 bulunamadi. Python 3.13 kurup tekrar run_bot.bat dosyasini acin."
    exit 1
}

$env:PYTHONUTF8 = "1"
cmd.exe /d /c "py -3.13 --version >nul 2>nul"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Python 3.13 bulunamadi. py install 3.13 ile kuruluyor..."
    & cmd.exe /d /c "py install 3.13"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Python 3.13 otomatik kurulamadi. Internet baglantisini kontrol edip 'py install 3.13' komutunu calistirin."
        exit 1
    }

    cmd.exe /d /c "py -3.13 --version >nul 2>nul"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Python kuruldu ancak py -3.13 ile bulunamadi. 'py list' ile kurulu runtime'lari kontrol edin."
        exit 1
    }
}

if (-not (Test-Path -LiteralPath $envFile)) {
    Copy-Item -LiteralPath $exampleFile -Destination $envFile
    Write-Host "Gizli ayar sablonu olusturuldu: bots\telegram-bot\.env.local"
}

function Import-LocalEnvironment {
    foreach ($rawLine in Get-Content -LiteralPath $envFile) {
        $line = $rawLine -replace "^\uFEFF", ""
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith("#")) {
            continue
        }
        if ($line -match "^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$") {
            $name = $Matches[1]
            $value = $Matches[2].Trim()
        } else {
            Write-Error "Gecersiz ayar satiri .env.local dosyasinda."
            exit 1
        }
        if ($value.Length -ge 2 -and
            (($value.StartsWith('"') -and $value.EndsWith('"')) -or
             ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

Import-LocalEnvironment
$required = @(
    "TELEGRAM_BOT_TOKEN",
    "TELEGRAM_SENDER_BOT_TOKEN",
    "TELEGRAM_OWNER_ID",
    "SESSION_SECRET"
)
$missing = @($required | Where-Object {
    [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($_, "Process"))
})
if ($missing.Count -gt 0) {
    Write-Host ("Once .env.local dosyasindaki su alanlari doldurun: " + ($missing -join ", "))
    Write-Host "Not Defteri acilacak. Degerleri kaydedip kapattiginizda baslatma devam eder."
    Start-Process -FilePath "notepad.exe" -ArgumentList "`"$envFile`"" -Wait
    foreach ($name in $required) {
        [Environment]::SetEnvironmentVariable($name, $null, "Process")
    }
    Import-LocalEnvironment
    $missing = @($required | Where-Object {
        [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($_, "Process"))
    })
    if ($missing.Count -gt 0) {
        Write-Error (".env.local dosyasinda hala bos ayarlar var: " + ($missing -join ", "))
        exit 1
    }
}

Write-Host "Ayni Telegram tokenlariyla yayindaki bot calisiyorsa once onu durdurun."
Write-Host "Telegram ayni tokenla iki polling botuna izin vermez."
$confirm = Read-Host "Yayindaki bot durduruldu mu? (E/H)"
if ($confirm -notmatch "^(E|e|Y|y)$") {
    Write-Host "Baslatma iptal edildi."
    exit 0
}

if (-not (Test-Path -LiteralPath $venvPython)) {
    & py.exe -3.13 -m venv (Join-Path $root ".venv")
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Python sanal ortami olusturulamadi."
        exit 1
    }
}

& $venvPython -m pip install --disable-pip-version-check -r (Join-Path $botDir "requirements.txt")
if ($LASTEXITCODE -ne 0) {
    Write-Error "Bot bagimliliklari kurulamadi."
    exit 1
}

# Keep a local run isolated from any machine-wide production database URL.
[Environment]::SetEnvironmentVariable("DATABASE_URL", $null, "Process")
& $venvPython (Join-Path $botDir "main.py")
exit $LASTEXITCODE
