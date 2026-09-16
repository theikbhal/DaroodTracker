import SwiftUI

struct SplitBatchView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var showResetConfirm = false
    
    // Split sizes for each batch of 100
    let splitSizes = [33, 33, 34]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Darood Tracker")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(Date(), style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Progress summary
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
                
                // Batch cards
                ForEach(1...11, id: \.self) { batch in
                    BatchSplitCard(batch: batch, splitSizes: splitSizes)
                }
                
                // Quick add
                HStack(spacing: 10) {
                    Button(action: { addCount(1) }) {
                        Label("+1", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { addCount(10) }) {
                        Label("+10", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { addCount(50) }) {
                        Label("+50", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
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
        SoundManager.shared.play(.tick)
    }
}

// MARK: - Batch Split Card

struct BatchSplitCard: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    
    let batch: Int
    let splitSizes: [Int]
    
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
    
    var body: some View {
        VStack(spacing: 8) {
            // Batch header
            HStack {
                Text("Batch \(batch)")
                    .font(.headline)
                
                Spacer()
                
                Text("\(batchCurrentCount)/100")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if isBatchComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            // Split progress bars
            HStack(spacing: 4) {
                ForEach(0..<splitSizes.count, id: \.self) { index in
                    let splitStart = index * 33
                    let splitSize = splitSizes[index]
                    let splitProgress = splitProgressForSplit(splitStart: splitStart, splitSize: splitSize)
                    
                    VStack(spacing: 2) {
                        // Split bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(splitColor(for: splitProgress))
                                    .frame(width: geo.size.width * splitProgress)
                            }
                        }
                        .frame(height: 16)
                        
                        // Split label
                        Text("\(splitSize)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 30)
            
            // Split buttons
            HStack(spacing: 4) {
                ForEach(0..<splitSizes.count, id: \.self) { index in
                    let splitSize = splitSizes[index]
                    let splitStart = index * 33
                    let isSplitComplete = splitProgressForSplit(splitStart: splitStart, splitSize: splitSize) >= 1.0
                    
                    Button(action: {
                        addCount(splitSize)
                    }) {
                        Text("+\(splitSize)")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(isBatchComplete)
                    .opacity(isSplitComplete ? 0.5 : 1.0)
                }
            }
        }
        .padding()
        .background(isCurrentBatch ? theme.currentTheme.accentColor.opacity(0.05) : Color.clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isCurrentBatch ? theme.currentTheme.accentColor.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func splitProgressForSplit(splitStart: Int, splitSize: Int) -> Double {
        let countInBatch = batchCurrentCount
        let splitEnd = splitStart + splitSize
        
        if countInBatch <= splitStart {
            return 0
        } else if countInBatch >= splitEnd {
            return 1.0
        } else {
            return Double(countInBatch - splitStart) / Double(splitSize)
        }
    }
    
    private func splitColor(for progress: Double) -> Color {
        if progress >= 1.0 {
            return .green
        } else if progress > 0 {
            return theme.currentTheme.accentColor
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func addCount(_ count: Int) {
        if experiments.isEnabled("focusMode") {
            focusManager.addCount(count)
        } else {
            store.addCount(count)
        }
        SoundManager.shared.play(.batchComplete)
        SoundManager.shared.playHaptic()
    }
}
