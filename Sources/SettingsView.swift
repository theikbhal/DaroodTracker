import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: DaroodStore
    @Environment(\.dismiss) var dismiss
    @AppStorage("reminderEnabled") private var reminderEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("showInDock") private var showInDock = false
    
    private let hourRange = 0...23
    private let minuteRange = 0...59
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            Divider()
            
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
            
            // Data Management
            GroupBox("Data") {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Reset Today's Count") {
                        store.resetToday()
                    }
                    .foregroundColor(.red)
                    
                    Button("Export Data") {
                        exportData()
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            // App Info
            VStack(spacing: 4) {
                Text("Darood Tracker v1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Daily Target: \(store.dailyTarget)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 350, height: 450)
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
