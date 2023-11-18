$url = "https://omegaup.com/api/contest/runs/"
$apiToken = "AQUI VA EL TOKEN DE OMEGAUP";
$contestAlias = "ccup23";

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

$params = "contest_alias=$contestAlias"

$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $params

$aliases = New-Object System.Collections.Generic.HashSet[System.String]
$languages = New-Object System.Collections.Generic.HashSet[System.String]

foreach ($run in $response.runs) {
    $alias = $run.alias
    $language = Normalize-Language -orignalLanguage $run.language
    
    $aliases.Add($alias)
    $languages.Add($language)
}

$currentPath = Get-Location
$basePath = Join-Path -Path $currentPath -ChildPath "RunsData"

foreach ($alias in $aliases) {
    $aliasFolderPath = Join-Path -Path $basePath -ChildPath $alias

    if (-not(Test-Path -Path $aliasFolderPath -PathType Container)) {
        New-Item -Path $aliasFolderPath -ItemType Directory

        foreach ($language in $languages) {
            $problemFolderPath = Join-Path -Path $aliasFolderPath -ChildPath $language

            if (-not(Test-Path -Path $problemFolderPath -PathType Container)) {
                New-Item -Path $problemFolderPath -ItemType Directory
            }
        }
    } 
}