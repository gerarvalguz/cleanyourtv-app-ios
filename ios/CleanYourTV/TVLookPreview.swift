import SwiftUI

// A drawing of the launcher's home screen in a look, like the Android app's Look sheet preview: the
// greeting and clock, the big name of the focused app, and the dock with the apps in a row. It shows
// the shape of the look, not the TV's pixels.
struct TVLookPreview: View {
    let style: TVLookStyle
    let columns: Int
    var greetingName = ""
    var picture: UIImage?
    var pictureDim = 0   // percent, as the launcher's wallpaper_dim

    private let tiles: [(String, Color)] = [
        ("Netflix", Color(red: 0.75, green: 0.1, blue: 0.12)), ("Disney+", Color(red: 0.1, green: 0.2, blue: 0.5)),
        ("Spotify", Color(red: 0.1, green: 0.55, blue: 0.3)), ("YouTube", Color(red: 0.8, green: 0.15, blue: 0.15)),
        ("Prime", Color(red: 0.1, green: 0.45, blue: 0.75)), ("Twitch", Color(red: 0.5, green: 0.3, blue: 0.8)),
        ("Max", Color(red: 0.3, green: 0.2, blue: 0.7)), ("Apple TV", Color(white: 0.3)),
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .topLeading) {
                background
                VStack(alignment: .leading, spacing: 0) {
                    topBar(width: w)
                    Spacer(minLength: 0)
                    if style.isCinematic {
                        Text("Netflix").font(.system(size: w * 0.075, weight: .bold)).foregroundStyle(.white)
                            .padding(.bottom, h * 0.02)
                    } else if style.showsBigName {
                        Text("Netflix").font(.system(size: w * 0.06, weight: .semibold)).foregroundStyle(.white)
                            .padding(.bottom, h * 0.03)
                    }
                    dock(width: w)
                }
                .padding(w * 0.045)
            }
            .clipShape(RoundedRectangle(cornerRadius: w * 0.035, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: w * 0.035, style: .continuous).stroke(.white.opacity(0.18), lineWidth: 1))
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview of the \(style.title) look with \(columns) apps in a row")
    }

    private var background: some View {
        ZStack {
            if let picture {
                Color.black
                Image(uiImage: picture).resizable().scaledToFill()
                Color.black.opacity(Double(pictureDim) / 100)
            } else {
                LinearGradient(colors: [Color(red: 0.2, green: 0.05, blue: 0.3), Color(red: 0.05, green: 0.02, blue: 0.1)],
                               startPoint: .top, endPoint: .bottom)
                if style.showsGlow {
                    RadialGradient(colors: [Color(red: 1, green: 0.45, blue: 0.2).opacity(style == .glass ? 0.25 : 0.4), .clear],
                                   center: style == .glass ? .top : .center, startRadius: 4, endRadius: 160)
                }
            }
            if style.isCinematic {
                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            }
        }
    }

    private func topBar(width w: CGFloat) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                Text(greetingName.isEmpty ? String(localized: "GOOD NIGHT") : String(localized: "GOOD NIGHT, \(greetingName.uppercased())"))
                    .font(.system(size: w * 0.022, weight: .medium)).foregroundStyle(.white.opacity(0.7)).lineLimit(1)
                Text("1:02").font(.system(size: w * 0.07, weight: .light)).foregroundStyle(.white)
            }
            Spacer()
            HStack(spacing: w * 0.012) {
                ForEach([String(localized: "Inputs"), String(localized: "Wi-Fi"), String(localized: "Settings")], id: \.self) { label in
                    if style.roundButtons {
                        Circle().fill(.white.opacity(0.18)).frame(width: w * 0.05, height: w * 0.05)
                    } else {
                        Text(label).font(.system(size: w * 0.02)).foregroundStyle(.white)
                            .padding(.horizontal, w * 0.015).padding(.vertical, w * 0.008)
                            .background(.white.opacity(0.18), in: Capsule())
                    }
                }
            }
        }
    }

    @ViewBuilder private func dock(width w: CGFloat) -> some View {
        let spacing = w * 0.012
        let rowCount = style == .allapps ? 2 : 1
        let band = RoundedRectangle(cornerRadius: w * 0.02, style: .continuous)
        VStack(spacing: spacing) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { i in
                        let tile = tiles[(row * columns + i) % tiles.count]
                        RoundedRectangle(cornerRadius: w * 0.012, style: .continuous)
                            .fill(tile.1.opacity(i == 0 && row == 0 ? 1 : 0.75))
                            .aspectRatio(16 / 10, contentMode: .fit)
                            .overlay(RoundedRectangle(cornerRadius: w * 0.012, style: .continuous)
                                .stroke(.white, lineWidth: i == 0 && row == 0 ? 2 : 0))
                    }
                }
            }
        }
        .padding(style.showsDockBand ? spacing : 0)
        .background {
            if style.hasGlassDock { band.fill(.white.opacity(0.14)) }
            else if style.showsDockBand { band.fill(.black.opacity(0.55)) }
        }
    }
}
