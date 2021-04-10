# Custom Formulae
Collection of custom and deprecated formulae.

## News

<details>
  <summary>Big changes made in this repo.</summary>

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

## External Commands
- `brew switch`, the old goodie dropped by brew in 2.6.0
- `brew fix-perm`, fix formula file perms broke by `sudo brew services`
- `brew git-gc`, copied from ymyzk/homebrew-ymyzk, original tap died

## Formulae
Check the `Formula/` folder directly. No longer bother to update introduction here.

## References
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Formula API](https://rubydoc.brew.sh/Formula)
- [example-formula.rb](https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb)

[aa65535/ChinaDNS]: https://github.com/aa65535/ChinaDNS
[curedns]: https://github.com/semigodking/cdns
[17mon/china_ip_list]: https://github.com/17mon/china_ip_list
[cxw42/git-log-compact]: https://github.com/cxw42/git-log-compact
[license]: https://github.com/jfoster/license
[MEOW]: https://github.com/netheril96/MEOW
[sans]: https://github.com/puxxustc/sans
[shdns]: https://github.com/domosekai/shdns
[v2ray2clash]: https://github.com/ne1llee/v2ray2clash
