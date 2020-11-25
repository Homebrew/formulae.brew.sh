---
layout: page
permalink: /docs/api/
redirect_from:
  - /api/
  - /docs/
---
# JSON API Documentation

## Metadata

### List formulae metadata for all {{ site.taps.core.repo }} or {{ site.taps.cask.repo }} formulae
List the `brew info --json --all` output for all current {{ site.taps.core.fullname }}, {{ site.taps.linux.fullname }} or {{ site.taps.cask.fullname }} formulae.

```
GET https://formulae.brew.sh/api/formula.json
GET https://formulae.brew.sh/api/formula-linux.json
GET https://formulae.brew.sh/api/cask.json
```

#### [Response](https://formulae.brew.sh/api/formula.json)
```json
[
  ...
  {
    "name": "wget",
    "full_name": "wget",
    "oldname": null,
    "aliases": [],
    "versioned_formulae": [],
    "desc": "Internet file retriever",
    "homepage": "https://www.gnu.org/software/wget/",
    "versions": {
      "stable": "1.20.3",
      "devel": null,
      "head": "HEAD",
      "bottle": true
    },
    "urls": {
      "stable": {
        "url": "https://ftp.gnu.org/gnu/wget/wget-1.20.3.tar.gz",
        "tag": null,
        "revision": null
      }
    },
    "revision": 2,
    "version_scheme": 0,
    "bottle": {
      "stable": {
        "rebuild": 0,
        "cellar": "/usr/local/Cellar",
        "prefix": "/usr/local",
        "root_url": "https://homebrew.bintray.com/bottles",
        "files": {
          "catalina": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.20.3_2.catalina.bottle.tar.gz",
            "sha256": "ef65c759c5097a36323fa9c77756468649e8d1980a3a4e05695c05e39568967c"
          },
          "mojave": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.20.3_2.mojave.bottle.tar.gz",
            "sha256": "28f4090610946a4eb207df102d841de23ced0d06ba31cb79e040d883906dcd4f"
          },
          "high_sierra": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.20.3_2.high_sierra.bottle.tar.gz",
            "sha256": "91dd0caca9bd3f38c439d5a7b6f68440c4274945615fae035ff0a369264b8a2f"
          }
        }
      }
    },
    "keg_only": false,
    "bottle_disabled": false,
    "options": [],
    "build_dependencies": [
      "pkg-config"
    ],
    "dependencies": [
      "libidn2",
      "openssl@1.1"
    ],
    "recommended_dependencies": [],
    "optional_dependencies": [],
    "uses_from_macos": [],
    "requirements": [],
    "conflicts_with": [],
    "caveats": null,
    "installed": [
      {
        "version": "1.20.3_2",
        "used_options": [],
        "built_as_bottle": true,
        "poured_from_bottle": true,
        "runtime_dependencies": [
          {
            "full_name": "gettext",
            "version": "0.20.2"
          },
          {
            "full_name": "libunistring",
            "version": "0.9.10"
          },
          {
            "full_name": "libidn2",
            "version": "2.3.0"
          },
          {
            "full_name": "openssl@1.1",
            "version": "1.1.1g"
          }
        ],
        "installed_as_dependency": false,
        "installed_on_request": true
      }
    ],
    "linked_keg": "1.20.3_2",
    "pinned": false,
    "outdated": false
  },
  ...
]
```

### Get formula metadata for a {{ site.taps.core.repo }} formula
Get the `brew info --json <formula>` output for a single, current {{ site.taps.core.fullname }} or {{ site.taps.linux.fullname }} formula with an extra `analytics` key containing analytics data.

