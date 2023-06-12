#!/bin/sh

set -e # -e: exit on error

usage="Usage: `basename $0` [-s|-l] [-h]
Install source:
Default: decided automatically
  -c, --clone: clone from GitHub
  -l, --local: install from the script's directory\n"

# Get args
# Compounded options (i.e. -abc) would require a special case
for i in $@; do
  arg=`echo $i | tr "[:upper:]" "[:lower:]"`
  case $arg in

   -c | --clone )
      if [ ! -z $arg_source ]; then
        echo "error: multiple install source statements" >&2
        exit 1
      fi
      arg_source=clone
      ;;

   -l | --local )
      if [ ! -z $arg_source ]; then
        echo "error: multiple install source statements" >&2
        exit 1
      fi
      arg_source=local
      ;;

   -h )
      printf "POSIX install script for logicer's dotfiles.\nLearn more: https://github.com/Logicer16/dotfiles\n\n"
      printf "$usage"
      exit 0
      ;;

   * )  
      printf "$usage" >&2
      exit 1
      ;;

  esac
done

# Download chezmoi for bootstraping if required
if [ ! "`command -v chezmoi`" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "`command -v curl`" ]; then
    sh -c "`curl -fsSL https://git.io/chezmoi`" -- -b "$bin_dir"
  elif [ "`command -v wget`" ]; then
    sh -c "`wget -qO- https://git.io/chezmoi`" -- -b "$bin_dir"
  else
    echo "error: cannot install chezmoi. You must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# Decide source
if [ "$arg_source" != "clone" ]; then
  # POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
  # Looks like garbage but blame the bourne shell's syntax for not having $()
  script_dir="`cd -P -- \"\`dirname -- \\\"\\\`command -v -- \\\\\"$0\\\\\"\\\`\\\"\`\" && pwd -P`"
  # Check if in a git repo and if it's the right git repo
  git_url="`$chezmoi git -S $script_dir -- config --get remote.origin.url 2> /dev/null | tr "[:upper:]" "[:lower:]" || true`"
  # Remove the ".git" suffix, if present
  if echo $git_url | grep -q "\.git"; then
    git_url=`echo $git_url | sed 's/\(.*\)\(\.git\)/\1/'`
  fi
  if [ "${git_url%.git}" = "https://github.com/logicer16/dotfiles" ]; then
    # update git repo
    $chezmoi git -S $script_dir -- pull
    source="--source=$script_dir"
  else
    if [ "$arg_source" = "local" ]; then
      echo "error: not in valid git repository" >&2
      exit 1
    fi
  fi
fi

# Pass unattended status
if [ ! -t 0 ] || [ ! -t 1 ]; then
  UNATTENDED=true
fi

# exec: replace current process with chezmoi init
exec env UNATTENDED=$UNATTENDED "$chezmoi" init --apply ${source:-"logicer16"}
