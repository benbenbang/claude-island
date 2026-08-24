//
//  FeatureFlags.swift
//  ClaudeIsland
//
//  Central compile-time feature switches.
//

import Foundation

enum FeatureFlags {
    // Sparkle auto-update (feed check, background timer, in-app update UI).
    //
    // Disabled: the inherited `SUFeedURL` / `SUPublicEDKey` in Info.plist point at
    // the UPSTREAM "ClaudeIsland" appcast, so enabling Sparkle would silently replace
    // this app with Claude Island. Flip to `true` ONLY after:
    //   1. `SUFeedURL` points at an appcast you control,
    //   2. `SUPublicEDKey` is your own key (scripts/generate-keys.sh),
    //   3. you publish your own signed appcast.xml.
    //
    // Build-time controlled: OFF unless the `SPARKLE_ENABLED` Swift compilation
    // condition is set (e.g. `make build SPARKLE=1`). CI builds it OFF.
    #if SPARKLE_ENABLED
        static let sparkleUpdatesEnabled = true
    #else
        static let sparkleUpdatesEnabled = false
    #endif
}
