# Custom Formulae
Collection of custom and deprecated formulae.

## News

<details>
  <summary>Big changes made in this repo.</summary>

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
bing-wallpaper (`HEAD` only)

curl
- `with-brotli`, lossless compression support
- `with-c-ares`, C-Ares async DNS support
- `with-gssapi`, GSSAPI/Kerberos authentication support
- `with-libidn`, international domain name support
- `with-libmetalink`, Metalink XML support
- `with-libssh2`, scp and sftp support
- `with-libressl`, LibreSSL instead of Secure Transport or OpenSSL
- `with-nghttp2`, HTTP/2 support (requires OpenSSL or LibreSSL)
- `with-openldap`, OpenLDAP support
- `with-openssl@1.1`, OpenSSL 1.1 support
- `with-rtmpdump`, RTMP support

iterm2-zmodem

libass
- `--with-fontconfig` option

libcaca
- `--with-imlib2` option (X11 is needed)

openssh
- `--with-libressl`

poetry

ranger-fm with optional dependencies (`HEAD` only)
- `chardet` for better encoding detection
- `Pillow` (depended by image preview in kitty)

[sans](https://github.com/puxxustc/sans)

stubby, with TLS v1.3 support

vim
- `--with-client-server`, (recommended on remote server only)
- `--with-gettext`, default
- `--with-lua`, default
- `--with-luajit`
- `--with-override-system-vi`
- `--with-python@2`, (python3 is enabled by default)
- `--with-tcl`
- `--without-python`
