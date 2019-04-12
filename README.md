# Custom Formulae
Collection of custom and deprecated formulae.

## Installation

```bash
brew tap laggardkernel/tap
brew install laggardkernel/tap/<formula>
# not recommended, brew tap-pin laggardkernel/tap
```

## Formulae
~~curl~~
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

curl-openssl
- `with-openssl@1.1`, OpenSSL 1.1. (tls 1.3 enabled)

httpd
- `with-openssl@1.1`, enable tls 1.3 in Apache

libass
- `--with-fontconfig` option

libcaca
- `--with-imlib2` option (X11 is needed)

nginx
- `with-openssl@1.1`, enable tls 1.3 support through openssl 1.1

openssh
- `--with-libressl`

[sans](https://github.com/puxxustc/sans)

unbound
- `--with-python@2`
