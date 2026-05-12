import SwiftUI
import Combine

// MARK: - Preferences Service
class PreferencesService: ObservableObject {
    @AppStorage("showAnimations") var showAnimations: Bool = true
    @AppStorage("defaultQuantum") var defaultQuantum: Int = 4
    @AppStorage("defaultAlgorithmID") var defaultAlgorithmID: String = "fcfs"
    @AppStorage("autoRunOnChange") var autoRunOnChange: Bool = false
    @AppStorage("showTooltips") var showTooltips: Bool = true
    @AppStorage("showLearningCoach") var showLearningCoach: Bool = true
    @AppStorage("ganttChartHeight") var ganttChartHeight: Double = 300
    @AppStorage("liveWhatIfAutoRefreshEnabled") var liveWhatIfAutoRefreshEnabled: Bool = false
    @AppStorage("liveWhatIfRefreshIntervalSeconds") var liveWhatIfRefreshIntervalSeconds: Double = 5.0

    var defaultAlgorithm: AlgorithmInfo {
        AlgorithmInfo.all.first { $0.id == defaultAlgorithmID } ?? AlgorithmInfo.all[0]
    }
}
