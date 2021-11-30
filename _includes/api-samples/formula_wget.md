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
    "stable": "1.21.2",
    "head": "HEAD",
    "bottle": true
  },
  "urls": {
    "stable": {
      "url": "https://ftp.gnu.org/gnu/wget/wget-1.21.2.tar.gz",
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
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:571ef7b59ebab2aa947485aa33bf612d001d51f5bbc89b59d00ac39712b846c8",
          "sha256": "571ef7b59ebab2aa947485aa33bf612d001d51f5bbc89b59d00ac39712b846c8"
        },
        "arm64_big_sur": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:4f8b66c5f181f01064522a80bfda72eabddd47299a8b88bc7d0022c457e72594",
          "sha256": "4f8b66c5f181f01064522a80bfda72eabddd47299a8b88bc7d0022c457e72594"
        },
        "monterey": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:b6d6f422e3c4db0607caf5fc91dba4fb19b3c52883d7a012c9fc11b872b14bad",
          "sha256": "b6d6f422e3c4db0607caf5fc91dba4fb19b3c52883d7a012c9fc11b872b14bad"
        },
        "big_sur": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:7a8e6512e0890076b9ebc4f8db6165d70b4bd05e04dfc0491519ba3c91a5c21e",
          "sha256": "7a8e6512e0890076b9ebc4f8db6165d70b4bd05e04dfc0491519ba3c91a5c21e"
        },
        "catalina": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:3b191bb28b5011e7a105ae76427f6dd21a1e12c33da2273b7e01ef2110f0f375",
          "sha256": "3b191bb28b5011e7a105ae76427f6dd21a1e12c33da2273b7e01ef2110f0f375"
        },
        "mojave": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:e0d4b68c9e5abeaa6395241c43307c4bbd26133cd63d136321974535788c37e9",
          "sha256": "e0d4b68c9e5abeaa6395241c43307c4bbd26133cd63d136321974535788c37e9"
        },
        "x86_64_linux": {
          "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:1c102dc1129e508f7788824ea6ef4db4656fbab2a6a4b54419689925a5ed6855",
          "sha256": "1c102dc1129e508f7788824ea6ef4db4656fbab2a6a4b54419689925a5ed6855"
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
      "version": "1.21.2",
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
          "full_name": "ca-certificates",
          "version": "2021-10-26",
          "declared_directly": false
        },
        {
          "full_name": "openssl@1.1",
          "version": "1.1.1l",
          "declared_directly": true
        }
      ],
      "installed_as_dependency": false,
      "installed_on_request": true
    }
  ],
  "linked_keg": "1.21.2",
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
        "wget": 151301,
        "wget --HEAD": 14
      },
      "90d": {
        "wget": 617315,
        "wget --HEAD": 27
      },
      "365d": {
        "wget": 1964350,
        "wget --HEAD": 200
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 150880,
        "wget --HEAD": 14
      },
      "90d": {
        "wget": 614974,
        "wget --HEAD": 26
      },
      "365d": {
        "wget": 1955960,
        "wget --HEAD": 197
      }
    },
    "build_error": {
      "30d": {
        "wget": 15,
        "wget --HEAD": 7
      }
    }
  },
  "analytics-linux": {
    "install": {
      "30d": {
        "wget": 1043
      },
      "90d": {
        "wget": 3393
      },
      "365d": {
        "wget": 10975
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 1021
      },
      "90d": {
        "wget": 3286
      },
      "365d": {
        "wget": 10515
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2021-11-30"
}
```