import ImageIO
import UIKit

// The pictures of the Android app's gallery that come with its looks (core/spec looks/*/wallpaper.jpg,
// CC0, see THIRD-PARTY-NOTICES), each with the keys the Android app writes with it (its config.json:
// background colour, sky, and for a festival its name, last day and accent). Dim is the person's
// (slider); every picture of the gallery starts at 0.
struct TVPicture: Identifiable {
    let id: String
    let title: String
    let resource: String
    let background: String
    var sky = 0
    var festival: String?
    var festivalUntil: String?
    var accent: String?

    // nil means the key is removed, so nothing of the last picture stays behind (a festival's accent, say).
    var keys: [String: Any?] {
        ["background_color": background, "wallpaper": true, "wallpaper_rotation_minutes": 0, "sky_intensity": sky,
         "festival": festival, "festival_until": festivalUntil, "accent_color": accent]
    }

    private var url: URL? { Bundle.main.url(forResource: resource, withExtension: "jpg", subdirectory: "Wallpapers") }

    var jpeg: Data? { url.flatMap { try? Data(contentsOf: $0) } }

    private static var thumbnails: [String: UIImage] = [:]

    // A small copy for the strip, decoded once.
    var thumbnail: UIImage? {
        if let cached = Self.thumbnails[id] { return cached }
        guard let url, let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                  kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceThumbnailMaxPixelSize: 360,
              ] as CFDictionary) else { return nil }
        let thumbnail = UIImage(cgImage: image)
        Self.thumbnails[id] = thumbnail
        return thumbnail
    }

    // A festival's picture is offered up to its last day (ISO dates compare as text).
    static func offered(on today: String = isoDay(Date())) -> [TVPicture] {
        all.filter { $0.festivalUntil.map { today <= $0 } ?? true }
    }

    static func isoDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    static let all: [TVPicture] = [
        TVPicture(id: "curtains", title: String(localized: "Curtains"), resource: "cinema", background: "#07060A"),
        TVPicture(id: "mountains", title: String(localized: "Mountains"), resource: "horizon", background: "#000000", sky: 55),
        TVPicture(id: "neon", title: String(localized: "Neon"), resource: "arcade", background: "#0B0614"),
        TVPicture(id: "cobalt", title: String(localized: "Cobalt"), resource: "console", background: "#020611"),
        TVPicture(id: "lamp", title: String(localized: "Lamp light"), resource: "library", background: "#141210"),
        TVPicture(id: "mist", title: String(localized: "Mist"), resource: "mist", background: "#0E1022"),
        TVPicture(id: "diwali", title: String(localized: "Diwali"), resource: "diwali", background: "#120809",
                  festival: "diwali", festivalUntil: "2026-11-10", accent: "#FFB23C"),
    ]
}
