# Custom Formulae
Originnaly cr8d by laggardkernel as a place for Homebrew commands removed from [there](https://github.com/Homebrew/brew). Mac-centric formulas with options (passed away in original Homebrew-core repo). And python and DNS cli-apps.
This tap will be linuxbrew-core centric, w/o intention to lost homebrew-core compabillity. Python's whistles and bells removed.


## News

<details>
  <summary>Big changes made in this repo.</summary>

- 2021-04-13 New Readme 
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
- `brew switch`, the old goodie dropped by brew in 2.6.0
- `brew fix-perm`, fix formula file perms broke by `sudo brew services`
- 🕗️Coming soon: `brew pip`, [brew-pip](https://github.com/josegonzalez/brew-pip) [(my last modification - 🕗️Coming soon)]()
- 🕗️Coming soon: `brew gem`, [brew-gem](https://github.com/sportngin/brew-gem) [(my last modification)](https://github.com/sportngin/brew-gem/pull/68)

## Workflow to manage my tap
[Livecheck for the last versions][Livecheck for the last versions]
🕗️Coming soon: 1_brew-pip_brew-gem_formulas 
🕗️Coming soon: 2_maintained_formulas 
🕗️Coming soon: 3_options_formulas
🕗️Coming soon: 4_dns_formulas
🕗️Coming soon: Folder Cask deletion, folder Livechecks c8ion
🕗️Coming soon: script what with help of $HOMEBREW_LIVECHECK_WATCHLIST
  shows first 4 livecheck watchlists output
🕗️Coming soon: 5_maintained_linuxbrew_formulas
🕗️Coming soon: 6_maintained_linuxbinary_formulas

## Formulae
Check the `Formula/` folder directly. No longer bother to introduce them here.

### 🛡️ Adguard Home DNS

### 🔲🔘🔳 Aria2
aria2-options

- Header 'Want-Digest' is removed
- `--with-gnutls` (no TLSv1.3 support in appletls)

### 🛠 Bing Wallpaper
bing-wallpaper
- `--head`, `HEAD` only

### 🛠 BrowserSh
🕗️Coming soon

### 🛡️ CDNS

### 🛡️ ChinaDNS
`chinadns`, fork [aa65535/ChinaDNS][aa65535/ChinaDNS]
- more exact [17mon/china_ip_list][17mon/china_ip_list] is recommended

### 🛠 Cht.Sh
🕗️Coming soon

### 🛡️ ClashPremium

### 🛡️ CureDNS
[cdns][curedns], filter poisoned result with EDNS option.
- fails to build from `HEAD` for the time being

### 🔲🔘🔳 cURL
`curl-options`

- `--with-brotli`, lossless compression support
- `--with-c-ares`, C-Ares async DNS support
- `--with-gssapi`, GSSAPI/Kerberos authentication support
- `--with-libidn`, international domain name support
- `--with-libmetalink`, Metalink XML support
- `--with-libssh2`, scp and sftp support
- `--with-libressl`, LibreSSL instead of Secure Transport or OpenSSL
- `--with-nghttp2`, HTTP/2 support (requires OpenSSL or LibreSSL)
- `--with-openldap`, OpenLDAP support
- `--with-openssl@1.1`, OpenSSL 1.1 support
- `--with-rtmpdump`, RTMP support

### 🛡️ curl-doh

### 🔲🔘🔳 🛡️ DNSmasq
`dnsmasq-options`

- `--with-dnssec`
- `--with-libidn`

### 🛡️ dns-over-https

### 🛡️ doh-proxy

### 🛠 Git Log Compact
git-log-compact

- `HEAD` only
- fork [cxw42/git-log-compact][cxw42/git-log-compact] but not the original one is used for more options

### 🛠 Git Open
git-open from paulirish/git-open support open repo, branch, issue from terminal.

### 🛠 Grc
Rust implementation of git-cz, standard git commit.

### 🔲🔘🔳 FFMpeg
`ffmpeg-options`

### 🛠 FilebrowserBin

### 🛠 iTerm2 ZModem
iterm2-zmodem

### 🔲🔘🔳 Libass
`libass`

- `--with-fontconfig` option

Library only, keep name just as `libass`.

### 🛠 License
license mit > LICENSE.txt, [jfoster's fork][license]

### 🛡️ MEOW
[MEOW][MEOW], fork of proxy cow. Proxy or direct connect according to geolocation of the
IP address.

meow

- `--HEAD` only

### 🛡️ Mos-ChinaDNS


### 🛡️ MosDNS


### 🛠 mpdscribble
🕗️Coming soon, update to 0.23, add livecheck, transfer to linuxbrew-core

### 🛠 NaliBin

livecheck ✔️

### 🔲🔘🔳 OpenSSH
`openssh-options`

- `--with-libressl`

### 🛡️ Overture

### 🛠 Pipe-viewer
🕗️Coming soon

### 🛠 plan9port
🕗️Coming soon [jacobvosmaer's binaries][jacobvosmaer_plan9port]

### 🛠 QWT
🕗️Coming soon

### 🛡️ Pcap DNS proxy

### 🔲🔘🔳 Ranger
TODO: python 3 errors closed?
ranger-fm with optional dependencies

- `HEAD` only
- `chardet` for better encoding detection
- `Pillow` (depended by image preview in kitty)

### 🛡️ Routedns

### 🛡️ sans
[sans][sans]

### 🛡️ ShDNS
[shdns][shdns], A port of ChinaDNS (DNS filter) in golang with IPv6 support.

```bash
brew install shdns-bin
```

### 🛠 SML NJ
🕗️Coming soon
x86_64 only, for darwin see Macports

### 🛠 sshpass
🕗️Coming soon [hudochenkov's fornmula modified][hudochenkov_sshpass]

### 🔲🔘🔳 tmux
`tmux-options`

- `--with-fps=`, `--with-fps=30` custom FPS 30, default 10

### 🔲🔘🔳 🛡️ Unbound

### 🛡️ V2ray2Clash
[v2ray2clash]:[v2ray2clash] a web API used to convert v2ray, ssr subscription lists into clash format.

v2ray2clash

- `--HEAD`

## References
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Formula API](https://rubydoc.brew.sh/Formula)
- [example-formula.rb](https://github.com/syhw/homebrew/blob/master/Library/Contributions/example-formula.rb)
- [Livecheck for the last versions](https://docs.brew.sh/Brew-Livecheck)

[aa65535/ChinaDNS]: https://github.com/aa65535/ChinaDNS
[curedns]: https://github.com/semigodking/cdns
[17mon/china_ip_list]: https://github.com/17mon/china_ip_list
[cxw42/git-log-compact]: https://github.com/cxw42/git-log-compact
TODO [license]: https://github.com/jfoster/license nishanths/license
[MEOW]: https://github.com/netheril96/MEOW
TODO [jacobvosmaer_plan9port]: http://TODO
[sans]: https://github.com/puxxustc/sans
[shdns]: https://github.com/domosekai/shdns
TODO [hudochenkov_sshpass]: TODO
TODO [v2ray2clash]: https://github.com/ne1llee/v2ray2clash xch04028/v2ray2clash

TODO: Transfer non-DNS binaries to https://github.com/athrunsun/homebrew-linuxbinary
TODO: Transfer GNU/MIT soft to https://github.com/athrunsun/homebrew-linuxbinary
TODO: (Optional) Add Penguin/Apple emoticons per apps.
