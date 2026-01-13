# Custom Formulae

Collection of custom and deprecated formulae.

## News

<details>
  <summary>Big changes made in this repo.</summary>

- ...
- 05-23-2021
  - Fix checkalive
- 12-01-2020
  - `Homebrew.args` is deprecated in 2.6.0. Passing value into formula build with
    `--with-key=value` is not possible anymore.
- 02-28-2020
  - Drops cask `mellow`, which is now maintained in Homebrew Cask repo
- 02-26-2020
  - Rename some formulae to avoid name conflicting after `brew tap-pin` is
    obsolete
- 10-04-2019
  - Remove formula `libcaca`, cause dependency `imlib2` is added in formula in
    homebrew-core
- 08-30-2019
  - Formulae with option `--with-openssl@1.1` is being removed cause formulae
    from Homebrew-core are moving to openssl@1.1.

</details>

## Installation

```bash
brew tap laggardkernel/tap
brew install laggardkernel/tap/<formula>
# brew tap-pin laggardkernel/tap # deprecated
```

## Development

```bash
git config --local blame.ignoreRevsFile .git-blame-ignore-revs
```

## External Commands

- `brew switch`, the old goodie dropped by brew in 2.6.0
- `brew fix-perm`, fix formula file perms broke by `sudo brew services`
- `brew git-gc`, copied from ymyzk/homebrew-ymyzk, original tap unmaintained
- `brew bat formula`, `bat` path hardcoding removed

## Formulae

Check the `Formula/` folder directly. No longer bother to update introduction here.

## References

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Formula API](https://rubydoc.brew.sh/Formula)
- [example-formula.rb](https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb)
- [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [Detect OS, CPU arch from GoReleaser](https://github.com/filebrowser/homebrew-tap/blob/master/Formula/filebrowser.rb)
- [`brew checkalive`](https://docs.brew.sh/Brew-Livecheck)
- `brew style --fix`, helpful but not trustworthy. Be careful!
- Deprecation of ARGV
  - https://github.com/Homebrew/brew/issues/1803
  - https://github.com/Homebrew/brew/issues/7093
  - https://github.com/Homebrew/brew/issues/5730
  - https://github.com/Homebrew/brew/pull/6857
