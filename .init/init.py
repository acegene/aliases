#!/usr/bin/env python3
# pylint: disable=wrong-import-position
import argparse
import os
import sys
from collections.abc import Sequence

sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "repos", "scripts", "py"))

from utils import argparse_utils
from utils import cli_utils
from utils import log_manager
from utils import path_utils
from utils import python_utils

_LOG_FILE_PATH, _LOG_CFG_DEFAULT = log_manager.get_default_log_paths(__file__)
logger = log_manager.LogManager()


def init_bash_base(
    path_src_template: str,
    path_src: str,
    template_replacements: tuple[str, str],
    check_only: bool,
) -> bool:
    cp_template_success = path_utils.cp_with_replace(
        path_src_template,
        path_src,
        template_replacements,
        check_only=check_only,
    )

    bashrc = os.path.expanduser("~/.bashrc")
    bash_aliases = os.path.expanduser("~/.bash_aliases")
    lines_bashrc = [
        f"[ -f '{path_utils.path_as_posix_if_windows(bash_aliases)}' ] && . '{path_utils.path_as_posix_if_windows(bash_aliases)}'",
    ]
    lines_bash_aliases = [
        f"[ -f '{path_utils.path_as_posix_if_windows(path_src)}' ] && . '{path_utils.path_as_posix_if_windows(path_src)}'",
    ]

    add_to_bashrc_success = path_utils.append_missing_lines_to_file(bashrc, lines_bashrc, check_only=check_only)
    add_to_bash_aliases_success = path_utils.append_missing_lines_to_file(
        bash_aliases,
        lines_bash_aliases,
        check_only=check_only,
    )

    return cp_template_success and add_to_bashrc_success and add_to_bash_aliases_success


def init_bash(dir_repo: str, check_only: bool = False) -> bool:
    path_src_template = os.path.join(dir_repo, ".src", "src.bash.template")
    path_src = os.path.join(dir_repo, ".src", "src.bash")
    if python_utils.is_os_linux():
        start_str = "xdg-open"
    elif python_utils.is_os_mac():
        start_str = "open"
    elif python_utils.is_os_windows():
        start_str = "start"
    else:
        print(f"ERROR: unexpected os={python_utils.get_os()}")
        sys.exit(1)

    template_replacements = (
        ("<TEMPLATE_DIR_REPO>", path_utils.path_as_posix_if_windows(dir_repo)),
        ("<TEMPLATE_SRC>", path_utils.path_as_posix_if_windows(path_src)),
        ("<TEMPLATE_OS_START>", start_str),
    )

    return init_bash_base(path_src_template, path_src, template_replacements, check_only=check_only)


def init_powershell(dir_repo, check_only: bool = False):
    assert python_utils.is_os_windows()
    profiles = (
        os.path.expanduser("~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"),
        os.path.expanduser("~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"),
    )
    srcs = (os.path.join(dir_repo, ".src", "src.ps1"),)
    src_lines = (f". {path_utils.path_posix_to_windows(src)}" for src in srcs)

    profiles_src_success = True
    for profile in profiles:
        profiles_src_success = (
            path_utils.append_missing_lines_to_file(profile, src_lines, is_windows=True, check_only=check_only)
            and profiles_src_success
        )
    return profiles_src_success


def main(argparse_args: Sequence[str] | None = None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", default=_LOG_FILE_PATH)
    parser.add_argument("--log-cfg", default=_LOG_CFG_DEFAULT, help="Log cfg; empty str uses LogManager default cfg")
    args = parser.parse_args(argparse_args)

    log_manager.LogManager.setup_logger(globals(), log_cfg=args.log_cfg, log_file=args.log)

    logger.debug(f"argparse args:\n{argparse_utils.parsed_args_to_str(args)}")

    dir_this = os.path.dirname(os.path.abspath(__file__))
    dir_repo = os.path.dirname(dir_this)
    assert os.path.basename(dir_repo) == "aliases"

    logger.info("Checking bashrc and .bash_aliases status")
    if init_bash(dir_repo, check_only=True) or cli_utils.prompt(
        "PROMPT: Initialize .bashrc and .bash_aliases for gene-ws? (y/n) ",
    ):
        init_bash(dir_repo)

    if python_utils.is_os_windows():
        logger.info("Checking powershell profile status")
        if init_powershell(dir_repo, check_only=True) or cli_utils.prompt(
            "PROMPT: Initialize powershell profiles for gene-ws? (y/n) ",
        ):
            init_powershell(dir_repo, check_only=True)


if __name__ == "__main__":
    main()
