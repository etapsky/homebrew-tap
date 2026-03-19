# typed: false
# frozen_string_literal: true

# Copyright (c) 2026 Yunus YILDIZ — SPDX-License-Identifier: BUSL-1.1
#
# ─── Formula: sdf@0.2 ─────────────────────────────────────────────────────────
# Pinnable versioned formula for sdf-cli v0.2.x.
# Use when you need to stay on a specific version:
#   brew install etapsky/tap/sdf@0.2
#
# Source: https://github.com/etapsky/sdf
# Binary releases: GitHub Releases (sdf-cli-v* tags)

class SdfAT02 < Formula
    desc     "SDF (Smart Document Format) CLI v0.2 — inspect, validate, convert .sdf files"
    homepage "https://github.com/etapsky/sdf"
    version  "0.2.2"
    license  "BUSL-1.1"
  
    # ── Platform-specific binary downloads ──────────────────────────────────────
    # Self-contained native binaries — no Node.js required at runtime.
  
    on_macos do
      on_arm do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-macos-arm64.tar.gz"
        sha256 "REPLACE_AFTER_FIRST_RELEASE_0_2_macos_arm64"
      end
  
      on_intel do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-macos-x64.tar.gz"
        sha256 "REPLACE_AFTER_FIRST_RELEASE_0_2_macos_x64"
      end
    end
  
    on_linux do
      on_arm do
        cpu :arm
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-linux-arm64.tar.gz"
        sha256 "REPLACE_AFTER_FIRST_RELEASE_0_2_linux_arm64"
      end
  
      on_intel do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-linux-x64.tar.gz"
        sha256 "REPLACE_AFTER_FIRST_RELEASE_0_2_linux_x64"
      end
    end
  
    keg_only :versioned_formula
  
    # ── Install ──────────────────────────────────────────────────────────────────
  
    def install
      bin.install "sdf"
    end
  
    # ── Test ─────────────────────────────────────────────────────────────────────
  
    test do
      assert_match "sdf-cli", shell_output("#{bin}/sdf --version")
    end
  end