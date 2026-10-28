import XCTest
@testable import CleanYourTV

final class TVLauncherLayoutTests: XCTestCase {
    func testNamesReadLikeTheAndroidApp() {
        XCTAssertEqual(TVAppNames.name(for: "com.netflix.ninja"), "Netflix")
        XCTAssertEqual(TVAppNames.fromPackage("com.lego.android.tvleanback"), "Lego")
        XCTAssertEqual(TVAppNames.fromPackage("com.android.traceur"), "Traceur")
        XCTAssertEqual(TVAppNames.fromPackage("com.miui.tv.analytics"), "Miui Analytics")
        XCTAssertEqual(TVAppNames.fromPackage("com.google.android.play.games"), "Play Games")
    }

    func testLaunchableAppsSkipNoiseAndOurOwnPackages() throws {
        let output = """
        28 activities found:
          Activity #0:
            priority=0 preferredOrder=0 match=0x108000 specificIndex=-1 isDefault=false
          com.netflix.ninja/.MainActivity
          com.netflix.ninja/.Other
          com.gathin.tvhome/.MainActivity
          tv.cleanyour.homeinterceptor/.ProbeActivity
          com.disney.disneyplus/com.disney.MainActivity
        """
        XCTAssertEqual(try TVLaunchableApps.parse(output), ["com.disney.disneyplus", "com.netflix.ninja"])
    }

    func testRowsAndRowsBelowDockFollowTheLauncher() {
        XCTAssertEqual(TVLauncherRows.rows(["a", "b", "c", "d", "e"], columns: 4), [["a", "b", "c", "d"], ["e"]])
        XCTAssertEqual(TVLauncherRows.rowsBelowDock(count: 0, columns: 4), 0)
        XCTAssertEqual(TVLauncherRows.rowsBelowDock(count: 4, columns: 4), 0)
        XCTAssertEqual(TVLauncherRows.rowsBelowDock(count: 5, columns: 4), 1)
        XCTAssertEqual(TVLauncherRows.rowsBelowDock(count: 12, columns: 4), 2)
        XCTAssertEqual(TVLauncherRows.trim(["a", "a", "b"], columns: 1), ["a", "b"])
        XCTAssertEqual(TVLauncherRows.trim((0..<20).map(String.init), columns: 4).count, 12)
    }

    func testApplyingKeepsEveryOtherKeyAndWritesTheDock() throws {
        let existing = Data(##"{"columns":4,"wallpaper":false,"background_color":"#000000"}"##.utf8)
        let config = try TVLauncherConfig(data: existing)
        let data = try config.applying(order: ["com.netflix.ninja", "com.amazon.firebat", "com.hbo.hbonow", "com.disney.disneyplus", "com.spotify.tv.android"])
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["dock_apps"] as? [String], ["com.netflix.ninja", "com.amazon.firebat", "com.hbo.hbonow", "com.disney.disneyplus", "com.spotify.tv.android"])
        XCTAssertEqual(json["rows_below_dock"] as? Int, 1)
        XCTAssertEqual(json["columns"] as? Int, 4)
        XCTAssertEqual(json["wallpaper"] as? Bool, false)
        XCTAssertEqual(json["background_color"] as? String, "#000000")
        XCTAssertNil(json["dock_title"])
    }

