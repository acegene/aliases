# This file is sourced by powershell profile's after this repo's init.ps1 is executed
#
# todos
#   * name clashing with gc and gp
#   * perl path not generalized
#   * git tab completion
#   * rm invoke cmds
#   * check ps version

$ErrorActionPreference = 'Stop'

function _src {
    #### hardcoded values
    $path_this = $PSCommandPath # not compatible with PS version < 3.0
    $dir_this = $PSScriptRoot # not compatible with PS version < 3.0
    $dir_repo = "$(Push-Location $(git -C $($dir_this) rev-parse --show-toplevel); Write-Output $PWD; Pop-Location)"
    $dir_bin = "$($dir_repo)\bin"
    $path_cfg = "$($dir_repo)\.src\cfg.ps1"
    $path_cfg_default = "$($dir_repo)\.src\cfg-default.ps1"
    #### includes
    if (!(Test-Path $path_cfg)) {
        Write-Output "INFO: cp '$path_cfg_default' '$($path_cfg)'"
        Copy-Item -Path "$path_cfg_default" -Destination "$path_cfg"
    }
    . "$path_cfg"
    #### exports
    $env:PATH += ";$($dir_bin)" # TODO: redundant with gws
    #### git-number check if can be enabled
    $git_number = "$($dir_bin)\git-number"
    $use_git_number = $false; if ($(Test-Path $git_number) -And $(Test-Path $perl)) {$use_git_number = $true}
    if ($use_git_number) {$gitcmd = $perl; $gitargs = @("'$($dir_bin)\git-number'")}
    else {Write-Output 'Warning: git-number and/or perl not found, defaulting to git'; $gitcmd = 'git'; $gitargs = @('-c', 'color.status=always')}
    #### funcs
    Invoke-Expression "function global:_git_or_gn {& '$($gitcmd)' $($gitargs -join ' ') @args}"
    function _cd_parent_aliases {
        $num_cd_aliases = $args[0]; $body = 'cd '; $name = '.'
        for ($i = 0; $i -lt $num_cd_aliases; $i = $i + 1 ) {
            $name += '.'; $body += '..\'
            Invoke-Expression "function global:$($name) {$($body)}"
        }
    }
    #### aliases
    ## git
    function global:gn {& _git_or_gn @args}
    Invoke-Expression "function global:gg {if (`$$use_git_number) { git -c color.status=always status -sb | select -first 1; if(`$?){& global:_git_or_gn -s}} else {git status -sb}}"
    function global:ga {& _git_or_gn 'add' @args}
    function global:ggc {& _git_or_gn 'checkout' @args} # windows stomps on gc
    function global:gr {& _git_or_gn 'reset' @args}
    function global:gd {& _git_or_gn 'diff' @args}
    function global:gf {git fetch}
    function global:ggp {git pull} # windows stomps on gp
    function global:grb {git rebase}
    function global:gcp {git cherry-pick}
    function global:gcm {git checkout master}
    function global:grom {git fetch; if ($?) {git rebase origin/master}}
    function global:lg {git log --date=format:'%y-%m-%d %H:%M' --pretty=format:'%h%x20%x20%Cred%ad%x20%x20%Cblue%an%x20%x20%Creset%s'}
    function global:log {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n          %C(white)%s%C(reset)%n          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'}
    function global:ggg {git submodule foreach git status -sb}
    function global:gsu {git submodule update}
    function global:gss {git submodule status}
    ## dirs
    _cd_parent_aliases '10'
    function global:dl {Set-Location "$($HOME)/Downloads"}
    function global:dsk {Set-Location "$($HOME)/Desktop"}
    function global:doc {Set-Location "$($HOME)/Documents"}
    ## profile interactions
    Invoke-Expression "function global:psp {& '$editor' '$path_ps_profile'}"
    Invoke-Expression "function global:psps {. '$path_ps_profile'}"
    Invoke-Expression "function global:pspg {& '$editor' '$path_this'}"
    Invoke-Expression "function global:pspgs {. '$path_this'}"
    Invoke-Expression "function global:rc {& '$editor' '$path_bashrc'}"
    Invoke-Expression "function global:rca {& '$editor' '$path_bash_aliases'}"
    Invoke-Expression "function global:rcg {& '$editor' '$path_bash_gene_src'}"
    ## shell interactions
    function global:Start-PS-Admin { Start-Process -Verb RunAs (Get-Process -Id $PID).Path}
    Set-Alias -Scope 'global' -Name 'admined-ps' -Value 'Start-PS-Admin'
    function global:Start-WT-Admin { powershell "Start-Process -Verb RunAs cmd.exe '/c start wt.exe'"}
    Set-Alias -Scope 'global' -Name 'admined-wt' -Value 'Start-WT-Admin'
    Invoke-Expression "function global:bashed {if(`$args.count -eq 0){& '$bash' -i}else{`$x = `$args | % {`$_ -replace '`"', '\`"'}; & '$bash' -ic `"`$x`"}}"
    ## misc
    Set-Alias -Scope 'global' -Name 'op' -Value 'start'
    Set-Alias -Scope 'global' -Name 'rs' -Value 'clear'
}

_src @args
