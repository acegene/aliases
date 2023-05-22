#### config vars for powershell
## ps profiles
$profiles = @(
    "$($HOME)\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    "$($HOME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)
## bash profiles
$path_bashrc = "$($HOME)\.bashrc"
$path_bash_aliases = "$($HOME)\.bash_aliases"
$path_bash_gene_src = "$($PSScriptRoot)\src.bash"
## user specific locations and choices
$editor = 'code'
$bash = 'C:\Program Files\Git\bin\bash.exe'
$perl = 'C:\Program Files\Git\usr\bin\perl.exe'
