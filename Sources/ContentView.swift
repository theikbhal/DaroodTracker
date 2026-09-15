import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DaroodStore
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HeaderView()
            
            // Large Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: store.todayProgress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple, .pink]),
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
                Button(action: { store.addCount(1) }) {
                    Label("+1", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
                
                Button(action: { store.addCount(10) }) {
                    Label("+10", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
                
                Button(action: { store.addCount(50) }) {
                    Label("+50", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
            }
            
            // Streak Info
            StreakView()
            
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
        }
    }
}

struct LargeBatchButton: View {
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
            VStack(spacing: 4) {
                Text("\(batch)")
                    .font(.system(size: 20, weight: .bold))
                Text("100")
                    .font(.caption)
            }
            .frame(width: 70, height: 50)
            .background(isCompleted ? Color.green.opacity(0.3) : Color.blue.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isCompleted ? Color.green : Color.blue, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
    }
}
