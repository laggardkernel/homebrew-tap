# Custom Formulae
Collection of custom and deprecated formulae.

## News

<details>
  <summary>Big changes made in this repo.</summary>

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

## Formulae
### Bing Wallpaper
bing-wallpaper
- `--head`, `HEAD` only

### ChinaDNS
chinadns-c, fork [aa65535/ChinaDNS][aa65535/ChinaDNS]
- more exact [17mon/china_ip_list][17mon/china_ip_list] is recommended

### CureDNS
[cdns][curedns], filter poisoned result with EDNS option.
- fails to build from `HEAD` for the time being

### cURL
curl
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

### DNSmasq
dnsmasq
- `--with-dnssec`
- `--with-libidn`

### Git Log Compact
git-log-compact
- `HEAD` only
- fork [cxw42/git-log-compact][cxw42/git-log-compact] but not the original one is used for more options

### Git Open
git-open from paulirish/git-open support open repo, branch, issue from terminal.

### iTerm2 ZModem
iterm2-zmodem

### Libass
libass
- `--with-fontconfig` option

### License
license, [jfoster's fork][license]

### MEOW
[MEOW][MEOW], fork of proxy cow. Proxy or direct connect according to geolocation of the
IP address.

meow
- `--HEAD` only

### OpenSSH
openssh
- `--with-libressl`

### Poetry
poetry

### Ranger
ranger-fm with optional dependencies
- `HEAD` only
- `chardet` for better encoding detection
- `Pillow` (depended by image preview in kitty)

### sans
[sans][sans]

### ShDNS
[shdns][shdns], A port of ChinaDNS (DNS filter) in golang with IPv6 support.

### V2ray2Clash
[v2ray2clash]:[v2ray2clash] a web API used to convert v2ray, ssr subscription lists into clash format.

v2ray2clash
- `--HEAD`

### Vim
vim
- `--with-client-server`, (recommended on remote server only)
- `--with-gettext`, default
- `--with-lua`, default
- `--with-luajit`
- `--with-override-system-vi`
- `--with-python@2`, (python3 is enabled by default)
- `--with-tcl`
- `--without-python`

## References
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Formula API](https://rubydoc.brew.sh/Formula)

[aa65535/ChinaDNS]: https://github.com/aa65535/ChinaDNS
[curedns]: https://github.com/semigodking/cdns
[17mon/china_ip_list]: https://github.com/17mon/china_ip_list
[cxw42/git-log-compact]: https://github.com/cxw42/git-log-compact
[license]: https://github.com/jfoster/license
[MEOW]: https://github.com/netheril96/MEOW
[sans]: https://github.com/puxxustc/sans
[shdns]: https://github.com/domosekai/shdns
[v2ray2clash]: https://github.com/ne1llee/v2ray2clash
