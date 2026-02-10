import SwiftUI

@main
struct CPUSchedulerUIApp: App {
    @StateObject private var preferences = PreferencesService()

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(preferences)
                .frame(minWidth: 1100, minHeight: 700)
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
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newSimulation = Notification.Name("newSimulation")
    static let exportResults = Notification.Name("exportResults")
    static let loadScenario = Notification.Name("loadScenario")
}
