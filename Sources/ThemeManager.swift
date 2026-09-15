import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case ocean = "Ocean"
    case forest = "Forest"
    case sunset = "Sunset"
    case royal = "Royal"
    case minimal = "Minimal"
    
    var id: String { rawValue }
    
    var accentColor: Color {
        switch self {
        case .system: return .blue
        case .light: return .blue
        case .dark: return .cyan
        case .ocean: return Color(red: 0.0, green: 0.5, blue: 1.0)
        case .forest: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .sunset: return Color(red: 1.0, green: 0.4, blue: 0.2)
        case .royal: return Color(red: 0.5, green: 0.2, blue: 0.8)
        case .minimal: return .gray
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .system: return [.blue, .purple]
        case .light: return [.blue, .cyan]
        case .dark: return [.cyan, .blue]
        case .ocean: return [Color(red: 0.0, green: 0.4, blue: 0.8), Color(red: 0.0, green: 0.7, blue: 1.0)]
        case .forest: return [Color(red: 0.1, green: 0.5, blue: 0.2), Color(red: 0.3, green: 0.8, blue: 0.4)]
        case .sunset: return [Color(red: 0.9, green: 0.3, blue: 0.1), Color(red: 1.0, green: 0.6, blue: 0.0)]
        case .royal: return [Color(red: 0.4, green: 0.1, blue: 0.7), Color(red: 0.6, green: 0.3, blue: 0.9)]
        case .minimal: return [.gray, .black]
        }
    }
    
    var progressGradient: [Color] {
        switch self {
        case .system: return [.blue, .purple, .pink]
        case .light: return [.blue, .cyan, .teal]
        case .dark: return [.cyan, .blue, .indigo]
        case .ocean: return [Color(red: 0.0, green: 0.3, blue: 0.7), Color(red: 0.0, green: 0.6, blue: 1.0), Color(red: 0.2, green: 0.8, blue: 1.0)]
        case .forest: return [Color(red: 0.1, green: 0.4, blue: 0.2), Color(red: 0.2, green: 0.7, blue: 0.3), Color(red: 0.4, green: 0.9, blue: 0.5)]
        case .sunset: return [Color(red: 0.8, green: 0.2, blue: 0.1), Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.8, blue: 0.0)]
        case .royal: return [Color(red: 0.3, green: 0.1, blue: 0.6), Color(red: 0.5, green: 0.2, blue: 0.8), Color(red: 0.7, green: 0.4, blue: 1.0)]
        case .minimal: return [.gray, .black]
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    
    private let saveKey = "DaroodTracker_Theme"
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
        saveTheme()
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: saveKey)
    }
    
    private func loadTheme() {
        if let saved = UserDefaults.standard.string(forKey: saveKey),
           let theme = AppTheme(rawValue: saved) {
            currentTheme = theme
        }
    }
}
