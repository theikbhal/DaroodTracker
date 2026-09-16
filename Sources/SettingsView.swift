import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @Environment(\.dismiss) var dismiss
    @StateObject var launchAtLogin = LaunchAtLoginManager()
    @AppStorage("reminderEnabled") private var reminderEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("showInDock") private var showInDock = false
    @AppStorage("focusModeEnabled") private var focusModeEnabled = true
    @AppStorage("autoStartFocus") private var autoStartFocus = true
    @AppStorage("microBreakAfterCount") private var microBreakAfterCount = 10
    @AppStorage("microBreakDuration") private var microBreakDuration = 10
    @AppStorage("batchBreakDuration") private var batchBreakDuration = 30
    @AppStorage("idleDetectionEnabled") private var idleDetectionEnabled = true
    @AppStorage("idleThresholdSeconds") private var idleThresholdSeconds = 120
    @AppStorage("adaptiveNotificationsEnabled") private var adaptiveNotificationsEnabled = true
    @AppStorage("notificationStyle") private var notificationStyle = "gentle"
    @AppStorage("progressCheckInterval") private var progressCheckInterval = 30
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled = true
    @AppStorage("deadlineReminderEnabled") private var deadlineReminderEnabled = true
    @AppStorage("idleReminderEnabled") private var idleReminderEnabled = true
    @AppStorage("showFloatingButton") private var showFloatingButton = false
    
    @State private var selectedTab = "focus"
    @State private var showResetConfirm = false
    @State private var resetType: ResetType = .today
    @State private var showExportSheet = false
    
    private let hourRange = 0...23
    private let minuteRange = 0...59
    
    enum ResetType: String {
        case today = "Today"
        case all = "All Data"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
            }
            
            // Tab selector
            Picker("Tab", selection: $selectedTab) {
                Text("Focus").tag("focus")
                Text("Startup").tag("startup")
                Text("General").tag("general")
                Text("Themes").tag("themes")
                Text("Experiments").tag("experiments")
                Text("Data").tag("data")
            }
            .pickerStyle(.segmented)
            
            Divider()
            
            // Content
            ScrollView {
                switch selectedTab {
                case "focus":
                    focusSettings
                case "startup":
                    startupSettings
                case "general":
                    generalSettings
                case "themes":
                    themeSettings
                case "experiments":
                    experimentsSettings
                case "data":
                    dataSettings
                default:
                    focusSettings
                }
            }
        }
        .padding()
        .frame(width: 420, height: 520)
        .alert("Reset \(resetType.rawValue)?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                switch resetType {
                case .today:
                    store.resetToday()
                case .all:
                    store.resetAll()
                }
            }
        } message: {
            if resetType == .all {
                Text("This cannot be undone. All your darood records will be permanently deleted.")
            } else {
                Text("This will reset today's count to zero.")
            }
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet()
                .environmentObject(store)
        }
    }
    
    // MARK: - Focus Settings
    
    var focusSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Focus Mode") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Focus Mode", isOn: $focusModeEnabled)
                    
                    if focusModeEnabled {
                        Toggle("Auto-start on app open", isOn: $autoStartFocus)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("Micro-Breaks") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Micro-Breaks", isOn: Binding(
                        get: { experiments.isEnabled("microBreaks") },
                        set: { _ in experiments.toggle("microBreaks") }
                    ))
                    
                    if experiments.isEnabled("microBreaks") {
                        HStack {
                            Text("Break after every:")
                            Picker("", selection: $microBreakAfterCount) {
                                Text("5 darood").tag(5)
                                Text("10 darood").tag(10)
                                Text("15 darood").tag(15)
                                Text("20 darood").tag(20)
                            }
                            .frame(width: 120)
                        }
                        
                        HStack {
                            Text("Break duration:")
                            Picker("", selection: $microBreakDuration) {
                                Text("5 sec").tag(5)
                                Text("10 sec").tag(10)
                                Text("15 sec").tag(15)
                                Text("30 sec").tag(30)
                                Text("1 min").tag(60)
                            }
                            .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Batch break:")
                            Picker("", selection: $batchBreakDuration) {
                                Text("15 sec").tag(15)
                                Text("30 sec").tag(30)
                                Text("1 min").tag(60)
                                Text("2 min").tag(120)
                            }
                            .frame(width: 100)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("Idle Detection") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Detect idle time", isOn: $idleDetectionEnabled)
                    
                    if idleDetectionEnabled {
                        HStack {
                            Text("Notify after:")
                            Picker("", selection: $idleThresholdSeconds) {
                                Text("1 min").tag(60)
                                Text("2 min").tag(120)
                                Text("5 min").tag(300)
                                Text("10 min").tag(600)
                            }
                            .frame(width: 100)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("Adaptive Notifications") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Smart Notifications", isOn: $adaptiveNotificationsEnabled)
                    
                    if adaptiveNotificationsEnabled {
                        Picker("Style", selection: $notificationStyle) {
                            Text("Gentle").tag("gentle")
                            Text("Moderate").tag("moderate")
                            Text("Silent").tag("silent")
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text("Check progress every:")
                            Picker("", selection: $progressCheckInterval) {
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                                Text("1 hour").tag(60)
                            }
                            .frame(width: 100)
                        }
                        
                        Toggle("Morning reminder (8 AM)", isOn: $morningReminderEnabled)
                        Toggle("Deadline reminder (4 PM)", isOn: $deadlineReminderEnabled)
                        Toggle("Idle reminder", isOn: $idleReminderEnabled)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Startup Settings
    
    var startupSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Launch") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Launch at login", isOn: Binding(
                        get: { launchAtLogin.isEnabled },
                        set: { _ in launchAtLogin.toggle() }
                    ))
                    
                    if let status = launchAtLogin.statusDescription {
                        Text(status)
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Button("Open System Settings") {
                            launchAtLogin.openLoginItemsSettings()
                        }
                        .font(.caption)
                    }
                    
                    Toggle("Show in Dock", isOn: $showInDock)
                        .onChange(of: showInDock) { _, newValue in
                            toggleDockIcon(show: newValue)
                        }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("Floating Button") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Show Floating Button", isOn: $showFloatingButton)
                        .onChange(of: showFloatingButton) { _, newValue in
                            if newValue {
                                FloatingWindowManager.shared.showFloatingButton()
                            } else {
                                FloatingWindowManager.shared.hideFloatingButton()
                            }
                        }
                    
                    if showFloatingButton {
                        Text("✓ Floating button is now visible on screen")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("• Drag to move anywhere")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• Click +1 to count darood")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• Click X to close")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("Notifications Permission") {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Request Notification Permission") {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                    }
                    
                    Button("Open Notification Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
                    }
                    .font(.caption)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - General Settings
    
    var generalSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Reminders") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Daily Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        HStack {
                            Text("Reminder Time:")
                            Picker("Hour", selection: $reminderHour) {
                                ForEach(hourRange, id: \.self) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .frame(width: 60)
                            
                            Text(":")
                            
                            Picker("Minute", selection: $reminderMinute) {
                                ForEach(minuteRange, id: \.self) { minute in
                                    Text(String(format: "%02d", minute)).tag(minute)
                                }
                            }
                            .frame(width: 60)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("Appearance") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Show in Dock", isOn: $showInDock)
                        .onChange(of: showInDock) { _, newValue in
                            toggleDockIcon(show: newValue)
                        }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    var themeSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Theme")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(AppTheme.allCases) { themeOption in
                    ThemeCard(theme: themeOption, isSelected: theme.currentTheme == themeOption)
                }
            }
        }
    }
    
    var experimentsSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Toggle Features")
                .font(.headline)
            
            Text("Enable or disable experimental features")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(experiments.availableExperiments) { experiment in
                HStack {
                    VStack(alignment: .leading) {
                        Text(experiment.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(experiment.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { experiments.isEnabled(experiment.id) },
                        set: { _ in experiments.toggle(experiment.id) }
                    ))
                    .labelsHidden()
                }
                .padding(.vertical, 4)
            }
            
            Button("Reset All Experiments") {
                experiments.resetAll()
            }
            .foregroundColor(.red)
        }
    }
    
    var dataSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Reset
            GroupBox("Reset") {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Reset Today's Count") {
                        resetType = .today
                        showResetConfirm = true
                    }
                    .foregroundColor(.orange)
                    
                    Divider()
                    
                    Button("Reset All Data") {
                        resetType = .all
                        showResetConfirm = true
                    }
                    .foregroundColor(.red)
                }
                .padding(.vertical, 8)
            }
            
            // Export
            GroupBox("Export Data") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export your tracking data in various formats")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showExportSheet = true }) {
                        Label("Export...", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 8)
            }
            
            // Stats
            GroupBox("Statistics") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Total Days Tracked:")
                        Spacer()
                        Text("\(store.records.count)")
                    }
                    
                    HStack {
                        Text("Total Darood:")
                        Spacer()
                        Text("\(store.records.values.reduce(0) { $0 + $1.totalCount })")
                    }
                    
                    HStack {
                        Text("Days Completed:")
                        Spacer()
                        Text("\(store.records.values.filter { $0.isComplete }.count)")
                    }
                    
                    HStack {
                        Text("Current Streak:")
                        Spacer()
                        Text("\(store.currentStreak) days")
                    }
                    
                    HStack {
                        Text("Longest Streak:")
                        Spacer()
                        Text("\(store.longestStreak) days")
                    }
                    
                    HStack {
                        Text("Join Date:")
                        Spacer()
                        Text(profile.profile.joinDate, style: .date)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    func toggleDockIcon(show: Bool) {
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

// MARK: - Export Sheet

struct ExportSheet: View {
    @EnvironmentObject var store: DaroodStore
    @Environment(\.dismiss) var dismiss
    
    enum ExportFormat: String, CaseIterable, Identifiable {
        case json = "JSON"
        case csv = "CSV"
        case markdown = "Markdown"
        case sql = "SQL"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .json: return "doc.text"
            case .csv: return "tablecells"
            case .markdown: return "doc.richtext"
            case .sql: return "externaldrive"
            }
        }
        
        var description: String {
            switch self {
            case .json: return "Structured data, easy to import"
            case .csv: return "Spreadsheet compatible"
            case .markdown: return "Formatted for reading"
            case .sql: return "Database with schema"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csv: return "csv"
            case .markdown: return "md"
            case .sql: return "sql"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Export Data")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            
            Divider()
            
            Text("Choose a format to export your darood tracking data")
                .font(.callout)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(ExportFormat.allCases) { format in
                    ExportFormatCard(format: format) {
                        export(format: format)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 450)
    }
    
    func export(format: ExportFormat) {
        let content: String
        
        switch format {
        case .json:
            content = store.exportJSON() ?? "{}"
        case .csv:
            content = store.exportCSV()
        case .markdown:
            content = store.exportMarkdown()
        case .sql:
            content = store.exportSQL()
        }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: format.fileExtension) ?? .plainText]
        panel.nameFieldStringValue = "darood_tracker.\(format.fileExtension)"
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                try? content.write(to: url, atomically: true, encoding: .utf8)
                dismiss()
            }
        }
    }
}

struct ExportFormatCard: View {
    let format: ExportSheet.ExportFormat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: format.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(format.rawValue)
                        .font(.headline)
                    
                    Text(format.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            themeManager.setTheme(theme)
        }) {
            VStack(spacing: 8) {
                HStack {
                    ForEach(theme.gradientColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                    }
                }
                
                Text(theme.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? theme.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
