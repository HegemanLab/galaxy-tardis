[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3339453.svg)](https://doi.org/10.5281/zenodo.3339453)
[![Docker Repository on quay.io](https://quay.io/repository/eschen42/galaxy-tardis/status "Docker Repository on quay.io")](https://quay.io/repository/eschen42/galaxy-tardis)

# TARDIS - Temporal Archive Remote Distribution and Installation System

## Motivation: Administering a Local Galaxy with Minimal Stress

Suppose that:
- You want to host a local instance of Galaxy.
- You want to lose nothing if your Galaxy is swallowed by a black hole.
- You want your backups to be efficient, easy to manage, secure, and offsite.

Basically, you want to be able to travel (back) in time.

The Galaxy ["Temporal Archive Remote Distribution and Installation System", https://github.com/HegemanLab/galaxy-tardis](https://github.com/HegemanLab/galaxy-tardis) may be right for you.
- Any resemblance of the Galaxy TARDIS to [the TARDIS from *Doctor Who*](https://en.wikipedia.org/wiki/TARDIS) is purely (albeit intentionally) coincidental.

The intent of Galaxy TARDIS is:
- to facilitate restoration of an existing ([`docker-galaxy-stable`](https://github.com/bgruening/docker-galaxy-stable/)-based) Galaxy instance to a known state.
- to facilitates migrating an instance to another host.

Notably, the intent is **not** to replace other automation systems (e.g., ansible); conversely, Galaxy TARDIS facilitate the job of automating backup and restoration of a `docker-galaxy-stable`-based Galaxy instance.

## Overview

- The purpose of the Galaxy `tardis` Docker image is to back up and restore Galaxy instances that are based on [docker-galaxy-stable](https://github.com/bgruening/docker-galaxy-stable/).
- The only storage back-end for backup implemented thus far is S3-compatible storage such as Ceph.
    - Because the implementation is modular, it should not be particularly challenging to support other back-ends.
- You can [pull the image](#how-to-pull-the-docker-image-by-tag) or [build it yourself](#how-to-build-the-docker-image).
- A practical example of application of the Galaxy TARDIS is given in the `restore example` directory.

### Documentation

Documentation and instructions for using the Galaxy TARDIS may be found at [https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html](https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html).
This also describes the illustrative example available in the `restore_example` directory.

### How to pull the Docker image by tag:

Identify a tag with a "Passed" security tag from [https://quay.io/repository/eschen42/galaxy-tardis?tab=tags](https://quay.io/repository/eschen42/galaxy-tardis?tab=tags).
> For example, when this was written, the "v0.0.1" had passed the "security scan" for known vulnerabilities.
  As time goes on, new vulnerabilites may be discovered and the "security scan" status of a tag may change.

Use the tag that you chose to pull the image and tag it as `tardis:latest`.  The `pull_tag.sh` exists to simplify this:
```bash
bash pull_tag.sh -s quay.io/eschen42/galaxy-tardis:v0.0.1 -t tardis:latest
```

### How to build the Docker image:

You can build the image with:
```bash
git clone https://github.com/HegemanLab/galaxy-tardis.git
cd galaxy-tardis
bash build_notar.sh
```

### Quick Start

Suppose that you have significant familiarity with the following (links are not provided to avoid the impression that following a few links is a substitute for significant experience):
- bash
- docker
- docker-compose
- S3
- s3cmd
- docker-galaxy-stable

If so, then try looking at the first lines of the comment at the head of the [`restore_example/DEMO` script](https://github.com/HegemanLab/galaxy-tardis/blob/master/restore_example/DEMO).
Otherwise, please [see Documentation](#documentation).

## Usage 

Please [see Documentation](#documentation) to understand how the parts of Galaxy TARDIS work.

If you were to:
- create `tags-for-tardis_envar-to-source.sh` by copying `tags-for-tardis_envar-to-source.sh.example`
- adjust it for your Galaxy instance (based on `docker-galaxy-stable` or one of its derivitives)
- and run:
```bash
source tardis_envar.sh
$TARDIS help
```
you would see the following help text:

```
tardis - Temporal Archive Remote Distribution and Installation System for Galaxy-in-Docker

Usage:
  tardis backup                - Back up PostgreSQL database and galaxy-central/config.
  tardis transmit              - Transmit datasets and backup to Amazon-S3-compatible storage.
  tardis cron [hour24UTC]      - Run backup and transmit daily at hour24 UTC.
  tardis restore_datasets      - Retrieve datasets from S3 (not desirable when using object store).
  tardis retrieve_config       - Retrieve database and config backup (but not datasets) from S3.
  tardis apply_config [date]   - Restore config from backup, whether from S3 or "tardis backup".
  tardis seed_database [date]  - Replace PostgreSQL database with copy from backup.
  tardis purge_empty_tmp_dirs  - Purge empty tmp directories that accumulate with datasets.
  tardis upgrade_database      - Upgrade the PostgreSQL database to match the Galaxy version.
  tardis bash                  - Enter a bash shell.
  tardis upgrade_conda {url_or_path} {md5sum}
                               - Upgrade conda (both arguments required)
where:
  date        - can be relative (e.g., "1 hour ago") or absolute (e.g., any format accepted by the
                  --date argument of the Linux `date` program, see e.g. https://linux.die.net/man/1/date)
  hour24UTC   - any two digit hour for backup to occur; must be UTC (GMT), not local time.
  url_or_path - any URL from https://repo.continuum.io/miniconda/, or path (e.g., if you
                  copied the miniconda installer to your export directory)
  md5sum      - MD5 digest for url_or_path, e.g., from https://repo.continuum.io/miniconda/

Optional environment variable:
  PGDATA_SUBDIR (default "main") - name of subdirectory of PGDATA_PARENT where PostgreSQL database lives
    - Used by "seed database"
Required environment Variables (set using the "-e" option of the "docker run")
  These are the environment variables and the tasks that require them:
    EXPORT_DIR (usually "/export") - path to directory containing "galaxy-central"
      - Used by most tasks
    HOST_EXPORT_DIR - host path to the EXPORT_DIR as bind-mounted in docker
      - Used by "seed database"
    HOST_PGDATA_PARENT - host directory whose PGDATA_SUBDIR subdirectory is
        bind-mounted by the "galaxy-postgres" container to the path specified by PGDATA
      - Used by "seed database"
    PGDATA_PARENT - bind-mount within "tardis" for HOST_PGDATA_PARENT
      - Used by "seed database"
    IMAGE_POSTGRES - docker image for PostgreSQL, e.g., "quay.io/bgruening/galaxy-postgres"
      - Used by "seed database"
    TAG_POSTGRES - tag for docker image for PostgreSQL, e.g., "9.6.5_for_19.01"
      - Used by "seed database"
    IMAGE_GALAXY_INIT - docker image for initializing Galaxy, e.g., "quay.io/bgruening/galaxy-init"
      - Used by "apply_config" and "upgrade_conda"
    TAG_GALAXY - tag for docker image for PostgreSQL, e.g., "19.01"
      - Used by "apply_config" and "upgrade_conda"
    CONTAINER_GALAXY - name of instantiated PostgreSQL container, e.g., "galaxy-init"
      - Used by "apply_config" and "upgrade_conda"
Required bind-mounts:
  "/export"       - required by all but "bash" and "help"
  "/var/run/docker.sock"  - required by "seed_database", "backup"
  "/opt/s3/dest.s3cfg"    - required by "transmit", "retrieve_config", and "restore_datasets"
  "/opt/s3/dest.config"   - required by "transmit", "retrieve_config", and "restore_datasets"

```

## Supporting Software

### CVS

Configuration is backed up using CVS repositories

#### Why use CVS rather than Git?

CVS (Concurrent Versions System, [https://www.nongnu.org/cvs/](https://www.nongnu.org/cvs/)) stores all revisions of a text file in an extremely compact format.  This project backs up the Galaxy database to a single SQL file.  Multiple revisions of this file take up an much larger space in a Git repository, whereas, in a CVS repository, they take up little more room than a few times the size of the SQL file.  CVS has been replaced for general software development, but it seems to fill a good niche here.  On the other hand, a more compelling question might be "Why use CVS rather than RCS?", since both CVS and RCS use the same storage format - maybe CVS is more familiar and easier to install (CVS has a single binary, compared to nine for RCS).

There may be a modern source control system that could achieve compact storage and a single binary.  Fossil ([https://www.fossil-scm.org/](https://www.fossil-scm.org/)) seems like a possible candidate, but I have not yet worked with it enough to become familiar with its operation and security model.

#### Statically linked `cvs` binary

The `support/cvs-static` binary, version 1.12.13, was compiled and statically linked as described at [https://github.com/eschen42/cvs-static#how-to-build-a-statically-linked-cvs-binary](https://github.com/eschen42/cvs-static#how-to-build-a-statically-linked-cvs-binary)

### Busybox

This Docker image is based on Alpine linux, which uses the `musl` C library rather than `glibc`.  Busybox provides diverse functionality, especially useful inside a very minimal Docker container.  However, I don't want to have track one `musl` busybox and another `glibc` busybox, so I replaced the Alpine busybox in the image with a statically linked busybox, built as described at [https://github.com/eschen42/alpine-cbuilder#statically-linked-busybox](https://github.com/eschen42/alpine-cbuilder#statically-linked-busybox).

### Docker clients

The `support/docker-usernetes` binary is a statically linked binary that was extracted from:
[https://github.com/rootless-containers/usernetes/releases/tag/v20190511.1](https://github.com/rootless-containers/usernetes/releases/tag/v20190511.1)
as follows:
```bash
wget -O - https://github.com/rootless-containers/usernetes/releases/download/v20190511.1/SHA256SUM 2>/dev/null
wget https://github.com/rootless-containers/usernetes/releases/download/v20190511.1/usernetes-x86_64.tbz
sha256sum usernetes-x86_64.tbz
# If the sha256 sums don't match, stop here!
bzip2 -d usernetes-x86_64.tbz
tar -xvf usernetes-x86_64.tar usernetes/bin/docker
cp usernetes/bin/docker support/docker-usernetes
rm -rf usernetes-x86_64.tar usernetes
```

### dcron - Dillon's Cron

[Dillon's Cron Daemon](http://www.jimpryor.net/linux/dcron.html) was chosen over the more traditional Vixie Cron because:
- "having to combine a cron daemon with another daemon like anacron makes for too much complexity", and
- "All jobs are run with `/bin/sh` for conformity and portability".

## Bugs and missing features

See [./RELEASES.md#bugs-and-missing-features](./RELEASES.md#bugs-and-missing-features)
 
## Release notes

See [./RELEASES.md#release-notes](./RELEASES.md#release-notes)
