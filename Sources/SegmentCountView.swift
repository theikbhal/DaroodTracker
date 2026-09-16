import SwiftUI

struct SegmentCountView: View {
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
                        Text("Finger Segments")
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
                
                // Current sub-goal display
                CurrentSubGoalCard()
                    .environmentObject(store)
                    .environmentObject(theme)
                
                // Two hands with segments
                HStack(spacing: 40) {
                    // Left hand
                    SegmentHand(handNumber: 1)
                        .environmentObject(store)
                        .environmentObject(theme)
                    
                    // Right hand
                    SegmentHand(handNumber: 2)
                        .environmentObject(store)
                        .environmentObject(theme)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                
                // Quick add buttons
                QuickAddButtons()
                    .environmentObject(store)
                    .environmentObject(theme)
                    .environmentObject(focusManager)
                    .environmentObject(experiments)
                
                // Sub-goal progress
                SubGoalProgressView()
                    .environmentObject(store)
                    .environmentObject(theme)
                
                // Batch progress
                SegmentBatchProgress()
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
        SoundManager.shared.play(.tick)
    }
}

// MARK: - Current Sub-Goal Card

struct CurrentSubGoalCard: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    // 1100 = 11 batches, each batch = 33+33+34
    var currentBatch: Int {
        (store.todayTotalCount / 100) + 1
    }
    
    var countInBatch: Int {
        store.todayTotalCount % 100
    }
    
    var currentSubGoal: Int {
        if countInBatch < 33 { return 1 }
        else if countInBatch < 66 { return 2 }
        else { return 3 }
    }
    
    var subGoalTarget: Int {
        if currentSubGoal == 1 { return 33 }
        else if currentSubGoal == 2 { return 33 }
        else { return 34 }
    }
    
    var countInSubGoal: Int {
        switch currentSubGoal {
        case 1: return countInBatch
        case 2: return countInBatch - 33
        case 3: return countInBatch - 66
        default: return 0
        }
    }
    
    var subGoalProgress: Double {
        Double(countInSubGoal) / Double(subGoalTarget)
    }
    
    var remainingSegments: Int {
        subGoalTarget - countInSubGoal
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Batch \(currentBatch)")
                    .font(.headline)
                Text("·")
                Text("Sub-goal \(currentSubGoal) of 3")
                    .font(.subheadline)
                Spacer()
                Text("\(countInSubGoal) / \(subGoalTarget)")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.accentColor)
            }
            
            // Sub-goal progress bar
            ProgressView(value: subGoalProgress)
                .tint(theme.currentTheme.accentColor)
            
            // Remaining segments indicator
            if remainingSegments > 0 && remainingSegments <= 5 {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.orange)
                    Text("\(remainingSegments) more to complete sub-goal \(currentSubGoal)")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                    Text("33/33/34")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            
            // Sub-goal labels
            HStack {
                Text("33")
                    .font(.caption2)
                    .foregroundColor(currentSubGoal == 1 ? theme.currentTheme.accentColor : .secondary)
                Spacer()
                Text("33")
                    .font(.caption2)
                    .foregroundColor(currentSubGoal == 2 ? theme.currentTheme.accentColor : .secondary)
                Spacer()
                Text("34")
                    .font(.caption2)
                    .foregroundColor(currentSubGoal == 3 ? theme.currentTheme.accentColor : .secondary)
            }
        }
        .padding()
        .background(theme.currentTheme.accentColor.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Segment Hand

struct SegmentHand: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    let handNumber: Int
    
    // 15 segments per hand (5 fingers × 3 segments)
    var segmentsFilled: Int {
        let countInBatch = store.todayTotalCount % 100
        let subGoalCount: Int
        
        if countInBatch < 33 {
            subGoalCount = countInBatch
        } else if countInBatch < 66 {
            subGoalCount = countInBatch - 33
        } else {
            subGoalCount = countInBatch - 66
        }
        
        // Within sub-goal, which hand?
        let subGoalProgress = subGoalCount
        let handOffset = (handNumber - 1) * 15
        
        return max(0, min(15, subGoalProgress - handOffset))
    }
    
    var handLabel: String {
        let countInBatch = store.todayTotalCount % 100
        let subGoal: Int
        if countInBatch < 33 { subGoal = 1 }
        else if countInBatch < 66 { subGoal = 2 }
        else { subGoal = 3 }
        
        return "Hand \(handNumber) · Sub \(subGoal)"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Hand label
            Text(handLabel)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Palm
            ZStack {
                // Palm shape
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 140, height: 160)
                
                // Fingers
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { finger in
                        FingerWithSegments(fingerNumber: finger, segmentsFilled: fingerSegments(for: finger), isNext: finger == nextFingerIndex)
                            .environmentObject(theme)
                    }
                }
            }
            
            // Count indicator with remaining
            HStack(spacing: 4) {
                Text("\(segmentsFilled) / 15")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if remainingInHand > 0 && remainingInHand <= 5 {
                    Text("( \(remainingInHand) left )")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func fingerSegments(for finger: Int) -> Int {
        let start = finger * 3
        return max(0, min(3, segmentsFilled - start))
    }
    
    var nextFingerIndex: Int {
        segmentsFilled / 3
    }
    
    var remainingInHand: Int {
        15 - segmentsFilled
    }
}

// MARK: - Finger With Segments

struct FingerWithSegments: View {
    @EnvironmentObject var theme: ThemeManager
    
    let fingerNumber: Int
    let segmentsFilled: Int
    var isNext: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            // Segment 3 (tip)
            SegmentBlock()
                .fill(segmentsFilled >= 3 ? theme.currentTheme.accentColor : Color.gray.opacity(0.2))
                .frame(width: 14, height: 16)
                .overlay(
                    Text("3")
                        .font(.system(size: 8))
                        .foregroundColor(segmentsFilled >= 3 ? .white : .gray)
                )
                .border(isNext && segmentsFilled < 3 ? Color.orange : Color.clear, width: 2)
            
            // Segment 2 (middle)
            SegmentBlock()
                .fill(segmentsFilled >= 2 ? theme.currentTheme.accentColor : Color.gray.opacity(0.2))
                .frame(width: 14, height: 16)
                .overlay(
                    Text("2")
                        .font(.system(size: 8))
                        .foregroundColor(segmentsFilled >= 2 ? .white : .gray)
                )
                .border(isNext && segmentsFilled < 2 ? Color.orange : Color.clear, width: 2)
            
            // Segment 1 (base)
            SegmentBlock()
                .fill(segmentsFilled >= 1 ? theme.currentTheme.accentColor : Color.gray.opacity(0.2))
                .frame(width: 14, height: 16)
                .overlay(
                    Text("1")
                        .font(.system(size: 8))
                        .foregroundColor(segmentsFilled >= 1 ? .white : .gray)
                )
                .border(isNext && segmentsFilled < 1 ? Color.orange : Color.clear, width: 2)
            
            // Finger number
            Text("\(fingerNumber + 1)")
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Segment Block Shape

struct SegmentBlock: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: 4)
    }
}

