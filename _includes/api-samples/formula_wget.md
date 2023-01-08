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
  "revision": 1,
  "version_scheme": 0,
  "bottle": {
    "stable": {
      "rebuild": 0,
      "root_url": "https://ghcr.io/v2/homebrew/core",
      "files": {
        "arm64_ventura": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:a205f83efcbd5cfe22e70261f2b8afdca71cb172222ee3106bb44bc3512414ca",
          "sha256": "a205f83efcbd5cfe22e70261f2b8afdca71cb172222ee3106bb44bc3512414ca"
        },
        "arm64_monterey": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:d1f955187691ad37ede6c33a1eabcd9f25b2f9841fc51ca3422a6cd8e830bd64",
          "sha256": "d1f955187691ad37ede6c33a1eabcd9f25b2f9841fc51ca3422a6cd8e830bd64"
        },
        "arm64_big_sur": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:ea51216e20e8e7e8d13370c54f2282d7bbf472af73550a685cd7bbf78ed9af89",
          "sha256": "ea51216e20e8e7e8d13370c54f2282d7bbf472af73550a685cd7bbf78ed9af89"
        },
        "ventura": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:24d0f69261b578a8f7c80130cf695a78b9b0a554405d63a30ad7d36c487ce789",
          "sha256": "24d0f69261b578a8f7c80130cf695a78b9b0a554405d63a30ad7d36c487ce789"
        },
        "monterey": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:6f17f29657928ecbd76873ef55ee572414650dfc431c28e0587351532b251ae7",
          "sha256": "6f17f29657928ecbd76873ef55ee572414650dfc431c28e0587351532b251ae7"
        },
        "big_sur": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:e33bd34193575636ee2b7cc761821e316d475947b95280a296069324ee31f44f",
          "sha256": "e33bd34193575636ee2b7cc761821e316d475947b95280a296069324ee31f44f"
        },
        "x86_64_linux": {
          "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:47534590ea4e6468e74fe5945d28ab87510efab485490a132f7fb3bd02686e5d",
          "sha256": "47534590ea4e6468e74fe5945d28ab87510efab485490a132f7fb3bd02686e5d"
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
  "outdated": true,
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
        "wget": 135565,
        "wget --HEAD": 6
      },
      "90d": {
        "wget": 353878,
        "wget --HEAD": 12
      },
      "365d": {
        "wget": 1575461,
        "wget --HEAD": 51
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 134938,
        "wget --HEAD": 6
      },
      "90d": {
        "wget": 352363,
        "wget --HEAD": 12
      },
      "365d": {
        "wget": 1567318,
        "wget --HEAD": 51
      }
    },
    "build_error": {
      "30d": {
        "wget": 79,
        "wget --HEAD": 4
      }
    }
  },
  "analytics-linux": {
    "install": {
      "30d": {
        "wget": 1219
      },
      "90d": {
        "wget": 3470
      },
      "365d": {
        "wget": 14187,
        "wget --HEAD": 2
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 1197
      },
      "90d": {
        "wget": 3342
      },
      "365d": {
        "wget": 13805,
        "wget --HEAD": 2
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2023-01-08"
}
```