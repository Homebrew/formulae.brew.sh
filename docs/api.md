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
    "tap": "homebrew/core",
    "oldname": null,
    "aliases": [],
    "versioned_formulae": [],
    "desc": "Internet file retriever",
    "license": "GPL-3.0-or-later",
    "homepage": "https://www.gnu.org/software/wget/",
    "versions": {
      "stable": "1.21.1",
      "head": "HEAD",
      "bottle": true
    },
    "urls": {
      "stable": {
        "url": "https://ftp.gnu.org/gnu/wget/wget-1.21.1.tar.gz",
        "tag": null,
        "revision": null
      }
    },
    "revision": 0,
    "version_scheme": 0,
    "bottle": {
      "stable": {
        "rebuild": 0,
        "cellar": "/usr/local/Cellar",
        "prefix": "/usr/local",
        "root_url": "https://homebrew.bintray.com/bottles",
        "files": {
          "arm64_big_sur": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.arm64_big_sur.bottle.tar.gz",
            "sha256": "e9034fc9062d5d28972135be031876672aff18fa945ce37e9c2ee1e2c4287f3a"
          },
          "big_sur": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.big_sur.bottle.tar.gz",
            "sha256": "e6ea2a50b8196206f7072360e713535bb16fb786c8b5fe23cab05757e0f67b13"
          },
          "catalina": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.catalina.bottle.tar.gz",
            "sha256": "88116cb28d6b85e441d1bb9df0a1454b84f8b9d0e8817a5bee0f228acc59e75a"
          },
          "mojave": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.mojave.bottle.tar.gz",
            "sha256": "ae4e6f1dc4ecaf2bbed7700e8d64cdc671bf9d6c085ba335f119861fd15956fe"
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
        "version": "1.21.1",
        "used_options": [],
        "built_as_bottle": true,
        "poured_from_bottle": true,
        "runtime_dependencies": [
          {
            "full_name": "gettext",
            "version": "0.21"
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
            "version": "1.1.1j"
          }
        ],
        "installed_as_dependency": false,
        "installed_on_request": true
      }
    ],
    "linked_keg": "1.21.1",
    "pinned": false,
    "outdated": false,
    "deprecated": false,
    "deprecation_date": null,
    "deprecation_reason": null,
    "disabled": false,
    "disable_date": null,
    "disable_reason": null
  },
  ...
]
```

### Get formula metadata for a {{ site.taps.core.repo }} formula
Get the `brew info --json --formula <formula>` output for a single, current {{ site.taps.core.fullname }} or {{ site.taps.linux.fullname }} formula with extra keys containing analytics data and generation date.

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
  "tap": "homebrew/core",
  "oldname": null,
  "aliases": [],
  "versioned_formulae": [],
  "desc": "Internet file retriever",
  "license": "GPL-3.0-or-later",
  "homepage": "https://www.gnu.org/software/wget/",
  "versions": {
    "stable": "1.21.1",
    "head": "HEAD",
    "bottle": true
  },
  "urls": {
    "stable": {
      "url": "https://ftp.gnu.org/gnu/wget/wget-1.21.1.tar.gz",
      "tag": null,
      "revision": null
    }
  },
  "revision": 0,
  "version_scheme": 0,
  "bottle": {
    "stable": {
      "rebuild": 0,
      "cellar": "/usr/local/Cellar",
      "prefix": "/usr/local",
      "root_url": "https://homebrew.bintray.com/bottles",
      "files": {
        "arm64_big_sur": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.arm64_big_sur.bottle.tar.gz",
          "sha256": "e9034fc9062d5d28972135be031876672aff18fa945ce37e9c2ee1e2c4287f3a"
        },
        "big_sur": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.big_sur.bottle.tar.gz",
          "sha256": "e6ea2a50b8196206f7072360e713535bb16fb786c8b5fe23cab05757e0f67b13"
        },
        "catalina": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.catalina.bottle.tar.gz",
          "sha256": "88116cb28d6b85e441d1bb9df0a1454b84f8b9d0e8817a5bee0f228acc59e75a"
        },
        "mojave": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.21.1.mojave.bottle.tar.gz",
          "sha256": "ae4e6f1dc4ecaf2bbed7700e8d64cdc671bf9d6c085ba335f119861fd15956fe"
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
      "version": "1.21.1",
      "used_options": [],
      "built_as_bottle": true,
      "poured_from_bottle": true,
      "runtime_dependencies": [
        {
          "full_name": "gettext",
          "version": "0.21"
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
          "version": "1.1.1j"
        }
      ],
      "installed_as_dependency": false,
      "installed_on_request": true
    }
  ],
  "linked_keg": "1.21.1",
  "pinned": false,
  "outdated": false,
  "deprecated": false,
  "deprecation_date": null,
  "deprecation_reason": null,
  "disabled": false,
  "disable_date": null,
  "disable_reason": null,
  "analytics": {
    "install": {
      "30d": {
        "wget": 190955,
        "wget --HEAD": 29
      },
      "90d": {
        "wget": 516497,
        "wget --HEAD": 97
      },
      "365d": {
        "wget": 1414803,
        "wget --HEAD": 141
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 190105,
        "wget --HEAD": 29
      },
      "90d": {
        "wget": 513934,
        "wget --HEAD": 97
      },
      "365d": {
        "wget": 1394159,
        "wget --HEAD": 140
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2021-03-01"
}
```

