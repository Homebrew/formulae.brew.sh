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
        "wget": 99784,
        "wget --HEAD": 9
      },
      "90d": {
        "wget": 322522,
        "wget --HEAD": 36
      },
      "365d": {
        "wget": 1561861,
        "wget --HEAD": 172
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 99287,
        "wget --HEAD": 9
      },
      "90d": {
        "wget": 321120,
        "wget --HEAD": 36
      },
      "365d": {
        "wget": 1552042,
        "wget --HEAD": 172
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2021-08-13"
}
```