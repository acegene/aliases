#!/usr/bin/env bash
#
# owner: acegene
#
# descr: adds sourcing of this repo's src.bash in ~/.bash_aliases

# shellcheck disable=SC1091

set -u

dir_this="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && printf %s "${PWD}")" || ! printf '%s\n' "ERROR: UNKNOWN_CONTEXT: could not generate dir_this" >&2 || exit 1
base_this="$(basename -- "${BASH_SOURCE[0]}")" || ! printf '%s\n' "ERROR: UNKNOWN_CONTEXT: could not generate base_this" >&2 || exit 1
path_this="${dir_this}/${base_this}"
[ -f "${path_this}" ] && [ -d "${dir_this}" ] || ! printf '%s\n' "ERROR: UNKNOWN_CONTEXT: could not generate paths" >&2 || exit 1

# shellcheck disable=SC2034
log_context="${base_this}" # implicitly used by __log func

dir_repo="$(git -C "${dir_this}" rev-parse --show-toplevel | sed 's/^\([a-zA-Z]\):/\/\1/')" || ! printf '%s\n' "ERROR: ${log_context}: could not locate git repo dir for ${base_this}" || exit 1

for file in "${dir_repo}/../scripts/shell/sh/utils/"*.sh; do . "${file}" || exit "${?}"; done || exit "${?}"

__parse_args() {
    while __is_not_eq "${#}" '0'; do
        case "${1}" in
        --operating-system | --os | -o)
            case "${2}" in
            ubuntu1804 | ubuntu2004 | win10 | wsl-ubuntu1804 | wsl-ubuntu2004)
                os="${2}"
                shift
                ;;
            *) __log -e "unrecognized '${1}' parameter '${2}'; choose from [ubuntu1804, ubuntu2004, win10, wsl-ubuntu1804, wsl-ubuntu2004]" && return 1 ;;
            esac
            ;;
        *) __log -e "arg ${1} is unexpected" && return 2 ;;
        esac
        shift
    done
    [ "${os}" != '' ] || ! __log -e "--os is required; choose from [ubuntu1804, ubuntu2004, win10, wsl-ubuntu1804, wsl-ubuntu2004]" || return 3
}

__generate_src() {
    local dir_repo="${1}"
    local path_src="${2}"
    local os="${3}"
    local path_src_template="${dir_repo}/src/src.bash.template"
    #### create src file from template
    __exec_only_err cp "${path_src_template}" "${path_src}" || return 1
    #### overwrite placeholde template parameters
    __exec_only_err sed -i "s|TEMPLATE_DIR_REPO|${dir_repo}|g" "${path_src}" || return 1
    __exec_only_err sed -i "s|TEMPLATE_SRC|${path_src}|g" "${path_src}" || return 1
    case "${os}" in
    ubuntu1804 | ubuntu2004 | wsl-ubuntu1804 | wsl-ubuntu2004)
        __exec_only_err sed -i 's|TEMPLATE_OS_START|xdg-open|g' "${path_src}" || return 1
        ;;
    win10)
        __exec_only_err sed -i 's|TEMPLATE_OS_START|start|g' "${path_src}" || return 1
        ;;
    *) __log -e "unrecognized operating_system='${os}'; choose from [ubuntu1804, ubuntu2004, win10, wsl-ubuntu1804, wsl-ubuntu2004]" && return 1 ;;
    esac
}

__main() {
    #### hardcoded vars
    ## files
    local bash_aliases="${HOME}/.bash_aliases"
    local bashrc="${HOME}/.bashrc"
    #### default vars
    local os=''
    #### parse args and overwrite default vars
    __parse_args "${@}" || return "${?}"
    #### create $bash_aliases and $bashrc if they do not exist
    __is_file "${bash_aliases}" || touch "${bash_aliases}" || ! __log -e "could not create '${bash_aliases}'" || return 1
    __is_file "${bashrc}" || __print_out_nl ". '${bash_aliases}'" >>"${bashrc}" || ! __log -e "could not write to '${bashrc}'" || return 1
    #### generate src file based on parameters
    local path_src="${dir_repo}/src/src-${os}.bash"
    __generate_src "${dir_repo}" "${path_src}" "${os}" || ! __log -e "could not generate src" || return 1
    #### lines to add to files
    local lines_bash_aliases=("[ -f '${path_src}' ] && . '${path_src}'")
    #### add ${lines_bash_aliases[@]} to $bash_aliases if not already within $bash_aliases
    __file_append_trailing_nl_if_none "${bash_aliases}" || return 1
    for line_bash_aliases in "${lines_bash_aliases[@]}"; do
        __file_append_line_if_not_found "${bash_aliases}" "${line_bash_aliases}" || return 1
    done
}

__main "${@}"
