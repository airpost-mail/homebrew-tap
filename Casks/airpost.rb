# frozen_string_literal: true

# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Airpost contributors
#
# The airpost-mail/homebrew-tap cask for the desktop app: the zips desktop-build-macos.yml builds
# (Airpost-AppleSilicon.zip, Airpost.zip for Intel), from a `desktop-v<version>` GitHub release.
# scripts/bump.sh --cask sets the version and checksums.
cask "airpost" do
  arch arm: "-AppleSilicon"

  version "0.1.0"
  sha256 arm:   "a9478c30f3a762d782c20c2e3b28ec7e4737489767a9183e76c277d84c8146b3",
         intel: "6edf7f12e06dcebe93aae16bc79ba6c69ec458666e68301191189855ad038182"

  url "https://github.com/airpost-mail/airpost/releases/download/desktop-v#{version}/Airpost#{arch}.zip"
  name "Airpost"
  desc "Email client with a local sync engine"
  homepage "https://github.com/airpost-mail/airpost"

  livecheck do
    url :homepage
    regex(/^desktop-v(\d+(?:\.\d+)+)$/i)
  end

  depends_on macos: :monterey

  app "Airpost.app"

  zap trash: [
    "~/Library/Application Support/Airpost",
    "~/Library/Caches/com.airpost.airpost",
    "~/Library/Caches/com.airpost.airpost.ShipIt",
    "~/Library/HTTPStorages/com.airpost.airpost",
    "~/Library/Preferences/com.airpost.airpost.plist",
    "~/Library/Saved Application State/com.airpost.airpost.savedState",
  ]

  # The app bundles the airpost command and links it from Preferences > General; the `airpost`
  # formula installs the same programs standalone.
  caveats <<~EOS
    Airpost isn't notarized by Apple yet, so macOS blocks it the first time you
    open it. Open System Settings > Privacy & Security and click Open Anyway.

    To use the airpost command, click Install next to it in Airpost's
    Preferences > General, or install it on its own with:
      brew install airpost-mail/tap/airpost
  EOS
end
