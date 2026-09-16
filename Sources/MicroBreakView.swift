import SwiftUI

struct MicroBreakView: View {
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var theme: ThemeManager
    @State private var breathingPhase = 0.0
    @State private var showSuggestion = false
    
    let suggestions = [
        "Take a deep breath 🌙",
        "Stand up and stretch",
        "Roll your shoulders",
        "Look away from the screen",
        "Take 3 slow breaths",
        "Relax your jaw",
        "Unclench your fists",
        "Stretch your neck gently"
    ]
    
    @State private var currentSuggestion = ""
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Micro Break")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Breathing circle
                ZStack {
                    Circle()
                        .stroke(theme.currentTheme.accentColor.opacity(0.3), lineWidth: 4)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(breathingPhase))
                        .stroke(
                            LinearGradient(
                                colors: theme.currentTheme.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    // Countdown
                    Text("\(focusManager.microBreakCountdown)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Suggestion
                Text(currentSuggestion)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut, value: currentSuggestion)
                
                // Progress
                VStack(spacing: 4) {
                    Text("\(focusManager.daroodCount) / \(focusManager.dailyTarget)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(focusManager.remainingCount) remaining • Batch \(focusManager.currentBatch)/11")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Skip button
                Button(action: { focusManager.skipMicroBreak() }) {
                    Text("Skip Break")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            currentSuggestion = suggestions.randomElement() ?? suggestions[0]
            startBreathingAnimation()
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breathingPhase = 1.0
        }
        
        // Rotate suggestions
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation {
                    currentSuggestion = suggestions.randomElement() ?? suggestions[0]
                }
            }
        }
    }
}

struct BatchBreakView: View {
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var theme: ThemeManager
    @State private var breathingPhase = 0.0
    
    let breakSuggestions = [
        "Stand up and walk around",
        "Stretch your arms overhead",
        "Touch your toes",
        "Roll your wrists",
        "Take a sip of water",
        "Look out the window",
        "Do 5 deep breaths",
        "Shake out your hands"
    ]
    
    @State private var currentSuggestion = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Batch complete badge
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Batch \(focusManager.completedBatches) Complete!")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                
                // Timer circle
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 4)
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(breathingPhase))
                        .stroke(
                            LinearGradient(
                                colors: [.green, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(focusManager.batchBreakCountdown)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("seconds")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Suggestion
                Text(currentSuggestion)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // Stats
                VStack(spacing: 4) {
                    Text("\(focusManager.daroodCount) / \(focusManager.dailyTarget) darood")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(focusManager.remainingBatches) batches remaining")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Button(action: { focusManager.skipBatchBreak() }) {
                    Text("Skip Break")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            currentSuggestion = breakSuggestions.randomElement() ?? breakSuggestions[0]
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breathingPhase = 1.0
            }
        }
    }
}
