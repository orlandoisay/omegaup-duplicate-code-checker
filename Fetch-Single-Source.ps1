$url = "https://omegaup.com/api/run/details/"
$apiToken = "AQUI VA EL TOKEN DE OMEGAUP";

function Normalize-Language {
    param (
        [string] $orignalLanguage
    )

    $normalizedLanguage = $orignalLanguage

    if ($normalizedLanguage.StartsWith("cpp") -or $normalizedLanguage.StartsWith("c11")) {
        $normalizedLanguage = "cpp"
    }

    if ($normalizedLanguage.StartsWith("py")) {
        $normalizedLanguage = "py"
    }
    return $normalizedLanguage
}

$headers = @{
    "Authorization" = "token $apiToken"
    "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
}

$currentPath = Get-Location
$basePath = Join-Path -Path $currentPath -ChildPath "RunsData"

$submissionsFileName = "Submissions.csv"
$submissionsFilePath = Join-Path -Path $basePath -ChildPath $submissionsFileName

$submissionsCsv = Import-Csv -Path $submissionsFilePath

$rowIndex = $args[0]
$rowData = $submissionsCsv[$rowIndex]

$guid = $rowData.guid
$username = $rowData.username

Write-Host ($guid + "_" + $username)

$params = "run_alias=$guid"
$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $params

$alias = $response.alias
$language = Normalize-Language -orignalLanguage $response.language
$source = $response.source
$score = $response.details.contest_score
$verdict = $response.details.verdict

$result = "$verdict$score"

$currentPath = Get-Location
$basePath = Join-Path -Path $currentPath -ChildPath "RunsData"

$problemPath = Join-Path -Path $basePath -ChildPath $alias
$languagePath = Join-Path -Path $problemPath -ChildPath $language

$resultPath = Join-Path -Path $languagePath -ChildPath $result

if (-not(Test-Path -Path $resultPath -PathType Container)) {
    New-Item -Path $resultPath -ItemType Directory
}

$sourceFilename = $guid + "_" + $username.Replace(":", "")
$sourceFilePath = Join-Path -Path $resultPath -ChildPath $sourceFilename

Write-Host $sourceFilePath
New-Item -Path $sourceFilePath -ItemType File -Value $source

