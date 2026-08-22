//
//  Ext+NSScreen.swift
//  ClaudeIsland
//
//  Extensions for NSScreen to detect notch and built-in display
//

import AppKit

extension NSScreen {
    static let menuBarHeight: CGFloat = 25

    /// Returns the size of the notch on this screen (auto-detects based on hardware)
    var notchSize: CGSize {
        let fullWidth = frame.width
        let leftPadding = auxiliaryTopLeftArea?.width ?? 0
        let rightPadding = auxiliaryTopRightArea?.width ?? 0

        // Calculate width (same for both physical notch and menu bar)
        let notchWidth: CGFloat = if leftPadding > 0, rightPadding > 0 {
            fullWidth - leftPadding - rightPadding + 4
        } else {
            hasPhysicalNotch ? 180 : 224
        }

        // Auto-detect height based on physical notch presence
        if hasPhysicalNotch {
            // Physical notch - use actual hardware dimensions
            let notchHeight = safeAreaInsets.top
            return CGSize(width: notchWidth, height: notchHeight)
        } else {
            // No physical notch - use menu bar height
            return CGSize(width: notchWidth, height: NSScreen.menuBarHeight)
        }
    }

    /// Whether this is the built-in display
    var isBuiltinDisplay: Bool {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return false
        }
        return CGDisplayIsBuiltin(screenNumber) != 0
    }

    /// The built-in display (with notch on newer MacBooks)
    static var builtin: NSScreen? {
        if let builtin = screens.first(where: { $0.isBuiltinDisplay }) {
            return builtin
        }
        return NSScreen.main
    }

    /// Whether this screen has a physical notch (camera housing)
    var hasPhysicalNotch: Bool {
        safeAreaInsets.top > 0
    }
}
