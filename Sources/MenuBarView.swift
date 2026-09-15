import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: DaroodStore
    @State private var showCalendar = false
    @State private var showSettings = false
    
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
                Button(action: { showCalendar = true }) {
                    Label("Calendar", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
                
                Button(action: { showSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
            }
            
            // Streak Info
            StreakView()
        }
        .padding()
        .frame(width: 300)
        .sheet(isPresented: $showCalendar) {
            CalendarView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    @EnvironmentObject var store: DaroodStore
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Darood Tracker")
                .font(.headline)
            
            Text(Date(), style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Progress Ring

struct ProgressRingView: View {
    @EnvironmentObject var store: DaroodStore
    
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
                        gradient: Gradient(colors: [.blue, .purple]),
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
    let batch: Int
    
    var isCompleted: Bool {
        store.completedBatches >= batch
    }
    
    var body: some View {
        Button(action: {
            if !isCompleted {
                store.addCount(100)
            }
        }) {
            VStack(spacing: 2) {
                Text("\(batch)")
                    .font(.system(size: 14, weight: .bold))
                Text("100")
                    .font(.caption2)
            }
            .frame(width: 55, height: 40)
            .background(isCompleted ? Color.green.opacity(0.3) : Color.blue.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCompleted ? Color.green : Color.blue, lineWidth: 1)
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
