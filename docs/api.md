---
title: JSON API documentation
layout: page
permalink: /docs/api/
---
## Formulae
### List formulae metadata for all {{ site.taps.core.repo }} formulae
List the `brew info --json=v1` output for all current {{ site.taps.core.fullname }} formulae.

```
GET https://formulae.brew.sh/api/formula.json
```

#### Response
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
      "stable": "1.19.5",
      "devel": null,
      "head": "HEAD",
      "bottle": true
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
          "high_sierra": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.19.5.high_sierra.bottle.tar.gz",
            "sha256": "af8880a424be0cde4d2891b0027ae9991ebb0e6f48ae60b369e3c9f0bdfcd04a"
          },
          "sierra": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.19.5.sierra.bottle.tar.gz",
            "sha256": "d61954cc95b1f60b64b86afa2a71a18d6d1676dbc3d566a3f9ba2249ad028b54"
          },
          "el_capitan": {
            "url": "https://homebrew.bintray.com/bottles/wget-1.19.5.el_capitan.bottle.tar.gz",
            "sha256": "473408a17dfea7393f2c8c96264535717328c3879db679fc09fc1007bac26113"
          }
        }
      }
    },
    "keg_only": false,
    "options": [
      {
        "option": "--with-debug",
        "description": "Build with debug support"
      },
      {
        "option": "--with-pcre",
        "description": "Build with pcre support"
      },
      {
        "option": "--with-libmetalink",
        "description": "Build with libmetalink support"
      },
      {
        "option": "--with-gpgme",
        "description": "Build with gpgme support"
      }
    ],
    "build_dependencies": [
      "pkg-config",
      "pod2man"
    ],
    "dependencies": [
      "libidn2",
      "openssl"
    ],
    "recommended_dependencies": [],
    "optional_dependencies": [
      "pcre",
      "libmetalink",
      "gpgme"
    ],
    "requirements": [],
    "conflicts_with": [],
    "caveats": null,
    "installed": [],
    "linked_keg": null,
    "pinned": false,
    "outdated": false
  },
  ...
]
```

### Get formula metadata for a {{ site.taps.core.repo }} formula
Get the `brew info --json=v1` output for a single, current {{ site.taps.core.fullname }} formula with an extra `analytics` key with analytics data.

```
GET https://formulae.brew.sh/api/formula/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula e.g. `wget`

