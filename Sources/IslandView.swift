import SwiftUI

// MARK: - Island Progression Model

enum IslandStage: Int, CaseIterable, Identifiable {
    case empty = 0
    case soil = 1
    case seed = 2
    case sprout = 3
    case tree = 4
    case flower = 5
    case fruit = 6
    case harvest = 7
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .empty: return "Empty Island"
        case .soil: return "Prepared Soil"
        case .seed: return "Planted Seed"
        case .sprout: return "Growing Sprout"
        case .tree: return "Mighty Tree"
        case .flower: return "Blooming Flowers"
        case .fruit: return "Ripe Fruits"
        case .harvest: return "Harvest Time!"
        }
    }
    
    var description: String {
        switch self {
        case .empty: return "Start counting to begin your journey"
        case .soil: return "The soil is ready for planting"
        case .seed: return "A seed has been planted"
        case .sprout: return "The seed is sprouting!"
        case .tree: return "A beautiful tree has grown"
        case .flower: return "Flowers are blooming!"
        case .fruit: return "Fruits are ripening!"
        case .harvest: return "Collect your rewards!"
        }
    }
    
    var requiredCount: Int {
        switch self {
        case .empty: return 0
        case .soil: return 100
        case .seed: return 200
        case .sprout: return 400
        case .tree: return 600
        case .flower: return 800
        case .fruit: return 1000
        case .harvest: return 1100
        }
    }
    
    var emoji: String {
        switch self {
        case .empty: return "🏝️"
        case .soil: return "🌱"
        case .seed: return "🌰"
        case .sprout: return "🌿"
        case .tree: return "🌳"
        case .flower: return "🌸"
        case .fruit: return "🍎"
        case .harvest: return "🎉"
        }
    }
}

// MARK: - Island View

struct IslandView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FocusSessionManager
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var showResetConfirm = false
    @State private var showCollectAnimation = false
    @State private var fruitsCollected = 0
    
    var currentStage: IslandStage {
        let count = store.todayTotalCount
        if count >= 1100 { return .harvest }
        if count >= 1000 { return .fruit }
        if count >= 800 { return .flower }
        if count >= 600 { return .tree }
        if count >= 400 { return .sprout }
        if count >= 200 { return .seed }
        if count >= 100 { return .soil }
        return .empty
    }
    
    var progressToNext: Double {
        let count = store.todayTotalCount
        let stages = IslandStage.allCases
        
        for i in (0..<stages.count).reversed() {
            if count >= stages[i].requiredCount {
                if i < stages.count - 1 {
                    let current = count - stages[i].requiredCount
                    let needed = stages[i+1].requiredCount - stages[i].requiredCount
                    return Double(current) / Double(needed)
                }
                return 1.0
            }
        }
        return Double(count) / 100.0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Island Garden")
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
                
                // Island scene
                ZStack {
                    // Sky gradient
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .cyan.opacity(0.2), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 300)
                    .cornerRadius(20)
                    
                    // Sun
                    SunView()
                        .offset(x: 120, y: -100)
                    
                    // Clouds
                    CloudView()
                        .offset(x: -80, y: -80)
                    
                    // Island
                    IslandShape()
                        .fill(Color.brown.opacity(0.6))
                        .frame(width: 280, height: 120)
                        .offset(y: 60)
                    
                    // Water
                    WaterView()
                        .offset(y: 100)
                    
                    // Progression elements
                    IslandProgressionView(stage: currentStage)
                        .offset(y: -20)
                    
                    // Collect animation
                    if showCollectAnimation {
                        CollectAnimationView()
                            .offset(y: -50)
                    }
                }
                .frame(height: 320)
                .clipped()
                
                // Stage info
                VStack(spacing: 8) {
                    HStack {
                        Text(currentStage.emoji)
                            .font(.largeTitle)
                        Text(currentStage.name)
                            .font(.headline)
                        Spacer()
                    }
                    
                    Text(currentStage.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(theme.currentTheme.accentColor.opacity(0.05))
                .cornerRadius(10)
                
                // Progress to next stage
                VStack(spacing: 4) {
                    HStack {
                        Text("Progress to next stage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(progressToNext * 100))%")
                            .font(.caption)
                            .foregroundColor(theme.currentTheme.accentColor)
                    }
                    
                    ProgressView(value: progressToNext)
                        .tint(theme.currentTheme.accentColor)
                }
                
                // Quick add buttons
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
                    
                    Button(action: { addCount(100) }) {
                        Label("+100", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Stage progression timeline
                StageTimelineView(currentStage: currentStage)
                
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
        let oldStage = currentStage
        
        if experiments.isEnabled("focusMode") {
            focusManager.addCount(count)
        } else {
            store.addCount(count)
        }
        
        let newStage = currentStage
        
        // Play sound and animation on stage change
        if newStage.rawValue > oldStage.rawValue {
            SoundManager.shared.play(.goalComplete)
            SoundManager.shared.playHaptic()
            
            if newStage == .harvest {
                showCollectAnimation = true
                fruitsCollected += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCollectAnimation = false
                }
            }
        } else if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.tick)
        }
    }
}

