import SwiftUI

@main
struct CPUSchedulerUIApp: App {
    @StateObject private var preferences = PreferencesService()
    @StateObject private var liveProcessStore = LiveProcessWhatIfStore()

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(preferences)
                .environmentObject(liveProcessStore)
                .frame(minWidth: 1100, minHeight: 700)
                .onAppear {
                    liveProcessStore.configure(
                        autoRefreshEnabled: preferences.liveWhatIfAutoRefreshEnabled,
                        refreshIntervalSeconds: preferences.liveWhatIfRefreshIntervalSeconds
                    )
                }
                .onChange(of: preferences.liveWhatIfAutoRefreshEnabled) { _, newValue in
                    liveProcessStore.autoRefreshEnabled = newValue
                }
                .onChange(of: preferences.liveWhatIfRefreshIntervalSeconds) { _, newValue in
                    liveProcessStore.refreshIntervalSeconds = newValue
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1400, height: 900)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Simulation") {
                    NotificationCenter.default.post(name: .newSimulation, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(after: .importExport) {
                Button("Export Results...") {
                    NotificationCenter.default.post(name: .exportResults, object: nil)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])

                Divider()

                Button("Load Example Scenario...") {
                    NotificationCenter.default.post(name: .loadScenario, object: nil)
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(preferences)
                .environmentObject(liveProcessStore)
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newSimulation = Notification.Name("newSimulation")
    static let exportResults = Notification.Name("exportResults")
    static let loadScenario = Notification.Name("loadScenario")
}