#### Response
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
    "stable": "1.19.5",
    "devel": null,
    "head": "HEAD",
    "bottle": true
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
        "high_sierra": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.19.5.high_sierra.bottle.tar.gz",
          "sha256": "af8880a424be0cde4d2891b0027ae9991ebb0e6f48ae60b369e3c9f0bdfcd04a"
        },
        "sierra": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.19.5.sierra.bottle.tar.gz",
          "sha256": "d61954cc95b1f60b64b86afa2a71a18d6d1676dbc3d566a3f9ba2249ad028b54"
        },
        "el_capitan": {
          "url": "https://homebrew.bintray.com/bottles/wget-1.19.5.el_capitan.bottle.tar.gz",
          "sha256": "473408a17dfea7393f2c8c96264535717328c3879db679fc09fc1007bac26113"
        }
      }
    }
  },
  "keg_only": false,
  "options": [
    {
      "option": "--with-debug",
      "description": "Build with debug support"
    },
    {
      "option": "--with-pcre",
      "description": "Build with pcre support"
    },
    {
      "option": "--with-libmetalink",
      "description": "Build with libmetalink support"
    },
    {
      "option": "--with-gpgme",
      "description": "Build with gpgme support"
    }
  ],
  "build_dependencies": [
    "pkg-config",
    "pod2man"
  ],
  "dependencies": [
    "libidn2",
    "openssl"
  ],
  "recommended_dependencies": [],
  "optional_dependencies": [
    "pcre",
    "libmetalink",
    "gpgme"
  ],
  "requirements": [],
  "conflicts_with": [],
  "caveats": null,
  "installed": [],
  "linked_keg": null,
  "pinned": false,
  "outdated": false,
  "analytics": {
    "install": {
      "30d": {
        "wget": 84516,
        "wget --with-debug": 51,
        "wget --with-libressl": 16,
        "wget --with-pcre": 14,
        "wget --with-pcre --with-libmetalink --with-gpgme": 12,
        "wget --with-debug --with-pcre --with-libmetalink --with-gpgme": 8,
        "wget --HEAD": 3,
        "wget --HEAD --with-debug --with-libmetalink --with-gpgme": 3,
        "wget --with-gpgme": 3,
        "wget --with-libmetalink": 3,
        "wget --with-pcre --with-libmetalink": 3,
        "wget --with-debug --with-pcre": 2,
        "wget --with-libmetalink --with-gpgme": 2,
        "wget --with-pcre --with-gpgme": 2
      },
      "90d": {
        "wget": 353131,
        "wget --with-debug": 188,
        "wget --with-pcre": 138,
        "wget --with-pcre --with-libmetalink --with-gpgme": 118,
        "wget --with-libressl": 81,
        "wget --with-debug --with-pcre --with-libmetalink --with-gpgme": 47,
        "wget --with-pcre --with-libmetalink": 31,
        "wget --HEAD": 13,
        "wget --with-pcre --with-gpgme": 12,
        "wget --with-gpgme": 11,
        "wget --with-debug --with-pcre": 10,
        "wget --with-libmetalink": 8,
        "wget --HEAD --with-pcre --with-libmetalink --with-gpgme": 4,
        "wget --with-debug --with-pcre --with-libmetalink": 4,
        "wget --with-libmetalink --with-gpgme": 4
      },
      "365d": {
        "wget": 1369530,
        "wget --with-pcre": 810,
        "wget --with-debug": 649,
        "wget --with-pcre --with-libmetalink --with-gpgme": 554,
        "wget --with-libressl": 479,
        "wget --with-debug --with-pcre --with-libmetalink --with-gpgme": 235,
        "wget --with-pcre --with-libmetalink": 184,
        "wget --with-gpgme": 67,
        "wget --with-pcre --with-gpgme": 67,
        "wget --with-debug --with-pcre": 65,
        "wget --HEAD": 54,
        "wget --with-libmetalink": 30,
        "wget --with-libmetalink --with-gpgme": 27,
        "wget --with-debug --with-pcre --with-libmetalink": 24
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 77827,
        "wget --with-debug": 48,
        "wget --with-pcre": 12,
        "wget --with-pcre --with-libmetalink --with-gpgme": 11,
        "wget --with-debug --with-pcre --with-libmetalink --with-gpgme": 8,
        "wget --HEAD": 3,
        "wget --HEAD --with-debug --with-libmetalink --with-gpgme": 3,
        "wget --with-gpgme": 3,
        "wget --with-libmetalink": 3,
        "wget --with-debug --with-pcre": 2,
        "wget --with-libmetalink --with-gpgme": 2,
        "wget --with-pcre --with-gpgme": 2,
        "wget --with-pcre --with-libmetalink": 2
      },
      "90d": {
        "wget": 290818,
        "wget --with-debug": 157,
        "wget --with-pcre --with-libmetalink --with-gpgme": 101,
        "wget --with-pcre": 100,
        "wget --with-debug --with-pcre --with-libmetalink --with-gpgme": 42,
        "wget --with-pcre --with-libmetalink": 30,
        "wget --HEAD": 13,
        "wget --with-pcre --with-gpgme": 11,
        "wget --with-gpgme": 10,
        "wget --with-debug --with-pcre": 8,
        "wget --with-libmetalink": 7,
        "wget --HEAD --with-pcre --with-libmetalink --with-gpgme": 4,
        "wget --with-debug --with-pcre --with-libmetalink": 4
      },
      "365d": {
        "wget": 1042845,
        "wget --with-pcre": 504,
        "wget --with-debug": 458,
        "wget --with-pcre --with-libmetalink --with-gpgme": 432,
        "wget --with-debug --with-pcre --with-libmetalink --with-gpgme": 201,
        "wget --with-pcre --with-libmetalink": 158,
        "wget --with-gpgme": 61,
        "wget --HEAD": 54,
        "wget --with-pcre --with-gpgme": 49,
        "wget --with-debug --with-pcre": 47,
        "wget --with-debug --with-pcre --with-libmetalink": 24,
        "wget --with-libressl": 23,
        "wget --with-libmetalink": 22,
        "wget --with-libmetalink --with-gpgme": 20
      }
    },
    "build_error": {
      "30d": {
        "wget": 9,
        "wget --HEAD": 1,
        "wget --with-debug": 1
      }
    }
  }
}
```


## Analytics
### List analytics events
List all analytics events for a specified category and number of days.

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the category of the analytics events, i.e.
  - `install`: the installation of all formulae
  - `install-on-request`: the requested installation of all formulae (i.e. not as a dependency of other formulae)
  - `cask-install`: the installation of all casks
  - `build-error`: the installation failure of all formulae
  - `os-version`: the macOS version of all machines that have submitted an event
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### Response
```json
{
  "category": "install",
  "total_items": 16980,
  "start_date": "2018-04-28",
  "end_date": "2018-05-28",
  "total_count": 12112262,
  "items": [
    ...
    {
      "number": 12,
      "formula": "wget",
      "count": "146,641",
      "percent": "1.21"
    },
    ...
    {
      "number": 2275,
      "formula": "wget --with-pcre",
      "count": "101",
      "percent": "0.00"
    },
    ...
  ]
}
```

### List analytics events for all {{ site.taps.core.repo }} formulae
List all the {{ site.taps.core.fullname }} formulae's analytics events for a specified category and number of days (grouped by formula name).

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/homebrew-core/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the category of the analytics events, i.e.
  - `install`: the installation of all {{ site.taps.core.repo }} formulae
  - `install-on-request`: the requested installation of all {{ site.taps.core.repo }} formulae (i.e. not as a dependency of other formulae)
  - `build-error`: the installation failure of all {{ site.taps.core.repo }} formulae. Only `${DAYS}: 30d` (30 days) is available.
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### Response
```json
{
  "category": "install",
  "total_items": 11520,
  "start_date": "2018-04-28",
  "end_date": "2018-05-28",
  "total_count": 11867550,
  "formulae": {
    ...
    "wget": [
      {
        "formula": "wget",
        "count": "146,641"
      },
      {
        "formula": "wget --with-pcre",
        "count": "101"
      },
      ...
    ],
    ...
  }
]
```
