import SwiftUI

struct FingerCountView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var showResetConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Finger Counting")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(Date(), style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(store.todayTotalCount) / \(store.dailyTarget)")
                            .font(.headline)
                        Text("\(store.remainingBatches) batches left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Overall progress bar
                VStack(spacing: 4) {
                    ProgressView(value: store.todayProgress)
                        .tint(theme.currentTheme.accentColor)
                    
                    HStack {
                        Text("\(Int(store.todayProgress * 100))% complete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(store.todayRemaining) remaining")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                // Current set display
                CurrentSetCard()
                    .environmentObject(store)
                    .environmentObject(theme)
                
                // Two hands
                HStack(spacing: 30) {
                    // Left hand (1-5)
                    FingerHand(handNumber: 1, fingerRange: 1...5)
                        .environmentObject(store)
                        .environmentObject(theme)
                    
                    // Right hand (6-10)
                    FingerHand(handNumber: 2, fingerRange: 6...10)
                        .environmentObject(store)
                        .environmentObject(theme)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                
                // Quick add buttons
                HStack(spacing: 10) {
                    Button(action: { addCount(1) }) {
                        Label("+1", systemImage: "hand.point.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { addCount(5) }) {
                        Label("+5", systemImage: "hand.raised")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { addCount(10) }) {
                        Label("+10", systemImage: "hand.thumbsup")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Batch progress
                BatchFingerProgress()
                    .environmentObject(store)
                    .environmentObject(theme)
                
                // Reset
                Button(action: { showResetConfirm = true }) {
                    Label("Reset Today", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            .padding()
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
    
    private func addCount(_ count: Int) {
        if experiments.isEnabled("focusMode") {
            focusManager.addCount(count)
        } else {
            store.addCount(count)
        }
        
        // Play sound based on count size
        if experiments.isEnabled("buttonSounds") {
            switch count {
            case 1: SoundManager.shared.play(.count1)
            case 5: SoundManager.shared.play(.count5)
            case 10: SoundManager.shared.play(.count15)
            default: SoundManager.shared.play(.tick)
            }
        }
    }
}

// MARK: - Current Set Card

struct CurrentSetCard: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var currentSetInBatch: Int {
        let countInBatch = store.todayTotalCount % 100
        return (countInBatch / 10) + 1
    }
    
    var countInCurrentSet: Int {
        let countInBatch = store.todayTotalCount % 100
        return countInBatch % 10
    }
    
    var batchNumber: Int {
        (store.todayTotalCount / 100) + 1
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Batch \(batchNumber)")
                    .font(.headline)
                Text("·")
                Text("Set \(currentSetInBatch) of 10")
                    .font(.subheadline)
                Spacer()
                Text("\(countInCurrentSet) / 10")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.accentColor)
            }
            
            // Set progress dots
            HStack(spacing: 6) {
                ForEach(1...10, id: \.self) { dot in
                    Circle()
                        .fill(dot <= countInCurrentSet ? theme.currentTheme.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding()
        .background(theme.currentTheme.accentColor.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Finger Hand

struct FingerHand: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    let handNumber: Int
    let fingerRange: ClosedRange<Int>
    
    var countInCurrentSet: Int {
        let countInBatch = store.todayTotalCount % 100
        return countInBatch % 10
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Hand label
            Text(handNumber == 1 ? "Left Hand" : "Right Hand")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Palm
            ZStack {
                // Palm shape
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 140)
                
                // Fingers
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        ForEach(fingerRange, id: \.self) { finger in
                            FingerShape()
                                .fill(finger <= countInCurrentSet ? theme.currentTheme.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 18, height: 50)
                                .overlay(
                                    Text("\(finger)")
                                        .font(.caption2)
                                        .foregroundColor(finger <= countInCurrentSet ? .white : .gray)
                                )
                        }
                    }
                }
            }
            
            // Count indicator
            Text("\(min(countInCurrentSet, 5)) / 5")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Finger Shape

struct FingerShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path(roundedRect: rect, cornerRadius: rect.width / 2)
        return path
    }
}

// MARK: - Batch Finger Progress

struct BatchFingerProgress: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Batch Progress")
                .font(.headline)
            
            // 11 batches
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(1...11, id: \.self) { batch in
                    BatchFingerCard(batch: batch)
                        .environmentObject(store)
                        .environmentObject(theme)
                }
            }
        }
    }
}

// MARK: - Batch Finger Card

struct BatchFingerCard: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    let batch: Int
    
    var batchStartCount: Int {
        (batch - 1) * 100
    }
    
    var batchCurrentCount: Int {
        let total = store.todayTotalCount
        let batchStart = batchStartCount
        return max(0, min(100, total - batchStart))
    }
    
    var isBatchComplete: Bool {
        batchCurrentCount >= 100
    }
    
    var isCurrentBatch: Bool {
        !isBatchComplete && store.todayTotalCount >= batchStartCount && store.todayTotalCount < batchStartCount + 100
    }
    
    var setsCompleted: Int {
        batchCurrentCount / 10
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("B\(batch)")
                .font(.caption)
                .fontWeight(.bold)
            
            // 10 set indicators
            HStack(spacing: 2) {
                ForEach(1...10, id: \.self) { set in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(set <= setsCompleted ? theme.currentTheme.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 12)
                }
            }
            
            Text("\(batchCurrentCount)/100")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(6)
        .background(isCurrentBatch ? theme.currentTheme.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isCurrentBatch ? theme.currentTheme.accentColor.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
