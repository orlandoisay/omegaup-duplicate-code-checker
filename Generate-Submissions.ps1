$url = "https://omegaup.com/api/contest/runs/"
$apiToken = "AQUI VA EL TOKEN";
$contestAlias= "ccup23"

$headers = @{
    "Authorization" = "token $apiToken"
    "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
}

$currentPath = Get-Location
$basePath = Join-Path -Path $currentPath -ChildPath "RunsData"

$fileName = "Submissions.csv"
$filePath = Join-Path -Path $basePath -ChildPath $fileName

Set-Content -Path $filePath -Value ""

$rows = @()
$rows += "guid,username"

# OmegaUp only returns 100 submissions per request. To get the next 100 we need to set an offset
$offset = 0

do {
    $params = "contest_alias=$contestAlias&show_all=true&offset=$offset"
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $params

    Write-Host "Fetching page: $offset"

    foreach ($run in $response.runs) {
        $guid = $run.guid
        $username = $run.username

        $row = "$guid,$username"
        $rows += $row
    }

    Write-Host "Fetched page: $offset"
    Start-Sleep -Milliseconds 500

    $offset = $offset + 1
} while ($response.runs.Count -ne 0)

$rows | Out-File -FilePath  $filePath