    func testThreeFullRowsTurnTheDockTitleOff() throws {
        let order = (0..<12).map { "com.example.app\($0)" }
        let data = try TVLauncherConfig(data: nil).applying(order: order)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["rows_below_dock"] as? Int, 2)
        XCTAssertEqual(json["dock_title"] as? Bool, false)
    }

    func testAnEmptyOrderLeavesDockAppsOut() throws {
        let config = try TVLauncherConfig(data: Data(#"{"dock_apps":["com.netflix.ninja"],"columns":5}"#.utf8))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: config.applying(order: [])) as? [String: Any])
        XCTAssertNil(json["dock_apps"])
        XCTAssertEqual(json["columns"] as? Int, 5)
    }

    func testRefusesInvalidPackagesAndUnreadableConfigs() {
        XCTAssertThrowsError(try TVLauncherConfig(data: nil).applying(order: ["bad name; rm -rf"]))
        XCTAssertThrowsError(try TVLauncherConfig(data: Data("[1,2]".utf8)))
        XCTAssertThrowsError(try TVLauncherConfig.fromReadOutput("Error: something else"))
    }

    func testReadOutputWithNoFileMeansNoConfig() throws {
        let missing = "Error while accessing provider:com.gathin.tvhome.theme\njava.io.FileNotFoundException: open failed: ENOENT"
        XCTAssertNil(try TVLauncherConfig.fromReadOutput(missing).original)
        let present = try TVLauncherConfig.fromReadOutput(#"{"columns":6,"dock_apps":["com.netflix.ninja","bad name"]}"#)
        XCTAssertEqual(present.columns, 6)
        XCTAssertEqual(present.dockApps, ["com.netflix.ninja"])
    }

    func testBackupStoreRoundTripsAndRemoves() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let store = TVLauncherBackupStore(directoryURL: dir)
        XCTAssertNil(try store.load(tvID: "tv1"))
        let original = Data(#"{"columns":4}"#.utf8)
        try store.save(TVLauncherBackup(config: original, savedAt: Date()), tvID: "tv1")
        try store.save(TVLauncherBackup(config: nil, savedAt: Date()), tvID: "tv2")
        XCTAssertEqual(try store.load(tvID: "tv1")?.config, original)
        XCTAssertNotNil(try store.load(tvID: "tv2"))
        XCTAssertNil(try store.load(tvID: "tv2")?.config)
        try store.remove(tvID: "tv1")
        XCTAssertNil(try store.load(tvID: "tv1"))
    }

    func testGreetingNameIsSetCleanedAndRemovedKeepingTheOtherKeys() throws {
        let config = try TVLauncherConfig(data: Data(#"{"columns":5,"theme":"aurora"}"#.utf8))
        let named = try JSONSerialization.jsonObject(with: config.applying(greetingName: "  Gera\n\u{7}  ")) as? [String: Any]
        XCTAssertEqual(named?["greeting_name"] as? String, "Gera")
        XCTAssertEqual(named?["columns"] as? Int, 5)
        XCTAssertEqual(named?["theme"] as? String, "aurora")

        let again = try TVLauncherConfig(data: JSONSerialization.data(withJSONObject: named as Any))
        XCTAssertEqual(again.greetingName, "Gera")
        let cleared = try JSONSerialization.jsonObject(with: again.applying(greetingName: "   ")) as? [String: Any]
        XCTAssertNil(cleared?["greeting_name"])
        XCTAssertEqual(cleared?["columns"] as? Int, 5)
    }

    func testAGreetingNameIsCappedToOneLine() {
        XCTAssertEqual(TVLauncherConfig.cleanName(String(repeating: "a", count: 90)).count, TVLauncherConfig.maxNameLength)
        XCTAssertEqual(TVLauncherConfig.cleanName("Ana\nMaría"), "AnaMaría")
        XCTAssertEqual(TVLauncherConfig.cleanName(""), "")
    }

    private func weatherConfig(_ json: String) throws -> TVLauncherConfig { try TVLauncherConfig(data: Data(json.utf8)) }

    func testTheWeatherChipKeysAreSetAndTakenOutKeepingTheRest() throws {
        let place = try XCTUnwrap(TVWeatherPlace(name: "Tapachula, Chiapas, Mexico", latitude: 14.904412345, longitude: -92.262198765))
        let out = try JSONSerialization.jsonObject(with: try weatherConfig(#"{"columns":5,"greeting_name":"Gera"}"#).applying(weatherPlace: place)) as! [String: Any]
        XCTAssertEqual(out["weather_lat"] as? Double, 14.9044)
        XCTAssertEqual(out["weather_lon"] as? Double, -92.2622)
        XCTAssertEqual(out["weather_name"] as? String, "Tapachula, Chiapas, Mexico")
        XCTAssertEqual(out["columns"] as? Int, 5)
        XCTAssertEqual(out["greeting_name"] as? String, "Gera")
        let again = try weatherConfig(String(decoding: try weatherConfig("{}").applying(weatherPlace: place), as: UTF8.self))
        XCTAssertEqual(again.weatherPlace?.name, "Tapachula, Chiapas, Mexico")
        XCTAssertEqual(again.weatherPlace?.latitude, 14.9044)
        let cleared = try JSONSerialization.jsonObject(with: again.applying(weatherPlace: nil)) as! [String: Any]
        XCTAssertNil(cleared["weather_lat"]); XCTAssertNil(cleared["weather_lon"]); XCTAssertNil(cleared["weather_name"])
    }

    func testRowsUnderTheDockDefaultToZeroAndStayInRange() throws {
        XCTAssertEqual(try weatherConfig("{}").rowsBelowDock, 0)
        XCTAssertEqual(try weatherConfig(#"{"rows_below_dock":2}"#).rowsBelowDock, 2)
        XCTAssertEqual(try weatherConfig(#"{"rows_below_dock":9}"#).rowsBelowDock, 0)
    }

    func testAPlaceNeedsRealCoordinates() {
        XCTAssertNil(TVWeatherPlace(name: "x", latitude: 91, longitude: 0))
        XCTAssertNil(TVWeatherPlace(name: "x", latitude: 0, longitude: -181))
        XCTAssertNil(try weatherConfig(#"{"weather_lat":14.9}"#).weatherPlace)
    }

    func testTheCitySearchReadsOpenMeteosAnswerAndAsksOnlyForTheCity() throws {
        let answer = #"{"results":[{"name":"Tapachula","latitude":14.9,"longitude":-92.26,"country":"México","admin1":"Chiapas"},{"name":"Tapachula","latitude":14.91,"longitude":-92.27}]}"#
        let places = try TVCitySearch.places(from: Data(answer.utf8))
        XCTAssertEqual(places.map(\.name), ["Tapachula, Chiapas, México", "Tapachula"])
        XCTAssertEqual(try TVCitySearch.places(from: Data("{\"generationtime_ms\":0.5}".utf8)), [])   // no "results" key: nothing matched
        let url = try XCTUnwrap(TVCitySearch.url(for: "  São Paulo ", language: "es"))
        XCTAssertEqual(url.host, "geocoding-api.open-meteo.com")
        XCTAssertTrue(url.absoluteString.contains("name=S%C3%A3o%20Paulo"))
        XCTAssertNil(TVCitySearch.url(for: "a", language: "es"))
    }
}
