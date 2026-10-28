import Foundation

// The place the launcher's weather chip shows. The launcher reads weather_lat and weather_lon from its
// config.json and asks Open-Meteo for them itself; weather_name is only here so this app can say which city it is.
struct TVWeatherPlace: Equatable, Identifiable {
    let name: String
    let latitude: Double
    let longitude: Double

    var id: String { "\(latitude),\(longitude)" }

    static let maxNameLength = 60

    // The coordinates to four decimals (about 11 m): all the chip needs, and nothing more precise leaves the phone.
    init?(name: String, latitude: Double, longitude: Double) {
        guard (-90.0...90.0).contains(latitude), (-180.0...180.0).contains(longitude) else { return nil }
        let clean = name.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
        self.name = String(String.UnicodeScalarView(clean)).trimmingCharacters(in: .whitespaces).prefix(Self.maxNameLength).description
        self.latitude = (latitude * 10_000).rounded() / 10_000
        self.longitude = (longitude * 10_000).rounded() / 10_000
    }
}

// Open-Meteo's place search (https://open-meteo.com/en/docs/geocoding-api, no account or key). The typed city
// goes to that one address and nowhere else; the app does not read the phone's location.
enum TVCitySearch {
    static func url(for query: String, language: String) -> URL? {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...80).contains(text.count) else { return nil }
        var parts = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        parts?.queryItems = [
            URLQueryItem(name: "name", value: text), URLQueryItem(name: "count", value: "5"),
            URLQueryItem(name: "language", value: language), URLQueryItem(name: "format", value: "json"),
        ]
        return parts?.url
    }

    // "Tapachula, Chiapas, Mexico": the name, its region and country when it has them.
    static func places(from data: Data) throws -> [TVWeatherPlace] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [] }
        let results = root["results"] as? [[String: Any]] ?? []   // the key is missing when nothing matches
        return results.compactMap { r in
            guard let name = r["name"] as? String, let lat = r["latitude"] as? Double, let lon = r["longitude"] as? Double else { return nil }
            let label = [name, r["admin1"] as? String, r["country"] as? String].compactMap { $0 }.joined(separator: ", ")
            return TVWeatherPlace(name: label, latitude: lat, longitude: lon)
        }
    }

    static func search(_ query: String, session: URLSession = .shared) async throws -> [TVWeatherPlace] {
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        guard let url = url(for: query, language: language) else { return [] }
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try places(from: data)
    }
}