### Get formula metadata for a {{ site.taps.cask.repo }} formula
Get the `brew info --json=v2 --cask <cask>` JSON output for a single, current {{ site.taps.cask.fullname }} formula with extra keys containing analytics data and generation date.

```
GET https://formulae.brew.sh/api/cask/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula, e.g. `docker`

#### [Response](https://formulae.brew.sh/api/cask/docker.json)
```json
{
  "token": "docker",
  "full_token": "docker",
  "tap": "homebrew/cask",
  "name": [
    "Docker Desktop",
    "Docker Community Edition",
    "Docker CE"
  ],
  "desc": "App to build and share containerized applications and microservices",
  "homepage": "https://www.docker.com/products/docker-desktop",
  "url": "https://desktop.docker.com/mac/stable/51484/Docker.dmg",
  "appcast": null,
  "version": "3.1.0,51484",
  "installed": null,
  "outdated": false,
  "sha256": "9e68684d7d19de90034630ec2127a5d49138dc314857059fa75a99687be2b6b8",
  "artifacts": [
    {
      "delete": [
        "/Library/PrivilegedHelperTools/com.docker.vmnetd",
        "/private/var/tmp/com.docker.vmnetd.socket",
        "$(brew --prefix)/bin/docker",
        "$(brew --prefix)/bin/docker-compose",
        "$(brew --prefix)/bin/docker-credential-desktop",
        "$(brew --prefix)/bin/docker-credential-ecr-login",
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
        "~/Library/Application Support/Docker Desktop",
        "~/Library/Application Scripts/com.docker.helper",
        "~/Library/Caches/KSCrashReports/Docker",
        "~/Library/Caches/com.docker.docker",
        "~/Library/Caches/com.plausiblelabs.crashreporter.data/com.docker.docker",
        "~/Library/Containers/com.docker.docker",
        "~/Library/Containers/com.docker.helper",
        "~/Library/Group Containers/group.com.docker",
        "~/Library/Preferences/com.docker.docker.plist",
        "~/Library/Preferences/com.electron.docker-frontend.plist",
        "~/Library/Saved Application State/com.electron.docker-frontend.savedState",
        "~/Library/Logs/Docker Desktop"
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
        "docker": 15083
      },
      "90d": {
        "docker": 50381
      },
      "365d": {
        "docker": 207465
      }
    }
  },
  "generated_date": "2021-03-01"
}
```

## Analytics

### List one category of analytics events
List all analytics events for a specified category over a number of days, ordered by event frequency count. This is the data source for `brew info --analytics`.

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
List all the {{ site.taps.core.fullname }} or {{ site.taps.linux.fullname }} formulae's analytics events for a specified category over a number of days, grouped by formula name. This is the data source for `brew info --analytics --formula <formula>`.

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
List all the {{ site.taps.cask.fullname }} formulae's analytics events for the `cask-install` category over a number of days, grouped by cask token.  This is the data source for `brew info --analytics --cask <cask>`.
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
