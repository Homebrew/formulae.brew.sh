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
  "revision": 1,
  "version_scheme": 0,
  "bottle": {
    "stable": {
      "rebuild": 0,
      "root_url": "https://ghcr.io/v2/homebrew/core",
      "files": {
        "arm64_big_sur": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:bedb0887083a2d3ebcfbc03a1fed9919b726810dbbc2cd0efae923ef9d6bd5f4",
          "sha256": "bedb0887083a2d3ebcfbc03a1fed9919b726810dbbc2cd0efae923ef9d6bd5f4"
        },
        "big_sur": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:307217b813330eda365570d7540aa2da69c678b6c4b78000d24048614902eea8",
          "sha256": "307217b813330eda365570d7540aa2da69c678b6c4b78000d24048614902eea8"
        },
        "catalina": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:e9efaae60b98da6832072ff1aa2336d0d12e2ab34df3b9acbc35c81a485ef505",
          "sha256": "e9efaae60b98da6832072ff1aa2336d0d12e2ab34df3b9acbc35c81a485ef505"
        },
        "mojave": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:c1709dfb1273aa522226ab34fc9ce73caae56d3536ebae2403017febef9fc256",
          "sha256": "c1709dfb1273aa522226ab34fc9ce73caae56d3536ebae2403017febef9fc256"
        },
        "x86_64_linux": {
          "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:0b90bc93557882763d632e443e82ae05a0c2933a5e22d6fb1d0597a3f7833098",
          "sha256": "0b90bc93557882763d632e443e82ae05a0c2933a5e22d6fb1d0597a3f7833098"
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
  "outdated": true,
  "deprecated": false,
  "deprecation_date": null,
  "deprecation_reason": null,
  "disabled": false,
  "disable_date": null,
  "disable_reason": null,
  "analytics": {
    "install": {
      "30d": {
        "wget": 127917,
        "wget --HEAD": 10
      },
      "90d": {
        "wget": 344088,
        "wget --HEAD": 40
      },
      "365d": {
        "wget": 1592851,
        "wget --HEAD": 176
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 127265,
        "wget --HEAD": 10
      },
      "90d": {
        "wget": 342523,
        "wget --HEAD": 40
      },
      "365d": {
        "wget": 1583174,
        "wget --HEAD": 176
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2021-08-24"
}
```