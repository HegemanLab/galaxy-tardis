#!/bin/bash

# NOTE WELL - This script ASSUMES that it is located in export/s3

# set the actual script directory per https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve ${SOURCE} until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}" # if ${SOURCE} was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )"

# set EXPORT_ROOT and CONFIG_BUCKET
source ${DIR}/dest.config

if [ $# = 1 -a -e $1 ]; then 
  if [[ "${1:0:1}" = "/" ]]; then
    ABSOLUTE=$1
  else
    ABSOLUTE=$( cd $(dirname $1) && pwd -P)/$(basename $1)
  fi
  s3cmd -c ${DIR}/dest.s3cfg sync ${ABSOLUTE} s3://${CONFIG_BUCKET}${ABSOLUTE}
else
  echo usage: bucket_backup.sh path_to_a_file
fi
