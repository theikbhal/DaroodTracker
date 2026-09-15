import Foundation
import SwiftUI

class ExperimentsManager: ObservableObject {
    @Published var experiments: [String: Bool] = [:]
    
    private let saveKey = "DaroodTracker_Experiments"
    
    static let shared = ExperimentsManager()
    
    // All available experiments
    let availableExperiments: [Experiment] = [
        Experiment(id: "onboarding", name: "Onboarding Flow", description: "Show welcome screens on first launch", defaultEnabled: true),
        Experiment(id: "themes", name: "Themes", description: "Enable multiple color themes", defaultEnabled: true),
        Experiment(id: "sounds", name: "Sound Effects", description: "Play sounds on count and achievements", defaultEnabled: true),
        Experiment(id: "animations", name: "Animations", description: "Show celebration animations", defaultEnabled: true),
        Experiment(id: "profile", name: "User Profile", description: "Track personal stats and milestones", defaultEnabled: true),
        Experiment(id: "subgoals", name: "Subgoals", description: "Break 1100 into smaller goals", defaultEnabled: true),
        Experiment(id: "help", name: "Help Section", description: "Show help and tips", defaultEnabled: true),
        Experiment(id: "haptics", name: "Haptic Feedback", description: "Vibrate on interactions", defaultEnabled: true),
        Experiment(id: "streaks", name: "Streak Tracking", description: "Track consecutive days", defaultEnabled: true),
        Experiment(id: "weekly_report", name: "Weekly Report", description: "Show weekly summary", defaultEnabled: true),
    ]
    
    init() {
        loadExperiments()
    }
    
    func isEnabled(_ id: String) -> Bool {
        experiments[id] ?? availableExperiments.first { $0.id == id }?.defaultEnabled ?? false
    }
    
    func toggle(_ id: String) {
        withAnimation {
            experiments[id] = !(experiments[id] ?? availableExperiments.first { $0.id == id }?.defaultEnabled ?? false)
        }
        saveExperiments()
    }
    
    func set(_ id: String, enabled: Bool) {
        withAnimation {
            experiments[id] = enabled
        }
        saveExperiments()
    }
    
    func resetAll() {
        experiments = [:]
        saveExperiments()
    }
    
    private func saveExperiments() {
        if let data = try? JSONEncoder().encode(experiments) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func loadExperiments() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) {
            experiments = decoded
        }
    }
}

struct Experiment: Identifiable {
    let id: String
    let name: String
    let description: String
    let defaultEnabled: Bool
}
