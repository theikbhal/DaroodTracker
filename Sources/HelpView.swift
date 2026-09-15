import SwiftUI

struct HelpView: View {
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection: HelpSection?
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Help & Tips")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            
            Divider()
            
            // Help sections
            ScrollView {
                VStack(spacing: 12) {
                    HelpSectionCard(
                        icon: "star.fill",
                        title: "Getting Started",
                        description: "Learn the basics of tracking your darood",
                        color: theme.currentTheme.accentColor
                    ) {
                        selectedSection = .gettingStarted
                    }
                    
                    HelpSectionCard(
                        icon: "target",
                        title: "Daily Routine",
                        description: "How to complete your daily 1100 target",
                        color: .orange
                    ) {
                        selectedSection = .dailyRoutine
                    }
                    
                    HelpSectionCard(
                        icon: "chart.bar.fill",
                        title: "Understanding Progress",
                        description: "Read your stats and streaks",
                        color: .green
                    ) {
                        selectedSection = .progress
                    }
                    
                    HelpSectionCard(
                        icon: "calendar",
                        title: "Calendar Views",
                        description: "Navigate day, week, month, year views",
                        color: .purple
                    ) {
                        selectedSection = .calendar
                    }
                    
                    HelpSectionCard(
                        icon: "gearshape.fill",
                        title: "Settings & Experiments",
                        description: "Customize your experience",
                        color: .gray
                    ) {
                        selectedSection = .settings
                    }
                    
                    HelpSectionCard(
                        icon: "questionmark.circle.fill",
                        title: "FAQ",
                        description: "Frequently asked questions",
                        color: .cyan
                    ) {
                        selectedSection = .faq
                    }
                }
            }
        }
        .padding()
        .frame(width: 450, height: 500)
        .sheet(item: $selectedSection) { section in
            HelpDetailView(section: section)
                .environmentObject(theme)
        }
    }
}

enum HelpSection: String, CaseIterable, Identifiable {
    case gettingStarted
    case dailyRoutine
    case progress
    case calendar
    case settings
    case faq
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .gettingStarted: return "Getting Started"
        case .dailyRoutine: return "Daily Routine"
        case .progress: return "Understanding Progress"
        case .calendar: return "Calendar Views"
        case .settings: return "Settings & Experiments"
        case .faq: return "FAQ"
        }
    }
}

struct HelpSectionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct HelpDetailView: View {
    let section: HelpSection
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(section.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    contentForSection
                }
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
    
    @ViewBuilder
    var contentForSection: some View {
        switch section {
        case .gettingStarted:
            gettingStartedContent
        case .dailyRoutine:
            dailyRoutineContent
        case .progress:
            progressContent
        case .calendar:
            calendarContent
        case .settings:
            settingsContent
        case .faq:
            faqContent
        }
    }
    
    var gettingStartedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "1. Menu Bar Access", content: "Click the star icon in the menu bar to open the tracker")
            HelpTip(title: "2. Add Counts", content: "Use the batch buttons to add 100 darood at a time, or use +1/+10/+50 for smaller increments")
            HelpTip(title: "3. Track Progress", content: "Watch the circular progress ring fill up as you complete your daily target")
            HelpTip(title: "4. View Calendar", content: "Click 'Calendar' to see your daily, weekly, monthly, and yearly progress")
            HelpTip(title: "5. Stay Consistent", content: "Build streaks by completing your target every day before 6 PM")
        }
    }
    
    var dailyRoutineContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "Morning", content: "Check your streak and plan your sessions")
            HelpTip(title: "Session 1", content: "Complete 100 darood (Batch 1)")
            HelpTip(title: "5-minute break", content: "Take a short break")
            HelpTip(title: "Session 2", content: "Complete another 100 darood")
            HelpTip(title: "Repeat", content: "Continue until you reach 1100 (11 batches)")
            HelpTip(title: "Evening", content: "Complete remaining batches before 6 PM")
        }
    }
    
    var progressContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "Progress Ring", content: "Shows your completion percentage for today")
            HelpTip(title: "Batch Count", content: "Tracks how many 100-darood batches you've completed (1-11)")
            HelpTip(title: "Remaining", content: "Shows how many darood you still need to complete")
            HelpTip(title: "Streaks", content: "Current streak = consecutive days completed. Longest streak = your record")
        }
    }
    
    var calendarContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "Day View", content: "See detailed stats and sessions for a specific day")
            HelpTip(title: "Week View", content: "Overview of the current week with daily progress")
            HelpTip(title: "Month View", content: "Monthly calendar showing completion status")
            HelpTip(title: "Year View", content: "Annual summary with monthly breakdowns")
        }
    }
    
    var settingsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "Themes", content: "Choose from multiple color themes in Settings")
            HelpTip(title: "Reminders", content: "Enable/disable daily reminders and set preferred time")
            HelpTip(title: "Experiments", content: "Toggle features on/off in the Experiments section")
            HelpTip(title: "Data Export", content: "Export your tracking data as JSON")
            HelpTip(title: "Reset", content: "Reset today's count or all data")
        }
    }
    
    var faqContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "Q: How do I reset today's count?", content: "Go to Settings > Data > Reset Today's Count")
            HelpTip(title: "Q: Can I change my daily target?", content: "Currently fixed at 1100. Future updates may allow customization.")
            HelpTip(title: "Q: Where is my data stored?", content: "All data is stored locally on your Mac using UserDefaults")
            HelpTip(title: "Q: How do I export my data?", content: "Go to Settings > Data > Export Data")
            HelpTip(title: "Q: Can I use this on multiple devices?", content: "Currently single-device only. iCloud sync is planned for future updates")
        }
    }
}

struct HelpTip: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
