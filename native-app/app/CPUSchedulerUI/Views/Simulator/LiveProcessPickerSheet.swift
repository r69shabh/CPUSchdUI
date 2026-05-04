import Foundation
import SwiftUI

struct LiveProcessPickerSheet: View {
    enum SortMode: String, CaseIterable, Identifiable {
        case cpu = "CPU"
        case memory = "Memory"
        case startTime = "Start Time"
        case name = "Name"
        case pid = "PID"

        var id: String { rawValue }
    }

    enum FilterScope: String, CaseIterable, Identifiable {
        case all = "All"
        case running = "Running"
        case currentUser = "My User"

        var id: String { rawValue }
    }

    @EnvironmentObject private var liveStore: LiveProcessWhatIfStore
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var sortMode: SortMode = .cpu
    @State private var filterScope: FilterScope = .all
    @State private var showSelectedOnly = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            controls
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            if filteredAndSorted.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(filteredAndSorted) { process in
                            LiveProcessPickerRow(
                                process: process,
                                isTopPrefill: topPrefillPIDs.contains(process.pid)
                            ) { isSelected in
                                liveStore.setSelection(pid: process.pid, isSelected: isSelected)
                            }
                        }
                    }
                    .padding(12)
                }
            }

            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Text("Visible \(filteredAndSorted.count) • Selected \(liveStore.all.filter(\.isSelected).count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
            .padding(16)
        }
        .frame(width: 760, height: 620)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Select Live Processes")
                    .font(.title2.bold())
                Text("Choose a process set for what-if scheduling. Top CPU processes are preselected on first snapshot.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Text("Snapshot scope: all processes (system + user).")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Prefill: top 12 active.")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }

    private var controls: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                TextField("Search by name, user, or PID", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)

                Picker("Scope", selection: $filterScope) {
                    ForEach(FilterScope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 250)

                Picker("Sort", selection: $sortMode) {
                    ForEach(SortMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 130)

                Button {
                    liveStore.refreshNow()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack(spacing: 8) {
                Toggle("Selected only", isOn: $showSelectedOnly)
                    .toggleStyle(.checkbox)
                    .font(.caption)

                Button("Top 12") {
                    liveStore.selectTopPrefill()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Select All") {
                    liveStore.selectAll()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Select Visible") {
                    setVisibleSelection(true)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(filteredAndSorted.isEmpty)

                Button("Clear") {
                    liveStore.clearSelection()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Clear Visible") {
                    setVisibleSelection(false)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(filteredAndSorted.isEmpty)

                Spacer()

                if let meta = liveStore.lastSnapshot {
                    Text("Snapshot: \(meta.capturedAt, format: Date.FormatStyle(date: .omitted, time: .standard))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var filteredAndSorted: [LiveProcessCandidate] {
        let base = liveStore.all.filter { process in
            if showSelectedOnly && !process.isSelected {
                return false
            }

            if !matchesScope(process) {
                return false
            }

            guard !searchText.isEmpty else {
                return true
            }
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty {
                return true
            }

            let lower = query.lowercased()
            return process.name.lowercased().contains(lower)
                || process.user.lowercased().contains(lower)
                || String(process.pid).contains(lower)
        }

        switch sortMode {
        case .cpu:
            return base.sorted {
                if $0.cpuUsage == $1.cpuUsage {
                    return $0.pid < $1.pid
                }
                return $0.cpuUsage > $1.cpuUsage
            }
        case .memory:
            return base.sorted {
                if $0.memoryMB == $1.memoryMB {
                    return $0.pid < $1.pid
                }
                return $0.memoryMB > $1.memoryMB
            }
        case .startTime:
            return base.sorted {
                if $0.startTimeEpochMS == $1.startTimeEpochMS {
                    return $0.pid < $1.pid
                }
                return $0.startTimeEpochMS < $1.startTimeEpochMS
            }
        case .name:
            return base.sorted {
                if $0.name == $1.name {
                    return $0.pid < $1.pid
                }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .pid:
            return base.sorted { $0.pid < $1.pid }
        }
    }

    private func matchesScope(_ process: LiveProcessCandidate) -> Bool {
        switch filterScope {
        case .all:
            return true
        case .running:
            return process.state.localizedCaseInsensitiveContains("running")
        case .currentUser:
            return process.user == NSUserName()
        }
    }

    private func setVisibleSelection(_ isSelected: Bool) {
        for process in filteredAndSorted {
            liveStore.setSelection(pid: process.pid, isSelected: isSelected)
        }
    }

    private var topPrefillPIDs: Set<Int> {
        Set(
            liveStore.all
                .sorted {
                    if $0.cpuUsage != $1.cpuUsage {
                        return $0.cpuUsage > $1.cpuUsage
                    }
                    if $0.memoryMB != $1.memoryMB {
                        return $0.memoryMB > $1.memoryMB
                    }
                    return $0.pid < $1.pid
                }
                .prefix(12)
                .map(\.pid)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)

            Text("No matching processes")
                .font(.headline)

            Text("Try a different query or refresh the snapshot.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LiveProcessPickerRow: View {
    let process: LiveProcessCandidate
    let isTopPrefill: Bool
    let onSelectionChanged: (Bool) -> Void

    @State private var showSelectionReason = false
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Toggle(
                "",
                isOn: Binding(
                    get: { process.isSelected },
                    set: { newValue in
                        onSelectionChanged(newValue)
                    }
                )
            )
            .toggleStyle(.checkbox)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(process.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text("PID \(process.pid)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)

                    if isTopPrefill {
                        Text("Top 12")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.12))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 8) {
                    statBadge("CPU \(String(format: "%.1f%%", process.cpuUsage))", color: .red)
                    statBadge("Mem \(String(format: "%.0f MB", process.memoryMB))", color: .purple)
                    statBadge("Thr \(process.threads)", color: .teal)
                    statBadge("Burst~\(estimatedBurst)", color: .orange)
                    statBadge("Pri~\(mappedPriority)", color: .blue)
                    statBadge(process.state, color: process.state.localizedCaseInsensitiveContains("running") ? .green : .gray)
                    statBadge(process.user, color: .indigo)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showSelectionReason = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showSelectionReason, arrowEdge: .leading) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selection Guidance")
                        .font(.headline)
                    Text("Top-12 prefill is based on highest CPU, then memory, then PID.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("You can override the prefill; your choices stay pinned by PID across refreshes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 280)
                .padding(12)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(process.isSelected ? Color.accentColor.opacity(0.35) : .clear, lineWidth: 1)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }

    private var estimatedBurst: Int {
        let cpuTerm = Int((process.cpuUsage / 4.0).rounded(.up))
        let threadTerm = min(process.threads, 8) / 2
        return max(1, min(25, cpuTerm + threadTerm))
    }

    private var mappedPriority: Int {
        let clampedNice = max(-20, min(20, process.nice))
        return 1 + ((clampedNice + 20) * 9) / 40
    }

    private var rowBackground: some ShapeStyle {
        if process.isSelected {
            return AnyShapeStyle(Color(nsColor: .controlBackgroundColor).opacity(0.95))
        }
        if isHovered {
            return AnyShapeStyle(Color(nsColor: .controlBackgroundColor).opacity(0.75))
        }
        return AnyShapeStyle(Color(nsColor: .controlBackgroundColor).opacity(0.45))
    }

    private func statBadge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
