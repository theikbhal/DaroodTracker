import SwiftUI

struct FocusModeView: View {
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Circle()
                    .fill(focusManager.isSessionActive ? Color.green : Color.gray)
                    .frame(width: 10, height: 10)
                
                Text(focusManager.isSessionActive ? "Focus Active" : "Focus Paused")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { focusManager.toggleSession() }) {
                    Label(focusManager.isSessionActive ? "Pause" : "Resume",
                          systemImage: focusManager.isSessionActive ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(focusManager.isSessionActive ? .orange : .green)
            }
            
            // Timer + Progress
            HStack(spacing: 30) {
                // Elapsed time
                VStack {
                    Text(focusManager.formattedElapsed)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                    Text("Elapsed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: focusManager.todayProgress)
                        .stroke(
                            LinearGradient(
                                colors: theme.currentTheme.progressGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(focusManager.daroodCount)")
                            .font(.system(size: 20, weight: .bold))
                        Text("/ \(focusManager.dailyTarget)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                // Pace
                VStack {
                    Text("\(Int(focusManager.sessionDaroodPerMinute))")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                    Text("per min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Batch progress
            VStack(spacing: 8) {
                HStack {
                    Text("Batch \(focusManager.currentBatch) of 11")
                        .font(.subheadline)
                    Spacer()
                    Text("\(focusManager.completedBatches) done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(focusManager.daroodCount % focusManager.batchSize), total: Double(focusManager.batchSize))
                    .tint(theme.currentTheme.accentColor)
                
                // Batch dots
                HStack(spacing: 4) {
                    ForEach(1...11, id: \.self) { batch in
                        Circle()
                            .fill(batch <= focusManager.completedBatches ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            // Quick add
            HStack(spacing: 10) {
                Button(action: { focusManager.addCount(1) }) {
                    Text("+1").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { focusManager.addCount(10) }) {
                    Text("+10").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { focusManager.addCount(50) }) {
                    Text("+50").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { focusManager.addBatch() }) {
                    Text("+100").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            // Status bar
            HStack {
                if focusManager.isIdle {
                    Label("Idle for \(focusManager.idleSeconds)s", systemImage: "clock.badge.exclamationmark")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                
                if focusManager.isAheadOfSchedule {
                    Label("Ahead of schedule", systemImage: "arrow.up.circle")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Label("Behind schedule", systemImage: "arrow.down.circle")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                
                Spacer()
                
                Text("Next break in: \(focusManager.microBreakAfterCount - (focusManager.daroodCount % focusManager.microBreakAfterCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
