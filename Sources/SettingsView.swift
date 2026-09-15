import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("reminderEnabled") private var reminderEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("showInDock") private var showInDock = false
    
    @State private var selectedTab = "general"
    
    private let hourRange = 0...23
    private let minuteRange = 0...59
    
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
                case "general":
                    generalSettings
                case "themes":
                    themeSettings
                case "experiments":
                    experimentsSettings
                case "data":
                    dataSettings
                default:
                    generalSettings
                }
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    var generalSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Reminder Settings
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
            
            // Appearance
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
                        store.resetToday()
                    }
                    .foregroundColor(.red)
                }
                .padding(.vertical, 8)
            }
            
            // Export
            GroupBox("Export") {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Export Data") {
                        exportData()
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Stats
            GroupBox("Statistics") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Total Records:")
                        Spacer()
                        Text("\(store.records.count)")
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
    
    func exportData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(store.records),
           let json = String(data: data, encoding: .utf8) {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "darood_tracker_export.json"
            
            panel.begin { result in
                if result == .OK, let url = panel.url {
                    try? json.write(to: url, atomically: true, encoding: .utf8)
                }
            }
        }
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
