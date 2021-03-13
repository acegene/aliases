#### config vars for bash
## tmp vars
__PATH_THIS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)/"$(basename -- "${BASH_SOURCE[0]}")""
__DIR_THIS="$(dirname -- "${__PATH_THIS}")"
if [ -f "${__PATH_THIS}" ] && [ -d "${__DIR_THIS}" ]; then
    ## ps profiles
    path_ps_profile="${HOME}/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
    path_ps_profile_2="${HOME}/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
    path_ps_gene_src="${__DIR_THIS}/src.ps1"
    ## bash profiles
    path_bashrc="${HOME}/.bashrc"
    path_bash_aliases="${HOME}/.bash_aliases"
    path_bash_gene_src="${__DIR_THIS}/src.bash"
    ## user specific locations and choices
    editor='code'
    bash='/c/Program Files/Git/bin/bash.exe'
    perl='/c/Program Files/Git/usr/bin/perl.exe'
else
    >&2 echo "ERROR: could not generate paths"
fi