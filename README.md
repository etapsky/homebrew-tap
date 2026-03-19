# etapsky/homebrew-tap

[![License: BUSL-1.1](https://img.shields.io/badge/License-BUSL--1.1-blue.svg)](LICENSE)

> Homebrew tap for Etapsky CLI tools. Part of the [Etapsky SDF](https://github.com/etapsky/sdf) ecosystem.

## Install

```bash
brew tap etapsky/tap
brew install sdf
```

Or in a single command:

```bash
brew install etapsky/tap/sdf
```

## Available formulae

| Formula | Description | Version |
|---|---|---|
| `sdf` | SDF (Smart Document Format) CLI — inspect, validate, convert, sign | latest |

## Usage

```bash
sdf --version
sdf --help

sdf inspect invoice.sdf
sdf validate invoice.sdf --quiet && echo "valid"
sdf convert --data invoice.json --schema invoice.schema.json --issuer "Acme" --out invoice.sdf
sdf sign invoice.sdf --key mykey.private.b64 --out invoice.signed.sdf
sdf verify invoice.signed.sdf --key mykey.public.b64
sdf schema diff --from v0.1.json --to v0.2.json
```

## Update

```bash
brew upgrade sdf
```

## Pin to a specific version

```bash
brew install etapsky/tap/sdf@0.2
```

## Uninstall

```bash
brew uninstall sdf
brew untap etapsky/tap
```

## Issues

For CLI bugs and feature requests, open an issue on the main repo:
[github.com/etapsky/sdf](https://github.com/etapsky/sdf)

For tap-specific issues (formula errors, installation failures):
[github.com/etapsky/homebrew-tap/issues](https://github.com/etapsky/homebrew-tap/issues)

## License

BUSL-1.1 — Copyright (c) 2026 Yunus YILDIZ

This software is licensed under the [Business Source License 1.1](LICENSE).
Non-production use is free. Commercial use requires a license from the author until the Change Date (2030-03-17), after which it converts to Apache License 2.0.
