# frozen_string_literal: true

# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Airpost contributors
#
# The airpost-mail/homebrew-tap formula, installing the release archives (scripts/archive.sh).
# scripts/bump.sh sets the version and checksums from a release's SHA256SUMS.
class Airpost < Formula
  desc "Mail engine, command-line client, MCP server and web gateway for Airpost"
  homepage "https://github.com/airpost-mail/airpost"
  license "GPL-3.0-only"

  livecheck do
    url :homepage
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/airpost-mail/airpost/releases/download/v0.1.0/airpost-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "ac25138f2a4c07e9a15c44cfbf7f27ac94b0cb0a94a849322b49abe5ed61631b"
    end
    on_intel do
      url "https://github.com/airpost-mail/airpost/releases/download/v0.1.0/airpost-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "4bb713215212e0d3dcfd038f67f4cf9706672c067929cadfd0e82a39fb757675"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/airpost-mail/airpost/releases/download/v0.1.0/airpost-0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "dc0c153b037db00dfb4a9bff0182e19b838abc9c68c03ec7c66790c3adaa70d0"
    end
    on_intel do
      url "https://github.com/airpost-mail/airpost/releases/download/v0.1.0/airpost-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "9ee68717ae44a03dfcf00c15809389973f0c367976151c2e267d8f0706b6b7ba"
    end
  end

  def install
    bin.install "bin/airpost", "bin/airpost-engine", "bin/airpost-mcp", "bin/airpost-gateway"
    (share/"airpost-gateway").install "share/airpost-gateway/web"
    doc.install Dir["share/doc/airpost/*"]
  end

  # No `service do`: `airpost engine install` writes and owns the engine's LaunchAgent or systemd
  # user unit (and the gateway's and service plugins' units, which start after it). A brew
  # services unit as well would be a second owner starting a second engine on the same profile.
  def caveats
    <<~EOS
      Run the engine in the background, started at login:
        airpost engine install
      then add an account:
        airpost account add you@example.com

      airpost manages the engine's unit itself; don't use `brew services` for Airpost.
      After `brew upgrade airpost`, run `airpost engine install` and `airpost engine restart`
      so the unit runs the new engine.

      The web client for airpost-gateway is in:
        #{opt_share}/airpost-gateway/web
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/airpost --version")
    assert_match version.to_s, shell_output("#{bin}/airpost-mcp --version")
    assert_match version.to_s, shell_output("#{bin}/airpost-gateway --version")
    (testpath/"profile").mkpath
    with_env(CONFIG_DIR_PATH: testpath/"profile") do
      system bin/"airpost-engine", "--mode", "migrate"
    end
    assert_path_exists testpath/"profile/airpost.db"
    assert_path_exists share/"airpost-gateway/web/index.html"
  end
end
