# Custom Formulae

Originnaly cr8d by laggardkernel as a place for:

- Homebrew commands removed from [there](https://github.com/Homebrew/brew).

- Mac-centric formulas with options (passed away in original Homebrew-core repo).

- Python and DNS cli-apps.

This tap will be linuxbrew-core centric, w/o intention to lost homebrew-core
compabillity.

Python's whistles and bells had removed, options formulas only for Mac also
had deleted.

## News

<details>
  <summary>Big changes made in this repo.</summary>

- 2021-04-13
  - New Readme, first watchlists for Homebrew's livecheck
      pywhistles/casks/formulas w/ options only for Mac had removed.
  - Backported new updates from original repo.
- 12-01-2020
  - `Homebrew.args` is deprecated in 2.6.0. Pass value into formula build with
      `--with-key=value` is not possible anymore.

    </details>

## Installation

```bash
brew tap juplutonic/tap
brew install juplutonic/tap/<formula>
```

## External Commands

- switch ```brew switch```, the old goodie dropped by brew in 2.6.0

- fix-perm ```brew fix-perm```, fix formula file perms broke by ```sudo brew services```

- git-gc `brew git-gc`, copied from ymyzk/homebrew-ymyzk, original tap removed

- pip `brew-pip`, [brew pip](https://github.com/josegonzalez/brew-pip) [(my last modification)](https://github.com/josegonzalez/brew-pip/pull/2)

- gem `brew-gem`, [brew gem](https://github.com/sportngin/brew-gem) [(my last modification)](https://github.com/sportngin/brew-gem/pull/68)

## Workflow to manage my tap

- 🕗️Coming soon: 1_brew-pip_brew-gem_formulas

- 🕗️Coming soon: 2_maintained_formulas

- 3_options_formulas

- 🕗️Coming soon: 4_dns_formulas

- 🕗️Coming soon: 5_maintained_linuxbrew_formulas

- 🕗️Coming soon: 6_maintained_linuxbinary_formulas

Command:

```bash
brew livecheck < Livechecks/3_options_formulas
```

>[Livecheck for the last versions][Homebrew/Livecheck]


## Formulae

Check the `Formula/` folder directly. No longer bother to introduce them here.

#### 🛡️ Adguard Home DNS

> TODO: livecheck
>
> GPL-3.0 License

#### 🔲🔘🔳 Aria2

> `aria2-options`
>
> - Header 'Want-Digest' is removed
>
> - `--with-gnutls` (no TLSv1.3 support in appletls)

> livecheck ✔️
>
> GPL-2.0-or-later

#### 🛠 Bing Wallpaper

> `bing-wallpaper`
>
> - `--head`, `HEAD` only

#### 🛠 BrowserSh

> 🕗️Coming soon

#### 🛡️ CDNS

#### 🛡️ ChinaDNS

> `chinadns`, fork [aa65535/ChinaDNS][aa65535/ChinaDNS]
>
> - more exact [17mon/china_ip_list][17mon/china_ip_list] is recommended

#### 🛠 Cht.Sh

> 🕗️Coming soon

#### 🛡️ ClashPremium

> TODO: livecheck
>
> GPL-3.0 License

#### 🛡️ CureDNS

> [cdns][curedns], filter poisoned result with EDNS option.
>
> - fails to build from `HEAD` for the time being

#### 🔲🔘🔳 cURL

> `curl-options`
>
> `--with-brotli`, lossless compression support
>
> `--with-c-ares`, C-Ares async DNS support
>
> `--with-gssapi`, GSSAPI/Kerberos authentication support
>
> `--with-libidn`, international domain name support
>
> `--with-libmetalink`, Metalink XML support
>
> `--with-libssh2`, scp and sftp support
>
> `--with-libressl`, LibreSSL instead of Secure Transport or OpenSSL
>
> `--with-nghttp2`, HTTP/2 support (requires OpenSSL or LibreSSL)
>
> `--with-openldap`, OpenLDAP support
>
> `--with-openssl@1.1`, OpenSSL 1.1 support
>
> `--with-rtmpdump`, RTMP support

> livecheck ✔️
>
> curl License

#### 🛡️ curl-doh

#### 🔲🔘🔳 🛡️ DNSmasq

> `dnsmasq-options`
>
> - `--with-dnssec`
>
> - `--with-libidn`

> livecheck ✔️
>
> GPL-2.0-only or GPL-3.0-only

#### 🛡️ dns-over-https

#### 🛡️ doh-proxy

#### 🛠 Git Log Compact

> git-log-compact
>
> - `HEAD` only
>
> - fork [cxw42/git-log-compact][cxw42/git-log-compact] but not the original one is used for more options

#### 🛠 Git Open

> git-open from paulirish/git-open support open repo, branch, issue from terminal.

#### 🛠 Grc

> Rust implementation of git-cz, standard git commit.

#### 🔲🔘🔳 FFMpeg

> `ffmpeg-options`
>
> --with-chromaprint - the Chromaprint audio fingerprinting library
>
> --with-decklink - DeckLink support
>
> --with-fdk-aac - the Fraunhofer FDK AAC library
>
> --with-game-musi-emu - Game Music Emu (GME) support
>
> --with-librsvg - SVG files as inputs via librsvg
>
> --with-libssh - SFTP protocol via libssh
>
> --with-openh264 - OpenH264 library
>
> --with-openssl - SSL support
>
> --with-zeromq - using libzeromq to receive commands sent through a ZeroMQ client
>
> --with-zimg - z.lib zimg library
>
> --with-libvmaf - libvmaf scoring library

> livecheck ✔️
>
> GPL-2.0-or-later License

#### 🛠 FilebrowserBin

> TODO: livecheck
>
> Apache-2.0 License

#### 🛠 iTerm2 ZModem

> iterm2-zmodem

#### 🛠 License

> license mit > LICENSE.txt, [nishanths's licence][license]

> TODO: v3.0.0
>
> MIT

#### 🛡️ MEOW

> Fork of proxy cow. Proxy or direct connect according to geolocation of the
>
> IP address [MEOW][meow]
>
> - `--HEAD` only

#### 🛡️ Mos-ChinaDNS

#### 🛡️ MosDNS

> livecheck ✔️
>
> GPL-3.0 License

#### 🛠 mpdscribble

> `MPD scrobbler`

> TODO: transfer to linuxbrew-core
>
> livecheck ✔️
>
> GPL-2.0 License

#### 🛠 Nali

> livecheck ✔️
>
> MIT

#### 🔲🔘🔳 OpenSSH

> `openssh-options`
>
> - `--with-libressl`

> livecheck ✔️
>
> SSH-OpenSSH License

#### 🛡️ Overture

> TODO: linux install
>
> livecheck ✔️
>
> MIT

#### 🛠 Pipe-viewer

> 🕗️Coming soon: A lightweight YouTube client for Linux
>
> TODO: transfer to linuxbrew-core
>
> Artistic-2.0 License / GPLv1

#### 🛠 plan9port

> 🕗️Coming soon: [jacobvosmaer's formula][jacobvosmaer_plan9port]
>
> TODO: PR to jacobvosmaer / linuxbrew-core

#### 🛠 QWT

> 🕗️Coming soon

#### 🛡️ Pcap DNS proxy

#### 🔲🔘🔳 Ranger

> ranger-fm with optional dependencies
>
> - `HEAD` only
>
> - `chardet` for better encoding detection
>
> - `Pillow` (depended by image preview in kitty)

> TODO: add livecheck, do python3 errors closed?
>
> GPL-3.0 License

#### 🛡️ Routedns

#### 🛡️ sans

> [sans][sans]

#### 🛡️ ShDNS

> [shdns][shdns], A port of ChinaDNS (DNS filter) in golang with IPv6 support.
>
> Only works if shdns-bin is installed (with `brew install`)

#### 🛠 SML NJ

> Standard ML of New Jersey
>
> TODO: livecheck and transfer to linuxbrew-core because it now x86_64
>
> For darwin see [macports][smlnjs]
>
> Unknown, Macports writes it's BSD

#### 🛠 sshpass

> 🕗️Coming soon: Sshpass is easier, less secure way to do auth with SSH, mostly for home use.[Site][sshpass]
>
> TODO: liveckeck in (2_maintained_formulas)
>
> GPLv2 License

#### 🔲🔘🔳 tmux

> `tmux-options`
>
> - `--with-fps=`, `--with-fps=30` custom FPS 30, default 10

> livecheck ✔️
>
> ISC License

#### 🔲🔘🔳 🛡️ Unbound

> livecheck ✔️
>
> BSD-3-Clause

#### 🛡️ V2ray2Clash

> [ne1llee's v2ray2clash][v2ray2clash] a web API used to convert v2ray, ssr subscription lists
> into clash, QuantumultX format /for VPN creation.
>
> - `--HEAD`

## References

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)

- [Formula API](https://rubydoc.brew.sh/Formula)

- [example-formula.rb](https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb)

[aa65535/ChinaDNS]: https://github.com/aa65535/ChinaDNS

[curedns]: https://github.com/semigodking/cdns

[17mon/china_ip_list]: https://github.com/17mon/china_ip_list

[cxw42/git-log-compact]: https://github.com/cxw42/git-log-compact

[license]: https://github.com/nishanths/license

[Homebrew/Livecheck]: https://docs.brew.sh/Brew-Livecheck

[meow]: https://github.com/netheril96/MEOW

[jacobvosmaer_plan9port]: https://github.com/jacobvosmaer/homebrew-stuff

[sans]: https://github.com/puxxustc/sans

[shdns]: https://github.com/domosekai/shdns

[smlnjs]: https://ports.macports.org/port/smlnj/summary

[sshpass]: https://sourceforge.net/projects/sshpass/

[v2ray2clash]: https://github.com/xch04028/v2ray2clash

> TODO: Transfer non-DNS binaries to https://github.com/athrunsun/homebrew-linuxbinary

> TODO: Transfer GNU/MIT soft to https://github.com/Homebrew/linuxbrew-core

> TODO: (Optional) Add Penguin/Apple emoticons per apps.
