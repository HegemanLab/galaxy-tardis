## Bugs and missing features

- The approach of rebuilding conda environments is sensitive to changes of package availability in conda channels.
  - A more robust alternative would be to backup tarballs of the conda environments themselves.
- Need to back up and restore:
  - static HTML content ("welcome")
  - other features that I don't use yet
- Security issues
  - As of 2019.08.12, [CVE-2019-14697](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-14697) is still not fixed in the latest stable Alpine Linux build, 3.10.1.

## Release notes

- [v0.0.2](https://github.com/HegemanLab/galaxy-tardis/compare/v0.0.3...v0.0.2)
  - Upgrade Alpine Linux to 3.10.1
- [v0.0.2](https://github.com/HegemanLab/galaxy-tardis/compare/v0.0.2...v0.0.1)
  - Upgrade static CVS binary to 1.12.13
  - Upgrade static busybox binary to 1.31.0
- v0.0.1
  - First release
