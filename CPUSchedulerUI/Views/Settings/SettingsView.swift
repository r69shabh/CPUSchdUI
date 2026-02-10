import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var preferences: PreferencesService

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            displaySettings
                .tabItem {
                    Label("Display", systemImage: "paintbrush")
                }
        }
        .frame(width: 450, height: 300)
    }

    private var generalSettings: some View {
        Form {
            Section("Simulation Defaults") {
                Picker("Default Algorithm", selection: $preferences.defaultAlgorithmID) {
                    ForEach(AlgorithmInfo.all) { algo in
                        Text(algo.name).tag(algo.id)
                    }
                }

                Stepper("Default Time Quantum: \(preferences.defaultQuantum)", value: $preferences.defaultQuantum, in: 1...20)

                Toggle("Auto-run on parameter change", isOn: $preferences.autoRunOnChange)
            }

            Section("Interface") {
                Toggle("Show tooltips", isOn: $preferences.showTooltips)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var displaySettings: some View {
        Form {
            Section("Animations") {
                Toggle("Enable animations", isOn: $preferences.showAnimations)
            }

            Section("Gantt Chart") {
                Slider(value: $preferences.ganttChartHeight, in: 200...500, step: 50) {
                    Text("Chart Height: \(Int(preferences.ganttChartHeight))px")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
