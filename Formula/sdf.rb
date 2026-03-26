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
    version  "0.3.1"
    license  "BUSL-1.1"
  
    # ── Platform-specific binary downloads ──────────────────────────────────────
    # Binaries are compiled with `bun build --compile` — self-contained,
    # no Node.js or npm required at runtime.
  
    on_macos do
      on_arm do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-macos-arm64.tar.gz"
        sha256 "6768a135ecd1cd8dc05f55ad91115929e3a28480951f370d241f0233f59d9220"
      end
  
      on_intel do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-macos-x64.tar.gz"
        sha256 "14fc5fb55170e8c43ced7393d3dc452a640fe77cd6bc6a62842cf3d4b4c61856"
      end
    end
  
    on_linux do
      on_arm do
        cpu :arm
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-linux-arm64.tar.gz"
        sha256 "1e300b4d73d520672fdd8c6dd5b398656ce18e6efe1ded16c0ffae85a1a3592d"
      end
  
      on_intel do
        url "https://github.com/etapsky/sdf/releases/download/sdf-cli-v#{version}/sdf-linux-x64.tar.gz"
        sha256 "b0077bb9a805321b953bab81fa2d97be88f033cacf7f007a5f52d45158b9c6d7"
      end
    end
  
    # ── Install ──────────────────────────────────────────────────────────────────
    # NOTE: Starting from next release, SDFDocument.icns is included in the tarball.
    # The icon is used in post_install to register the .sdf file type on macOS.

    def install
      bin.install "sdf"
      # Install icon if present in tarball (added from v0.4.0 onwards)
      (pkgshare/"icons").install "SDFDocument.icns" if File.exist?("SDFDocument.icns")
    end

    # ── Shell completions + macOS file type registration ─────────────────────────

    def post_install
      # Bash completion
      bash_completion_dir = Pathname.new(HOMEBREW_PREFIX) / "etc/bash_completion.d"
      if (bin/"sdf").exist? && bash_completion_dir.directory?
        completion_file = bash_completion_dir/"sdf"
        completion_file.unlink if completion_file.exist?
        completion_file.write <<~'BASH'
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

      # macOS: register .sdf file type icon with Launch Services
      # Requires SDFDocument.icns to be present (included in tarball from v0.4.0+)
      if OS.mac?
        icns_src = pkgshare/"icons/SDFDocument.icns"
        if icns_src.exist?
          sdf_register_icon(icns_src.to_s)
        end
      end
    end

    private

    # Creates a minimal .app bundle and registers it with macOS Launch Services
    # so that .sdf files display the SDF icon in Finder.
    def sdf_register_icon(icns_src)
      bundle = Pathname.new(Dir.home)/"Library/SDFFileType.app"
      lsreg  = "/System/Library/Frameworks/CoreServices.framework/Versions/A/" \
               "Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

      return unless File.exist?(lsreg)

      # Build minimal bundle structure
      (bundle/"Contents/MacOS").mkpath
      (bundle/"Contents/Resources").mkpath

      # Dummy executable — macOS only checks it exists and is executable
      exe = bundle/"Contents/MacOS/SDFFileType"
      exe.write("#!/bin/sh\n")
      exe.chmod(0755)

      # Icon
      FileUtils.cp(icns_src, bundle/"Contents/Resources/SDFDocument.icns")

      # Info.plist — declares com.etapsky.sdf UTI and associates the icon
      (bundle/"Contents/Info.plist").write <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
          "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleIdentifier</key>
          <string>com.etapsky.sdf-filetype</string>
          <key>CFBundleName</key>
          <string>SDF File Type</string>
          <key>CFBundleExecutable</key>
          <string>SDFFileType</string>
          <key>CFBundleShortVersionString</key>
          <string>#{version}</string>
          <key>CFBundleVersion</key>
          <string>1</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>LSUIElement</key>
          <true/>
          <key>CFBundleDocumentTypes</key>
          <array>
            <dict>
              <key>CFBundleTypeExtensions</key>
              <array><string>sdf</string></array>
              <key>CFBundleTypeMIMETypes</key>
              <array><string>application/vnd.sdf</string></array>
              <key>CFBundleTypeName</key>
              <string>Smart Document Format</string>
              <key>CFBundleTypeIconFile</key>
              <string>SDFDocument</string>
              <key>CFBundleTypeRole</key>
              <string>Viewer</string>
              <key>LSTypeIsPackage</key>
              <false/>
            </dict>
          </array>
          <key>UTExportedTypeDeclarations</key>
          <array>
            <dict>
              <key>UTTypeIdentifier</key>
              <string>com.etapsky.sdf</string>
              <key>UTTypeDescription</key>
              <string>Smart Document Format</string>
              <key>UTTypeConformsTo</key>
              <array>
                <string>public.data</string>
                <string>public.archive</string>
              </array>
              <key>UTTypeTagSpecification</key>
              <dict>
                <key>public.filename-extension</key>
                <array><string>sdf</string></array>
                <key>public.mime-type</key>
                <array><string>application/vnd.sdf</string></array>
              </dict>
              <key>UTTypeIconFile</key>
              <string>SDFDocument</string>
            </dict>
          </array>
        </dict>
        </plist>
      XML

      # Register with Launch Services
      system lsreg, "-f", bundle.to_s

      # Flush icon cache
      icon_cache = Pathname.new(Dir.home)/"Library/Caches/com.apple.iconservices.store"
      icon_cache.rmtree if icon_cache.exist?

      # Restart Finder to pick up the new icon
      system "killall", "Finder"
    rescue => e
      opoo "SDF icon registration failed: #{e.message}"
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