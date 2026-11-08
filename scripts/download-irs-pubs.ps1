# Downloads the IRS publications used by the knowledge base from irs.gov.
# Run in PowerShell:  .\scripts\download-irs-pubs.ps1
# Files go to data\irs\ (ignored by git; they are not stored in the repository).

$ErrorActionPreference = "Stop"

$pubs = @(
    "p17",    "p334",  "p463",  "p4681", "p501",  "p502",  "p505",
    "p523",   "p526",  "p527",  "p544",  "p550",  "p551",  "p575",
    "p587",   "p590a", "p590b", "p596",  "p915",  "p936",  "p946",
    "p969",   "p970",  "i1040gi", "i1040s8"
)

$outDir = Join-Path $PSScriptRoot "..\data\irs"
New-Item -ItemType Directory -Force $outDir | Out-Null

foreach ($p in $pubs) {
    $url  = "https://www.irs.gov/pub/irs-pdf/$p.pdf"
    $dest = Join-Path $outDir "$p.pdf"
    if (Test-Path $dest) { Write-Host "skip  $p (already downloaded)"; continue }
    try {
        Invoke-WebRequest $url -OutFile $dest -UseBasicParsing
        Write-Host "ok    $p"
    } catch {
        Write-Warning "failed $p : $($_.Exception.Message)"
    }
}

Write-Host "`nSaved to $((Resolve-Path $outDir).Path)"
Write-Host "Note: irs.gov always serves the latest revision. Check each PDF's cover says tax year 2025."
