FROM alpine:3.12
LABEL maintainer="'Art Eschenlauer, esch0041@umn.edu'"

###################################  Accounts and Groups  ####################################
# Add required galaxy and postgres accounts
RUN sed -i -e 's/^postgres:x:[^:]*:[^:]*:/postgres:x:999:999:/' /etc/passwd
RUN sed -i -e 's/^postgres:x:[^:]*:/postgres:x:999:/'           /etc/group
RUN adduser -s /bin/bash -h /export -D -H -u 1450 -g "Galaxy-file owner" galaxy

######################################  Python Basis  ########################################
# Base python for the image as Python3
RUN apk add python3 py3-pip

########################################  Packages  ##########################################
# The coreutils binary adds a megabyte to the image size,
#   but it gives some required invocation options for 'date'
RUN apk add coreutils
# Including bash (required), curl (handy)
RUN apk add bash curl
# Support scheduled activity, e.g., daily backups
RUN apk add dcron
# Support documentation in the unix-manual format
# Package mandoc is needed to view man pages
#   Package name has changed from man to mandoc in alpine 3.12
#     according to https://stackoverflow.com/a/62240153
RUN apk add mandoc && bash -c 'for i in {1..8}; do mkdir -p /usr/local/man/man${i}; done'
# To get all of the standard man pages themselves, you could uncomment the next line,
#   but note that it nearly doubles the size of the image.
#RUN apk add man-pages
# Support the vim editor
RUN apk add vim

####################################  Large Binaries  #######################################
# Substitute statically linked busybox so that it can be shared with glibc-based containers
#   See https://github.com/eschen42/alpine-cbuilder#statically-linked-busybox
#   and https://github.com/HegemanLab/galaxy-tardis/releases/tag/binary1-pre
RUN mkdir -p /opt/support && \
    cd       /opt/support && \
    wget https://github.com/HegemanLab/galaxy-tardis/releases/download/binary3-pre/busybox-1.32.0-static.gz --output-document busybox.gz && \
    gzip -d busybox.gz && \
    chmod +x busybox
RUN ln -f /opt/support/busybox /bin/busybox

# The coreutils binary adds a megabyte to the image size,
#   but it gives some required invocation options for 'date'
RUN apk add coreutils
# Including bash (required), curl (handy)
RUN apk add bash curl
# Include py-pip for installing s3cmd (see below) 
RUN apk add py-pip
# Support scheduled activity, e.g., daily backups
RUN apk add dcron

# Add statically linked docker binary
#   See https://github.com/rootless-containers/usernetes/releases/tag/v20190212.0
#   and https://github.com/HegemanLab/galaxy-tardis/releases/tag/binary1-pre
RUN mkdir -p /usr/local/bin && \
    cd       /usr/local/bin && \
    wget https://github.com/HegemanLab/galaxy-tardis/releases/download/binary1-pre/docker-usernetes.gz --output-document docker.gz && \
    gzip -d docker.gz && \
    chmod +x docker && \
    cd ..

# Add statically linked cvs binary so that it can be shared with glibc-based containers
#   See https://github.com/eschen42/cvs-static#how-to-build-a-statically-linked-cvs-binary
#   and https://github.com/eschen42/alpine-cbuilder#cvs-executable-independent-of-glibc
RUN cd /opt/support && \
    wget https://github.com/eschen42/cvs-static/releases/download/v1.12.13-1/cvs-static.gz --output-document cvs.gz && \
    gzip -d cvs.gz && \
    chmod +x cvs
RUN ln /opt/support/cvs /usr/local/bin/cvs

######################################## Scripts ##########################################
# Support file, configuration, and database backup and restore with S3-compatible block storage
COPY s3/live_file_backup.sh                  /opt/s3/live_file_backup.sh
COPY s3/live_file_restore.sh                 /opt/s3/live_file_restore.sh
COPY s3/bucket_backup.sh                     /opt/s3/bucket_backup.sh
COPY s3/bucket_retrieve.sh                   /opt/s3/bucket_retrieve.sh
# S3-independent scripts to support backup and restore
COPY support/transmit_backup.sh              /opt/support/transmit_backup.sh
COPY support/retrieve_backup.sh              /opt/support/retrieve_backup.sh
# Dump galaxy configuration files and downloaded shed tools
COPY support/config_xml_dump.sh              /opt/support/config_xml_dump.sh
COPY support/pgadmin_dump.sh                 /opt/support/pgadmin_dump.sh
# Load galaxy configuration files and downloaded shed tools
COPY support/config_seed.sh                  /opt/support/config_seed.sh
# Upgrade miniconda as needed
COPY support/conda_upgrade.sh                /opt/support/conda_upgrade.sh
# Dump and load PostgreSQL database
COPY support/db_dump.sh                      /opt/support/db_dump.sh
COPY support/db_seed.sh                      /opt/support/db_seed.sh
# Core executable for the TARDIS container
COPY support/tardis                          /opt/support/tardis
COPY support/tardis_setup                    /opt/support/tardis_setup
# Daily backup cron task
COPY support/backup.crontab                  /opt/support/backup.crontab
COPY support/cron.sh                         /opt/support/cron.sh
# Entrypoint executable
COPY init                                    /opt/init

# Include s3cmd for transmitting files to Amazon-S3 compatible buckets.  See e.g.:
#   https://en.wikipedia.org/wiki/Amazon_S3#S3_API_and_competing_services
# Modify s3cmd to make it unbuffered
RUN pip install s3cmd && \
    sed -i -e "s/config_file = None/config_file = None; sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)/" /usr/bin/s3cmd

#######################################  Permissions  ######################################
# Executable-file permissions (besides busybox and cvs because they are hard-linked)
RUN chmod +x                                 /opt/init
RUN chmod +x                                 /opt/s3/*.sh
RUN chmod +x                                 /opt/support/*.sh
RUN chmod +x                                 /opt/support/tardis

#######################################  Wrapping Up  ######################################
# Set the entry point
ENTRYPOINT ["/opt/init"]
# Provide intra-container copy of this container-definition
COPY Dockerfile /opt/support/Dockerfile
