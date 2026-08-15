# laggardkernel/tap

Personal Homebrew tap for custom builds, pinned/legacy versions, missing apps,
and a few extra `brew` commands.

Things live here when Homebrew-core/cask will not take them:

- option/patched rebuilds: `aria2-options`, `tmux-options`, `libass-options`,
  `mkcert-custom`
- upstream binaries packaged differently from core: `*-bin`, `ffmpeg-static`,
  `neovim-nightly`
- launchd helpers: `openvpn-service`, `rc-local`
- version-pinned casks official Homebrew will not keep: `*-versioned`,
  `forklift3`
- apps missing from official cask

Look in `Formula/` and `Casks/` for the current inventory, or run
`brew tap-info laggardkernel/tap`.

## Installation

```bash
brew tap laggardkernel/tap
brew install laggardkernel/tap/<formula>
brew install --cask laggardkernel/tap/<cask>
```

## External Commands

- `brew switch <formula> <version>` — old `brew switch` (removed in Homebrew
  2.6), for kegs that are not `@`-versioned
- `brew fix-perm [formula|all]` — repair root-owned kegs after
  `sudo brew services`
- `brew git-gc` — `git gc` across the Homebrew repo and every tap
- `brew bat <formula|cask>` — `brew cat` through `bat`

## Contributing

```bash
git config --local blame.ignoreRevsFile .git-blame-ignore-revs
brew style --fix
```

`brew style --fix` is helpful but not trustworthy. Be careful.

## References

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Formula API](https://rubydoc.brew.sh/Formula)
- [example-formula.rb](https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb)
- [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [How to Create and Maintain a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Detect OS, CPU arch from GoReleaser](https://github.com/filebrowser/homebrew-tap/blob/master/Formula/filebrowser.rb)
- [`brew livecheck`](https://docs.brew.sh/Brew-Livecheck)
- Deprecation of ARGV
  - https://github.com/Homebrew/brew/issues/1803
  - https://github.com/Homebrew/brew/issues/7093
  - https://github.com/Homebrew/brew/issues/5730
  - https://github.com/Homebrew/brew/pull/6857
