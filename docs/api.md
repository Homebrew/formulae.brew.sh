---
title: JSON API documentation
layout: page
permalink: /docs/api/
---
## Formulae
### List formulae metadata for all homebrew-core formulae
List the `brew info --json=v1` output for all current Homebrew/homebrew-core formulae.

```
GET /api/formula.json
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

### Get formula metadata for a homebrew-core formula
Get the `brew info --json=v1` output for a single, current Homebrew/homebrew-core formula.

```
GET /api/formula/${FORMULA}.json
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
  "outdated": false
}
```


## Analytics
### List analytics events
List all analytics events for a specified category and number of days.

```
GET /api/analytics/${CATEGORY}/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the category of the analytics events i.e.
  - `install`: the installation of all formulae
  - `install-on-request`: the requested installation of all formulae (i.e. not as a dependency of other formulae)
  - `build-error`: the installation failure of all formulae
  - `os-version`: the macOS version of the machine that submitted an event
- `${DAYS}`: the number of days of analytics events i.e.
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

### List analytics events for all homebrew-core formulae
List all the Homebrew/homebrew-core formulae's analytics events for a specified category and number of days (grouped by formula name).

```
GET /api/analytics/${CATEGORY}/homebrew-core/${DAYS}.json
```

#### Variables
- `${CATEGORY}`: the category of the analytics events i.e.
  - `install`: the installation of all homebrew-core formulae
  - `install-on-request`: the requested installation of all homebrew-core formulae (i.e. not as a dependency of other formulae)
- `${DAYS}`: the number of days of analytics events i.e.
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
