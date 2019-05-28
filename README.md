# TARDIS - Temporal Archive Remote Distribution and Installation System

## Motivation: Administering a Local Galaxy with Minimal Stress

Suppose that:
- You want to host a local instance of Galaxy.
- You want to lose nothing if your Galaxy is swallowed by a black hole.
- You want your backups to be efficient, easy to manage, secure, and offsite.

Basically, you want to be able to travel (back) in time.

The Galaxy ["Temporal Archive Remote Distribution and Installation System", https://github.com/HegemanLab/galaxy-tardis](https://github.com/HegemanLab/galaxy-tardis) may be right for you.
- Any resemblance of the Galaxy TARDIS to [the TARDIS from *Doctor Who*](https://en.wikipedia.org/wiki/TARDIS) is purely (albeit intentionally) coincidental.

Notably, the intent is **not** to replace other automation systems (e.g., ansible):
- Rather, it is focused on restoring an existing Galaxy instance to a known state.
- However, the TARDIS facilitates migrating an instance to another host.

## Overview

- The purpose of the Galaxy `tardis` Docker image is to back up and restore Galaxy instances that are based on [galaxy-docker-stable](https://github.com/bgruening/docker-galaxy-stable/).
- The only storage back-end for backup implemented thus far is S3-compatible storage such as Ceph.
- You can build the image from this repository with:
```bash
bash build_notar.sh
```
- A practical example of application of the Galaxy TARDIS is given in the `restore example` directory.

## TL;DR

For a quick start with minimal reading, got to [https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html#getting-started---tldr---part-1---setup-composition-and-the-tardis](https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html#getting-started---tldr---part-1---setup-composition-and-the-tardis).

## Usage 

Usage for the `tardis` Docker image:

```
tardis - Temporal Archive Remote Distribution and Installation System for Galaxy-in-Docker

Usage:
  tardis backup                - Back up PostgreSQL database and galaxy-central/config.
  tardis transmit              - Transmit datasets and backup to Amazon-S3-compatible storage.
  tardis cron [hour24UTC]      - Run backup and transmit daily at hour24 UTC.
  tardis restore_files         - Retrieve datasets from S3 (not desirable when using object store).
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
                  Linux `date` program, see e.g. http://man7.org/linux/man-pages/man1/date.1.html)
  hour24UTC   - any two digit hour for backup to occur; must be UTC (GMT), not local time.
  url_or_path - any URL from https://repo.continuum.io/miniconda/, or path (e.g., if you
                  copied the miniconda installer to your export directory)
  md5sum      - MD5 digest for url_or_path, e.g., from https://repo.continuum.io/miniconda/

Optional environment variables:
  EXPORT_DIR (default "/export") - path to directory containing "galaxy-central"
    - Optional, used by most tasks
  PGDATA (default "/var/lib/postgresql/data") - internal path to database in "galaxy-postgres"
    - Optional, used by "backup" and "seed_database"
  PGDATA_SUBDIR (default "main") - name of subdirectory of PGDATA_PARENT where PostgreSQL database lives
Required environment Variables (set using the "-e" option of the "docker run")
  These are the environment variables and the tasks that require them:
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
Required bind-mounts:
  "/export"       - required by all but "bash" and "help"
  "/var/run/docker.sock"  - required by "seed_database", "backup"
  "/opt/s3/dest.s3cfg"    - required by "transmit", "retrieve_config", and "restore_files"
  "/opt/s3/dest.config"   - required by "transmit", "retrieve_config", and "restore_files"

```

## Documentation

The main documentation for using the Galaxy TARDIS may be found at [https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html](https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html).

### How to build the Docker image:

See [https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html#build-and-fly-the-tardis](https://hegemanlab.github.io/galaxy-tardis/tardis-intro.html#build-and-fly-the-tardis)

## Supporting Software

### CVS

Configuration is backed up using CVS repositories

#### Why use CVS rather than Git?

CVS (Concurrent Versions System, [https://www.nongnu.org/cvs/](https://www.nongnu.org/cvs/)) stores all revisions of a text file in an extremely compact format.  This project backs up the Galaxy database to a single SQL file.  Multiple revisions of this file take up an much larger space in a Git repository, whereas, in a CVS repository, they take up little more room than a few times the size of the SQL file.  CVS has been replaced for general software development, but it seems to fill a good niche here.  On the other hand, a more compelling question might be "Why use CVS rather than RCS?", since both CVS and RCS use the same storage format - maybe CVS is more familiar and easier to install (CVS has a single binary, compared to nine for RCS).

There may be a modern source control system that could achieve compact storage and a single binary.  Fossil ([https://www.fossil-scm.org/](https://www.fossil-scm.org/)) seems like a possible candidate, but I have not yet worked with it enough to become familiar with its operation and security model.

#### Statically linked `cvs` binary

The `support/cvs-static` binary was compiled and statically linked as described at [https://github.com/eschen42/alpine-cbuilder#cvs-executable-independent-of-glibc](https://github.com/eschen42/alpine-cbuilder#cvs-executable-independent-of-glibc)

### Busybox

This Docker image is based on Alpine linux, which uses the `musl` C library rather than `glibc`.  Busybox provides diverse functionality, especially useful inside a very minimal Docker container.  However, I don't want to have track one `musl` busybox and another `glibc` busybox, so I replaced the Alpine busybox in the image with a statically linked busybox, built as described at [https://github.com/eschen42/alpine-cbuilder#statically-linked-busybox](https://github.com/eschen42/alpine-cbuilder#statically-linked-busybox).

### Docker client

The `support/docker-usernetes` binary is a statically linked binary that was extracted from:
[https://github.com/rootless-containers/usernetes/releases/tag/v20190511.1](https://github.com/rootless-containers/usernetes/releases/tag/v20190511.1)
as follows:
```bash
wget https://github.com/rootless-containers/usernetes/releases/download/v20190511.1/usernetes-x86_64.tbz
bzip2 -d usernetes-x86_64.tbz
tar -xvf usernetes-x86_64.tar usernetes/bin/docker
cp usernetes/bin/docker support/docker-usernetes
rm -rf usernetes-x86_64.tar usernetes
```
