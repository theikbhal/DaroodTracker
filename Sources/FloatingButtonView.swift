import SwiftUI

// MARK: - Floating Button Style

enum FloatingButtonStyle: String, CaseIterable, Identifiable {
    case modern3D = "3D Modern"
    case retro1980 = "1980 Retro"
    case retro1990 = "1990 Retro"
    case retro2000 = "2000s Games"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .modern3D: return "cube.fill"
        case .retro1980: return "gamecontroller"
        case .retro1990: return "gamecontroller.fill"
        case .retro2000: return "sportscourt"
        }
    }
}

// MARK: - Floating Button View

struct FloatingButtonView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var position = CGPoint(x: 100, y: 100)
    @State private var isDragging = false
    @State private var lastTapTime = Date()
    @State private var tapCount = 0
    @State private var showRipple = false
    
    @AppStorage("floatingButtonStyle") private var buttonStyle: FloatingButtonStyle = .modern3D
    
    var body: some View {
        VStack(spacing: 8) {
            // Style selector
            HStack(spacing: 4) {
                ForEach(FloatingButtonStyle.allCases) { style in
                    Button(action: {
                        buttonStyle = style
                    }) {
                        Image(systemName: style.icon)
                            .font(.caption)
                            .foregroundColor(buttonStyle == style ? .white : .gray)
                            .frame(width: 24, height: 24)
                            .background(buttonStyle == style ? Color.white.opacity(0.3) : Color.clear)
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button(action: {
                    closeFloatingButton()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            // Button based on style
            switch buttonStyle {
            case .modern3D:
                Modern3DButton()
            case .retro1980:
                Retro1980Button()
            case .retro1990:
                Retro1990Button()
            case .retro2000:
                Retro2000Button()
            }
            
            // Count display
            Text("\(store.todayTotalCount)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Progress bar
            ProgressView(value: store.todayProgress)
                .tint(.white)
                .frame(width: 80)
                .scaleEffect(0.8)
        }
        .frame(width: 140, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                    }
                    position = value.location
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
        .animation(.easeInOut(duration: 0.1), value: isDragging)
    }
    
    private func handleTap() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)
        
        if timeSinceLastTap > 0.5 {
            tapCount = 0
        }
        
        tapCount += 1
        lastTapTime = now
        
        store.addCount(1)
        
        if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.count1)
        }
        
        SoundManager.shared.playHaptic()
        
        withAnimation(.easeOut(duration: 0.3)) {
            showRipple = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showRipple = false
                tapCount = 0
            }
        }
    }
    
    private func closeFloatingButton() {
        FloatingWindowManager.shared.hideFloatingButton()
    }
}

// MARK: - Modern 3D Button

struct Modern3DButton: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            ZStack {
                // 3D shadow layer
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .offset(y: 4)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.currentTheme.accentColor, theme.currentTheme.accentColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // +1 text
                Text("+1")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func handleTap() {
        store.addCount(1)
        if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.count1)
        }
        SoundManager.shared.playHaptic()
    }
}

// MARK: - Retro 1980 Button

struct Retro1980Button: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            ZStack {
                // Pixelated border
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 104, height: 104)
                
                // Inner button
                Rectangle()
                    .fill(Color(red: 0.0, green: 0.8, blue: 0.0))
                    .frame(width: 100, height: 100)
                
                // Pixel highlight
                Rectangle()
                    .fill(Color(red: 0.0, green: 1.0, blue: 0.0))
                    .frame(width: 96, height: 4)
                    .offset(y: -48)
                
                // Pixel shadow
                Rectangle()
                    .fill(Color(red: 0.0, green: 0.4, blue: 0.0))
                    .frame(width: 96, height: 4)
                    .offset(y: 48)
                
                // +1 text - pixel font style
                Text("+1")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 0, x: 2, y: 2)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.05)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func handleTap() {
        store.addCount(1)
        if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.count1)
        }
        SoundManager.shared.playHaptic()
    }
}

// MARK: - Retro 1990 Button

struct Retro1990Button: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var isPressed = false
    @State private var gradientPhase = 0.0
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            ZStack {
                // Metallic border
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.gray, .white, .gray, .black, .gray],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 108, height: 108)
                
                // Main button
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.8, green: 0.2, blue: 0.2),
                                Color(red: 0.6, green: 0.1, blue: 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Shine effect
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // +1 text
                Text("+1")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 0, x: 1, y: 1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func handleTap() {
        store.addCount(1)
        if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.count1)
        }
        SoundManager.shared.playHaptic()
    }
}

// MARK: - Retro 2000 Button

struct Retro2000Button: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var isPressed = false
    @State private var rotation = 0.0
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.cyan.opacity(0.6), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.6, blue: 1.0),
                                Color(red: 0.1, green: 0.3, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Glass effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Rotating ring
                Circle()
                    .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(rotation))
                
                // +1 text
                Text("+1")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .cyan, radius: 4, x: 0, y: 0)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
    
    private func handleTap() {
        store.addCount(1)
        if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.count1)
        }
        SoundManager.shared.playHaptic()
    }
}

// MARK: - Floating Window Manager

class FloatingWindowManager: ObservableObject {
    static let shared = FloatingWindowManager()
    
    @Published var isFloatingButtonVisible = false
    private var floatingWindow: NSWindow?
    
    func showFloatingButton() {
        if floatingWindow == nil {
            createFloatingWindow()
        }
        
        DispatchQueue.main.async {
            self.floatingWindow?.orderFront(nil)
            self.isFloatingButtonVisible = true
        }
    }
    
    func hideFloatingButton() {
        DispatchQueue.main.async {
            self.floatingWindow?.orderOut(nil)
            self.isFloatingButtonVisible = false
        }
    }
    
    func toggleFloatingButton() {
        if isFloatingButtonVisible {
            hideFloatingButton()
        } else {
            showFloatingButton()
        }
    }
    
    private func createFloatingWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 140, height: 240),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        
        let store = DaroodStore()
        let theme = ThemeManager()
        let experiments = ExperimentsManager.shared
        
        let contentView = FloatingButtonView()
            .environmentObject(store)
            .environmentObject(theme)
            .environmentObject(experiments)
        
        window.contentView = NSHostingView(rootView: contentView)
        
        self.floatingWindow = window
    }
}
