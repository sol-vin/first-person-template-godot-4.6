# URLs for the tools
$TrenchBroomURL = "https://github.com/TrenchBroom/TrenchBroom/releases/download/v2025.3/TrenchBroom-Win64-AMD64-v2025.3-Release.zip"
$MessURL = "https://github.com/pwitvoet/mess/releases/download/1.2.3/mess_1.2.3_win64.zip"

# Get the script's directory to use as the root
$RootDir = $PSScriptRoot

# Paths for extraction
$TrenchbroomDir = Join-Path $RootDir "bin/trenchbroom"
$MESSDir = Join-Path $RootDir "bin/mess"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $TrenchbroomDir
New-Item -ItemType Directory -Force -Path $MESSDir

# Temporary file paths
$TrenchbroomZip = Join-Path $RootDir "trenchbroom.zip"
$MESSZip = Join-Path $RootDir "mess.zip"

# Download and extract TrenchBroom
Write-Host "Downloading TrenchBroom..."
Invoke-WebRequest -Uri $TrenchBroomURL -OutFile $TrenchbroomZip
Write-Host "Extracting TrenchBroom..."
Expand-Archive -Path $TrenchbroomZip -DestinationPath $TrenchbroomDir -Force
Remove-Item $TrenchbroomZip

# Download and extract Mess
$MESSExtractDir = Join-Path $RootDir "mess_temp"
Write-Host "Downloading Mess..."
Invoke-WebRequest -Uri $MessURL -OutFile $MESSZip
Write-Host "Extracting Mess..."
Expand-Archive -Path $MESSZip -DestinationPath $MESSExtractDir -Force

$MESSInnerDir = Get-ChildItem -Path $MESSExtractDir -Directory | Select-Object -First 1
if ($MESSInnerDir) {
    Move-Item -Path "$($MESSInnerDir.FullName)\*" -Destination $MESSDir -Force
} else {
    Move-Item -Path "$($MESSExtractDir)\*" -Destination $MESSDir -Force
}

Remove-Item $MESSZip
Remove-Item -Recurse -Force $MESSExtractDir

# Download and extract Godot
$GodotVersion = "4.6"
$GodotFlavor = "dev4"
$GodotOS = "windows.64"
$GodotMiniName = $GodotOS -replace 'windows\.64', 'win64' -replace 'linux\.64', 'linux64' -replace 'macos\.64', 'macos64'


$GodotURL = "https://downloads.godotengine.org/?version=$($GodotVersion)&flavor=$($GodotFlavor)&slug=win64.exe.zip&platform=$($GodotOS)"
$GodotZip = Join-Path $RootDir "godot.zip"
$GodotExtractDir = Join-Path $RootDir "godot_temp"

Write-Host "Downloading Godot..."
Invoke-WebRequest -Uri $GodotURL -OutFile $GodotZip
Write-Host "Extracting Godot..."
Expand-Archive -Path $GodotZip -DestinationPath $GodotExtractDir -Force

$GodotExe = Get-ChildItem -Path $GodotExtractDir -Filter "Godot_*.exe" | Where-Object { !$_.Name.Contains("console") } | Select-Object -First 1
if ($GodotExe) {
    Rename-Item -Path $GodotExe.FullName -NewName "godot.exe"
    Move-Item -Path (Join-Path $GodotExtractDir "godot.exe") -Destination $RootDir
} else {
    Write-Host "Could not find Godot executable."
}

Remove-Item $GodotZip
Remove-Item -Recurse -Force $GodotExtractDir

# Copy editor files
$TrenchBroomGamesDir = Join-Path $TrenchbroomDir "games"
if (Test-Path $TrenchBroomGamesDir) {
    Write-Host "Clearing existing TrenchBroom game configurations..."
    Remove-Item -Path "$TrenchBroomGamesDir\*" -Recurse -Force
}
Write-Host "Copying editor files..."
Copy-Item -Path (Join-Path $RootDir "editor/*") -Destination $TrenchbroomDir -Recurse -Force


Write-Host "Setup complete."
