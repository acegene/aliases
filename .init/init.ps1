# init.ps1
#
# Generate a powershell profile with aliases configs etc

$ErrorActionPreference = 'Stop'

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "EXEC: cd '$PWD'; & '$PSCommandPath' $args # as admin powershell"
    Start-Process PowerShell -Verb RunAs "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"cd '$PWD'; & '$PSCommandPath' $args`""
    exit
}

################&&!%@@%!&&################ AUTO GENERATED CODE BELOW THIS LINE ################&&!%@@%!&&################
# yymmdd: 210228
# generation cmd on the following line:
# python "${GWSPY}/write_btw.py" "-t" "ps1" "-w" "${GWSA}/init/init.ps1" "-x" "Group-Unspecified-Args"

function Group-Unspecified-Args {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $ExtraParameters
    )

    $ParamHashTable = @{}
    $UnnamedParams = @()
    $CurrentParamName = $null
    $ExtraParameters | ForEach-Object -Process {
        if ($_ -match '^-') {
            # Parameter names start with '-'
            if ($CurrentParamName) {
                # Have a param name w/o a value; assume it's a switch
                # If a value had been found, $CurrentParamName would have been nulled out again
                $ParamHashTable.$CurrentParamName = $true
            }

            $CurrentParamName = $_ -replace '^-|:$'
        } else {
            # Parameter value
            if ($CurrentParamName) {
                $ParamHashTable.$CurrentParamName += $_
                $CurrentParamName = $null
            } else {
                $UnnamedParams += $_
            }
        }
    } -End {
        if ($CurrentParamName) {
            $ParamHashTable.$CurrentParamName = $true
        }
    }

    return $ParamHashTable, $UnnamedParams
}
################&&!%@@%!&&################ AUTO GENERATED CODE ABOVE THIS LINE ################&&!%@@%!&&################

function _init {
    param (
        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true)]
        $unspecified_args
    )
    #### collect cmd args
    $named_args, $unnamed_args = Group-Unspecified-Args @unspecified_args
    #### hardcoded values
    $dir_this = $PSScriptRoot # not compatible with PS version < 3.0
    $dir_repo = "$(Push-Location $(git -C $($dir_this) rev-parse --show-toplevel); Write-Output $PWD; Pop-Location)"
    $path_src = "$($dir_repo)\.src\src.ps1"
    $path_cfg = "$($dir_repo)\.src\cfg.ps1"
    $path_cfg_default = "$($dir_repo)\.src\cfg-default.ps1"
    #### includes
    if (!(Test-Path $path_cfg)) {
        Write-Host "INFO: cp '$path_cfg_default' '$($path_cfg)'"
        Copy-Item -Path "$path_cfg_default" -Destination "$path_cfg"
    }
    . "$path_cfg"
    #### if no profile exists create one
    foreach ($profile in $profiles) {
        if (!(Test-Path $profile)) {New-Item -Type File -Force $profile}
    }
    #### lines to append
    $cmd_args = "$($named_args.Keys | ForEach-Object { "-$($_)" + " '$($named_args.Item($_))'" }) "
    $cmd_args += "$($unnamed_args | ForEach-Object { "'$($_)'" })"
    if ($cmd_args -eq " ''") {$cmd_args = ''}
    $prof_cmd = ". '$($path_src)' $($cmd_args)"
    #### append lines to profiles
    foreach ($profile in $profiles) {
        #### if no profile exists create one
        if (!(Test-Path $profile)) {New-Item -Type File -Force $profile}
        #### check if lines exist in profile, otherwise append them
        if ($(((Get-Content -Raw $profile) -split '\n')[-1]) -ne '') {
            $prof_cmd = "`r`n$($prof_cmd)" ## TODO: check to ensure using crlf
        }
        $file_str = Get-Content $profile | Select-String -SimpleMatch $prof_cmd
        if ($null -eq $file_str) {
            Write-Output $prof_cmd >> $profile
            Write-Host "INFO: Writing string to file: $($prof_cmd) >> $($profile)"
        }
    }
}

_init @args
