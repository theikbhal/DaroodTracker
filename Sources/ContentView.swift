import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @EnvironmentObject var subGoals: SubGoalManager
    @State private var showSettings = false
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if experiments.isEnabled("onboarding") {
                OnboardingView()
                    .environmentObject(store)
                    .environmentObject(experiments)
                    .environmentObject(theme)
                    .environmentObject(profile)
            } else {
                mainContent
            }
        }
        .onAppear {
            if experiments.isEnabled("onboarding") {
                showOnboarding = true
            }
        }
    }
    
    var mainContent: some View {
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
                
                if experiments.isEnabled("profile") {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Large Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: store.todayProgress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: theme.currentTheme.progressGradient),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: store.todayProgress)
                
                VStack(spacing: 4) {
                    Text("\(store.todayTotalCount)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text("/ \(store.dailyTarget)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("\(store.todayRemaining) remaining")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 200, height: 200)
            
            // Batch Grid
            VStack(spacing: 12) {
                Text("Batches (100 each)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(1...11, id: \.self) { batch in
                        LargeBatchButton(batch: batch)
                    }
                }
            }
            
            // Quick Add
            HStack(spacing: 12) {
                Button(action: { 
                    store.addCount(1)
                    SoundManager.shared.play(.tick)
                }) {
                    Label("+1", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
                
                Button(action: { 
                    store.addCount(10)
                    SoundManager.shared.play(.tick)
                }) {
                    Label("+10", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
                
                Button(action: { 
                    store.addCount(50)
                    SoundManager.shared.play(.tick)
                }) {
                    Label("+50", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
            }
            
            // Streak Info
            if experiments.isEnabled("streaks") {
                StreakView()
            }
            
            // Settings Button
            Button(action: { showSettings = true }) {
                Label("Settings", systemImage: "gear")
            }
            .buttonStyle(.bordered)
        }
        .padding(32)
        .frame(minWidth: 400, minHeight: 600)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
                .environmentObject(experiments)
                .environmentObject(theme)
                .environmentObject(profile)
        }
    }
}

struct LargeBatchButton: View {
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
                
                if store.completedBatches == batch {
                    CelebrationManager.shared.celebrateBatch(batch)
                }
            }
        }) {
            VStack(spacing: 4) {
                Text("\(batch)")
                    .font(.system(size: 20, weight: .bold))
                Text("100")
                    .font(.caption)
            }
            .frame(width: 70, height: 50)
            .background(isCompleted ? Color.green.opacity(0.3) : theme.currentTheme.accentColor.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isCompleted ? .green : theme.currentTheme.accentColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }
}