// MARK: - Sun View

struct SunView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            // Sun rays
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(width: 4, height: 20)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
            
            // Sun body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.yellow, .orange],
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Cloud View

struct CloudView: View {
    @State private var offset: CGFloat = -20
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 30, height: 30)
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 40, height: 40)
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 30, height: 30)
        }
        .offset(x: offset)
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                offset = 20
            }
        }
    }
}

// MARK: - Water View

struct WaterView: View {
    @State private var phase = 0.0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Wave(phase: phase + Double(i) * 0.5)
                    .fill(Color.blue.opacity(0.3 - Double(i) * 0.1))
                    .offset(y: CGFloat(i) * 10)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

struct Wave: Shape {
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for x in stride(from: 0, through: width, by: 5) {
            let relativeX = x / width
            let y = height * 0.5 + sin(relativeX * .pi * 2 + phase) * 10
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Island Shape

struct IslandShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.6))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY * 0.6),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Island Progression View

struct IslandProgressionView: View {
    let stage: IslandStage
    @State private var animationPhase = 0.0
    
    var body: some View {
        ZStack {
            switch stage {
            case .empty:
                EmptyIsland()
            case .soil:
                SoilIsland()
            case .seed:
                SeedIsland()
            case .sprout:
                SproutIsland()
            case .tree:
                TreeIsland()
            case .flower:
                FlowerIsland()
            case .fruit:
                FruitIsland()
            case .harvest:
                HarvestIsland()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                animationPhase = 1
            }
        }
    }
}

// MARK: - Island Stages

struct EmptyIsland: View {
    var body: some View {
        VStack {
            Text("🏝️")
                .font(.system(size: 40))
            Text("Start counting!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .offset(y: 20)
    }
}

struct SoilIsland: View {
    var body: some View {
        VStack {
            Text("🌱")
                .font(.system(size: 40))
            Text("Soil ready")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .offset(y: 20)
    }
}

struct SeedIsland: View {
    @State private var bounce = false
    
    var body: some View {
        VStack {
            Text("🌰")
                .font(.system(size: 40))
                .offset(y: bounce ? -5 : 0)
            Text("Seed planted")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .offset(y: 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                bounce.toggle()
            }
        }
    }
}

struct SproutIsland: View {
    @State private var sway = false
    
    var body: some View {
        VStack {
            Text("🌿")
                .font(.system(size: 50))
                .rotationEffect(.degrees(sway ? 5 : -5))
            Text("Growing!")
                .font(.caption)
                .foregroundColor(.green)
        }
        .offset(y: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                sway.toggle()
            }
        }
    }
}

struct TreeIsland: View {
    @State private var sway = false
    
    var body: some View {
        VStack {
            Text("🌳")
                .font(.system(size: 70))
                .rotationEffect(.degrees(sway ? 3 : -3))
            Text("Beautiful tree!")
                .font(.caption)
                .foregroundColor(.green)
        }
        .offset(y: -10)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                sway.toggle()
            }
        }
    }
}

