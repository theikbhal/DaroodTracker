import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @EnvironmentObject var subGoals: SubGoalManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @State private var showCalendar = false
    @State private var showSettings = false
    @State private var showHelp = false
    @State private var showProfile = false
    @State private var showSubGoals = false
    @State private var showSplitBatches = false
    @State private var showResetConfirm = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with profile
            HStack {
                Text(profile.profile.avatarEmoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Darood Tracker")
                        .font(.headline)
                    Text(Date(), style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Focus status indicator
                if experiments.isEnabled("focusMode") && focusManager.isSessionActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text(focusManager.formattedElapsed)
                            .font(.caption2.monospacedDigit())
                    }
                }
                
                // Settings gear
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.caption)
                }
                
                // Floating button toggle
                Button(action: {
                    FloatingWindowManager.shared.toggleFloatingButton()
                }) {
                    Image(systemName: "cursorarrow.motionlines")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            Divider()
            
            // Focus Mode View
            if experiments.isEnabled("focusMode") {
                FocusModeView()
                    .environmentObject(store)
                    .environmentObject(theme)
                    .environmentObject(focusManager)
            } else {
                // Progress Ring (non-focus mode)
                ProgressRingView()
                
                // Batch Buttons
                BatchButtonsView()
            }
            
            // Quick Add buttons
            HStack(spacing: 6) {
                Button(action: { 
                    if experiments.isEnabled("focusMode") {
                        focusManager.addCount(1)
                    } else {
                        store.addCount(1)
                    }
                    SoundManager.shared.play(.tick) 
                }) {
                    Text("+1")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { 
                    if experiments.isEnabled("focusMode") {
                        focusManager.addCount(10)
                    } else {
                        store.addCount(10)
                    }
                    SoundManager.shared.play(.tick) 
                }) {
                    Text("+10")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { 
                    if experiments.isEnabled("focusMode") {
                        focusManager.addCount(50)
                    } else {
                        store.addCount(50)
                    }
                    SoundManager.shared.play(.tick) 
                }) {
                    Text("+50")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            // Reset button
            Button(action: { showResetConfirm = true }) {
                Label("Reset Today", systemImage: "arrow.counterclockwise")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
            
            Divider()
            
            // Bottom row - navigation buttons
            HStack(spacing: 6) {
                NavButton(icon: "square.split.2x2", label: "Split") { showSplitBatches = true }
                NavButton(icon: "calendar", label: "Day") { showCalendar = true }
                NavButton(icon: "flame.fill", label: "Streaks") { showProfile = true }
                NavButton(icon: "target", label: "Subgoals") { showSubGoals = true }
                NavButton(icon: "questionmark.circle", label: "Help") { showHelp = true }
            }
        }
        .padding()
        .frame(width: experiments.isEnabled("focusMode") ? 320 : 300)
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
        .sheet(isPresented: $showSplitBatches) {
            SplitBatchView()
                .environmentObject(store)
                .environmentObject(theme)
                .environmentObject(focusManager)
                .environmentObject(experiments)
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

// MARK: - Nav Button

struct NavButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}

// MARK: - Progress Ring

struct ProgressRingView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: store.todayProgress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: theme.currentTheme.progressGradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: store.todayProgress)
            
            VStack(spacing: 2) {
                Text("\(store.todayTotalCount)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("/ \(store.dailyTarget)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(store.remainingBatches) batches left")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .frame(width: 100, height: 100)
    }
}

// MARK: - Batch Buttons

struct BatchButtonsView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
            ForEach(1...11, id: \.self) { batch in
                MenuBarBatchButton(batch: batch)
            }
        }
    }
}

struct MenuBarBatchButton: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
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
            }
        }) {
            VStack(spacing: 1) {
                Text("\(batch)")
                    .font(.system(size: 12, weight: .bold))
                Text("100")
                    .font(.system(size: 8))
            }
            .frame(width: 50, height: 32)
            .background(isCompleted ? Color.green.opacity(0.3) : theme.currentTheme.accentColor.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isCompleted ? .green : theme.currentTheme.accentColor.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }
}
