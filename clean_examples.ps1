# Deletes the contents of the /maps directory
Remove-Item -Path "maps\*" -Recurse -Force
Remove-Item -Path "dialogue\*" -Recurse -Force

# Replaces the contents of main.gd with "extends Node3D"
Set-Content -Path "main.gd" -Value "extends Node3D"
