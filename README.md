# Homebrew Formulae

[Homebrew Formulae](https://formulae.brew.sh) is an online package browser for [Homebrew](https://brew.sh).

It displays all packages in the [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core) and [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask). A [GitHub Action](https://github.com/Homebrew/formulae.brew.sh/blob/main/.github/workflows/tests.yml) is run periodically which pulls changes from each tap and deploys the site to GitHub Pages.

## JSON API

It also provides a JSON API for all packages (or individual packages) in each tap and their related analytics. This JSON data is used for the creation of the HTML resources on this site.

Currently available:

- List metadata for all formulae and casks
- Get metadata for each formula and cask
- List analytics events for all formulae and casks
- List analytics events for each formula and cask

Read more in the [JSON API documentation](https://formulae.brew.sh/docs/api/).

## Usage

Open <https://formulae.brew.sh/> in your web browser.

To instead run the site locally, run:

```bash
git clone https://github.com/Homebrew/formulae.brew.sh
cd formulae.brew.sh
script/prepare-local-preview.rb
bundle install
bundle exec jekyll serve
```

This downloads the generated data from the public API, so it does not require
local tap checkouts or Homebrew repository write access.

RSS feeds are published at `/feeds/formula-new.xml` (latest 50 additions) and
`/feeds/formula-updated.xml` (latest 500 version changes or revision increases).
Bottle-only rebuilds are excluded. Pages include RSS discovery links, and the
formula index has subscription links.

To populate the feeds for a local build, run `PATH="$PWD/script:$PATH" brew generate-formula-feeds`
with a complete `homebrew/core` Git checkout installed. CI generates the feeds with
the formula API. If generation fails, CI retains the last successfully generated
feeds from its cache. If no cached feeds are available, it publishes empty feeds
and reports a warning, allowing the site and package API deployment to continue.

Run the tests with `bundle exec rspec`. The feed tests require `brew` on `PATH`
and a Homebrew checkout that includes `Utils::Analytics::FormulaHistory` in
`Library/Homebrew/utils/analytics/formula_history.rb`. They use temporary Git
repositories, so a local `homebrew/core` checkout is not required for the tests.

## Search

Search is indexed by Algolia crawler at <https://crawler.algolia.com/admin/crawlers/26b9e6e2-bce4-4f42-9930-6b6ddf06cc9e/overview>.
This is only accessible by brew organisation members.

## License

Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
