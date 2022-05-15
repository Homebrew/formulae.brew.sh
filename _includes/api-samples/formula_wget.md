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
    "stable": "1.21.3",
    "head": "HEAD",
    "bottle": true
  },
  "urls": {
    "stable": {
      "url": "https://ftp.gnu.org/gnu/wget/wget-1.21.3.tar.gz",
      "tag": null,
      "revision": null
    }
  },
  "revision": 0,
  "version_scheme": 0,
  "bottle": {
    "stable": {
      "rebuild": 0,
      "root_url": "https://ghcr.io/v2/homebrew/core",
      "files": {
        "arm64_monterey": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:fc83eec77acee50d2d7ce3bb0cca08d80acccc148e909921de42e57dd5fc7f3d",
          "sha256": "fc83eec77acee50d2d7ce3bb0cca08d80acccc148e909921de42e57dd5fc7f3d"
        },
        "arm64_big_sur": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:a0c491ae7de2b722320efa94704567e36f3a0bd04bd946b1431ecbd1bcbfb899",
          "sha256": "a0c491ae7de2b722320efa94704567e36f3a0bd04bd946b1431ecbd1bcbfb899"
        },
        "monterey": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:aa706c58ae7e97abf91be56e785335aff058c431f9973dffac06aacbea558497",
          "sha256": "aa706c58ae7e97abf91be56e785335aff058c431f9973dffac06aacbea558497"
        },
        "big_sur": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:b90e0d7a4319ccdb18ee0c2ed097e9cddeeceaaf70dc0a785d96b4ba69dbeb54",
          "sha256": "b90e0d7a4319ccdb18ee0c2ed097e9cddeeceaaf70dc0a785d96b4ba69dbeb54"
        },
        "catalina": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:2aadef5aae81ecdd7e28bc9a776adcf0eaa393edae904e0c69740a442b7a3e69",
          "sha256": "2aadef5aae81ecdd7e28bc9a776adcf0eaa393edae904e0c69740a442b7a3e69"
        },
        "x86_64_linux": {
          "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:b6f20b1f4da03b9ee6a42f9305ee015eae7f80afea198e405c0b775eb2333de1",
          "sha256": "b6f20b1f4da03b9ee6a42f9305ee015eae7f80afea198e405c0b775eb2333de1"
        }
      }
    }
  },
  "keg_only": false,
  "keg_only_reason": null,
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
      "version": "1.21.3",
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
          "version": "1.0",
          "declared_directly": false
        },
        {
          "full_name": "libidn2",
          "version": "2.3.2",
          "declared_directly": true
        },
        {
          "full_name": "ca-certificates",
          "version": "2022-04-26",
          "declared_directly": false
        },
        {
          "full_name": "openssl@1.1",
          "version": "1.1.1o",
          "declared_directly": true
        }
      ],
      "installed_as_dependency": false,
      "installed_on_request": true
    }
  ],
  "linked_keg": "1.21.3",
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
        "wget": 141756,
        "wget --HEAD": 3
      },
      "90d": {
        "wget": 536097,
        "wget --HEAD": 11
      },
      "365d": {
        "wget": 1865954,
        "wget --HEAD": 103
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 140977,
        "wget --HEAD": 3
      },
      "90d": {
        "wget": 533239,
        "wget --HEAD": 11
      },
      "365d": {
        "wget": 1857454,
        "wget --HEAD": 100
      }
    },
    "build_error": {
      "30d": {
        "wget": 29,
        "wget --HEAD": 3
      }
    }
  },
  "analytics-linux": {
    "install": {
      "30d": {
        "wget": 1161
      },
      "90d": {
        "wget": 3363
      },
      "365d": {
        "wget": 12692,
        "wget --HEAD": 2
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 1142
      },
      "90d": {
        "wget": 3289
      },
      "365d": {
        "wget": 12355,
        "wget --HEAD": 2
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2022-05-15"
}
```