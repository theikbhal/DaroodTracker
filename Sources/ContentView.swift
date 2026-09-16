import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @EnvironmentObject var subGoals: SubGoalManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @State private var showOnboarding = false
    @State private var selectedTab: AppTab = .home
    @State private var showResetConfirm = false
    
    enum AppTab: String, CaseIterable {
        case home = "Home"
        case focus = "Focus"
        case splitBatches = "Split"
        case calendar = "Calendar"
        case subgoals = "Subgoals"
        case profile = "Profile"
        case settings = "Settings"
        case help = "Help"
    }
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .environmentObject(store)
                    .environmentObject(experiments)
                    .environmentObject(theme)
                    .environmentObject(profile)
            } else {
                mainApp
            }
        }
        .onAppear {
            showOnboarding = experiments.isEnabled("onboarding")
        }
    }
    
    var mainApp: some View {
        NavigationSplitView {
            // Sidebar
            List(AppTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: iconFor(tab))
            }
            .navigationSplitViewColumnWidth(min: 140, ideal: 160)
        } detail: {
            // Detail
            switch selectedTab {
            case .home:
                HomeView(selectedTab: $selectedTab)
            case .focus:
                FocusModeView()
                    .environmentObject(store)
                    .environmentObject(theme)
                    .environmentObject(focusManager)
            case .splitBatches:
                SplitBatchView()
                    .environmentObject(store)
                    .environmentObject(theme)
                    .environmentObject(focusManager)
                    .environmentObject(experiments)
            case .calendar:
                CalendarView()
                    .environmentObject(store)
                    .environmentObject(theme)
            case .subgoals:
                SubGoalsView()
                    .environmentObject(store)
                    .environmentObject(subGoals)
                    .environmentObject(theme)
                    .environmentObject(experiments)
            case .profile:
                ProfileView()
                    .environmentObject(store)
                    .environmentObject(profile)
                    .environmentObject(theme)
            case .settings:
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(experiments)
                    .environmentObject(theme)
                    .environmentObject(profile)
            case .help:
                HelpView()
                    .environmentObject(theme)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showResetConfirm) {
            // Reset confirmation handled in HomeView
        }
    }
    
    func iconFor(_ tab: AppTab) -> String {
        switch tab {
        case .home: return "house.fill"
        case .focus: return "brain.head.profile"
        case .splitBatches: return "square.split.2x2"
        case .calendar: return "calendar"
        case .subgoals: return "target"
        case .profile: return "person.circle"
        case .settings: return "gear"
        case .help: return "questionmark.circle"
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    @Binding var selectedTab: ContentView.AppTab
    @State private var showResetConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text(profile.profile.avatarEmoji)
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading) {
                        Text("Welcome, \(profile.profile.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(Date(), style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                    
                    Circle()
                        .trim(from: 0, to: store.todayProgress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: theme.currentTheme.progressGradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: store.todayProgress)
                    
                    VStack(spacing: 4) {
                        Text("\(store.todayTotalCount)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        
                        Text("/ \(store.dailyTarget)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("\(store.remainingBatches) batches remaining")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .frame(width: 180, height: 180)
                
                // Batch Grid
                VStack(spacing: 10) {
                    Text("Batches (100 each)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                        ForEach(1...11, id: \.self) { batch in
                            HomeBatchButton(batch: batch)
                        }
                    }
                }
                
                // Quick Add + Reset
                HStack(spacing: 10) {
                    Button(action: { 
                        if experiments.isEnabled("focusMode") {
                            focusManager.addCount(1)
                        } else {
                            store.addCount(1)
                        }
                        SoundManager.shared.play(.tick) 
                    }) {
                        Label("+1", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { 
                        if experiments.isEnabled("focusMode") {
                            focusManager.addCount(10)
                        } else {
                            store.addCount(10)
                        }
                        SoundManager.shared.play(.tick) 
                    }) {
                        Label("+10", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { 
                        if experiments.isEnabled("focusMode") {
                            focusManager.addCount(50)
                        } else {
                            store.addCount(50)
                        }
                        SoundManager.shared.play(.tick) 
                    }) {
                        Label("+50", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Reset Button
                Button(action: { showResetConfirm = true }) {
                    Label("Reset Today", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                // Streaks
                HStack(spacing: 20) {
                    VStack {
                        Text("\(store.currentStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Current Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider().frame(height: 30)
                    
                    VStack {
                        Text("\(store.longestStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Longest Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Quick Nav
                HStack(spacing: 12) {
                    Button(action: { selectedTab = .focus }) {
                        Label("Focus Mode", systemImage: "brain.head.profile")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { selectedTab = .calendar }) {
                        Label("Calendar", systemImage: "calendar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { selectedTab = .settings }) {
                        Label("Settings", systemImage: "gear")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(32)
        }
        .alert("Reset Today?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetToday()
                if experiments.isEnabled("focusMode") {
                    focusManager.resetSession()
                }
                SoundManager.shared.play(.pop)
            }
        } message: {
            Text("This will set today's count back to 0.")
        }
    }
}

// MARK: - Batch Button

struct HomeBatchButton: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    let batch: Int
    
    var isCompleted: Bool {
        store.completedBatches >= batch
    }
    
    var body: some View {
        Button(action: {
            if !isCompleted {
                if experiments.isEnabled("focusMode") {
                    focusManager.addBatch()
                } else {
                    store.addCount(100)
                }
                SoundManager.shared.play(.batchComplete)
                SoundManager.shared.playHaptic()
            }
        }) {
            VStack(spacing: 4) {
                Text("\(batch)")
                    .font(.system(size: 18, weight: .bold))
                Text("100")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(isCompleted ? Color.green.opacity(0.3) : theme.currentTheme.accentColor.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCompleted ? .green : theme.currentTheme.accentColor.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }
}