```
GET https://formulae.brew.sh/api/formula/${FORMULA}.json
GET https://formulae.brew.sh/api/formula-linux/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula, e.g. `wget`

#### [Response](https://formulae.brew.sh/api/formula/wget.json)
```json
{
  "name": "wget",
  "full_name": "wget",
  "oldname": null,
  "aliases": [],
  "versioned_formulae": [],
  "desc": "Internet file retriever",
  "homepage": "https://www.gnu.org/software/wget/",
  "versions": {
    "stable": "1.20.3",
    "devel": null,
    "head": "HEAD",
    "bottle": true
  },
  "urls": {
    "stable": {
      "url": "https://ftp.gnu.org/gnu/wget/wget-1.20.3.tar.gz",
      "tag": null,
      "revision": null
    }
  },
  "revision": 2,
  "version_scheme": 0,
  "bottle": {
    "stable": {
      "rebuild": 0,
      "cellar": "/usr/local/Cellar",
      "prefix": "/usr/local",
      "root_url": "https://homebrew.bintray.com/bottles",
      "files": {
        "catalina": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.20.3_2.catalina.bottle.tar.gz",
          "sha256": "ef65c759c5097a36323fa9c77756468649e8d1980a3a4e05695c05e39568967c"
        },
        "mojave": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.20.3_2.mojave.bottle.tar.gz",
          "sha256": "28f4090610946a4eb207df102d841de23ced0d06ba31cb79e040d883906dcd4f"
        },
        "high_sierra": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.20.3_2.high_sierra.bottle.tar.gz",
          "sha256": "91dd0caca9bd3f38c439d5a7b6f68440c4274945615fae035ff0a369264b8a2f"
        }
      }
    }
  },
  "keg_only": false,
  "bottle_disabled": false,
  "options": [],
  "build_dependencies": [
    "pkg-config"
  ],
  "dependencies": [
    "libidn2",
    "openssl@1.1"
  ],
  "recommended_dependencies": [],
  "optional_dependencies": [],
  "uses_from_macos": [],
  "requirements": [],
  "conflicts_with": [],
  "caveats": null,
  "installed": [
    {
      "version": "1.20.3_2",
      "used_options": [],
      "built_as_bottle": true,
      "poured_from_bottle": true,
      "runtime_dependencies": [
        {
          "full_name": "gettext",
          "version": "0.20.2"
        },
        {
          "full_name": "libunistring",
          "version": "0.9.10"
        },
        {
          "full_name": "libidn2",
          "version": "2.3.0"
        },
        {
          "full_name": "openssl@1.1",
          "version": "1.1.1g"
        }
      ],
      "installed_as_dependency": false,
      "installed_on_request": true
    }
  ],
  "linked_keg": "1.20.3_2",
  "pinned": false,
  "outdated": false,
  "analytics": {
    "install": {
      "30d": {
        "wget": 103008,
        "wget --HEAD": 5
      },
      "90d": {
        "wget": 311247,
        "wget --HEAD": 14,
        "wget --with-libressl": 1
      },
      "365d": {
        "wget": 1350482,
        "wget --HEAD": 67,
        "wget --with-libressl": 14
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 100179,
        "wget --HEAD": 5
      },
      "90d": {
        "wget": 301209,
        "wget --HEAD": 13
      },
      "365d": {
        "wget": 1277288,
        "wget --HEAD": 66
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  }
}
```

### Get formula metadata for a {{ site.taps.cask.repo }} formula
Get the JSON output for a single, current {{ site.taps.cask.fullname }} formula with an extra `analytics` key containing analytics data.

```
GET https://formulae.brew.sh/api/cask/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula, e.g. `docker`

#### [Response](https://formulae.brew.sh/api/cask/docker.json)
```json
{
  "token": "docker",
  "name": [
    "Docker Desktop",
    "Docker Community Edition",
    "Docker CE"
  ],
  "homepage": "https://www.docker.com/community-edition",
  "url": "https://download.docker.com/mac/stable/45183/Docker.dmg",
  "appcast": "https://download.docker.com/mac/stable/appcast.xml",
  "version": "2.3.0.2,45183",
  "sha256": "ed187365b2b9c6de0ddaa1146c86796f0f3a2f6af1cb2693211e600aad233f35",
  "artifacts": [
    {
      "delete": [
        "/Library/PrivilegedHelperTools/com.docker.vmnetd",
        "/private/var/tmp/com.docker.vmnetd.socket",
        "$(brew --prefix)/bin/docker",
        "$(brew --prefix)/bin/docker-compose",
        "$(brew --prefix)/bin/docker-credential-desktop",
        "$(brew --prefix)/bin/docker-credential-osxkeychain",
        "$(brew --prefix)/bin/hyperkit",
        "$(brew --prefix)/bin/kubectl",
        "$(brew --prefix)/bin/kubectl.docker",
        "$(brew --prefix)/bin/notary",
        "$(brew --prefix)/bin/vpnkit"
      ],
      "launchctl": [
        "com.docker.helper",
        "com.docker.vmnetd"
      ],
      "quit": "com.docker.docker",
      "signal": {}
    },
    [
      "Docker.app"
    ],
    {
      "trash": [
        "$(brew --prefix)/bin/docker-compose.backup",
        "$(brew --prefix)/bin/docker.backup",
        "~/Library/Application Scripts/com.docker.helper",
        "~/Library/Caches/KSCrashReports/Docker",
        "~/Library/Caches/com.docker.docker",
        "~/Library/Caches/com.plausiblelabs.crashreporter.data/com.docker.docker",
        "~/Library/Containers/com.docker.docker",
        "~/Library/Containers/com.docker.helper",
        "~/Library/Group Containers/group.com.docker",
        "~/Library/Preferences/com.docker.docker.plist"
      ],
      "rmdir": [
        "~/Library/Caches/KSCrashReports",
        "~/Library/Caches/com.plausiblelabs.crashreporter.data"
      ],
      "signal": {}
    }
  ],
  "caveats": null,
  "depends_on": {},
  "conflicts_with": null,
  "container": null,
  "auto_updates": true,
  "analytics": {
    "install": {
      "30d": {
        "docker": 16315
      },
      "90d": {
        "docker": 53660
      },
      "365d": {
        "docker": 239542
      }
    }
  }
}
```

## Analytics

### List one category of analytics events
List all analytics events for a specified category over a number of days, ordered by event frequency count.

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/${DAYS}.json
GET https://formulae.brew.sh/api/analytics-linux/${CATEGORY}/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the analytics event category, i.e.
  - `install`: the installation of all formulae
  - `install-on-request`: the requested installation of all formulae (i.e. not as a dependency of other formulae)
  - `cask-install`: the installation of all casks
    - only available under `/analytics/`
  - `build-error`: the installation failure of all formulae
  - `os-version`: the macOS version of all machines that have submitted an event
    - only available under `/analytics/`
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### [Response](https://formulae.brew.sh/api/analytics/install/30d.json)
```json
{
  "category": "install",
  "total_items": 13856,
  "start_date": "2020-04-12",
  "end_date": "2020-05-12",
  "total_count": 22408801,
  "items": [
    ...
    {
      "number": 47,
      "formula": "wget",
      "count": "103,008",
      "percent": "0.46"
    },
    ...
    {
      "number": 7809,
      "formula": "wget --HEAD",
      "count": "5",
      "percent": "0.00"
    },
    ...
  ]
}
```

### List analytics events for all {{ site.taps.core.repo }} formulae
List all the {{ site.taps.core.fullname }} or {{ site.taps.linux.fullname }} formulae's analytics events for a specified category over a number of days, grouped by formula name.

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/homebrew-core/${DAYS}.json
GET https://formulae.brew.sh/api/analytics-linux/${CATEGORY}/linuxbrew-core/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the analytics event category, i.e.
  - `install`: the installation of all {{ site.taps.core.repo }} formulae
  - `install-on-request`: the requested installation of all {{ site.taps.core.repo }} formulae (i.e. not as a dependency of other formulae)
  - `build-error`: the installation failure of all {{ site.taps.core.repo }} formulae
    - only `${DAYS}: 30d` (30 days) is available
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### [Response](https://formulae.brew.sh/api/analytics/install/homebrew-core/30d.json)
```json
{
  "category": "install",
  "total_items": 7078,
  "start_date": "2020-04-12",
  "end_date": "2020-05-12",
  "total_count": 21941863,
  "formulae": {
    ...
    "wget": [
      {
        "formula": "wget",
        "count": "103,008"
      },
      {
        "formula": "wget --HEAD",
        "count": "5"
      },
      ...
    ],
    ...
  }
}
```

### List analytics events for all {{ site.taps.cask.repo }} formulae
List all the {{ site.taps.cask.fullname }} formulae's analytics events for the `cask-install` category over a number of days, grouped by formula name.

```
GET https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/${DAYS}.json
```

#### Variables
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### [Response](https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/30d.json)
```json
{
  "category": "cask_install",
  "total_items": 5510,
  "start_date": "2020-04-12",
  "end_date": "2020-05-12",
  "total_count": 6589765,
  "formulae": {
    ...
    "docker": [
      {
        "cask": "docker",
        "count": "16,315"
      }
    ],
    "docker-edge": [
      {
        "cask": "docker-edge",
        "count": "170"
      }
    ],
    "docker-toolbox": [
      {
        "cask": "docker-toolbox",
        "count": "416"
      }
    ],
    ...
  }
}
```