// MARK: - Sub-Goal Progress View

struct SubGoalProgressView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var countInBatch: Int {
        store.todayTotalCount % 100
    }
    
    var subGoal1: Int {
        min(33, countInBatch)
    }
    
    var subGoal2: Int {
        max(0, min(33, countInBatch - 33))
    }
    
    var subGoal3: Int {
        max(0, min(34, countInBatch - 66))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sub-Goal Progress")
                .font(.headline)
            
            // 3 sub-goals
            HStack(spacing: 12) {
                SegmentSubGoalCard(label: "33", count: subGoal1, target: 33)
                    .environmentObject(theme)
                SegmentSubGoalCard(label: "33", count: subGoal2, target: 33)
                    .environmentObject(theme)
                SegmentSubGoalCard(label: "34", count: subGoal3, target: 34)
                    .environmentObject(theme)
            }
        }
    }
}

// MARK: - Segment Sub-Goal Card

struct SegmentSubGoalCard: View {
    @EnvironmentObject var theme: ThemeManager
    
    let label: String
    let count: Int
    let target: Int
    
    var progress: Double {
        Double(count) / Double(target)
    }
    
    var isComplete: Bool {
        count >= target
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
            
            ProgressView(value: progress)
                .tint(isComplete ? .green : theme.currentTheme.accentColor)
            
            Text("\(count)/\(target)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(isComplete ? .green.opacity(0.1) : theme.currentTheme.accentColor.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isComplete ? .green : theme.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Segment Batch Progress

struct SegmentBatchProgress: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Batch Progress")
                .font(.headline)
            
            // 11 batches
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(1...11, id: \.self) { batch in
                    SegmentBatchCard(batch: batch)
                        .environmentObject(store)
                        .environmentObject(theme)
                }
            }
        }
    }
}

// MARK: - Segment Batch Card

struct SegmentBatchCard: View {
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
    
    // Sub-goal progress indicators
    var subGoal1Progress: Double {
        Double(min(33, batchCurrentCount)) / 33.0
    }
    
    var subGoal2Progress: Double {
        let count = max(0, batchCurrentCount - 33)
        return Double(min(33, count)) / 33.0
    }
    
    var subGoal3Progress: Double {
        let count = max(0, batchCurrentCount - 66)
        return Double(min(34, count)) / 34.0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("B\(batch)")
                .font(.caption)
                .fontWeight(.bold)
            
            // 3 sub-goal progress bars
            VStack(spacing: 2) {
                ProgressView(value: subGoal1Progress)
                    .tint(subGoal1Progress >= 1.0 ? .green : theme.currentTheme.accentColor)
                ProgressView(value: subGoal2Progress)
                    .tint(subGoal2Progress >= 1.0 ? .green : theme.currentTheme.accentColor)
                ProgressView(value: subGoal3Progress)
                    .tint(subGoal3Progress >= 1.0 ? .green : theme.currentTheme.accentColor)
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

// MARK: - Quick Add Buttons

struct QuickAddButtons: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    
    var countInBatch: Int {
        store.todayTotalCount % 100
    }
    
    var currentSubGoal: Int {
        if countInBatch < 33 { return 1 }
        else if countInBatch < 66 { return 2 }
        else { return 3 }
    }
    
    var countInSubGoal: Int {
        switch currentSubGoal {
        case 1: return countInBatch
        case 2: return countInBatch - 33
        case 3: return countInBatch - 66
        default: return 0
        }
    }
    
    var remainingInSubGoal: Int {
        let target = currentSubGoal == 3 ? 34 : 33
        return target - countInSubGoal
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Row 1: +1, +3, +5
            HStack(spacing: 10) {
                Button(action: { addCount(1) }) {
                    Label("+1", systemImage: "hand.point.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: { addCount(3) }) {
                    Label("+3", systemImage: "hand.raised.fingers.spread")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: { addCount(5) }) {
                    Label("+5", systemImage: "hand.raised")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // Row 2: +15 (hand), +remaining (smart), +33/34 (sub-goal)
            HStack(spacing: 10) {
                Button(action: { addCount(15) }) {
                    Label("+15", systemImage: "hand.thumbsup")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                if remainingInSubGoal > 0 && remainingInSubGoal <= 10 {
                    Button(action: { addCount(remainingInSubGoal) }) {
                        Label("+\(remainingInSubGoal)", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                
                Button(action: { addCount(33) }) {
                    Label("+33", systemImage: "arrow.right.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
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
