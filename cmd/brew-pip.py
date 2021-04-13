#!/usr/bin/env python

"""
Wrapper around pip to install python distributions within Homebrew.
"""

__version__ = '0.5.1'

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

HOMEBREW_CELLAR = os.environ.get("HOMEBREW_CELLAR", None)
if not HOMEBREW_CELLAR:
    try:
        output = subprocess.check_output(["brew", "--prefix"], stderr=subprocess.STDOUT)
        HOMEBREW_CELLAR = str(output, "utf-8").splitlines()[0] + "/Cellar"
    except subprocess.CalledProcessError:
        print("warning: falling back to hardcoded HOMEBREW_CELLAR=/usr/local/Cellar")
        HOMEBREW_CELLAR = "/usr/local/Cellar"


def package_folders(package):
    return next(os.walk("{0}/{1}/".format(HOMEBREW_CELLAR, package)))[1]


def main(args):
    install_commands = ["install", "reinstall", "upgrade"]
    list_commands = ["ls", "list"]
    uninstall_commands = ["reinstall", "remove", "rm", "uninstall", "upgrade"]

    if args.command in list_commands:
        try:
            output = subprocess.check_output(["brew", "list"], stderr=subprocess.STDOUT)
            packages = [lnchk for lnchk in str(output, "utf-8").splitlines() if lnchk.startswith("pip-")]
            [print(p[4:]) for p in packages if "pypi" in package_folders(p)]
        except subprocess.CalledProcessError:
            pass
        return

    for package in args.packages:
        # Just the name part of the package (no version info)
        # Django==1.4 -> Django
        package_name = re.search(r'^(?P<name>[\w.-]+)', package).group('name')
        assert package_name, "Invalid package name: '%s'" % package

        # Directory in /usr/local/Cellar it gets installed to
        # Django==1.4 -> pip-django
        cellar_package_name = "pip-%s" % package_name.lower()

        if args.command in uninstall_commands:
            os.system("brew rm %s" % cellar_package_name)

        if args.command not in install_commands:
            continue

        # Why hard-code the version to "pypi"? Because if you care about
        # versions you're probably already using virtualenv and not
        # installing distributions site wide.
        prefix = os.path.join(HOMEBREW_CELLAR, cellar_package_name, "pypi")
        build_dir = tempfile.mkdtemp(prefix='brew-pip-')

        cmd = ["TMPDIR=/tmp/%s" % build_dir, "pip", "install",
               "-v" if args.verbose else "",
               package,
               "--no-clean",
               "--prefix=''",
               "--target=%s" % os.path.join(prefix, "bin")]

        if args.verbose:
            print(" ".join(cmd))

        os.system(" ".join(cmd))

        if not args.keg_only:
            os.system("brew link %s" % cellar_package_name)

        shutil.rmtree(build_dir)


if __name__ == "__main__":
    choices = ["install", "list", "ls", "reinstall", "rm", "remove", "upgrade", "uninstall"]
    parser = argparse.ArgumentParser(prog='brew pip')
    parser.add_argument("--version", action="version", version="%(prog)s v" + __version__)
    parser.add_argument("-v", "--verbose", action="store_true", default=False, help="be verbose")
    parser.add_argument("-k", "--keg-only", action="store_true", default=False, help="don't link files into prefix")
    parser.add_argument('command', choices=choices, nargs=1, help="command to run")
    parser.add_argument("packages", nargs='*', help="name of the package(s) to install", metavar="package")
    args = parser.parse_args()

    if isinstance(args.command, (list,)):
        args.command = args.command[0]

    if args.command not in ["list", "ls"] and len(args.packages) == 0:
        parser.print_help(sys.stderr)
        sys.exit(1)

    main(args)
