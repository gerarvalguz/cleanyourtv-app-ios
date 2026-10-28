import XCTest
import SwiftUI
@testable import CleanYourTV

final class TVLookStyleTests: XCTestCase {
    private func config(_ json: String) throws -> TVLauncherConfig { try TVLauncherConfig(data: Data(json.utf8)) }
    private func object(_ data: Data) throws -> [String: Any] { try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any]) }

    func testClassicWritesTheKeysAndroidWrites() throws {
        let out = try object(try config("{}").applying(style: .classic, columns: 4))
        XCTAssertEqual(out["dock_row"] as? Bool, true)
        XCTAssertEqual(out["dock_title"] as? Bool, true)
        XCTAssertEqual(out["ambient_glow"] as? Bool, true)
        XCTAssertEqual(out["glow_style"] as? String, "radial")
        XCTAssertEqual(out["app_glow"] as? Bool, false)
        XCTAssertEqual(out["dock_glass"] as? Bool, false)
        XCTAssertEqual(out["dock_opacity"] as? Int, 100)
        XCTAssertEqual(out["fill_dock"] as? Bool, false)
        XCTAssertEqual(out["columns"] as? Int, 4)
        XCTAssertNil(out["cinematic_scrim"])
    }

    func testGlassSpotlightAllAppsAndCalmDifferWhereTheTableSays() throws {
        let glass = try object(try config("{}").applying(style: .glass, columns: 5))
        XCTAssertEqual(glass["dock_glass"] as? Bool, true)
        XCTAssertEqual(glass["glow_style"] as? String, "horizon")
        XCTAssertEqual(glass["icon_only_buttons"] as? Bool, true)
        XCTAssertEqual(glass["wifi_status_color"] as? Bool, true)
        XCTAssertEqual(glass["dock_even_padding"] as? Bool, true)

        let spot = try object(try config("{}").applying(style: .spotlight, columns: 4))
        XCTAssertEqual(spot["cinematic_home"] as? Bool, true)
        XCTAssertEqual(spot["cinematic_scrim"] as? Int, 100)
        XCTAssertEqual(spot["cinematic_art"] as? Int, 50)
        XCTAssertEqual(spot["cinematic_white_focus"] as? Bool, false)
        XCTAssertEqual(spot["app_glow"] as? Bool, false)

        let all = try object(try config("{}").applying(style: .allapps, columns: 4))
        XCTAssertEqual(all["dock_row"] as? Bool, false)
        XCTAssertEqual(all["dock_title"] as? Bool, false)
        XCTAssertEqual(all["app_glow"] as? Bool, true)

        let calm = try object(try config("{}").applying(style: .calm, columns: 4))
        XCTAssertEqual(calm["ambient_glow"] as? Bool, false)
        XCTAssertEqual(calm["dock_title"] as? Bool, false)
        XCTAssertEqual(calm["icon_only_inputs"] as? Bool, true)
    }

    func testSpotlightOverAPictureIsSofterAndLeavesThePictureAlone() throws {
        let out = try object(try config(#"{"wallpaper":true,"wallpaper_dim":30,"theme":"x"}"#).applying(style: .spotlight, columns: 4))
        XCTAssertEqual(out["cinematic_scrim"] as? Int, 45)
        XCTAssertEqual(out["cinematic_art"] as? Int, 20)
        XCTAssertEqual(out["wallpaper"] as? Bool, true)
        XCTAssertEqual(out["wallpaper_dim"] as? Int, 30)
        XCTAssertEqual(out["theme"] as? String, "x")
    }

    func testAStyleRemovesWhatTheLastOneLeftBehind() throws {
        let spot = try config("{}").applying(style: .spotlight, columns: 4)
        let out = try object(try config(String(decoding: spot, as: UTF8.self)).applying(style: .classic, columns: 4))
        XCTAssertNil(out["cinematic_scrim"])
        XCTAssertNil(out["cinematic_art"])
        XCTAssertNil(out["cinematic_white_focus"])
        XCTAssertEqual(out["cinematic_home"] as? Bool, false)
    }

    func testTheDockIsCutForTheNewColumns() throws {
        let apps = (1...13).map { "com.example.app\($0)" }
        let json = #"{"dock_apps":["# + apps.map { "\"\($0)\"" }.joined(separator: ",") + "]}"
        let eight = try object(try config(json).applying(style: .classic, columns: 4))
        XCTAssertEqual((eight["dock_apps"] as? [String])?.count, 12)
        XCTAssertEqual(eight["rows_below_dock"] as? Int, 2)
        XCTAssertEqual(eight["dock_title"] as? Bool, false, "three rows leave no room for the focused name")
        let spot = try object(try config(json).applying(style: .spotlight, columns: 8))
        XCTAssertEqual(spot["rows_below_dock"] as? Int, 0, "the Spotlight shelf keeps rows 0")
        XCTAssertEqual((spot["dock_apps"] as? [String])?.count, 13)
    }

    func testColumnsOutsideWhatIsOfferedAreRefused() throws {
        XCTAssertThrowsError(try config("{}").applying(style: .classic, columns: 3))
        XCTAssertThrowsError(try config("{}").applying(style: .classic, columns: 9))
    }

    func testTheStyleOfAConfigIsRecognisedAndAHandTunedOneIsNot() throws {
        for style in TVLookStyle.allCases {
            let data = try config("{}").applying(style: style, columns: 6)
            XCTAssertEqual(try config(String(decoding: data, as: UTF8.self)).style, style)
        }
        XCTAssertNil(try config("{}").style)
        XCTAssertNil(try config(#"{"dock_row":true,"dock_title":true,"dock_opacity":60}"#).style)
    }

    func testNewPictureTurnsTheWallpaperOnKeepingItsDim() throws {
        let out = try object(try config(#"{"wallpaper":false,"wallpaper_dim":50,"wallpaper_rotation_minutes":30}"#).applying(style: .spotlight, columns: 4, withNewPicture: true))
        XCTAssertEqual(out["wallpaper"] as? Bool, true)
        XCTAssertEqual(out["wallpaper_dim"] as? Int, 50)
        XCTAssertEqual(out["wallpaper_rotation_minutes"] as? Int, 0)
        XCTAssertNotNil(out["cinematic_scrim"])
        XCTAssertNil(try object(try config("{}").applying(style: .classic, columns: 4, withNewPicture: true))["wallpaper_dim"])
    }

    func testDimIsWrittenOnlyWithAPictureAndKeptInRange() throws {
        XCTAssertEqual(try object(try config(#"{"wallpaper":true}"#).applying(style: .classic, columns: 4, dim: 10))["wallpaper_dim"] as? Int, 10)
        XCTAssertEqual(try object(try config("{}").applying(style: .classic, columns: 4, withNewPicture: true, dim: 200))["wallpaper_dim"] as? Int, 90)
        XCTAssertNil(try object(try config("{}").applying(style: .classic, columns: 4, dim: 10))["wallpaper_dim"])
        XCTAssertEqual(try config(#"{"wallpaper_dim":50}"#).pictureDim, 50)
        XCTAssertEqual(try config("{}").pictureDim, 30)
    }

    func testWallpaperIsA16by9JpegWithinTheLauncherLimit() throws {
        let tall = UIGraphicsImageRenderer(size: CGSize(width: 900, height: 1600)).image { c in
            UIColor.systemTeal.setFill(); c.fill(CGRect(x: 0, y: 0, width: 900, height: 1600))
        }
        let jpeg = try XCTUnwrap(TVWallpaper.jpeg(from: try XCTUnwrap(tall.pngData())))
        XCTAssertLessThanOrEqual(jpeg.count, TVWallpaper.maxBytes)
        let image = try XCTUnwrap(UIImage(data: jpeg))
        XCTAssertEqual(image.size.width * image.scale / (image.size.height * image.scale), 16.0 / 9.0, accuracy: 0.01)
        XCTAssertNil(TVWallpaper.jpeg(from: Data("not a picture".utf8)))
    }

    func testGlassCinemaIsSpotlightWithAGlassDock() throws {
        let out = try object(try config("{}").applying(style: .cinemaglass, columns: 6))
        XCTAssertEqual(out["cinematic_home"] as? Bool, true)
        XCTAssertEqual(out["dock_glass"] as? Bool, true)
        XCTAssertEqual(out["dock_even_padding"] as? Bool, true)
        XCTAssertEqual(out["rows_below_dock"] as? Int ?? 0, 0)
        let spot = try object(try config("{}").applying(style: .spotlight, columns: 6))
        XCTAssertEqual(spot["dock_glass"] as? Bool, false)
    }

    func testEachStyleIsDetectedFromItsOwnConfig() throws {
        for style in TVLookStyle.allCases {
            let data = try config("{}").applying(style: style, columns: 5)
            XCTAssertEqual(try config(String(decoding: data, as: UTF8.self)).style, style, "\(style)")
        }
    }

    func testEveryGalleryPictureIsBundledAndFitsTheLauncher() throws {
        for picture in TVPicture.all {
            let jpeg = try XCTUnwrap(picture.jpeg, picture.id)
            XCTAssertLessThanOrEqual(jpeg.count, TVWallpaper.maxBytes, picture.id)
            XCTAssertNotNil(UIImage(data: jpeg), picture.id)
        }
    }

    func testAGalleryPictureWritesItsKeysAndAFestivalEndsOnItsLastDay() throws {
        let diwali = try XCTUnwrap(TVPicture.all.first { $0.id == "diwali" })
        let out = try object(try config("{}").applying(style: .classic, columns: 5, withNewPicture: true, dim: 0, picture: diwali))
        XCTAssertEqual(out["festival"] as? String, "diwali")
        XCTAssertEqual(out["festival_until"] as? String, "2026-11-10")
        XCTAssertEqual(out["background_color"] as? String, "#120809")
        XCTAssertEqual(out["wallpaper_dim"] as? Int, 0)
        // Another picture afterwards leaves no festival behind.
        let mountains = try XCTUnwrap(TVPicture.all.first { $0.id == "mountains" })
        let next = try object(try config(String(decoding: try config("{}").applying(style: .classic, columns: 5, withNewPicture: true, picture: diwali), as: UTF8.self))
            .applying(style: .classic, columns: 5, withNewPicture: true, picture: mountains))
        XCTAssertNil(next["festival"])
        XCTAssertNil(next["accent_color"])
        XCTAssertEqual(next["sky_intensity"] as? Int, 55)
        XCTAssertTrue(TVPicture.offered(on: "2026-11-10").contains { $0.id == "diwali" })
        XCTAssertFalse(TVPicture.offered(on: "2026-11-11").contains { $0.id == "diwali" })
    }
}
