
# Get the script's directory to use as the root
$RootDir = $PSScriptRoot

# Paths for extraction
$TrenchbroomDir = Join-Path $RootDir "bin/trenchbroom"

Write-Host "Copying editor files..."
Copy-Item -Path (Join-Path $RootDir "editor/*") -Destination $TrenchbroomDir -Recurse -Force


Write-Host "FGD Copied."
