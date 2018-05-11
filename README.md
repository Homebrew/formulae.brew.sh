# Homebrew Formulae

[Homebrew Formulae](https://formulae.brew.sh) is an online package browser for [Homebrew](https://brew.sh).

It displays a list of all packages in [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core) and provides a JSON API for all packages (or individual packages) in [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core). It is deployed to GitHub Pages after every [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core) commit by [Travis CI](https://travis-ci.org).

## Usage
Open https://formulae.brew.sh/ in your web browser.

Instead, to run Homebrew Formulae locally run:
```bash
git clone https://github.com/Homebrew/formulae.brew.sh
cd formulae.brew.sh
bundle install
bundle exec jekyll serve
```

## License
Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
