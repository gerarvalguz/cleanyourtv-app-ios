import UIKit

// The person's own photo made into the launcher's wallpaper.jpg, as the Android app does (OwnPhoto):
// the 16:9 middle of the photo, turned by its orientation, as a fresh JPEG without the original's
// metadata (place, camera, time). 1920 x 1080 at the best quality from 85 down to 60 that fits
// maxBytes, else 1600 x 900, else 1280 x 720; nil when not even that fits.
// shortcut: the middle is cropped, with no zoom or pan; add a crop screen if people ask to move it.
enum TVWallpaper {
    static let maxBytes = 280_000
    static let sizes = [CGSize(width: 1920, height: 1080), CGSize(width: 1600, height: 900), CGSize(width: 1280, height: 720)]
    static let qualities: [CGFloat] = [0.85, 0.8, 0.75, 0.7, 0.65, 0.6]

    static func jpeg(from data: Data) -> Data? {
        guard let photo = UIImage(data: data), photo.size.width > 0, photo.size.height > 0 else { return nil }
        for size in sizes {
            let frame = render(photo, into: size)
            for quality in qualities {
                if let bytes = frame.jpegData(compressionQuality: quality), bytes.count <= maxBytes { return bytes }
            }
        }
        return nil
    }

    // The photo scaled to cover `size`, centred; drawing honours the photo's orientation.
    private static func render(_ photo: UIImage, into size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let scale = max(size.width / photo.size.width, size.height / photo.size.height)
        let drawn = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            photo.draw(in: CGRect(x: (size.width - drawn.width) / 2, y: (size.height - drawn.height) / 2, width: drawn.width, height: drawn.height))
        }
    }
}
