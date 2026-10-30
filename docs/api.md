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

List the `brew info --json` output for all current {{ site.taps.core.fullname }} formulae or {{ site.taps.cask.fullname }} casks.

```console
curl https://formulae.brew.sh/api/formula.json
curl https://formulae.brew.sh/api/cask.json
```

**[Response](https://formulae.brew.sh/api/formula.json):**

{% include api-samples/formula.md %}

### Get formula metadata for a {{ site.taps.core.name }} formula

Get the `brew info --json --formula <formula>` output for a single, current {{ site.taps.core.fullname }} formula with extra keys containing analytics data and generation date.

```console
curl https://formulae.brew.sh/api/formula/${FORMULA}.json
```

**Variables:**

- `${FORMULA}`: the name of the formula, e.g. `wget`

**[Response](https://formulae.brew.sh/api/formula/wget.json):**

{% include api-samples/formula_wget.md %}

### Get cask metadata for a {{ site.taps.cask.name }} cask

Get the `brew info --json=v2 --cask <cask>` JSON output for a single, current {{ site.taps.cask.fullname }} cask with extra keys containing analytics data and generation date.

```console
curl https://formulae.brew.sh/api/cask/${CASK}.json
```

**Variables:**

- `${CASK}`: the name of the cask, e.g. `docker-desktop`

**[Response](https://formulae.brew.sh/api/cask/docker-desktop.json):**

{% include api-samples/cask_docker_desktop.md %}

## Analytics

### GitHub package downloads

Package-wide download totals and comparisons with 30-day core formula install analytics are generated daily for the top 1,000 formulae by install events.
The download analytics page shows all 1,000 selected formulae, ordered by cumulative downloads; its only large table is last.
They are also included as `github_packages_downloads` in selected formulae's JSON and displayed on their pages and the [download analytics page](../../analytics/github-packages/).

```console
curl https://formulae.brew.sh/api/analytics/github-packages/30d.json
brew info --github-packages-downloads wget
```

The source is GitHub's package overview HTML: the exact total since the migration from Bintray and the daily counts in its 30-day chart, across versions and platforms.
The `all_time` field excludes earlier downloads from Bintray.
The report includes each package's source URL, fetch timestamp, chart dates and analytics dates.
Successful lookups are cached for the UTC day; missing or unparseable pages appear in `unavailable_formulae`, not as zero downloads.
These counts cover current core formulae with available package data, not casks or third-party taps.
The HTML is not a documented API and may change.

`analytics_ratio` is 30-day downloads divided by 30-day install events; 2 means twice as many downloads as reported install events.
It is null when install events are zero.
Formula analytics count reported installation attempts, including dependencies, source builds and CI.
GitHub downloads can include other clients and repeated downloads, while local cache hits can avoid downloads.
The chart dates may not align exactly with the rolling analytics window, and today's chart count may be incomplete.
The difference therefore does not measure people or installations with analytics disabled.
The all-time count is separate and is never compared with 30-day analytics.

`selected_formulae` and `catalog_formulae` describe coverage; `analytics_coverage_percent` is the selected formulae's share of current core formula install events.
This is not their share of downloads, which is unknown for the rest of the catalogue.
Formulae outside the subset are not measured; `unavailable_formulae` lists selected formulae whose download counters could not be fetched.
Use `brew generate-analytics-api --github-packages-limit=500` for a smaller subset.
The limit must be between 1 and 1,000; `all`, zero and larger values are rejected before generation starts.

The download Top 1,000 row sums every available package in the JSON.
Its ratio is the unweighted arithmetic mean of available per-formula ratios, excluding zero-install denominators; it is not the ratio of the two totals.

### Repository and catalogue analytics

The [repository analytics page](../../analytics/github/) and JSON report cover `Homebrew/brew`, `Homebrew/homebrew-core`, `Homebrew/homebrew-cask` and the archived `Homebrew/legacy-homebrew` from 2009 onwards.

```console
curl https://formulae.brew.sh/api/analytics/github/history.json
brew generate-analytics-api --repositories --legacy-homebrew=/path/to/legacy-homebrew
```

Brew, core and cask each have a `current` row followed by annual rows, newest first.
Current activity counts are cumulative; annual activity counts cover UTC calendar years, with the current year incomplete.
Formula and cask counts are catalogue snapshots, at present or year end, including deprecated, disabled and versioned packages but excluding aliases and third-party taps.
Counts use regular Ruby files at the reported Git revision, so deletions and renames are reflected in the snapshot rather than counted as additional packages.
Historical cask totals cover the main cask repository; other cask taps enter the count only when merged into it.

`pull_requests_opened` and `issues_opened` count records created in the period, regardless of their current state.
`pull_requests_merged` counts distinct PR references applied on Git's first-parent branch, by UTC committer year.
It includes `brew pull`'s standalone `Closes #123.` trailers as well as merge and squash subjects, deduplicating each PR number across commits and years.
Brew and core exclude inherited references before their repository split commits; cross-repository references are excluded.
These are inferred applied PRs, not GitHub merge states: unrecognised references are missed and manually written issue-only `Closes` trailers can overcount.
A closed PR therefore must not be treated as rejected.
Issues explicitly exclude pull requests; all counts include bot activity.
Opened PRs and issues cover completed UTC days, using the shared paginated repository issues endpoint and its `pull_request` marker.
A saved completed-day baseline lets the generator count only newly created records; repeated pagination records are deduplicated.
A missing baseline, excessive pagination or year-end reconciliation uses two search `total_count` queries.
Across a run, list pages plus fallbacks cannot exceed twice the search-only request count; spare requests carry forward between repositories.
Incremental counts cannot observe later transfers or deletion of previously counted records; a fresh search baseline can reconcile them.
Applied PRs use local Git. Legacy references below [PR #2326, opened on 1 September 2010](https://github.com/Homebrew/legacy-homebrew/pull/2326), are issue closures and excluded.
Legacy `Closes` trailers are counted using the same parser as core, but `brew pull` only started adding them automatically on 30 December 2010.
A one-off backfill of archived Git PR refs #2326–9500 recovers applied PR heads and exact stable patch, author email and author timestamp matches.
Every non-merge PR commit absent from main must match; ambiguous applied heads are excluded and PR numbers already counted by trailers are deduplicated.
The committed archive records the method and recovered annual counts; unmatched or manually edited patches remain unknown, not rejected PRs.
PRs opened and applied in different years belong to different annual rows.
The website and its JSON cap `pull_requests_merged` at `pull_requests_opened` for each period; the source history retains uncapped counts.
`merge_rate` uses the capped merged count divided by opened PRs in the period, expressed as a percentage up to 100% to one decimal place; it is null when counts are unavailable or no PRs were opened.
`security_advisories` counts currently published repository advisories by publication date, including published withdrawn records.
Private and draft advisories and vulnerabilities in distributed packages are excluded.
`security_disclosures` separately counts brew.sh security incident disclosure posts, excluding audits, under brew for the whole project.
These may overlap repository advisories and must not be added as unique incidents.
Pass `--homebrew-site=/path/to/brew.sh` to read tracked posts from local Git; CI keeps a daily refreshed, filtered bare clone in the working cache.
The same flag adds release announcement links to release JSON.

`contributors` counts distinct non-merge commit author email identities, using the current `.mailmap` and UTC committer dates.
It includes bots and inherited Git history, excludes co-author trailers and does not identify unique people or GitHub accounts.
`releases` counts stable numeric Homebrew/brew Git tags reachable from HEAD, dated by their target commits; these are not GitHub Release publication dates.
Catalogue, contributor and release counts use local Git rather than GitHub API queries.
Each repository table combines Git and GitHub counts.
Brew and core display annual rows from 2016; legacy displays annual rows through 2015 without a Current row.
The optional `--legacy-homebrew` path adds a complete local clone of the original shared repository, including its own PRs, issues, contributors, release tags and historical formula counts.
Legacy GitHub activity stays in its own table rather than being assigned to either brew or core.
Inherited Git history overlaps between repositories, so their contributor and release counts cannot be added as unique totals.
`combined_contributors` reports the union of non-merge commit author email identities across brew, core and cask for each UTC committer year and across all years in `current`.
It uses each repository's current mailmap and counts an identical email once across repositories and years; legacy-only identities are excluded.
This is an identity count, including bots, rather than a count of unique people: unmapped aliases remain separate and shared addresses count once.
`new_contributors` counts identities first appearing in that UTC year; combined counts use their first appearance across all three repositories.
Current total and new contributor counts both cover all available history.
`maintainers` counts distinct GitHub accounts listed as current maintainers, project leader or technical steering members in brew's year-end README.
Former maintainers are excluded.
Before 2014, maintainer counts use non-bot first-parent committers who applied another author's work, deduplicating names and known aliases.
The 2014 cross-check gives six, matching its README roster; pre-2014 counts are 2, 4, 7, 6 and 8 for 2009–2013.
`maintainer_contributor_ratio` is maintainers as a percentage of active unique contributors.
`pull_requests_per_maintainer` and `issues_per_maintainer` divide opened records across the three repositories and legacy by maintainers.
Current ratios use today’s maintainers and cumulative contributors, PRs and issues.
Only aggregate counts are published; local Git checkpoints supply the identities without additional GitHub queries.
CI caches the archived Git clone alongside the incremental analytics checkpoints.

The generator requires complete local brew, core and cask Git histories and brew release tags.
It stores the checked Git revision, reuses historical catalogue snapshots and updates contributor identities, applied PR references and cask changes from new commits.
A rewritten history, changed `.mailmap` or changed generator invalidates that Git cache.
Completed years come from the committed archive; the current year refreshes daily.
Current contributor totals count each email identity once across all available history.
`github_fetched_at` records query age because later transfers and deletions can alter historical GitHub counts.
Frozen years require an explicit archive edit; without `--history`, clearing working cache files permits new historical queries.
Advisory pagination follows GitHub's cursor links. Incomplete search responses fail generation so the site can use its dated fallback.
Definitions for every column are displayed on the analytics page.

### Homebrew release analytics

The [brew release page](../../analytics/releases/) reports commits, PR references and contributors per release using local Git only.
Annual release totals remain in the JSON and on the repository analytics page.

```console
curl https://formulae.brew.sh/api/analytics/releases/history.json
brew generate-analytics-api --releases
```

Stable numeric tags reachable from the checked revision count as releases; dates use their target commits in UTC rather than GitHub publication dates.
Each release's changes are commits reachable from its tag but not the preceding release tag on its first-parent ancestry.
The first release includes all its preceding history; backport branches use their own predecessor.
`commits` counts non-merge commits and `contributors` counts their distinct author email identities after the current mailmap, including bots but excluding co-author trailers.
`new_contributors` counts identities appearing for the first time in a stable release, ordered by tagged commit date then version.
This includes inherited history and assigns each identity to one release; it is not a count of newly created GitHub accounts.
`pull_requests` counts distinct PR numbers in merge subjects or trailing `(#123)` squash subjects.
This is a lower bound inferred from Git, not an authoritative GitHub merged PR count; missing references and predecessor repository history limit attribution.
Backports can appear in multiple release ranges, so per-release PR and contributor counts must not be summed as unique annual totals.
Unchanged release statistics are cached; new tags are processed incrementally, while changed generator code or mailmap invalidates the cache.
Major and minor `.0` releases also have an aggregate row since the preceding major or minor `.0` tag.
For example, 7.0.0 has its usual release row and a major aggregate from 6.0.0.
Aggregate new contributors are absent from the preceding boundary's ancestry; normal release rows use first appearance across all stable releases.
`totals` deduplicates commits, PR references and authors across all included tags.
Complete local brew history and tags are required. No GitHub API or InfluxDB token is needed.

### Formula version history

The [formula history page](../../analytics/formula-history/) uses local Git and `FormulaVersions` to count stable versions, major/minor/patch changes, formula revision bumps and bottle rebuilds.

```console
curl https://formulae.brew.sh/api/analytics/formula-history/history.json
brew generate-analytics-api --formula-history
```

Without an archive, the initial window starts on 1 January five years before the first run and is retained as later years accumulate.
The site archive selects its 2009 baseline instead.
A baseline snapshot establishes versions already present before the window; those are not counted as newly introduced versions.
History follows core's first-parent branch and uses UTC committer dates, including merge changes once.
Git-detected renames preserve formula identity; deletions end a lifetime and re-additions begin a new one.
Versioned formulae count separately, and other taps are excluded.

Historical formulae are evaluated for the latest supported macOS and Linux on ARM and Intel.
Versions shared across these platforms count once per formula lifetime; this does not reconstruct every historical macOS variant.
Version changes use Homebrew's `Version` components, not strict semantic versioning.
One version-change category is counted per formula commit, preferring major, minor, patch then other.
Revision bumps require an unchanged upstream version; bottle rebuilds require both version and revision to be unchanged.

The persistent checkpoint stores the checked Git revision, latest formula metadata, previously observed versions and annual aggregates.
New runs process only commits after that revision, fetching missing Git objects in batches when the clone is partial.
Changed parser code, platform targets or rewritten history invalidate the checkpoint.
A run works for approximately ten minutes, stopping at a batch boundary and preserving progress for the next run.
`complete: false` identifies an unfinished backfill; unvisited years are null, and current maintenance counts are withheld until the target revision is reached.
`unreadable` remains in JSON and counts historical formula changes that today's loader cannot evaluate on at least one platform.
Missing metadata and backwards-incompatible DSL or dependency changes can cause these failures; this is neither a count of unreadable current formulae nor a sum of other columns.
Unreadable changes make observed version counts lower bounds.
`formulae` adds year-end catalogue totals; Current uses the checked revision, and totals remain pending until the backfill completes.
The same page includes cask `added`, `removed` and total `casks` from the repository JSON, covering all available cask history.
Cask changes use first-parent Git metadata without evaluating old casks: exact-content renames and aliases are excluded, while renamed-and-edited files count as removed and added.
Other cask taps enter these counts only when merged into the main repository; cask version changes are not evaluated.

To seed CI from a formulae.brew.sh checkout, run `brew generate-analytics-api --formula-history --history=analytics/history.json` until `_data/analytics/formula-history/history.json` reports `complete: true`, then export the checkpoint:

```console
cp "$(brew --cache)/analytics/git/formula-history.json" formula-history-cache.json
```

To replace the pinned seed, upload the checkpoint to a public HTTPS URL and update the URL and SHA-256 in `script/bootstrap-formula-history.rb`.
CI downloads it only when no local checkpoint was restored, then persists incremental updates in its working cache.
The uploaded file must be the checkpoint, not the public report, which lacks the per-formula state needed to resume.
Use the same Homebrew parser code and platform targets locally and in CI; the generator discards incompatible checkpoints or checkpoints whose revision is no longer an ancestor of core's current revision.
To replace an existing CI checkpoint with a new upload, remove the `analytics-working-v1-*` Actions caches before the next analytics generation.
Neither generation nor checkpoint export needs an InfluxDB token.

The JSON retains maintenance groups for current formulae into confirmed updates, no observed update, unknown history and no stable version.
An update is a formula addition, stable version change or formula revision increase in the last 12 months; bottle-only changes are excluded.
This is a defined activity signal, not a judgement of project maintenance or security.

### Package security analytics

The [package security page](../../analytics/security/) publishes two snapshots without adding network scans:

```console
curl https://formulae.brew.sh/api/analytics/security/corpus.json
curl https://formulae.brew.sh/api/analytics/security/current.json
```

`generate-advisories-api` summarises all records in its advisory-database checkout, including withdrawn and uncomparable counts, recorded patch/version fixes, severity and distinct upstream identifiers.
All corpus breakdowns except total records exclude withdrawn records.
The JSON includes the source Git revision and generation time.

`generate-formula-api` aggregates the findings it already attaches to current formula JSON, using the same advisory range and severity logic as `brew vulns`.
It reports catalogue coverage, formulae with open findings, open/patched/version-fixed findings, open severity counts and per-formula rows.
These use the formula API's latest supported macOS/ARM version; other variants and bundled dependencies can differ.
Formulae without corpus records are not covered, rather than declared clean.
An unavailable feed is labelled `available: false`, rather than interpreted as zero findings.

Findings are formula-specific advisory records, so the same upstream vulnerability can appear for several formulae.
Distinct upstream identifiers are not unique vulnerabilities because aliases are not merged.
Fix counts describe the corpus or current version status, not the number of fixes shipped in a calendar year.
The corpus checkout and the advisory index used for formula generation can have different collection times.
Repository security advisories remain a separate metric on the repository analytics page.

### Completed-year archive

[`analytics/history.json`](../../analytics/history.json) commits repository, contributor, catalogue, formula and release aggregates through 2025 in approximately 256 KB.
Sources and collection times are included; definitions are prose on the analytics pages, while contributor identities remain in the private working cache.
Repository, catalogue and formula series start in 2009.
A one-off formula backfill extracted version, revision and rebuild declarations before evaluating them with the existing version reader.
This recovered obsolete formulae without adding permanent compatibility code to `FormulaVersions`.
The JSON records the source revision, method and validation; future runs use the normal generator with the uploaded checkpoint.
All 8,667 current formula records match the original checkpoint and all previously observed versions are retained.
The replay recovers the original 3,674 unreadable changes from 2021 onwards and another 27 from 2010–2015.
The last case was an intentionally emptied `bbcp` file immediately before removal; adjacent commits establish the migration, so it is excluded without inventing a version.
No unresolved formula metadata remains in the committed history.
Release rows, major/minor aggregates and annual release totals are included.
Downloads and security findings are current snapshots, so no unavailable historical series is inferred from them.

Pass `--history=/path/to/analytics/history.json` to `brew generate-analytics-api` to reuse completed years and retain backfill provenance.
The current year and Current rows refresh daily; Current contributor/release totals still use cached Git state to deduplicate overlapping histories.
Frozen years do not change when GitHub records are later transferred or deleted.

The `Archive History` workflow runs at 02:00 UTC on 1 January and supports manual dispatch.
On 1 January 2027 it generates final 2026 data and proposes a pull request appending that year.
Push runs trigger only when `.github/workflows/analytics-history.yml` changes.
They restore caches, generate fresh reports in parallel and run the archive update in dry-run mode, without writing the archive or proposing a PR.
With generated reports present, the same command previews an update:

```console
ruby script/update-analytics-history.rb --dry-run
ruby script/update-analytics-history.rb
```

The updater rejects current/future years, missing annual rows, incomplete formula backfills and reports generated before the year ended.
Existing years remain unchanged; corrections require explicit JSON edits.
The scheduled job needs a formula-history checkpoint and permission for GitHub Actions to create pull requests.
PRs created with the default Actions token require a maintainer to approve their workflow runs before CI starts ([GitHub documentation](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow)).

InfluxDB data is excluded from the archive.
Only 30-, 90- and 365-day rolling reports are generated, replacing previous reports; there are no historical usage snapshots.
`script/prune-analytics.rb` removes restored usage reports spanning more than 365 days or ending over a year ago.
Restored GitHub Packages reports are removed if any package counter was fetched over a year ago.
This controls the site's generated data, not the InfluxDB server's retention policy.

### Generation cost and caching

Local measurements on 24 October 2026, excluding checkout and cache transfer:

| Data | Time | Repeat-run behaviour |
| --- | --- | --- |
| Formula API and security findings | 75 seconds | Formulae parsed and all outputs regenerated every run. |
| Cask API | 34 seconds | Casks parsed and all outputs regenerated every run. |
| Internal API | 107 seconds | Formulae and casks parsed independently every run. |
| Advisory API and corpus | 4 seconds | Output cache keyed by advisory tree and generator code. |
| Repository Git data | 58 seconds cold; 1.7 seconds cached | New commits only; year-end snapshots persist. |
| GitHub PR/issue/advisory data | At most 12 list/search requests plus three advisory requests daily | Incremental completed-day lists; completed years use committed JSON. |
| 1,000 package download counters | 4 minutes 5 seconds cold; under 1 second cached | One HTML request per formula per UTC day. |
| Homebrew releases | 26 seconds cold; under 1 second cached | New/changed release and major/minor ranges only. |
| Formula history | 17-minute one-off metadata replay; 0.73 seconds unchanged | Uploaded checkpoint seeds state; only new commits are evaluated. |
| Jekyll build | 68 seconds | Full site rebuild. |

The formula replay timing uses already available Git objects; initial downloads and pack maintenance take additional time.
A changed-day formula run scales with the new commits; the unchanged timing does not include evaluating new formula changes.

Searches remain for a missing completed-day baseline, excessive pagination and final year-end reconciliation of deletions and transfers.
These cannot be recovered from Git because unmerged PRs and issues may never appear in a commit.
Applied PRs, releases, contributors, maintainers and catalogue counts use Git; repository advisory dates use the non-search REST endpoint.
Advisory pagination adds requests above 100 advisories per repository.
A cold baseline needs six searches: at least 13 seconds authenticated or 37 seconds unauthenticated, plus network time; cached periods make no queries.
January rollover uses six searches to reconcile the final completed year before freezing it; daily lists cannot detect deleted or transferred old records.

The 15-minute publication workflow restores analytics output for the UTC day and archive hash.
Only the first successful daily run refreshes it; failures preserve the dated last successful snapshot.
The generator calls the shared Ruby InfluxDB query interface directly, then builds repository, release, formula-history and download reports.
The January archive workflow runs the independent Git reports in parallel.
Formula, cask and internal API generation run independently in parallel.
InfluxDB generation was not timed locally because the session had no token; its unmeasured thread pool was removed.
Download fetching retains four workers: 32 uncached package requests took 3.42 seconds sequentially and 0.94 seconds with four workers after warming GitHub’s responses, a 3.6× speed-up.
Warm Git reports took 1.55 seconds sequentially and 0.97 seconds with three threads; the small absolute saving does not justify a second thread pool.

CI downloads the initial checkpoint using `script/bootstrap-formula-history.rb`, which pins the attachment URL and verifies its SHA-256 before installing it.
After verification, committed historical corrections update the seed’s annual counts and recovered version observations.
Restored incremental checkpoints take precedence and are not compared with the original seed’s hash.
The aggregate archive cannot replace this checkpoint's per-formula state.
Other Git analytics caches populate automatically on their first run; no upload is needed.
Parser or platform changes can invalidate the formula checkpoint, so keep the seed compatible with CI's brew code.

### List one category of analytics events

List all analytics events for a specified category over a number of days, ordered by event frequency count. This is the data source for `brew info --analytics`.

```console
curl https://formulae.brew.sh/api/analytics/${CATEGORY}/${DAYS}.json
```

**Variables:**

- `${CATEGORY}`: the analytics event category, i.e.
  - `install`: the installation of all formulae
  - `install-on-request`: the requested installation of all formulae (i.e. not as a dependency of other formulae)
  - `build-error`: the installation failure of all formulae
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

**[Response](https://formulae.brew.sh/api/analytics/install/30d.json):**

{% include api-samples/analytics_install_30d.md %}

### List analytics events for all {{ site.taps.core.name }} formulae

List all the {{ site.taps.core.fullname }} formulae's analytics events for a specified category over a number of days, grouped by formula name. This is the data source for `brew info --analytics --formula <formula>`.

```console
curl https://formulae.brew.sh/api/analytics/${CATEGORY}/homebrew-core/${DAYS}.json
```

**Variables:**

- `${CATEGORY}`: the analytics event category, i.e.
  - `install`: the installation of all {{ site.taps.core.repository }} formulae
  - `install-on-request`: the requested installation of all {{ site.taps.core.repository }} formulae (i.e. not as a dependency of other formulae)
  - `build-error`: the installation failure of all {{ site.taps.core.repository }} formulae
    - only `${DAYS}: 30d` (30 days) is available
- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

**[Response](https://formulae.brew.sh/api/analytics/install/homebrew-core/30d.json):**

{% include api-samples/analytics_install_homebrew_core_30d.md %}

### List analytics events for all {{ site.taps.cask.name }} casks

List all the {{ site.taps.cask.fullname }} cask's analytics events for the `cask-install` category over a number of days, grouped by cask token.
This is the data source for `brew info --analytics --cask <cask>`.

```console
curl https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/${DAYS}.json
```

**Variables:**

- `${DAYS}`: the number of days of analytics events, i.e.
  - `30d`: 30 days
  - `90d`: 90 days
  - `365d`: 365 days

**[Response](https://formulae.brew.sh/api/analytics/cask-install/homebrew-cask/30d.json):**

{% include api-samples/analytics_cask_install_homebrew_cask_30d.md %}
