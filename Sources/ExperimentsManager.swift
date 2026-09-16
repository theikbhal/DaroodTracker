import Foundation
import SwiftUI

class ExperimentsManager: ObservableObject {
    @Published var experiments: [String: Bool] = [:]
    
    private let saveKey = "DaroodTracker_Experiments"
    
    static let shared = ExperimentsManager()
    
    // All available experiments
    let availableExperiments: [Experiment] = [
        // Core
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
        // ADHD Focus Features
        Experiment(id: "focusMode", name: "Focus Mode Timer", description: "Session timer with pace tracking and progress", defaultEnabled: true),
        Experiment(id: "adaptiveNotifications", name: "Smart Notifications", description: "Progress-aware adaptive reminders", defaultEnabled: true),
        Experiment(id: "microBreaks", name: "Micro-Break System", description: "10-second breaks after every 10 darood", defaultEnabled: true),
        Experiment(id: "launchAtLogin", name: "Launch at Login", description: "Auto-start app on computer restart", defaultEnabled: false),
        Experiment(id: "idleDetection", name: "Idle Detection", description: "Detect when you stop counting", defaultEnabled: true),
        Experiment(id: "splitBatches", name: "Split Batches (33/33/34)", description: "Break each 100 into 3 sub-goals", defaultEnabled: false),
        Experiment(id: "fingerCounting", name: "Finger Counting Mode", description: "Count on fingers instead of tasbih", defaultEnabled: false),
        Experiment(id: "segmentCounting", name: "Finger Segments Mode", description: "Count using finger segments (3 per finger)", defaultEnabled: false),
        Experiment(id: "buttonSounds", name: "Button Sounds", description: "Play sounds when clicking count buttons", defaultEnabled: true),
        Experiment(id: "easyCount", name: "Easy Count Mode", description: "Big +1 button for eyes-closed counting", defaultEnabled: false),
        Experiment(id: "islandGarden", name: "Island Garden Game", description: "Idle progression game with island", defaultEnabled: false),
        Experiment(id: "floatingButton", name: "Floating Button", description: "Floating +1 button for quick counting", defaultEnabled: false),
        Experiment(id: "bugTracker", name: "Project Tracker", description: "Track bugs, features, and improvements", defaultEnabled: false),
        Experiment(id: "webcamFinger", name: "Webcam Finger Count", description: "Use camera to count with hand gestures", defaultEnabled: false),
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
