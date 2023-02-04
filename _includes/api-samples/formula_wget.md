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
      "rebuild": 1,
      "root_url": "https://ghcr.io/v2/homebrew/core",
      "files": {
        "arm64_ventura": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:7415a3b847237e0a981f2df42761578d6b6b285361c450c010219355bd1c0df2",
          "sha256": "7415a3b847237e0a981f2df42761578d6b6b285361c450c010219355bd1c0df2"
        },
        "arm64_monterey": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:ed959d9bd75bfac18aa823bd62c8e5f4736174fd183aee9ebaa913d0810dea36",
          "sha256": "ed959d9bd75bfac18aa823bd62c8e5f4736174fd183aee9ebaa913d0810dea36"
        },
        "arm64_big_sur": {
          "cellar": "/opt/homebrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:42233b960709325f6e4ec479eb1786379e1b3757b4b7641bdbbd8e6a058e1013",
          "sha256": "42233b960709325f6e4ec479eb1786379e1b3757b4b7641bdbbd8e6a058e1013"
        },
        "ventura": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:0915596ebf9426fc9aad9307a6813ba35ac860e9dfa755741a23e9d446ac3b93",
          "sha256": "0915596ebf9426fc9aad9307a6813ba35ac860e9dfa755741a23e9d446ac3b93"
        },
        "monterey": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:f97fc2639cd9d2d037c2bf1a94fa664ef2d81143ce8a1fb5b740ce2eb397889c",
          "sha256": "f97fc2639cd9d2d037c2bf1a94fa664ef2d81143ce8a1fb5b740ce2eb397889c"
        },
        "big_sur": {
          "cellar": "/usr/local/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:f85c6720bdabd86db32dd54837f577b709bc5de98896622a19f698f8a14e604f",
          "sha256": "f85c6720bdabd86db32dd54837f577b709bc5de98896622a19f698f8a14e604f"
        },
        "x86_64_linux": {
          "cellar": "/home/linuxbrew/.linuxbrew/Cellar",
          "url": "https://ghcr.io/v2/homebrew/core/wget/blobs/sha256:738ec27b5b39877b8004096d9c3edd04ff814e18dd6f6afca89a2f5b4eeedcac",
          "sha256": "738ec27b5b39877b8004096d9c3edd04ff814e18dd6f6afca89a2f5b4eeedcac"
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
    "openssl@3"
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
        "openssl@3",
        "util-linux"
      ]
    }
  },
  "analytics": {
    "install": {
      "30d": {
        "wget": 229825,
        "wget --HEAD": 8
      },
      "90d": {
        "wget": 436685,
        "wget --HEAD": 14
      },
      "365d": {
        "wget": 1665119,
        "wget --HEAD": 52
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 228586,
        "wget --HEAD": 8
      },
      "90d": {
        "wget": 434678,
        "wget --HEAD": 14
      },
      "365d": {
        "wget": 1656473,
        "wget --HEAD": 52
      }
    },
    "build_error": {
      "30d": {
        "wget": 79,
        "wget --HEAD": 5
      }
    }
  },
  "analytics-linux": {
    "install": {
      "30d": {
        "wget": 1485
      },
      "90d": {
        "wget": 3689
      },
      "365d": {
        "wget": 14435,
        "wget --HEAD": 1
      }
    },
    "install_on_request": {
      "30d": {
        "wget": 1455
      },
      "90d": {
        "wget": 3562
      },
      "365d": {
        "wget": 14047,
        "wget --HEAD": 1
      }
    },
    "build_error": {
      "30d": {
        "wget": 0
      }
    }
  },
  "generated_date": "2023-01-18"
}
```