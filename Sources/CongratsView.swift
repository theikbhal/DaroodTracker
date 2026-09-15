import SwiftUI

struct CongratsView: View {
    let title: String
    let message: String
    let type: CongratsType
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var animationPhase = 0
    @State private var showContent = false
    
    enum CongratsType {
        case batchComplete
        case goalComplete
        case streak
        case milestone
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Confetti animation
                if type == .goalComplete || type == .milestone {
                    ConfettiView()
                        .frame(height: 100)
                }
                
                // Icon
                Group {
                    switch type {
                    case .batchComplete:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    case .goalComplete:
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    case .streak:
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                    case .milestone:
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .font(.system(size: 80))
                .scaleEffect(showContent ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showContent)
                
                // Title
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: showContent)
                
                // Message
                Text(message)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
                
                // Button
                Button(action: { dismiss() }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.currentTheme.accentColor)
                        .cornerRadius(12)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
            }
            .padding(40)
        }
        .onAppear {
            showContent = true
            SoundManager.shared.play(type == .goalComplete ? .congrats : .batchComplete)
        }
    }
}

struct ConfettiView: View {
    @State private var animationPhase = 0
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { index in
                ConfettiPiece(color: colors[index % colors.count])
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: animationPhase == 0 ? -20 : geometry.size.height + 20
                    )
                    .opacity(0.8)
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Celebration Manager

class CelebrationManager: ObservableObject {
    @Published var showCongrats = false
    @Published var congratsTitle = ""
    @Published var congratsMessage = ""
    @Published var congratsType: CongratsView.CongratsType = .batchComplete
    
    static let shared = CelebrationManager()
    
    func celebrateBatch(_ batchNumber: Int) {
        guard ExperimentsManager.shared.isEnabled("animations") else { return }
        
        congratsTitle = "Batch \(batchNumber) Complete!"
        congratsMessage = "Great progress! Keep going!"
        congratsType = .batchComplete
        showCongrats = true
    }
    
    func celebrateGoal() {
        guard ExperimentsManager.shared.isEnabled("animations") else { return }
        
        congratsTitle = "Daily Goal Complete!"
        congratsMessage = "You've reached 1100 darood!\nMay your blessings be multiplied."
        congratsType = .goalComplete
        showCongrats = true
    }
    
    func celebrateStreak(_ days: Int) {
        guard ExperimentsManager.shared.isEnabled("animations") else { return }
        
        congratsTitle = "\(days) Day Streak!"
        congratsMessage = "Consistency is key!\nKeep up the amazing work."
        congratsType = .streak
        showCongrats = true
    }
    
    func celebrateMilestone(_ title: String) {
        guard ExperimentsManager.shared.isEnabled("animations") else { return }
        
        congratsTitle = "Milestone Reached!"
        congratsMessage = title
        congratsType = .milestone
        showCongrats = true
    }
}
