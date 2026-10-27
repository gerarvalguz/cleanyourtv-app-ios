import Foundation

// The five looks of the Clean Your TV launcher, as the Android app writes them (core/spec LookKeys:
// styleKeys, own and the detail rules of build with every detail left at the style's own, movement
// "lively", launcher names off). Every key is written outright, a style's value or its removal, so
// nothing of the last look stays behind on the TV. Picture, dim and sky keys are never touched.
enum TVLookStyle: String, CaseIterable, Identifiable {
    case classic, glass, spotlight, allapps, calm

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Classic"
        case .glass: "Glass"
        case .spotlight: "Spotlight"
        case .allapps: "All apps"
        case .calm: "Calm"
        }
    }

    var summary: String {
        switch self {
        case .classic: "A dark dock, a big name and a soft glow."
        case .glass: "A frosted dock and light in each app's colour."
        case .spotlight: "A big banner of the app you are on, like newer smart TVs."
        case .allapps: "Every app in one grid, with no dock band."
        case .calm: "No glow and no big name. Just apps and your picture."
        }
    }

    static let offeredColumns = 4...8

    // Spotlight's shade and art: softer over a picture, the launcher's own without one.
    private static let spotlightScrimWithPicture = 45, spotlightArtWithPicture = 20
    private static let spotlightScrimWithout = 100, spotlightArtWithout = 50

    var showsBigName: Bool { self != .allapps && self != .calm }
    var showsDockBand: Bool { self != .allapps && self != .spotlight }
    var showsGlow: Bool { self != .calm }
    var roundButtons: Bool { self == .glass || self == .calm }

    // nil means the key is removed.
    func keys(hasPicture: Bool) -> [String: Any?] {
        let spot = self == .spotlight
        let glass = self == .glass
        let ring = self != .classic && self != .calm
        let glowOn = self != .calm
        return [
            "dock_row": self != .allapps,
            "dock_title": showsBigName,
            "cinematic_home": spot,
            "cinematic_scrim": spot ? (hasPicture ? Self.spotlightScrimWithPicture : Self.spotlightScrimWithout) : nil,
            "cinematic_art": spot ? (hasPicture ? Self.spotlightArtWithPicture : Self.spotlightArtWithout) : nil,
            "cinematic_white_focus": spot ? !ring : nil,
            "ambient_glow": glowOn,
            "glow_style": glass ? "horizon" : "radial",
            "app_glow": spot ? false : ring,
            "dock_glass": glass,
            "dock_opacity": 100,
            "dock_even_padding": glass,
            "always_show_names": false,
            "icon_only_buttons": roundButtons,
            "icon_only_inputs": roundButtons,
            "top_menu": false,
            "wifi_status_color": glass,
            "animations": true,
            "reduced_motion": false,
            "focus_overshoot": true,
            "advanced_effects": false,
            "fill_dock": false,
        ]
    }

    // The keys that say which look a config is (movement and the dock fill are the person's, not the look's).
    private static let identifyingKeys: Set<String> = [
        "dock_row", "dock_title", "cinematic_home", "cinematic_scrim", "cinematic_art", "cinematic_white_focus",
        "ambient_glow", "glow_style", "app_glow", "dock_glass", "dock_opacity", "dock_even_padding",
        "always_show_names", "icon_only_buttons", "icon_only_inputs", "top_menu", "wifi_status_color",
    ]

    // The look whose keys the config has, nil for a config that was tuned by hand or never set.
    static func detect(in object: [String: Any]) -> TVLookStyle? {
        let hasPicture = (object["wallpaper"] as? Bool) ?? false
        return allCases.first { style in
            style.keys(hasPicture: hasPicture).allSatisfy { key, expected in
                guard identifyingKeys.contains(key) else { return true }
                guard let expected else { return object[key] == nil }
                return (object[key] as? NSObject)?.isEqual(expected as? NSObject) ?? false
            }
        }
    }
}
