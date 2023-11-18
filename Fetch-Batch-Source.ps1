$lower = $args[0]
$higher = $args[1]

$currentPath = Get-Location
$singleSourceFetchPath = Join-Path -Path $currentPath -ChildPath "Fetch-Single-Source.ps1"

for ($i = $lower; $i -le $higher; $i++) {
    Write-Host "Fetching: $i"
    Invoke-Expression -Command "$singleSourceFetchPath $i"

    Start-Sleep -Milliseconds 250

    Write-Host "Fetched: $i"
}