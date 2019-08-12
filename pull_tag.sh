# Created by argbash-init v2.5.1
#!/bin/bash

# ARG_OPTIONAL_SINGLE([srcimgtag],[s],[source path and tag to tardis image],[missing])
# ARG_OPTIONAL_SINGLE([tag],[t],[final tag],[tardis:latest])
# ARGBASH_SET_INDENT([  ])
# ARG_HELP([Pull a docker image and tag it (default tag=tardis:latest)],[e.g.:\nbash pull_tag.sh -s quay.io/eschen42/galaxy-tardis:v0.0.3\nbash pull_tag.sh -s quay.io/eschen42/galaxy-tardis:v0.0.3 -t tardis:v0.0.3])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


# # When called, the process ends.
# Args:
#   $1: The exit message (print to stderr)
#   $2: The exit code (default is 1)
# if env var _PRINT_HELP is set to 'yes', the usage is print to stderr (prior to $1)
# Example:
#   test -f "$_arg_infile" || _PRINT_HELP=yes die "Can't continue, have to supply file as an argument, got '$_arg_infile'" 4
die()
{
  local _ret=$2
  test -n "$_ret" || _ret=1
  test "$_PRINT_HELP" = yes && print_help >&2
  echo "$1" >&2
  exit ${_ret}
}


# Function that evaluates whether a value passed to it begins by a character
# that is a short option of an argument the script knows about.
# This is required in order to support getopts-like short options grouping.
begins_with_short_option()
{
  local first_option all_short_options='sth'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_srcimgtag="missing"
_arg_tag="tardis:latest"


# Function that prints general usage of the script.
# This is useful if users asks for it, or if there is an argument parsing error (unexpected / spurious arguments)
# and it makes sense to remind the user how the script is supposed to be called.
print_help()
{
  printf '%s\n' "Pull a docker image and tag it (default tag=tardis:latest)"
  printf 'Usage: %s [-s|--srcimgtag <arg>] [-t|--tag <arg>] [-h|--help]\n' "$0"
  printf '\t%s\n' "-s, --srcimgtag: source path and tag to tardis image (default: 'missing')"
  printf '\t%s\n' "-t, --tag: final tag (default: 'tardis:latest')"
  printf '\t%s\n' "-h, --help: Prints help"
  printf '\n%s\n' "e.g.:
bash pull_tag.sh -s quay.io/eschen42/galaxy-tardis:v0.0.3
bash pull_tag.sh -s quay.io/eschen42/galaxy-tardis:v0.0.3 -t tardis:v0.0.3"
}


# The parsing of the command-line
parse_commandline()
{
  while test $# -gt 0
  do
    _key="$1"
    case "$_key" in
      # We support whitespace as a delimiter between option argument and its value.
      # Therefore, we expect the --srcimgtag or -s value.
      # so we watch for --srcimgtag and -s.
      # Since we know that we got the long or short option,
      # we just reach out for the next argument to get the value.
      -s|--srcimgtag)
        test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
        _arg_srcimgtag="$2"
        shift
        ;;
      # We support the = as a delimiter between option argument and its value.
      # Therefore, we expect --srcimgtag=value, so we watch for --srcimgtag=*
      # For whatever we get, we strip '--srcimgtag=' using the ${var##--srcimgtag=} notation
      # to get the argument value
      --srcimgtag=*)
        _arg_srcimgtag="${_key##--srcimgtag=}"
        ;;
      # We support getopts-style short arguments grouping,
      # so as -s accepts value, we allow it to be appended to it, so we watch for -s*
      # and we strip the leading -s from the argument string using the ${var##-s} notation.
      -s*)
        _arg_srcimgtag="${_key##-s}"
        ;;
      # See the comment of option '--srcimgtag' to see what's going on here - principle is the same.
      -t|--tag)
        test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
        _arg_tag="$2"
        shift
        ;;
      # See the comment of option '--srcimgtag=' to see what's going on here - principle is the same.
      --tag=*)
        _arg_tag="${_key##--tag=}"
        ;;
      # See the comment of option '-s' to see what's going on here - principle is the same.
      -t*)
        _arg_tag="${_key##-t}"
        ;;
      # The help argurment doesn't accept a value,
      # we expect the --help or -h, so we watch for them.
      -h|--help)
        print_help
        exit 0
        ;;
      # We support getopts-style short arguments clustering,
      # so as -h doesn't accept value, other short options may be appended to it, so we watch for -h*.
      # After stripping the leading -h from the argument, we have to make sure
      # that the first character that follows coresponds to a short option.
      -h*)
        print_help
        exit 0
        ;;
      *)
        _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
        ;;
    esac
    shift
  done
}

# Now call all the functions defined above that are needed to get the job done
parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash
if [ $_arg_srcimgtag != missing ]; then
  docker pull $_arg_srcimgtag && docker tag $_arg_srcimgtag $_arg_tag
  exit $?
else
  print_help
  exit 1
fi
# vim: sw=2 ts=2 et ai :
# ] <-- needed because of Argbash