struct FlowerIsland: View {
    @State private var scale = 1.0
    
    var body: some View {
        VStack {
            ZStack {
                Text("🌳")
                    .font(.system(size: 70))
                
                // Flowers
                Text("🌸")
                    .font(.system(size: 20))
                    .offset(x: -30, y: -20)
                    .scaleEffect(scale)
                Text("🌺")
                    .font(.system(size: 20))
                    .offset(x: 30, y: -15)
                    .scaleEffect(scale)
                Text("🌼")
                    .font(.system(size: 18))
                    .offset(x: -20, y: -30)
                    .scaleEffect(scale)
            }
            Text("Flowers blooming!")
                .font(.caption)
                .foregroundColor(.pink)
        }
        .offset(y: -10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                scale = 1.2
            }
        }
    }
}

struct FruitIsland: View {
    @State private var bounce = false
    
    var body: some View {
        VStack {
            ZStack {
                Text("🌳")
                    .font(.system(size: 70))
                
                // Fruits
                Text("🍎")
                    .font(.system(size: 18))
                    .offset(x: -25, y: -15)
                    .offset(y: bounce ? -3 : 0)
                Text("🍊")
                    .font(.system(size: 18))
                    .offset(x: 25, y: -10)
                    .offset(y: bounce ? -3 : 0)
                Text("🍋")
                    .font(.system(size: 16))
                    .offset(x: 0, y: -25)
                    .offset(y: bounce ? -3 : 0)
            }
            Text("Fruits ready!")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .offset(y: -10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                bounce.toggle()
            }
        }
    }
}

struct HarvestIsland: View {
    @State private var scale = 1.0
    @State private var rotation = 0.0
    
    var body: some View {
        VStack {
            ZStack {
                Text("🌳")
                    .font(.system(size: 70))
                
                // Harvest fruits with animation
                Text("🍎")
                    .font(.system(size: 22))
                    .offset(x: -30, y: -20)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                Text("🍊")
                    .font(.system(size: 22))
                    .offset(x: 30, y: -15)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(-rotation))
                Text("🍋")
                    .font(.system(size: 20))
                    .offset(x: 0, y: -30)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                
                // Celebration
                Text("✨")
                    .font(.system(size: 24))
                    .offset(x: -40, y: -40)
                    .scaleEffect(scale)
                Text("🎉")
                    .font(.system(size: 24))
                    .offset(x: 40, y: -35)
                    .scaleEffect(scale)
            }
            Text("Harvest time!")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.bold)
        }
        .offset(y: -10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                scale = 1.2
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Collect Animation

struct CollectAnimationView: View {
    @State private var opacity = 1.0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            ForEach(0..<5) { i in
                Text("🍎")
                    .font(.system(size: 30))
                    .offset(y: offset - CGFloat(i * 20))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                offset = -100
                opacity = 0
            }
        }
    }
}

// MARK: - Stage Timeline View

struct StageTimelineView: View {
    let currentStage: IslandStage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Island Progression")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(IslandStage.allCases) { stage in
                        StageTimelineItem(
                            stage: stage,
                            isCurrent: stage == currentStage,
                            isCompleted: stage.rawValue < currentStage.rawValue
                        )
                    }
                }
            }
        }
    }
}

struct StageTimelineItem: View {
    let stage: IslandStage
    let isCurrent: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(stage.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(isCurrent ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Text("\(stage.requiredCount)")
                .font(.caption2)
                .foregroundColor(isCompleted ? .green : .secondary)
        }
        .opacity(isCompleted || isCurrent ? 1.0 : 0.5)
    }
}
