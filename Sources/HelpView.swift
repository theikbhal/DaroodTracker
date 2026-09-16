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
                        icon: "hand.tap.fill",
                        title: "Easy Count Mode",
                        description: "Big +1 button for eyes-closed counting",
                        color: .pink
                    ) {
                        selectedSection = .easyCount
                    }
                    
                    HelpSectionCard(
                        icon: "leaf.fill",
                        title: "Island Garden Game",
                        description: "Grow your island through counting",
                        color: .green
                    ) {
                        selectedSection = .islandGarden
                    }
                    
                    HelpSectionCard(
                        icon: "brain.head.profile",
                        title: "Focus Mode",
                        description: "Timer, micro-breaks, and idle detection",
                        color: .blue
                    ) {
                        selectedSection = .focusMode
                    }
                    
                    HelpSectionCard(
                        icon: "square.split.2x2",
                        title: "Split Batches (33/33/34)",
                        description: "Break each 100 into 3 smaller goals",
                        color: .orange
                    ) {
                        selectedSection = .splitBatches
                    }
                    
                    HelpSectionCard(
                        icon: "hand.raised.fill",
                        title: "Finger Counting",
                        description: "Count on your fingers for better focus",
                        color: .green
                    ) {
                        selectedSection = .fingerCounting
                    }
                    
                    HelpSectionCard(
                        icon: "hand.raised.fingers.spread",
                        title: "Finger Segments",
                        description: "Count using finger segments (3 per finger)",
                        color: .mint
                    ) {
                        selectedSection = .fingerSegments
                    }
                    
                    HelpSectionCard(
                        icon: "bell.badge.fill",
                        title: "Smart Notifications",
                        description: "Progress-aware reminders and alerts",
                        color: .purple
                    ) {
                        selectedSection = .smartNotifications
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
    case easyCount
    case islandGarden
    case focusMode
    case splitBatches
    case fingerCounting
    case fingerSegments
    case smartNotifications
    case dailyRoutine
    case progress
    case calendar
    case settings
    case faq
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .gettingStarted: return "Getting Started"
        case .easyCount: return "Easy Count Mode"
        case .islandGarden: return "Island Garden Game"
        case .focusMode: return "Focus Mode"
        case .splitBatches: return "Split Batches (33/33/34)"
        case .fingerCounting: return "Finger Counting"
        case .fingerSegments: return "Finger Segments"
        case .smartNotifications: return "Smart Notifications"
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
        case .easyCount:
            easyCountContent
        case .islandGarden:
            islandGardenContent
        case .focusMode:
            focusModeContent
        case .splitBatches:
            splitBatchesContent
        case .fingerCounting:
            fingerCountingContent
        case .fingerSegments:
            fingerSegmentsContent
        case .smartNotifications:
            smartNotificationsContent
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
    
    var easyCountContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What is Easy Count Mode?", content: "A big +1 button that's easy to click even with eyes closed")
            
            HelpTip(title: "When to Use", content: "Perfect for when you're using a mouse and want to count without looking at the screen")
            
            HelpTip(title: "How it Works", content: "A large circular button takes up most of the screen. Just click anywhere on it to add +1")
            
            HelpTip(title: "Visual Feedback", content: "The button pulses when clicked and shows the current count in big numbers")
            
            HelpTip(title: "Quick Actions", content: "Use +10 and +100 buttons at the bottom for larger increments")
            
            HelpTip(title: "Audio Feedback", content: "Each click plays a sound (if Button Sounds is enabled in Settings)")
            
            HelpTip(title: "Haptic Feedback", content: "You'll feel a vibration on each click for physical confirmation")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Easy Count Mode")
        }
    }
    
    var islandGardenContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What is Island Garden?", content: "An idle progression game where your island grows as you count darood")
            
            HelpTip(title: "How it Works", content: "Your island goes through 7 stages as you count from 0 to 1100")
            
            HelpTip(title: "Stage 1: Empty Island (0)", content: "Start with an empty island waiting for your first count")
            
            HelpTip(title: "Stage 2: Prepared Soil (100)", content: "The soil is ready for planting after 100 darood")
            
            HelpTip(title: "Stage 3: Planted Seed (200)", content: "A seed has been planted and is ready to grow")
            
            HelpTip(title: "Stage 4: Growing Sprout (400)", content: "The seed is sprouting! Watch it grow")
            
            HelpTip(title: "Stage 5: Mighty Tree (600)", content: "A beautiful tree has grown on your island")
            
            HelpTip(title: "Stage 6: Blooming Flowers (800)", content: "Flowers are blooming on the tree!")
            
            HelpTip(title: "Stage 7: Ripe Fruits (1000)", content: "Fruits are ripening and ready for harvest")
            
            HelpTip(title: "Stage 8: Harvest Time! (1100)", content: "Collect your rewards! Celebration animation plays")
            
            HelpTip(title: "Visual Elements", content: "Animated sun, clouds, water waves, and island progression")
            
            HelpTip(title: "Sound Effects", content: "Special sounds play when you reach new stages")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Island Garden Game")
        }
    }
    
    var focusModeContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What is Focus Mode?", content: "A timer-based tracking system that helps you stay on pace throughout the day")
            
            HelpTip(title: "Auto-Start", content: "Focus mode starts automatically when you open the app (toggle in Settings > Focus)")
            
            HelpTip(title: "Live Timer", content: "Shows elapsed time and your pace (darood per minute)")
            
            HelpTip(title: "Micro-Breaks", content: "After every 10 darood, a 10-second break appears with breathing animation. Take a deep breath!")
            
            HelpTip(title: "Batch Breaks", content: "After every 100 darood (1 batch), a 30-second break appears with stretch suggestions")
            
            HelpTip(title: "Idle Detection", content: "If you haven't counted for 2 minutes, a gentle reminder pops up")
            
            HelpTip(title: "Pace Tracking", content: "Shows if you're ahead, on track, or behind schedule for your daily goal")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Focus Mode Timer")
        }
    }
    
    var splitBatchesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What is Split Batches?", content: "Break each 100-darood batch into 3 smaller goals: 33 + 33 + 34")
            
            HelpTip(title: "Why Split?", content: "Smaller goals feel less overwhelming and give you more frequent wins")
            
            HelpTip(title: "How it Works", content: "Each batch shows 3 progress bars. Tap +33 to add to the current sub-goal")
            
            HelpTip(title: "Visual Progress", content: "Each sub-goal turns green when complete, showing your micro-progress")
            
            HelpTip(title: "When to Use", content: "Enable when you need smaller, more manageable goals to stay motivated")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Split Batches (33/33/34)")
        }
    }
    
    var fingerCountingContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What is Finger Counting?", content: "A visual counting method using two hands with 5 fingers each")
            
            HelpTip(title: "When to Use", content: "Perfect for when you're less focused and want to count physically on your fingers")
            
            HelpTip(title: "How it Works", content: "Each hand shows 5 fingers. Tap +1 to fill one finger. After 10, move to the next set")
            
            HelpTip(title: "Structure", content: "1100 total → 11 batches → 10 sets per batch → 10 counts per set → 5 fingers per hand")
            
            HelpTip(title: "Visual Cues", content: "Fingers light up as you count. Current batch and set are highlighted")
            
            HelpTip(title: "Quick Add", content: "Use +1 for single counts, +5 for one hand, +10 for both hands")
            
            HelpTip(title: "Batch Progress", content: "See all 11 batches with mini set indicators showing your progress")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Finger Counting Mode")
        }
    }
    
    var fingerSegmentsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What is Finger Segments?", content: "Most detailed counting method using 3 segments per finger (15 per hand)")
            
            HelpTip(title: "When to Use", content: "Best for medium ADHD - gives you the most granular counting experience")
            
            HelpTip(title: "How it Works", content: "Each finger has 3 segments (phalanges). Count fills segments from base to tip")
            
            HelpTip(title: "Structure", content: "1100 → 11 batches → 3 sub-goals (33/33/34) → 2 hands per sub-goal → 15 segments per hand")
            
            HelpTip(title: "33 Sub-Goal", content: "Uses 2 full hands (15+15) + 3 segments on first hand = 33")
            
            HelpTip(title: "34 Sub-Goal", content: "Uses 2 full hands (15+15) + 4 segments on first hand = 34")
            
            HelpTip(title: "Visual Cues", content: "Segments light up green when complete. Current sub-goal is highlighted")
            
            HelpTip(title: "Quick Add", content: "Use +1 for single segment, +15 for one hand, +33 for one sub-goal")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Finger Segments Mode")
        }
    }
    
    var smartNotificationsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "What are Smart Notifications?", content: "Progress-aware reminders that adapt to your counting pace")
            
            HelpTip(title: "Morning Reminder", content: "8 AM: Suggests starting with just 10 darood to build momentum")
            
            HelpTip(title: "Progress Checks", content: "Every 30 minutes: Shows exact pace with numbers (e.g., '150/1100 at 5/min')")
            
            HelpTip(title: "Idle Reminder", content: "After 2 minutes of no counting: Gentle nudge to get back on track")
            
            HelpTip(title: "Deadline Alerts", content: "4 PM: '2 hours left' | 5:30 PM: '30 min left!' | 6 PM: Deadline passed")
            
            HelpTip(title: "Goal Complete", content: "When you finish 1100: Celebration notification with 'Mashallah! 🎉'")
            
            HelpTip(title: "Notification Styles", content: "Choose Gentle, Moderate, or Silent in Settings > Focus > Notification Style")
            
            HelpTip(title: "How to Enable", content: "Go to Settings > Experiments > Smart Notifications")
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
            HelpTip(title: "Themes", content: "Choose from multiple color themes in Settings > Themes")
            HelpTip(title: "Reminders", content: "Enable/disable daily reminders and set preferred time in Settings > General")
            HelpTip(title: "Experiments", content: "Toggle features on/off in Settings > Experiments")
            HelpTip(title: "Data Export", content: "Export your tracking data as JSON, CSV, Markdown, or SQL in Settings > Data")
            HelpTip(title: "Reset", content: "Reset today's count or all data in Settings > Data > Reset")
            HelpTip(title: "Launch at Login", content: "Auto-start app when you log in (Settings > Startup > Launch at Login)")
            HelpTip(title: "Dock Icon", content: "Show/hide app in dock (Settings > Startup > Show in Dock)")
        }
    }
    
    var faqContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HelpTip(title: "Q: How do I reset today's count?", content: "Go to Settings > Data > Reset Today's Count")
            HelpTip(title: "Q: Can I change my daily target?", content: "Currently fixed at 1100. Future updates may allow customization.")
            HelpTip(title: "Q: Where is my data stored?", content: "All data is stored locally on your Mac using UserDefaults")
            HelpTip(title: "Q: How do I export my data?", content: "Go to Settings > Data > Export Data")
            HelpTip(title: "Q: Can I use this on multiple devices?", content: "Currently single-device only. iCloud sync is planned for future updates")
            HelpTip(title: "Q: What's the difference between Focus Mode and regular counting?", content: "Focus Mode adds timer, pace tracking, micro-breaks, and idle detection")
            HelpTip(title: "Q: Which counting mode should I use?", content: "Use Home for quick batch counting, Split for 33/33/34 goals, or Fingers for physical counting")
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
