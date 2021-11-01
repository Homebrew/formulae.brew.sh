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
List the `brew info --json --all` output for all current {{ site.taps.core.fullname }} or {{ site.taps.cask.fullname }} formulae.

```
GET https://formulae.brew.sh/api/formula.json
GET https://formulae.brew.sh/api/cask.json
```

#### [Response](https://formulae.brew.sh/api/formula.json)
{% include api-samples/formula.md %}

### List the latest versions for all {{ site.taps.core.repo }} or {{ site.taps.cask.repo }} formulae
List the latest version information for each formula or cask in the given tap. The result is a single JSON object with formula/cask names as keys. The values are JSON objects containing `version` and, for formulae, `revision` keys.

```
GET https://formulae.brew.sh/api/versions-formulae.json
GET https://formulae.brew.sh/api/versions-casks.json
```

#### [Formulae Response](https://formulae.brew.sh/api/versions-formulae.json)
{% include api-samples/versions_formulae.md %}

#### [Casks Response](https://formulae.brew.sh/api/versions-casks.json)
{% include api-samples/versions_casks.md %}

### Get formula metadata for a {{ site.taps.core.repo }} formula
Get the `brew info --json --formula <formula>` output for a single, current {{ site.taps.core.fullname }} formula with extra keys containing analytics data and generation date.

```
GET https://formulae.brew.sh/api/formula/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula, e.g. `wget`

#### [Response](https://formulae.brew.sh/api/formula/wget.json)
{% include api-samples/formula_wget.md %}

### Get bottle metadata for a {{ site.taps.core.repo }} formula
Get the `brew info --json --bottle --formula <formula>` output for a single, current {{ site.taps.core.fullname }} formula.

```
GET https://formulae.brew.sh/api/bottle/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula, e.g. `wget`

#### [Response](https://formulae.brew.sh/api/bottle/wget.json)
{% include api-samples/bottle_wget.md %}

### Get formula metadata for a {{ site.taps.cask.repo }} formula
Get the `brew info --json=v2 --cask <cask>` JSON output for a single, current {{ site.taps.cask.fullname }} formula with extra keys containing analytics data and generation date.

```
GET https://formulae.brew.sh/api/cask/${FORMULA}.json
```

#### Variables
- `${FORMULA}`: the name of the formula, e.g. `docker`

#### [Response](https://formulae.brew.sh/api/cask/docker.json)
{% include api-samples/cask_docker.md %}

### Get the source code for a cask in {{ site.taps.cask.fullname }}
Get the latest source code for a {{ site.taps.cask.repo }} that is defined in the {{ site.taps.cask.fullname }} repo.

```
GET https://formulae.brew.sh/api/cask-source/${FORMULA}.rb
```

#### Variables
- `${FORMULA}`: the name of the cask, e.g. `vagrant`

#### [Response](https://formulae.brew.sh/api/cask-source/vagrant.json)
{% include api-samples/cask_source_vagrant.md %}

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
{% include api-samples/analytics_install_30d.md %}

### List analytics events for all {{ site.taps.core.repo }} formulae
List all the {{ site.taps.core.fullname }} formulae's analytics events for a specified category over a number of days, grouped by formula name. This is the data source for `brew info --analytics --formula <formula>`.

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/homebrew-core/${DAYS}.json
GET https://formulae.brew.sh/api/analytics-linux/${CATEGORY}/homebrew-core/${DAYS}.json
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
{% include api-samples/analytics_install_homebrew_core_30d.md %}

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
{% include api-samples/analytics_cask_install_homebrew_cask_30d.md %}
