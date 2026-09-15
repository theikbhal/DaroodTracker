import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @EnvironmentObject var subGoals: SubGoalManager
    @State private var showCalendar = false
    @State private var showSettings = false
    @State private var showHelp = false
    @State private var showProfile = false
    @State private var showSubGoals = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HeaderView()
            
            // Progress Ring
            ProgressRingView()
            
            // Batch Buttons
            BatchButtonsView()
            
            // Quick Actions
            HStack(spacing: 12) {
                if experiments.isEnabled("subgoals") {
                    Button(action: { showSubGoals = true }) {
                        Label("Subgoals", systemImage: "target")
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: { showCalendar = true }) {
                    Label("Calendar", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
            }
            
            HStack(spacing: 12) {
                if experiments.isEnabled("profile") {
                    Button(action: { showProfile = true }) {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .buttonStyle(.bordered)
                }
                
                if experiments.isEnabled("help") {
                    Button(action: { showHelp = true }) {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: { showSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
            }
            
            // Streak Info
            if experiments.isEnabled("streaks") {
                StreakView()
            }
        }
        .padding()
        .frame(width: 320)
        .sheet(isPresented: $showCalendar) {
            CalendarView()
                .environmentObject(store)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
                .environmentObject(experiments)
                .environmentObject(theme)
                .environmentObject(profile)
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
                .environmentObject(theme)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(store)
                .environmentObject(profile)
                .environmentObject(theme)
        }
        .sheet(isPresented: $showSubGoals) {
            SubGoalsView()
                .environmentObject(store)
                .environmentObject(subGoals)
                .environmentObject(theme)
                .environmentObject(experiments)
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var profile: ProfileManager
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(profile.profile.avatarEmoji)
                    .font(.title2)
                
                Text("Darood Tracker")
                    .font(.headline)
            }
            
            Text(Date(), style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Progress Ring

struct ProgressRingView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: store.todayProgress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: theme.currentTheme.progressGradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: store.todayProgress)
            
            // Center text
            VStack(spacing: 2) {
                Text("\(store.todayTotalCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("/ \(store.dailyTarget)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(store.todayRemaining) remaining")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .frame(width: 120, height: 120)
    }
}

// MARK: - Batch Buttons

struct BatchButtonsView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var experiments: ExperimentsManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Batches (100 each)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(1...11, id: \.self) { batch in
                    BatchButton(batch: batch)
                }
            }
        }
    }
}

struct BatchButton: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var experiments: ExperimentsManager
    let batch: Int
    
    var isCompleted: Bool {
        store.completedBatches >= batch
    }
    
    var body: some View {
        Button(action: {
            if !isCompleted {
                store.addCount(100)
                SoundManager.shared.play(.batchComplete)
                SoundManager.shared.playHaptic()
                
                if store.completedBatches == batch {
                    CelebrationManager.shared.celebrateBatch(batch)
                }
            }
        }) {
            VStack(spacing: 2) {
                Text("\(batch)")
                    .font(.system(size: 14, weight: .bold))
                Text("100")
                    .font(.caption2)
            }
            .frame(width: 60, height: 40)
            .background(isCompleted ? Color.green.opacity(0.3) : theme.currentTheme.accentColor.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCompleted ? .green : theme.currentTheme.accentColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }
}

// MARK: - Streak View

struct StreakView: View {
    @EnvironmentObject var store: DaroodStore
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(store.currentStreak)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Current Streak")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 30)
            
            VStack {
                Text("\(store.longestStreak)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Longest Streak")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
