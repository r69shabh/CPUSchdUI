import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var preferences: PreferencesService
    @EnvironmentObject var liveProcessStore: LiveProcessWhatIfStore

    private let liveRefreshOptions: [Double] = [2, 5, 10]

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
        .frame(width: 500, height: 420)
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
                Toggle("Show learning coach panels", isOn: $preferences.showLearningCoach)
            }

            Section("Live Snapshot What-If") {
                Toggle("Enable auto-refresh for live what-if", isOn: Binding(
                    get: { preferences.liveWhatIfAutoRefreshEnabled },
                    set: { newValue in
                        preferences.liveWhatIfAutoRefreshEnabled = newValue
                        liveProcessStore.autoRefreshEnabled = newValue
                    }
                ))

                Picker("Refresh Interval", selection: Binding(
                    get: { preferences.liveWhatIfRefreshIntervalSeconds },
                    set: { newValue in
                        preferences.liveWhatIfRefreshIntervalSeconds = newValue
                        liveProcessStore.refreshIntervalSeconds = newValue
                    }
                )) {
                    ForEach(liveRefreshOptions, id: \.self) { option in
                        Text("\(Int(option)) seconds").tag(option)
                    }
                }
                .disabled(!preferences.liveWhatIfAutoRefreshEnabled)

                Text("Applies to Simulator and Comparison live snapshot mode.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
