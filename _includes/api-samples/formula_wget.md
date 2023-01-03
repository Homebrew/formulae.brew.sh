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
      "revision": null,
      "checksum": "5726bb8bc5ca0f6dc7110f6416e4bb7019e2d2ff5bf93d1ca2ffcc6656f220e5"
    }
  },
  "revision": 0,
  "version_scheme": 0,
  "bottle": {
    "stable": {
      "rebuild": 0,
      "root_url": "https://ghcr.io/v2/homebrew/core",
      "files": {
        "arm64_ventura": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:fb2b2297226438cf2e9af9f1cf94f450730fc515eace8e21dd2db03700e77629",
          "sha256": "fb2b2297226438cf2e9af9f1cf94f450730fc515eace8e21dd2db03700e77629"
        },
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
        "ventura": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:e7c2473d1ad12f24fcfa2a2de2eea915e478f5b0204c153daa00b7d3f440b7ab",
          "sha256": "e7c2473d1ad12f24fcfa2a2de2eea915e478f5b0204c153daa00b7d3f440b7ab"
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
  "options": [],
  "build_dependencies": [
    "pkg-config"
  ],
  "dependencies": [
    "libidn2",
    "openssl@1.1"
  ],
  "test_dependencies": [],
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
      "time": 1671153619,
      "runtime_dependencies": [
        {
          "full_name": "gettext",
          "version": "0.21.1",
          "declared_directly": false
        },
        {
          "full_name": "libunistring",
          "version": "1.0",
          "declared_directly": false
        },
        {
          "full_name": "libidn2",
          "version": "2.3.4",
          "declared_directly": true
        },
        {
          "full_name": "ca-certificates",
          "version": "2022-10-11",
          "declared_directly": false
        },
        {
          "full_name": "openssl@1.1",
          "version": "1.1.1s",
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
  "variations": {
    "x86_64_linux": {
      "dependencies": [
        "libidn2",
        "openssl@1.1",
        "util-linux"
      ]
    }
  },
  "analytics": {
    "install": {
      "30d": {
        "wget": 81600,
        "wget --HEAD": 5
      },
      "90d": {
        "wget": 300480,
        "wget --HEAD": 10
      },
      "365d": {
        "wget": 1522550,
        "wget --HEAD": 49
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 81317,
        "wget --HEAD": 5
      },
      "90d": {
        "wget": 299281,
        "wget --HEAD": 10
      },
      "365d": {
        "wget": 1514730,
        "wget --HEAD": 49
      }
    },
    "build_error": {
      "30d": {
        "wget": 19,
        "wget --HEAD": 5
      }
    }
  },
  "analytics-linux": {
    "install": {
      "30d": {
        "wget": 977
      },
      "90d": {
        "wget": 3273
      },
      "365d": {
        "wget": 13910,
        "wget --HEAD": 2
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 952
      },
      "90d": {
        "wget": 3131
      },
      "365d": {
        "wget": 13533,
        "wget --HEAD": 2
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2023-01-03"
}
```