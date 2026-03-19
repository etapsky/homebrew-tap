# typed: false
# frozen_string_literal: true

# Copyright (c) 2026 Yunus YILDIZ — SPDX-License-Identifier: BUSL-1.1
#
# ─── Formula: sdf ─────────────────────────────────────────────────────────────
# SDF (Smart Document Format) CLI tool.
# Installs a self-contained native binary — no Node.js required.
#
# Source: https://github.com/etapsky/sdf
# NPM:    https://www.npmjs.com/package/@etapsky/sdf-cli
# Spec:   https://github.com/etapsky/sdf/blob/main/spec/SDF_FORMAT.md
#
# Binary releases are published to GitHub Releases on every sdf-cli-v* tag.
# SHA256 hashes are updated automatically via CI in etapsky/sdf.

class Sdf < Formula
    desc     "SDF (Smart Document Format) CLI — inspect, validate, convert, sign .sdf files"
    homepage "https://github.com/etapsky/sdf"
    version  "0.3.0"
    license  "BUSL-1.1"
  
    # ── Platform-specific binary downloads ──────────────────────────────────────
    # Binaries are compiled with `bun build --compile` — self-contained,
    # no Node.js or npm required at runtime.
  
    on_macos do
      on_arm do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-macos-arm64.tar.gz"
        sha256 "c95999c73350055d3267edb31db96330ca3436f57239599e066c3db02318f930"
      end
  
      on_intel do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-macos-x64.tar.gz"
        sha256 "5c076c6440c533927becfefabff96e0c3824eb6e1980d8333d4a8db94ea58dfa"
      end
    end
  
    on_linux do
      on_arm do
        cpu :arm
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-linux-arm64.tar.gz"
        sha256 "1a9aecaf4fe6efba6791b53da0b56043a3c1b6075cc480be7c19ea5d5d2efac2"
      end
  
      on_intel do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-linux-x64.tar.gz"
        sha256 "e4ba5c3f88a034e8b8f1ea71c062078fa19944c469f453cd65c4e08e3ad64a1c"
      end
    end
  
    # ── Install ──────────────────────────────────────────────────────────────────
  
    def install
      bin.install "sdf"
    end
  
    # ── Shell completions ────────────────────────────────────────────────────────
    # Generated at build time — included in the release tarball.
  
    def post_install
      # Bash completion
      bash_completion_dir = Pathname.new(HOMEBREW_PREFIX) / "etc/bash_completion.d"
      if (bin/"sdf").exist? && bash_completion_dir.directory?
        (bash_completion_dir/"sdf").write <<~'BASH'
          # sdf bash completion — generated
          _sdf_completion() {
            local commands="inspect validate convert wrap keygen sign verify schema"
            local schema_cmds="list versions diff validate"
            local cur="${COMP_WORDS[COMP_CWORD]}"
            local prev="${COMP_WORDS[COMP_CWORD-1]}"

            case "$prev" in
              sdf) COMPREPLY=($(compgen -W "$commands --help --version" -- "$cur")) ;;
              schema) COMPREPLY=($(compgen -W "$schema_cmds" -- "$cur")) ;;
              inspect|validate) COMPREPLY=($(compgen -f -X "!*.sdf" -- "$cur")) ;;
              --data|--schema|--key) COMPREPLY=($(compgen -f -- "$cur")) ;;
              --out) COMPREPLY=($(compgen -f -- "$cur")) ;;
              *) COMPREPLY=() ;;
            esac
          }
          complete -F _sdf_completion sdf
        BASH
      end
    end
  
    # ── Test ─────────────────────────────────────────────────────────────────────
  
    test do
      # Binary runs
      assert_match "sdf-cli", shell_output("#{bin}/sdf --version")
  
      # Help output
      assert_match "inspect", shell_output("#{bin}/sdf --help")
      assert_match "validate", shell_output("#{bin}/sdf --help")
      assert_match "schema", shell_output("#{bin}/sdf --help")
  
      # Schema diff with identical schemas returns exit 0
      schema = testpath/"test.schema.json"
      schema.write <<~JSON
        {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "type": "object",
          "properties": { "hello": { "type": "string" } }
        }
      JSON
  
      system "#{bin}/sdf", "schema", "diff",
             "--from", schema.to_s,
             "--to",   schema.to_s
    end
  end