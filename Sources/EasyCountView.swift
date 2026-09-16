import SwiftUI

struct EasyCountView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var showResetConfirm = false
    @State private var lastTapTime = Date()
    @State private var tapCount = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.02)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Easy Count")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Tap anywhere to count")
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
                .padding(.horizontal)
                
                // Progress bar
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
                .padding(.horizontal)
                
                // BIG +1 BUTTON
                Button(action: {
                    addCount(1)
                    withAnimation(.easeInOut(duration: 0.1)) {
                        tapCount += 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            tapCount = 0
                        }
                    }
                }) {
                    ZStack {
                        // Button background
                        Circle()
                            .fill(theme.currentTheme.accentColor)
                            .frame(width: 280, height: 280)
                            .shadow(color: theme.currentTheme.accentColor.opacity(0.3), radius: 20, y: 10)
                        
                        // Ripple effect
                        if tapCount > 0 {
                            Circle()
                                .stroke(theme.currentTheme.accentColor.opacity(0.5), lineWidth: 4)
                                .frame(width: 280 + CGFloat(tapCount * 20), height: 280 + CGFloat(tapCount * 20))
                                .opacity(1.0 - Double(tapCount) * 0.2)
                        }
                        
                        // +1 text
                        VStack(spacing: 8) {
                            Text("+1")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Tap to Count")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Current count display
                Text("\(store.todayTotalCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(theme.currentTheme.accentColor)
                
                // Quick actions row
                HStack(spacing: 20) {
                    Button(action: { addCount(10) }) {
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.title)
                            Text("+10")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { addCount(100) }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                            Text("+100")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { showResetConfirm = true }) {
                        VStack {
                            Image(systemName: "arrow.counterclockwise.circle")
                                .font(.title)
                            Text("Reset")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 60)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.top, 10)
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
        
        // Play sound
        if experiments.isEnabled("buttonSounds") {
            switch count {
            case 1: SoundManager.shared.play(.count1)
            case 10: SoundManager.shared.play(.count15)
            case 100: SoundManager.shared.play(.count33)
            default: SoundManager.shared.play(.tick)
            }
        }
        
        // Haptic feedback
        SoundManager.shared.playHaptic()
    }
}
