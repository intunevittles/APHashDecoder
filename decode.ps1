# Get script directory
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$hashDir = Join-Path $baseDir "hash"

Write-Host "================================"
Write-Host "Finding latest CSV..."
Write-Host "================================"
Write-Host ""

# Get newest CSV
$file = Get-ChildItem $hashDir -Filter *.csv |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

if (-not $file) {
    Write-Host "No CSV found in $hashDir"
    exit
}

Write-Host "Using CSV:"
Write-Host $file.FullName
Write-Host ""

# Process each device
Import-Csv $file.FullName | ForEach-Object {

    $serial = $_."Device Serial Number"
    $hash   = $_."Hardware Hash"

    # Skip bad rows
    if ([string]::IsNullOrWhiteSpace($hash)) {
        return
    }

    Write-Host "--------------------------------"
    Write-Host "Serial: $serial"
    Write-Host "--------------------------------"

    # Run decode
    & "$baseDir\oa3tool.exe" "/DecodeHwHash:$hash"

    Write-Host ""
}

Write-Host "Done."
