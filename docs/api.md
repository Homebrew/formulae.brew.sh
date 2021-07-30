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
        "rebuild": 1,
        "root_url": "https://ghcr.io/v2/homebrew/core",
        "files": {
          "arm64_big_sur": {
            "cellar": "/opt/homebrew/Cellar",
            "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:ab03f58f6d9a4018b1b0bfd53e5b797fcd90b86b1d60b20948de499ec4d4c6b4",
            "sha256": "ab03f58f6d9a4018b1b0bfd53e5b797fcd90b86b1d60b20948de499ec4d4c6b4"
          },
          "big_sur": {
            "cellar": "/usr/local/Cellar",
            "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:277577a3a30ff9bf60d0e4b819570ca356aade39a3a5973065e89b0ad4b752f3",
            "sha256": "277577a3a30ff9bf60d0e4b819570ca356aade39a3a5973065e89b0ad4b752f3"
          },
          "catalina": {
            "cellar": "/usr/local/Cellar",
            "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:261ea49956e98d62975c1706cb839c6411473a7ec50ae8101526010275fe70c0",
            "sha256": "261ea49956e98d62975c1706cb839c6411473a7ec50ae8101526010275fe70c0"
          },
          "mojave": {
            "cellar": "/usr/local/Cellar",
            "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:df85a11661c551e9fe30445b6173e82c83d80a0622191a9c57f0edf6b21782d1",
            "sha256": "df85a11661c551e9fe30445b6173e82c83d80a0622191a9c57f0edf6b21782d1"
          },
          "x86_64_linux": {
            "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
            "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:d867d78ce4327653990116aad3cbeeba1a3aee1530eb3cf17f5de1441849e834",
            "sha256": "d867d78ce4327653990116aad3cbeeba1a3aee1530eb3cf17f5de1441849e834"
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
            "version": "0.21",
            "declared_directly": false
          },
          {
            "full_name": "libunistring",
            "version": "0.9.10",
            "declared_directly": false
          },
          {
            "full_name": "libidn2",
            "version": "2.3.2",
            "declared_directly": true
          },
          {
            "full_name": "openssl@1.1",
            "version": "1.1.1k",
            "declared_directly": true
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
      "rebuild": 1,
      "root_url": "https://ghcr.io/v2/homebrew/core",
      "files": {
        "arm64_big_sur": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:ab03f58f6d9a4018b1b0bfd53e5b797fcd90b86b1d60b20948de499ec4d4c6b4",
          "sha256": "ab03f58f6d9a4018b1b0bfd53e5b797fcd90b86b1d60b20948de499ec4d4c6b4"
        },
        "big_sur": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:277577a3a30ff9bf60d0e4b819570ca356aade39a3a5973065e89b0ad4b752f3",
          "sha256": "277577a3a30ff9bf60d0e4b819570ca356aade39a3a5973065e89b0ad4b752f3"
        },
        "catalina": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:261ea49956e98d62975c1706cb839c6411473a7ec50ae8101526010275fe70c0",
          "sha256": "261ea49956e98d62975c1706cb839c6411473a7ec50ae8101526010275fe70c0"
        },
        "mojave": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:df85a11661c551e9fe30445b6173e82c83d80a0622191a9c57f0edf6b21782d1",
          "sha256": "df85a11661c551e9fe30445b6173e82c83d80a0622191a9c57f0edf6b21782d1"
        },
        "x86_64_linux": {
          "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:d867d78ce4327653990116aad3cbeeba1a3aee1530eb3cf17f5de1441849e834",
          "sha256": "d867d78ce4327653990116aad3cbeeba1a3aee1530eb3cf17f5de1441849e834"
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
          "version": "0.21",
          "declared_directly": false
        },
        {
          "full_name": "libunistring",
          "version": "0.9.10",
          "declared_directly": false
        },
        {
          "full_name": "libidn2",
          "version": "2.3.2",
          "declared_directly": true
        },
        {
          "full_name": "openssl@1.1",
          "version": "1.1.1k",
          "declared_directly": true
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
        "wget": 103605,
        "wget --HEAD": 10
      },
      "90d": {
        "wget": 334792,
        "wget --HEAD": 35
      },
      "365d": {
        "wget": 1562744,
        "wget --HEAD": 170
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 103138,
        "wget --HEAD": 10
      },
      "90d": {
        "wget": 333385,
        "wget --HEAD": 35
      },
      "365d": {
        "wget": 1552590,
        "wget --HEAD": 170
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2021-07-30"
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
  "url": "https://desktop.docker.com/mac/stable/amd64/66501/Docker.dmg",
  "appcast": null,
  "version": "3.5.2,66501",
  "installed": null,
  "outdated": false,
  "sha256": "841498c9b2855e357baf22af125bffa6e512c20ffa1cd30752da3bc4c3e540e4",
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
    [
      "/Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion",
      {
        "target": "$(brew --prefix)/etc/bash_completion.d/docker-compose"
      }
    ],
    [
      "/Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion",
      {
        "target": "$(brew --prefix)/share/zsh/site-functions/_docker"
      }
    ],
    [
      "/Applications/Docker.app/Contents/Resources/etc/docker.fish-completion",
      {
        "target": "$(brew --prefix)/share/fish/vendor_completions.d/docker.fish"
      }
    ],
    [
      "/Applications/Docker.app/Contents/Resources/etc/docker-compose.fish-completion",
      {
        "target": "$(brew --prefix)/share/fish/vendor_completions.d/docker-compose.fish"
      }
    ],
    [
      "/Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion",
      {
        "target": "$(brew --prefix)/share/zsh/site-functions/_docker_compose"
      }
    ],
    [
      "/Applications/Docker.app/Contents/Resources/etc/docker.bash-completion",
      {
        "target": "$(brew --prefix)/etc/bash_completion.d/docker"
      }
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
  "conflicts_with": {
    "formula": [
      "docker",
      "docker-completion",
      "docker-compose",
      "docker-compose-completion",
      "hyperkit",
      "kubernetes-cli"
    ]
  },
  "container": null,
  "auto_updates": true,
  "analytics": {
    "install": {
      "30d": {
        "docker": 18068
      },
      "90d": {
        "docker": 55388
      },
      "365d": {
        "docker": 215461
      }
    }
  },
  "generated_date": "2021-07-30"
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
