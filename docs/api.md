---
layout: page
permalink: /docs/api/
redirect_from:
  - /api/
  - /docs/
---
# JSON API Documentation

## Metadata

### List metadata for all {{ site.taps.core.name }} formulae or {{ site.taps.cask.name }} casks

List the `brew info --json --all` output for all current {{ site.taps.core.fullname }} formulae or {{ site.taps.cask.fullname }} casks.

```
GET https://formulae.brew.sh/api/formula.json
GET https://formulae.brew.sh/api/cask.json
```

#### [Response](https://formulae.brew.sh/api/formula.json)

{% include api-samples/formula.md %}

### Get formula metadata for a {{ site.taps.core.name }} formula

Get the `brew info --json --formula <formula>` output for a single, current {{ site.taps.core.fullname }} formula with extra keys containing analytics data and generation date.

```
GET https://formulae.brew.sh/api/formula/${FORMULA}.json
```

#### Variables

- `${FORMULA}`: the name of the formula, e.g. `wget`

#### [Response](https://formulae.brew.sh/api/formula/wget.json)

{% include api-samples/formula_wget.md %}

### Get cask metadata for a {{ site.taps.cask.name }} cask

Get the `brew info --json=v2 --cask <cask>` JSON output for a single, current {{ site.taps.cask.fullname }} cask with extra keys containing analytics data and generation date.

```
GET https://formulae.brew.sh/api/cask/${CASK}.json
```

#### Variables

- `${CASK}`: the name of the cask, e.g. `docker`

#### [Response](https://formulae.brew.sh/api/cask/docker.json)

{% include api-samples/cask_docker.md %}

## Analytics

### List one category of analytics events

List all analytics events for a specified category over a number of days, ordered by event frequency count. This is the data source for `brew info --analytics`.

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/${DAYS}.json
```

#### Variables

- `${CATEGORY}`: the analytics event category, i.e.
  - `install`: the installation of all formulae
  - `install-on-request`: the requested installation of all formulae (i.e. not as a dependency of other formulae)
  - `build-error`: the installation failure of all formulae
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

#### [Response](https://formulae.brew.sh/api/analytics/install/30d.json)

{% include api-samples/analytics_install_30d.md %}

### List analytics events for all {{ site.taps.core.name }} formulae

List all the {{ site.taps.core.fullname }} formulae's analytics events for a specified category over a number of days, grouped by formula name. This is the data source for `brew info --analytics --formula <formula>`.

```
GET https://formulae.brew.sh/api/analytics/${CATEGORY}/homebrew-core/${DAYS}.json
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

### List analytics events for all {{ site.taps.cask.name }} casks

List all the {{ site.taps.cask.fullname }} cask's analytics events for the `cask-install` category over a number of days, grouped by cask token.  This is the data source for `brew info --analytics --cask <cask>`.

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
