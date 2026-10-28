import SwiftUI
import PhotosUI

private enum Palette {
    static let background = Color(red: 0.055, green: 0.063, blue: 0.078)
    static let surface = Color(red: 0.105, green: 0.118, blue: 0.141)
    static let amber = Color(red: 0.91, green: 0.66, blue: 0.30)
    static let muted = Color(red: 0.65, green: 0.68, blue: 0.72)
}

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Palette.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles.tv")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Palette.amber)
                            Text("CLEAN YOUR TV")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .tracking(2.2)
                                .foregroundStyle(Palette.muted)
                        }
                        .padding(.top, 24)

                        ZStack {
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.20, green: 0.19, blue: 0.17),
                                            Palette.surface,
                                            Color(red: 0.12, green: 0.14, blue: 0.17)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Circle()
                                .fill(Palette.amber.opacity(0.10))
                                .frame(width: 210, height: 210)
                                .blur(radius: 2)
                                .offset(x: 78, y: -20)
                            Image(systemName: "tv")
                                .font(.system(size: 96, weight: .ultraLight))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.95), Palette.amber],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Palette.amber.opacity(0.22), radius: 30, y: 12)
                            Image(systemName: "sparkle")
                                .font(.system(size: 25, weight: .medium))
                                .foregroundStyle(Palette.amber)
                                .offset(x: 77, y: -54)
                        }
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("A careful plan for your TV.")
                                .font(.system(size: 38, weight: .semibold, design: .rounded))
                                .tracking(-1.4)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Connect to your TV, review the safety report, and apply only selected reversible changes.")
                                .font(.system(size: 17))
                                .lineSpacing(5)
                                .foregroundStyle(Palette.muted)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "wifi", title: "On your home network", detail: "Your iPhone and TV need the same Wi-Fi.")
                            FeatureRow(icon: "list.clipboard", title: "Confirmed package plan", detail: "Select safety-reviewed packages before applying changes.")
                            FeatureRow(icon: "lock.shield", title: "Reversible changes", detail: "A restore point records each package's original state first.")
                        }
                        .padding(20)
                        .background(Palette.surface.opacity(0.76), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                        NavigationLink {
                            ConnectView()
                        } label: {
                            HStack(spacing: 10) {
                                Text("Inspect my TV")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.amber)
                        .foregroundStyle(.black)
                        .padding(.top, 4)

                        Text("Your TV's launcher stays an Android app. This iPhone app is its remote companion.")
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.muted.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Palette.amber)
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.amber)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct ConnectView: View {
    @StateObject private var discovery = TVDiscoveryModel()
    @State private var address = ""
    @FocusState private var addressFieldFocused: Bool

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Connect to your TV")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .tracking(-0.8)
                            .foregroundStyle(.white)
                        Text("Turn on network debugging on the TV, then choose it below.")
                            .font(.system(size: 16))
                            .lineSpacing(4)
                            .foregroundStyle(Palette.muted)
                    }
                    .padding(.top, 12)

                    HStack(spacing: 12) {
                        Image(systemName: discovery.isSearching ? "dot.radiowaves.left.and.right" : "wifi")
                            .foregroundStyle(Palette.amber)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(discovery.statusTitle)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(discovery.statusDetail)
                                .font(.system(size: 12))
                                .foregroundStyle(Palette.muted)
                        }
                        Spacer(minLength: 8)
                        if discovery.isSearching {
                            ProgressView().tint(Palette.amber)
                        } else {
                            Button("Scan again") { discovery.start() }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Palette.amber)
                        }
                    }
                    .padding(16)
                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    if discovery.services.isEmpty {
                        ContentUnavailableView {
                            Label("No TVs found yet", systemImage: "tv")
                        } description: {
                            Text("Keep this screen open while the TV is on the same Wi-Fi and network debugging is enabled.")
                        }
                        .foregroundStyle(Palette.muted)
                        .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ADB DEVICES")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(Palette.muted)
                            ForEach(discovery.services) { service in
                                Button {
                                    discovery.connect(to: service.endpoint)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "tv")
                                            .foregroundStyle(Palette.amber)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(service.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(.white)
                                            Text("Tap to request a secure ADB connection")
                                                .font(.system(size: 12))
                                                .foregroundStyle(Palette.muted)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .foregroundStyle(Palette.amber)
                                    }
                                    .padding(16)
                                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .disabled(discovery.isConnecting)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Enter an address instead")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        HStack(spacing: 10) {
                            TextField("192.168.1.42", text: $address)
                                .keyboardType(.decimalPad)
                                .focused($addressFieldFocused)
                                .textContentType(.URL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(Palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(.white)
                                .accessibilityLabel("TV IPv4 address")
                            Button {
                                discovery.connect(to: .hostPort(host: .init(address), port: 5555))
                            } label: {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 48, height: 48)
                            }
                            .buttonStyle(.bordered)
                            .tint(Palette.amber)
                            .disabled(!IPv4Address.isValid(address) || discovery.isConnecting)
                            .accessibilityLabel("Connect to TV")
                        }
                        Text("Connecting asks the TV to authorize this iPhone's ADB key. Package changes are limited to a reviewed plan with a saved restore point.")
                            .font(.system(size: 12))
                            .lineSpacing(3)
                            .foregroundStyle(Palette.muted)
                    }
                    .padding(18)
                    .background(Palette.surface.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                    if discovery.isConnecting {
                        Label("Connecting to TV…", systemImage: "arrow.trianglehead.2.clockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Palette.amber)
                            .frame(maxWidth: .infinity)
                    }
                    if let fingerprint = discovery.authFingerprint {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Approve this iPhone on your TV", systemImage: "key.horizontal")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("When the TV asks whether to allow USB/network debugging, choose Allow. Compare this fingerprint with the one shown by the TV if available.")
                                .font(.system(size: 13))
                                .lineSpacing(3)
                                .foregroundStyle(Palette.muted)
                            Text(fingerprint)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(Palette.amber)
                                .textSelection(.enabled)
                        }
                        .padding(16)
                        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    if let identity = discovery.identity {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Connected and identified", systemImage: "checkmark.shield.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Palette.amber)
                            Text(identity.model.isEmpty ? identity.device : identity.model)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Device \(identity.device) · Android API \(identity.sdk) · serial ending \(identity.serialLast4)")
                                .font(.system(size: 12))
                                .foregroundStyle(Palette.muted)
                            Button {
                                discovery.readPackages()
                            } label: {
                                HStack {
                                    if discovery.isReadingPackages { ProgressView().tint(.black) }
                                    Text(discovery.isReadingPackages ? String(localized: "Checking TV safety details…") : String(localized: "Analyze TV safely · read-only"))
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Palette.amber)
                            .foregroundStyle(.black)
                            .disabled(discovery.isReadingPackages)
                            if let packages = discovery.packages {
                                let disabledCount = packages.filter(\.isDisabled).count
                                Label("\(packages.count) installed · \(disabledCount) currently disabled", systemImage: "square.grid.2x2")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                DisclosureGroup("View package names") {
                                    VStack(alignment: .leading, spacing: 7) {
                                        ForEach(packages) { package in
                                            HStack {
                                                Text(package.name)
                                                    .font(.system(size: 11, design: .monospaced))
                                                    .foregroundStyle(Palette.muted)
                                                    .textSelection(.enabled)
                                                Spacer(minLength: 6)
                                                if package.isDisabled {
                                                    Text("OFF")
                                                        .font(.system(size: 9, weight: .bold))
                                                        .tracking(0.8)
                                                        .foregroundStyle(Palette.amber)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 10)
                                }
                                .font(.system(size: 13, weight: .medium))
                                .tint(Palette.amber)
                                .foregroundStyle(Palette.muted)
                            }
                            if let profile = discovery.profileResolution, let report = discovery.safetyReport {
                                SafetyReviewCard(profile: profile, report: report)
                                Button {
                                    discovery.createReviewPlan()
                                } label: {
                                    Label(
                                        discovery.reviewPlan == nil || discovery.reviewPlanIsStale
                                            ? String(localized: "Create reviewable plan")
                                            : String(localized: "Replace saved plan with this scan"),
                                        systemImage: "list.clipboard"
                                    )
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(.bordered)
                                .tint(Palette.amber)
                                .disabled(!report.incompleteReasons.isEmpty)
                                if let plan = discovery.reviewPlan {
                                    ReviewPlanCard(
                                        plan: plan,
                                        isStale: discovery.reviewPlanIsStale,
                                        restorePoint: discovery.restorePoint,
                                        canApply: discovery.canApplyReviewPlan,
                                        applyBlockReason: discovery.applyReviewPlanBlockReason,
                                        isApplying: discovery.isApplyingPlan,
                                        isRestoring: discovery.isRestoringPlan,
                                        onChoiceChanged: { package, selected in
                                            discovery.setReviewPlanChoice(package: package, selected: selected)
                                        },
                                        onApply: { discovery.applyReviewPlan() },
                                        onRestore: { discovery.restoreReviewPlan() }
                                    )
                                }
                                if let planMessage = discovery.planMessage {
                                    Label(planMessage, systemImage: "doc.text")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Palette.muted)
                                }
                            }
                            if let configuration = discovery.configuration {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label("Read-only TV configuration", systemImage: "slider.horizontal.3")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Current HOME app")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Palette.muted)
                                        Text(configuration.homeComponent ?? String(localized: "No HOME app resolved"))
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundStyle(Palette.amber)
                                            .textSelection(.enabled)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("HOME claimants")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Palette.muted)
                                        Text(configuration.homeClaimants.joined(separator: ", ").isEmpty ? String(localized: "None reported") : configuration.homeClaimants.joined(separator: ", "))
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundStyle(.white)
                                            .textSelection(.enabled)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TV input services")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Palette.muted)
                                        Text(configuration.inputServiceAvailable ? String(localized: "\(configuration.inputPackages.count) service packages detected") : String(localized: "Could not be verified"))
                                            .font(.system(size: 12))
                                            .foregroundStyle(configuration.inputServiceAvailable ? .white : Palette.amber)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Active keyboard")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Palette.muted)
                                        Text(configuration.inputMethod ?? String(localized: "Not set"))
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundStyle(.white)
                                            .textSelection(.enabled)
                                    }
                                    ForEach(configuration.settings) { setting in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(setting.setting.title)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(Palette.muted)
                                            Text(setting.value ?? String(localized: "Not set"))
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundStyle(.white)
                                                .textSelection(.enabled)
                                        }
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Palette.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            Text("Only selected review candidates can be disabled. The app saves each package's prior state on this iPhone before applying; no apps are uninstalled and no system settings are changed.")
                                .font(.system(size: 13))
                                .foregroundStyle(Palette.muted)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    if let identity = discovery.identity, let status = discovery.homeSwitchStatus,
                       TVHomeInterceptor.isFireTV(identity, platform: discovery.profileResolution?.platform) {
                        HomeSwitchCard(
                            status: status,
                            blockReason: discovery.homeSwitchBlockReason,
                            isWorking: discovery.isChangingHome,
                            message: discovery.homeSwitchMessage,
                            onInstall: { discovery.installHomeInterceptor() },
                            onRemove: { discovery.removeHomeInterceptor() }
                        )
                    }
                    if let status = discovery.homeSwitchStatus, status.launcherInstalled {
                        GreetingNameCard(
                            name: $discovery.greetingName,
                            savedName: discovery.greetingNameOnTV,
                            blockReason: discovery.layoutBlockReason,
                            isWorking: discovery.isChangingLayout,
                            message: discovery.greetingMessage,
                            onLoad: { discovery.loadGreetingName() },
                            onApply: { discovery.applyGreetingName() }
                        )
                        WeatherChipCard(
                            place: discovery.weatherChipPlace,
                            results: discovery.weatherChipResults,
                            isSearching: discovery.weatherChipSearching,
                            blockReason: discovery.layoutBlockReason,
                            isWorking: discovery.isChangingLayout,
                            message: discovery.weatherChipMessage,
                            onLoad: { discovery.loadWeatherChip() },
                            onSearch: { discovery.searchWeatherCity($0) },
                            onApply: { discovery.applyWeatherPlace($0) }
                        )
                        LauncherLookCard(
                            look: $discovery.launcherLook,
                            greetingName: discovery.greetingNameOnTV ?? "",
                            blockReason: discovery.layoutBlockReason,
                            isWorking: discovery.isChangingLayout,
                            message: discovery.lookMessage,
                            onLoad: { discovery.loadLauncherLook() },
                            onApply: { discovery.applyLauncherLook() },
                            onRestore: { discovery.restoreLauncherLook() }
                        )
                        LauncherLayoutCard(
                            layout: discovery.launcherLayout,
                            blockReason: discovery.layoutBlockReason,
                            isWorking: discovery.isChangingLayout,
                            message: discovery.layoutMessage,
                            onLoad: { discovery.loadLauncherLayout() },
                            onMove: { discovery.moveLauncherApp($0, by: $1) },
                            onAdd: { discovery.addLauncherApp($0) },
                            onRemove: { discovery.removeLauncherApp($0) },
                            onApply: { discovery.applyLauncherLayout() },
                            onRestore: { discovery.restoreLauncherLayout() }
                        )
                        WeatherCard(
                            installed: discovery.weatherInstalled,
                            blockReason: discovery.layoutBlockReason,
                            isWorking: discovery.isChangingHome,
                            message: discovery.weatherMessage,
                            onInstall: { discovery.installWeather() },
                            onRemove: { discovery.removeWeather() }
                        )
                    }
                    if let message = discovery.connectionMessage {
                        Label(message, systemImage: discovery.identity == nil ? "info.circle" : "lock.shield")
                            .font(.system(size: 12))
                            .lineSpacing(3)
                            .foregroundStyle(Palette.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Label("Only selected packages are changed, with a saved restore point.", systemImage: "lock.shield")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.muted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }

        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Clean Your TV")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { addressFieldFocused = false }
                    .tint(Palette.amber)
            }
        }
        .onAppear { discovery.start() }
        .onDisappear { discovery.stop() }
    }
}

private struct SafetyReviewCard: View {
            let profile: TVProfileResolution
            let report: TVSafetyReport

            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Read-only safety review", systemImage: "checkmark.shield")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    if profile.platform?.caseInsensitiveCompare("FIRE_OS") == .orderedSame {
                        Label("Fire TV keeps Amazon's home screen. This plan cannot remove or rearrange its rows.", systemImage: "info.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.amber)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("To stop featured videos from autoplaying, use the TV remote: Settings > Preferences > Featured Content, then turn off video and audio autoplay. Sponsored rows may still appear. These home-screen controls are not available from the iPhone app.")
                            .font(.system(size: 12))
                            .lineSpacing(3)
                            .foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(profile.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.amber)
                    Text(profile.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.muted)
                    HStack(spacing: 8) {
                        SafetyCount(value: report.candidateCount, title: "Review")
                        SafetyCount(value: report.protectedCount, title: "Kept safe")
                        SafetyCount(value: report.optionalCount, title: "Optional")
                        SafetyCount(value: report.alreadyDisabledCount, title: "Already off")
                    }
                    if !report.incompleteReasons.isEmpty {
                        Label("Some checks are incomplete", systemImage: "exclamationmark.triangle")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Palette.amber)
                        ForEach(report.incompleteReasons, id: \.self) { reason in
                            Text(reason)
                                .font(.system(size: 12))
                                .foregroundStyle(Palette.muted)
                        }
                    }
                    if report.groups.isEmpty {
                        Text("No packages from this catalog profile are installed.")
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.muted)
                    } else {
                        ForEach(report.groups) { group in
                            DisclosureGroup("\(group.title) · \(group.rows.count)") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(group.rows) { row in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                Text(row.package)
                                                    .font(.system(size: 11, design: .monospaced))
                                                    .foregroundStyle(.white)
                                                    .textSelection(.enabled)
                                                Spacer(minLength: 4)
                                                Text(row.status.title)
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundStyle(row.status == .reviewCandidate ? Palette.amber : Palette.muted)
                                            }
                                            if let explanation = row.reason ?? row.note, !explanation.isEmpty {
                                                Text(explanation)
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Palette.muted)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                            .font(.system(size: 12, weight: .medium))
                            .tint(Palette.amber)
                            .foregroundStyle(Palette.muted)
                        }
                    }
                    Text("Only selected review candidates can be applied. Optional and protected packages cannot be included.")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.muted)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }

        private struct ReviewPlanCard: View {
            let plan: TVReviewPlan
            let isStale: Bool
            let restorePoint: TVRestorePoint?
            let canApply: Bool
            let applyBlockReason: String?
            let isApplying: Bool
            let isRestoring: Bool
            let onChoiceChanged: (String, Bool) -> Void
            let onApply: () -> Void
            let onRestore: () -> Void
            @State private var confirmsApply = false
            @State private var confirmsRestore = false

            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Review plan", systemImage: "list.clipboard")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(plan.selectedCount) of \(plan.items.count) packages selected")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.amber)
                    if let restorePoint, !restorePoint.isRestored {
                        Label("Restore the active changes, analyze the TV again, then replace this plan before changing selections.", systemImage: "arrow.uturn.backward.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.amber)
                            .fixedSize(horizontal: false, vertical: true)
                    } else if isStale {
                        Label("This saved plan is read-only because it does not match the latest TV scan. Analyze the TV and replace the plan to edit it.", systemImage: "exclamationmark.triangle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.amber)
                            .fixedSize(horizontal: false, vertical: true)
                    } else if plan.items.contains(where: { $0.status == .optional }) {
                        Text("Gray switches marked Optional are locked. Only Review candidate packages can be selected.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let restorePoint, !restorePoint.isRestored {
                        Label(
                            "Restore point active · \(restorePoint.items.count) package(s)",
                            systemImage: "arrow.uturn.backward.circle"
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Palette.amber)
                        Button {
                            confirmsRestore = true
                        } label: {
                            HStack {
                                if isRestoring { ProgressView().tint(.black) }
                                Text(isRestoring ? String(localized: "Restoring original states…") : String(localized: "Restore original package states"))
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.amber)
                        .foregroundStyle(.black)
                        .disabled(isRestoring || isApplying)
                    } else {
                        Button {
                            confirmsApply = true
                        } label: {
                            HStack {
                                if isApplying { ProgressView().tint(.black) }
                                Text(isApplying ? String(localized: "Applying selected packages…") : String(localized: "Apply selected changes"))
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.amber)
                        .foregroundStyle(.black)
                        .disabled(!canApply || isApplying || isRestoring)
                        if let applyBlockReason, !isApplying, !isRestoring {
                            Label(applyBlockReason, systemImage: "info.circle")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Palette.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    ForEach(plan.items) { item in
                        Toggle(isOn: Binding(
                            get: { item.selected },
                            set: { onChoiceChanged(item.package, $0) }
                        )) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.package)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .textSelection(.enabled)
                                Text("\(item.groupTitle) · \(item.status.title)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Palette.muted)
                            }
                        }
                        .tint(Palette.amber)
                        .disabled(isStale || restorePoint?.isRestored == false || (item.status == .optional && !item.selected))
                    }
                    if plan.selectedItems.contains(where: { $0.status != .reviewCandidate }) {
                        Text("Deselect optional packages before applying. Only safety-approved review candidates can be changed.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Palette.amber)
                    }
                    if let restorePoint, restorePoint.isRestored {
                        Label("Original package states restored", systemImage: "checkmark.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Palette.muted)
                    }
                    ShareLink(item: plan.exportText) {
                        Label("Export review summary", systemImage: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!plan.isDigestValid)
                    Text("Applying disables selected candidates for user 0. The saved restore point stays on this iPhone; do not delete the app before restoring.")
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.muted)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .confirmationDialog(
                    "Apply selected package changes?",
                    isPresented: $confirmsApply,
                    titleVisibility: .visible
                ) {
                    Button("Apply \(plan.selectedCount) selected package(s)", role: .destructive, action: onApply)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("A restore point will be saved first. Selected packages will be disabled for user 0, not uninstalled. Restore requires this iPhone and its saved restore point.")
                }
                .confirmationDialog(
                    "Restore original package states?",
                    isPresented: $confirmsRestore,
                    titleVisibility: .visible
                ) {
                    Button("Restore \(restorePoint?.items.count ?? 0) package(s)", role: .destructive, action: onRestore)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("The app will compare each package with its saved state and only re-enable or re-disable it when needed.")
                }
            }
        }

        private struct SafetyCount: View {
            let value: Int
            let title: LocalizedStringKey

            var body: some View {
                VStack(spacing: 3) {
                    Text("\(value)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(title)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Palette.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }

private struct HomeSwitchCard: View {
    let status: TVHomeSwitchStatus
    let blockReason: String?
    let isWorking: Bool
    let message: String?
    let onInstall: () -> Void
    let onRemove: () -> Void
    @State private var confirmsInstall = false
    @State private var confirmsRemove = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Clean Your TV as the Home screen", systemImage: "house")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Fire OS does not let another launcher own Home. This installs the Clean Your TV launcher plus a small service that opens it whenever Amazon's Home screen appears. Amazon's own home stays installed and Settings still open normally.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 6) {
                statusRow("Launcher installed", status.launcherInstalled)
                statusRow("Home button service installed", status.interceptorInstalled)
                statusRow("Service switched on", status.serviceEnabled)
            }
            if status.isActive {
                Text("Pressing Home on the remote opens the Clean Your TV launcher.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.amber)
            }
            if let message {
                Label(message, systemImage: "doc.text")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let blockReason, !isWorking {
                Text(blockReason).font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            Button {
                confirmsInstall = true
            } label: {
                Label(status.isActive ? String(localized: "Reinstall") : String(localized: "Install and switch on"), systemImage: String(localized: "arrow.down.app"))
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
            .tint(Palette.amber)
            .disabled(blockReason != nil)
            if status.hasAnyPart {
                Button(role: .destructive) {
                    confirmsRemove = true
                } label: {
                    Label("Give Home back to Amazon", systemImage: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.bordered)
                .disabled(blockReason != nil)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .alert("Install on this TV?", isPresented: $confirmsInstall) {
            Button("Install", action: onInstall)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Installs the launcher and the Home button service, and switches the service on. Services you already use stay on. Remove it any time from this screen.")
        }
        .alert("Give Home back?", isPresented: $confirmsRemove) {
            Button("Remove", role: .destructive, action: onRemove)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Switches the service off and uninstalls the launcher and the service. Amazon's home screen is untouched.")
        }
    }

    private func statusRow(_ title: LocalizedStringKey, _ done: Bool) -> some View {
        Label(title, systemImage: done ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 12))
            .foregroundStyle(done ? Palette.amber : Palette.muted)
    }
}

private struct WeatherCard: View {
    let installed: Bool
    let blockReason: String?
    let isWorking: Bool
    let message: String?
    let onInstall: () -> Void
    let onRemove: () -> Void
    @State private var confirmsInstall = false
    @State private var confirmsRemove = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather card", systemImage: "cloud.sun")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Adds a Weather card to the launcher's dock: the temperature now, the air quality and the next days for one city. You type the city once on the TV with the remote. It reads Open-Meteo (no account) while the page is open, and is the only part that uses the internet.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            if installed {
                Label("Weather installed", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12)).foregroundStyle(Palette.amber)
            }
            if let message {
                Label(message, systemImage: "doc.text")
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let blockReason, !isWorking {
                Text(blockReason).font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            Button { confirmsInstall = true } label: {
                Label(installed ? String(localized: "Reinstall") : String(localized: "Install the Weather card"), systemImage: "arrow.down.app")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent).tint(Palette.amber)
            .disabled(blockReason != nil)
            if installed {
                Button(role: .destructive) { confirmsRemove = true } label: {
                    Label("Remove the Weather card", systemImage: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .buttonStyle(.bordered)
                .disabled(blockReason != nil)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .alert("Install the Weather card?", isPresented: $confirmsInstall) {
            Button("Install", action: onInstall)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Installs one small app (it asks for internet access only). After it, press Home on the TV and choose Show when the launcher asks. Remove it any time from this screen.")
        }
        .alert("Remove the Weather card?", isPresented: $confirmsRemove) {
            Button("Remove", role: .destructive, action: onRemove)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Uninstalls the Weather app. Nothing else on the TV changes.")
        }
    }
}

private struct GreetingNameCard: View {
    @Binding var name: String
    let savedName: String?
    let blockReason: String?
    let isWorking: Bool
    let message: String?
    let onLoad: () -> Void
    let onApply: () -> Void

    private var changed: Bool { TVLauncherConfig.cleanName(name) != (savedName ?? "") }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Your name on the launcher", systemImage: "person.text.rectangle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("The greeting at the top of the launcher says your name after it. Leave it empty and only the greeting shows.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .font(.system(size: 15))
                .padding(12)
                .background(Palette.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .disabled(isWorking)
            if let message {
                Label(message, systemImage: "doc.text")
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let blockReason, !isWorking {
                Text(blockReason).font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            Button(action: onApply) {
                Label("Send the name to the TV", systemImage: "paperplane")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent).tint(Palette.amber)
            .disabled(blockReason != nil || !changed)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear(perform: onLoad)
    }
}

private struct WeatherChipCard: View {
    let place: TVWeatherPlace?
    let results: [TVWeatherPlace]
    let isSearching: Bool
    let blockReason: String?
    let isWorking: Bool
    let message: String?
    let onLoad: () -> Void
    let onSearch: (String) -> Void
    let onApply: (TVWeatherPlace?) -> Void
    @State private var query = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather on the launcher", systemImage: "cloud.sun")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Shows the temperature, the conditions and today's high and low in a chip under the clock. The TV itself asks Open-Meteo (no account) when the home screen opens; only the city's coordinates are sent. It needs the updated launcher: use Reinstall in the Home screen card.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let place {
                Label(place.name.isEmpty ? String(localized: "A city is set") : place.name, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(Palette.amber)
            }
            HStack(spacing: 10) {
                TextField("City", text: $query)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { onSearch(query) }
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Palette.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .disabled(isWorking)
                Button { onSearch(query) } label: {
                    Image(systemName: "magnifyingglass").padding(.vertical, 12).padding(.horizontal, 6)
                }
                .buttonStyle(.bordered)
                .disabled(isWorking || isSearching || query.trimmingCharacters(in: .whitespaces).count < 2)
                .accessibilityLabel("Search the city")
            }
            ForEach(results) { result in
                Button { onApply(result) } label: {
                    HStack {
                        Text(result.name).font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "paperplane").foregroundStyle(Palette.amber)
                    }
                    .padding(12)
                    .background(Palette.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(blockReason != nil || isWorking)
            }
            if let message {
                Label(message, systemImage: "doc.text")
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let blockReason, !isWorking {
                Text(blockReason).font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            if place != nil {
                Button(role: .destructive) { onApply(nil) } label: {
                    Label("Remove the weather chip", systemImage: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .buttonStyle(.bordered)
                .disabled(blockReason != nil || isWorking)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear(perform: onLoad)
    }
}

private struct LauncherLookCard: View {
    @Binding var look: LauncherLookState?
    let greetingName: String
    let blockReason: String?
    let isWorking: Bool
    let message: String?
    let onLoad: () -> Void
    let onApply: () -> Void
    let onRestore: () -> Void
    @State private var confirmsApply = false
    @State private var pickedItem: PhotosPickerItem?
    @State private var photoImage: UIImage?
    @State private var photoMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Look", systemImage: "paintpalette")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Choose how the launcher looks and, if you want, a background photo. Your app order and the rest of the launcher's settings are kept.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let current = look {
                TVLookPreview(style: current.style ?? .classic, columns: current.columns, greetingName: greetingName, picture: photoImage, pictureDim: current.dim)
                if let style = current.style {
                    Text("\(style.title). \(style.summary)")
                        .font(.system(size: 12)).foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("The TV has a look tuned by hand. Pick one below to replace its look settings.")
                        .font(.system(size: 12)).foregroundStyle(Palette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("STYLE").font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.amber)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(TVLookStyle.allCases) { style in
                            Button { look?.style = style } label: {
                                VStack(spacing: 6) {
                                    TVLookPreview(style: style, columns: 4).frame(width: 130)
                                        .overlay(RoundedRectangle(cornerRadius: 6)
                                            .stroke(Palette.amber, lineWidth: current.style == style ? 2 : 0))
                                    Text(style.title).font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(current.style == style ? Palette.amber : .white)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(isWorking)
                            .accessibilityLabel("\(style.title) look")
                            .accessibilityAddTraits(current.style == style ? .isSelected : [])
                        }
                    }
                }
                Text("BACKGROUND PICTURE").font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.amber)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(TVPicture.offered()) { picture in
                            Button {
                                guard let jpeg = picture.jpeg else { return }
                                look?.photo = jpeg
                                look?.picture = picture
                                look?.dim = 0
                                if look?.style?.isCinematic != true { look?.style = .spotlight }
                                photoImage = UIImage(data: jpeg)
                                photoMessage = nil
                                pickedItem = nil
                            } label: {
                                VStack(spacing: 6) {
                                    Group {
                                        if let thumbnail = picture.thumbnail { Image(uiImage: thumbnail).resizable().scaledToFill() } else { Color.black }
                                    }
                                    .frame(width: 112, height: 63)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Palette.amber, lineWidth: current.picture?.id == picture.id ? 2 : 0))
                                    Text(picture.title).font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(current.picture?.id == picture.id ? Palette.amber : .white)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(isWorking)
                            .accessibilityLabel(picture.title)
                            .accessibilityAddTraits(current.picture?.id == picture.id ? .isSelected : [])
                        }
                    }
                }
                HStack(spacing: 10) {
                    PhotosPicker(selection: $pickedItem, matching: .images, photoLibrary: .shared()) {
                        Label(current.photo == nil ? String(localized: "Choose from your photos") : String(localized: "Choose another photo"), systemImage: String(localized: "photo"))
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity).padding(.vertical, 11)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isWorking)
                    if current.photo != nil {
                        Button { look?.photo = nil; look?.picture = nil } label: {
                            Image(systemName: "xmark").padding(.vertical, 11).padding(.horizontal, 6)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isWorking)
                        .accessibilityLabel("Don't use the chosen photo")
                    }
                }
                Text(photoMessage ?? (current.hasPicture && current.photo == nil
                     ? String(localized: "The TV already has a picture and keeps it. Choose a photo to replace it.")
                     : String(localized: "The photo is cropped to 16:9 and shrunk on this iPhone; its place and camera details are not sent.")))
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if current.showsPicture {
                    HStack {
                        Text("Clear").font(.system(size: 11)).foregroundStyle(Palette.muted)
                        Slider(value: Binding(get: { Double(current.dim) }, set: { look?.dim = Int($0) }),
                               in: 0...Double(TVWallpaper.maxDim), step: 5)
                            .tint(Palette.amber)
                            .disabled(isWorking)
                            .accessibilityLabel("Dim the picture")
                            .accessibilityValue("\(current.dim)%")
                        Text("Dark").font(.system(size: 11)).foregroundStyle(Palette.muted)
                    }
                }
                Text("APPS IN A ROW").font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.amber)
                Picker("Apps in a row", selection: Binding(get: { current.columns }, set: { look?.columns = $0 })) {
                    ForEach(Array(TVLookStyle.offeredColumns), id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
                .disabled(isWorking)
                HStack {
                    Text("Bigger").font(.system(size: 11)).foregroundStyle(Palette.muted)
                    Spacer()
                    Text("More apps").font(.system(size: 11)).foregroundStyle(Palette.muted)
                }
            }
            if let message {
                Label(message, systemImage: "doc.text")
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let blockReason, !isWorking {
                Text(blockReason).font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            Button { confirmsApply = true } label: {
                Label("Send the look to the TV", systemImage: "paperplane")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent).tint(Palette.amber)
            .disabled(blockReason != nil || look?.changed != true)
            if look?.hasBackup == true {
                Button(role: .destructive, action: onRestore) {
                    Label("Put the previous settings back", systemImage: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .buttonStyle(.bordered)
                .disabled(blockReason != nil)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear(perform: onLoad)
        .onChange(of: look?.photo) { _, photo in
            if photo == nil { photoImage = nil; pickedItem = nil; photoMessage = nil }
        }
        .onChange(of: pickedItem) { _, item in
            guard let item else { return }
            photoMessage = String(localized: "Preparing the photo.")
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self) else {
                    photoMessage = String(localized: "Could not load that photo. If it is in iCloud, open it in Photos first and try again.")
                    return
                }
                let jpeg = await Task.detached { TVWallpaper.jpeg(from: data) }.value
                if let jpeg, let image = UIImage(data: jpeg) {
                    look?.photo = jpeg
                    look?.picture = nil
                    look?.dim = TVWallpaper.newPhotoDim
                    if look?.style?.isCinematic != true { look?.style = .spotlight }   // apps in one row at the bottom, the rest of the screen shows the photo
                    photoImage = image
                    photoMessage = String(localized: "Photo ready (\(jpeg.count / 1000) KB). Spotlight keeps the apps in one row at the bottom so the photo shows; pick another look if you prefer.")
                } else {
                    photoMessage = String(localized: "That photo could not be used. Try another one.")
                }
            }
        }
        .confirmationDialog("Send this look to the TV?", isPresented: $confirmsApply, titleVisibility: .visible) {
            Button("Send and restart the launcher", action: onApply)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The launcher restarts. A copy of the TV's current settings stays on this iPhone.")
        }
    }
}

private struct LauncherLayoutCard: View {
    let layout: LauncherLayoutState?
    let blockReason: String?
    let isWorking: Bool
    let message: String?
    let onLoad: () -> Void
    let onMove: (String, Int) -> Void
    let onAdd: (String) -> Void
    let onRemove: (String) -> Void
    let onApply: () -> Void
    let onRestore: () -> Void
    @State private var confirmsApply = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Apps first on the launcher", systemImage: "square.grid.2x2")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Pick which apps come first. The first row is the dock; the rest fill the rows under it, up to three rows. Everything else in the launcher's settings is kept.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let layout {
                let rows = TVLauncherRows.rows(layout.order, columns: layout.columns)
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    Text(rowIndex == 0 ? String(localized: "Dock") : String(localized: "Row \(rowIndex + 1)"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Palette.amber)
                    ForEach(row, id: \.self) { package in
                        appRow(package, first: package == layout.order.first, last: package == layout.order.last)
                    }
                }
                if layout.order.isEmpty {
                    Text("No apps chosen: the launcher keeps its own order.")
                        .font(.system(size: 12)).foregroundStyle(Palette.muted)
                }
                if !layout.others.isEmpty {
                    Text("Other apps")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Palette.muted)
                    ForEach(layout.others, id: \.self) { package in
                        HStack {
                            Text(TVAppNames.name(for: package)).font(.system(size: 13)).foregroundStyle(.white)
                            Spacer()
                            Button { onAdd(package) } label: { Image(systemName: "plus.circle") }
                                .disabled(isWorking || layout.order.count >= TVLauncherRows.capacity(columns: layout.columns))
                                .accessibilityLabel("Add \(TVAppNames.name(for: package))")
                        }
                    }
                }
            }
            if let message {
                Label(message, systemImage: "doc.text")
                    .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let blockReason, !isWorking {
                Text(blockReason).font(.system(size: 12)).foregroundStyle(Palette.muted)
            }
            if layout == nil {
                Button(action: onLoad) {
                    Label("Choose apps", systemImage: "list.bullet")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .buttonStyle(.bordered).tint(Palette.amber)
                .disabled(blockReason != nil)
            } else {
                Button { confirmsApply = true } label: {
                    Label("Send to the TV", systemImage: "paperplane")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent).tint(Palette.amber)
                .disabled(blockReason != nil)
                if layout?.hasBackup == true {
                    Button(role: .destructive, action: onRestore) {
                        Label("Put the previous order back", systemImage: "arrow.uturn.backward")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                    }
                    .buttonStyle(.bordered)
                    .disabled(blockReason != nil)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .alert("Send this order to the TV?", isPresented: $confirmsApply) {
            Button("Send", action: onApply)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The launcher restarts to show it. The previous order stays saved on this iPhone so you can put it back.")
        }
    }

    private func appRow(_ package: String, first: Bool, last: Bool) -> some View {
        HStack(spacing: 14) {
            Text(TVAppNames.name(for: package)).font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
            Spacer()
            Button { onMove(package, -1) } label: { Image(systemName: "arrow.up") }
                .disabled(isWorking || first)
                .accessibilityLabel("Move \(TVAppNames.name(for: package)) earlier")
            Button { onMove(package, 1) } label: { Image(systemName: "arrow.down") }
                .disabled(isWorking || last)
                .accessibilityLabel("Move \(TVAppNames.name(for: package)) later")
            Button { onRemove(package) } label: { Image(systemName: "minus.circle") }
                .disabled(isWorking)
                .accessibilityLabel("Remove \(TVAppNames.name(for: package))")
        }
    }
}
