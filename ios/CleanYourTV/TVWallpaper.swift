import ImageIO
import UIKit

// The person's own photo made into the launcher's wallpaper.jpg, as the Android app does (OwnPhoto):
// the 16:9 middle of the photo, turned by its orientation, as a fresh JPEG without the original's
// metadata (place, camera, time). 1920 x 1080 at the best quality from 85 down to 40 that fits
// maxBytes, else 1600 x 900, else 1280 x 720; nil when not even that fits. The photo is decoded
// already shrunk (ImageIO), so a 48 MP photo does not need its full size in memory.
// shortcut: the middle is cropped, with no zoom or pan; add a crop screen if people ask to move it.
enum TVWallpaper {
    static let maxBytes = 280_000
    // The launcher's dim over the picture: 0 shows it as it is, 90 almost hides it. A new photo starts light.
    static let maxDim = 90
    static let defaultDim = 30
    static let newPhotoDim = 10
    static let sizes = [CGSize(width: 1920, height: 1080), CGSize(width: 1600, height: 900), CGSize(width: 1280, height: 720)]
    static let qualities: [CGFloat] = [0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.5, 0.4]
    private static let workingLongSide = 3200

    static func jpeg(from data: Data) -> Data? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: workingLongSide,
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let decoded = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        let photo = UIImage(cgImage: decoded)
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
