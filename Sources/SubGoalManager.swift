import Foundation
import SwiftUI

struct SubGoal: Codable, Identifiable {
    var id = UUID()
    var name: String
    var targetCount: Int
    var currentCount: Int
    var isCompleted: Bool
    var color: String
    
    var progress: Double {
        guard targetCount > 0 else { return 0 }
        return Double(currentCount) / Double(targetCount)
    }
    
    var remaining: Int {
        max(0, targetCount - currentCount)
    }
}

class SubGoalManager: ObservableObject {
    @Published var subGoals: [SubGoal] = []
    
    private let saveKey = "DaroodTracker_SubGoals"
    
    static let shared = SubGoalManager()
    
    init() {
        loadSubGoals()
        if subGoals.isEmpty {
            createDefaultSubGoals()
        }
    }
    
    func createDefaultSubGoals() {
        subGoals = [
            SubGoal(name: "Morning Session", targetCount: 100, currentCount: 0, isCompleted: false, color: "blue"),
            SubGoal(name: "Afternoon Session", targetCount: 100, currentCount: 0, isCompleted: false, color: "purple"),
            SubGoal(name: "Evening Session", targetCount: 100, currentCount: 0, isCompleted: false, color: "pink"),
        ]
        saveSubGoals()
    }
    
    func addSubGoal(name: String, targetCount: Int, color: String) {
        let subGoal = SubGoal(name: name, targetCount: targetCount, currentCount: 0, isCompleted: false, color: color)
        subGoals.append(subGoal)
        saveSubGoals()
    }
    
    func removeSubGoal(at index: Int) {
        subGoals.remove(at: index)
        saveSubGoals()
    }
    
    func updateCount(for subGoalId: UUID, count: Int) {
        if let index = subGoals.firstIndex(where: { $0.id == subGoalId }) {
            subGoals[index].currentCount = count
            subGoals[index].isCompleted = count >= subGoals[index].targetCount
            saveSubGoals()
        }
    }
    
    func incrementCount(for subGoalId: UUID, by amount: Int = 1) {
        if let index = subGoals.firstIndex(where: { $0.id == subGoalId }) {
            subGoals[index].currentCount += amount
            subGoals[index].isCompleted = subGoals[index].currentCount >= subGoals[index].targetCount
            saveSubGoals()
        }
    }
    
    func resetSubGoal(_ subGoalId: UUID) {
        if let index = subGoals.firstIndex(where: { $0.id == subGoalId }) {
            subGoals[index].currentCount = 0
            subGoals[index].isCompleted = false
            saveSubGoals()
        }
    }
    
    func resetAll() {
        for index in subGoals.indices {
            subGoals[index].currentCount = 0
            subGoals[index].isCompleted = false
        }
        saveSubGoals()
    }
    
    var totalTarget: Int {
        subGoals.reduce(0) { $0 + $1.targetCount }
    }
    
    var totalCurrent: Int {
        subGoals.reduce(0) { $0 + $1.currentCount }
    }
    
    var allCompleted: Bool {
        subGoals.allSatisfy { $0.isCompleted }
    }
    
    var completedCount: Int {
        subGoals.filter { $0.isCompleted }.count
    }
    
    private func saveSubGoals() {
        if let data = try? JSONEncoder().encode(subGoals) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func loadSubGoals() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([SubGoal].self, from: data) {
            subGoals = decoded
        }
    }
}
