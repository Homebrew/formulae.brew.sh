# Homebrew Formulae

[Homebrew Formulae](https://formulae.brew.sh) is an online package browser for [Homebrew](https://brew.sh).

It displays all packages in the [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core) and [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask). A [GitHub Action](https://github.com/Homebrew/formulae.brew.sh/blob/master/.github/workflows/scheduled.yml) is run periodically which pulls changes from each tap and deploys the site to GitHub Pages.

## JSON API
It also provides a JSON API for all packages (or individual packages) in each tap and their related analytics. This JSON data is used for the creation of the HTML resources on this site.

Currently available:

- List formulae metadata for all formulae
- Get formula metadata for each formula
- List analytics events for all formulae
- List analytics events for each formula

Read more in the [JSON API documentation](https://formulae.brew.sh/docs/api/).

## Usage
Open <https://formulae.brew.sh/> in your web browser.

To instead run Homebrew Formulae locally, run:
```bash
git clone https://github.com/Homebrew/formulae.brew.sh
cd formulae.brew.sh
bundle install
bundle exec jekyll serve
```

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
