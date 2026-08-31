# Third-party notices

## libsodium

This repository is a build/packaging wrapper for the upstream project:

- Project: libsodium
- Upstream: https://github.com/jedisct1/libsodium
- License: ISC License

libsodium is **not relicensed** by this repository.

The GitHub Actions workflow checks out libsodium directly from the official
`jedisct1/libsodium` repository. During packaging, the upstream `LICENSE`
file is copied unchanged into the binary distribution as:

```text
LICENSE.libsodium
```

This is intentional: the upstream ISC license requires its copyright and
permission notice to appear in distributed copies.

If you change the upstream source repository, remove the license-copying
step, or redistribute files outside the generated package, you are
responsible for reviewing and preserving all applicable notices.
