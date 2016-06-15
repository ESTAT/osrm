osrm CHANGELOG
==============

This file is used to list changes made in each version of the osrm cookbook.

5.1.0
-----

- Bump default osrm-backend version to 5.1.0

5.0.2
-----

- Bump default osrm-backend version to 5.0.2

5.0.1
-----

- Bump default osrm-backend version to 5.0.1

5.0.0
-----

- Update to new osrm-routed api (v5)
- Do not automatically create user in routed provider
- Remove some unused attributes in providers

0.3.3
-----

- Fix download paths for U.S. states

0.3.2
-----

- Fix issue with map download

0.3.1
-----

- Pinned version to 0.4.1
- Install osrm-datastore
- Add workaround for port option ("Port" statement in configuration seems to be ignored in latest version)

0.3.0
-----

- Removed `Memory` option for osrm_extract. This option was removed from osrm-extract some time ago

0.2.2
-----

- Fix a bug in map_prepare, now uses map_dir + profile + map basename as output path

0.2.1
-----

- Fix a bug in map_extract, now creates the correct directory before extracting

0.2.0
-----

- Use status option of routed service, prevents trying to restart a already running routed
- Add path and map_path attributes to providers, this allows local files instead of urls
- Do not check map checksum by default (will break with default settings on custom maps otherwise)
- Renamed map_path attribute to map_dir
- Add map_base attribute for map_routed provider


0.1.2
-----

- Attribute default for cleanup set to false [map_prepare]
- Add configuration settings for stxxl
- Attributes overriden in wrapper cookbooks are now evaluated correctly
- Use execute "rm -f" instead of file() { action :delete } for performance reasons
- Increase execute timeout to 1 day and add timeout option to the following providers

  * map
  * map_extract
  * map_prepare

  This is necessary for extract/prepare tasks that take longer than 1h.

- Added chefspecs
- Several small bugfixes


0.1.1
-----

- Small bugfixes


0.1.0
-----
- [Chris Aumann] - Initial release of osrm
