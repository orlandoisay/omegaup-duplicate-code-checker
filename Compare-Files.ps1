$currentPath = Get-Location
$basePath = Join-Path -Path $currentPath -ChildPath "RunsData"

$problemFolders = Get-ChildItem -Path $basePath -Directory

$suspiciousMatches = @()

foreach ($problemFolder in $problemFolders) {
    Write-Host "Checking problem $problemFolder"
    $languageFolders = Get-ChildItem -Path $problemFolder.FullName -Directory

    # $skipProblems = "Cartulina", "El-Puntaje-mas-alto"
    $skipProblems = @()

    if ($skipProblems -notcontains $problemFolder.Name) {
        foreach($languageFolder in $languageFolders) {
            Write-Host "  Checking language $languageFolder"
            $resultFolders = Get-ChildItem -Path $languageFolder.FullName -Directory

            foreach($resultFolder in $resultFolders) {
                Write-Host "    Checking result $resultFolder"
                $files = Get-ChildItem -Path $resultFolder.FullName -File

                $filesByHash = @{}

                foreach ($file in $files) {
                    $content = (Get-Content -Path $file.FullName) -replace '\s+', ' ' | Where-Object { $_ -match '\S' }
                    $tempPath = Join-Path -Path $basePath -ChildPath "tempFile"
                    
                    $content | Set-Content -Path $tempPath
                    $hash = Get-FileHash -Path $tempPath -Algorithm SHA256

                    if (-not $filesByHash.ContainsKey($hash.Hash)) {
                        $filesByHash[$hash.Hash] = @()
                    } 

                    $filesByHash[$hash.Hash] += $file.Name
                }

                foreach ($key in $filesByHash.Keys) {
                    if ($filesByHash[$key].Count -gt 1) {
                        foreach ($fileInHash in $filesByHash[$key]) {
                            $row = $problemFolder.Name + "," +  $languageFolder.Name + "," + $resultFolder.Name + "," + $key + "," + $fileInHash
                            $suspiciousMatches += $row
                        }
                    }
                }
            }
        }
    }
}

$matchesFilePath = Join-Path -Path $basePath "MatchesData.csv"
$suspiciousMatches | Set-Content -Path $matchesFilePath
