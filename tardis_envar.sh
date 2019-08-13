#!/bin/bash source this file - do not execute it

# set the actual script directory per https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

source $DIR/tags-for-tardis_envar-to-source.sh
# tags-for-tardis_envar-to-source.sh may contain, e.g.:
# TAG_GALAXY='19.01'
# EXPORT_DIR=/home/demo/export
# INTERNAL_EXPORT_DIR='/export'
# PGDATA_PARENT=/home/demo/postgres
# IMAGE_POSTGRES='quay.io/bgruening/galaxy-postgres'
# TAG_POSTGRES=9.6.5_for_19.01
# IMAGE_GALAXY_INIT='quay.io/bgruening/galaxy-init'
# CONTAINER_GALAXY_INIT='galaxy-init'
# TAG_GALAXY='19.01'

if [ ! -d ${EXPORT_DIR:?} ]; then
  # fail if EXPORT_DIR is not specified; to address this failure, e.g., EXPORT_DIR=/full/path/to/export
  echo "Please set EXPORT_DIR (the directory which must contain the exported files referenced by galomix-compose) before sourcing ${SOURCE}"
elif [ ! -d ${PGDATA_PARENT:?} ]; then
  # fail if PGDATA_PARENT is not specified; to address this failure, e.g., PGDATA_PARENT=/mnt/ace/piscesv/postgres
  echo "Please set PGDATA_PARENT (the directory which must contain a directory named 'main' containing the PostgreSQL data for galomix-compose) before sourcing ${SOURCE}"
elif [ -z "${TAG_POSTGRES:?}" ]; then
  # fail if TAG_POSTGRES is not specified; to address this failure, e.g., TAG_POSTGRES="9.6.5_for_19.01"
  echo "Please set TAG_POSTGRES (a valid tag for an image of quay.io/bgruening/galaxy-postgres) before sourcing ${SOURCE}"
elif [ -z "${MY_S3CFG}" ]; then
  echo "ERROR: environment variable MY_S3CFG is not set"
elif [ ! -f ${MY_S3CFG:?} ]; then
  # fail if ${MY_S3CFG:?} is not properly set or is not a path to a file
  echo "ERROR: ${MY_S3CFG:?} does not exist or is not a file"
elif [ ! -f $DIR/s3/dest.config ]; then
  # fail if $DIR/s3/dest.config is not proper
  echo "ERROR: $DIR/s3/dest.config does not exist or is not a file"
else
  TARDIS="docker run --rm -ti \
    -v ${XDG_RUNTIME_DIR:?}/docker.sock:/var/run/docker.sock \
    -v ${MY_S3CFG:?}:/opt/s3/dest.s3cfg \
    -v $DIR/s3/dest.config:/opt/s3/dest.config \
    -v ${EXPORT_DIR:?}:${INTERNAL_EXPORT_DIR:?} \
    -e EXPORT_DIR=${INTERNAL_EXPORT_DIR:?} \
    -e HOST_EXPORT_DIR=${EXPORT_DIR:?} \
    -v ${PGDATA_PARENT:?}:/pgparent \
    -e PGDATA_PARENT=/pgparent \
    -e HOST_PGDATA_PARENT=${PGDATA_PARENT:?} \
    -e PGDATA_SUBDIR=${PGDATA_SUBDIR:-main} \
    -e TAG_POSTGRES=${TAG_POSTGRES:?} \
    -e IMAGE_POSTGRES=${IMAGE_POSTGRES:?} \
    -e TAG_GALAXY=${TAG_GALAXY:?} \
    -e IMAGE_GALAXY_INIT=${IMAGE_GALAXY_INIT:?} \
    -e CONTAINER_GALAXY_INIT=${CONTAINER_GALAXY_INIT:?} \
    --name tardis tardis"
  echo "TARDIS=$TARDIS"
fi
