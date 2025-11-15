#https://pwitvoet.github.io/mess/

Set-Location -Path $PSScriptRoot

$MapFile = "../../maps/main.map"
$MapTable = @{
	"start"="../../maps/start.map";
}

foreach ($entry in $MapTable.GetEnumerator()) {
	$filePath = "$($entry.key).ps1"
	$scriptBlock = @"
		Set-Location -Path "$($PSScriptRoot)\bin\mess"
		Write-Host "Layers: $($entry.Key) -> $($entry.Value)"
		./MESS.exe -log off -onlyvisgroups "$($entry.Key)" -convert "$($MapFile)" "$($entry.Value)"
		Write-Host "$($entry.Value) is finished."
"@
	Invoke-Expression $scriptBlock
	# Set-Content -Path $filePath -Value $scriptBlock
	# Start-Process -FilePath "powershell.exe" -ArgumentList "-File", $filePath
}

# Create a new SpVoice objects
$voice = New-Object -ComObject Sapi.spvoice

# Set the speed - positive numbers are faster, negative numbers, slower
$voice.rate = 0

# Say something
$voice.speak("Map Compiled! Map Compiled! Map Compiled!")

Set-Location -Path $PSScriptRoot