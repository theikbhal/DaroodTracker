import Foundation

struct UserProfile: Codable {
    var name: String
    var joinDate: Date
    var totalDarood: Int
    var totalDays: Int
    var longestStreak: Int
    var currentStreak: Int
    var milestones: [Milestone]
    var avatarEmoji: String
    
    static let defaultProfile = UserProfile(
        name: "User",
        joinDate: Date(),
        totalDarood: 0,
        totalDays: 0,
        longestStreak: 0,
        currentStreak: 0,
        milestones: [],
        avatarEmoji: "🌙"
    )
}

struct Milestone: Codable, Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let date: Date
    let type: MilestoneType
    
    enum MilestoneType: String, Codable {
        case firstDay = "First Day"
        case weekStreak = "7 Day Streak"
        case monthStreak = "30 Day Streak"
        case totalDarood = "Total Darood"
        case perfectWeek = "Perfect Week"
        case earlyBird = "Early Bird"
    }
}

class ProfileManager: ObservableObject {
    @Published var profile: UserProfile
    
    private let saveKey = "DaroodTracker_Profile"
    
    static let shared = ProfileManager()
    
    init() {
        profile = ProfileManager.loadProfile()
    }
    
    func updateStats(totalDarood: Int, totalDays: Int, currentStreak: Int, longestStreak: Int) {
        profile.totalDarood = totalDarood
        profile.totalDays = totalDays
        profile.currentStreak = currentStreak
        profile.longestStreak = longestStreak
        checkMilestones()
        saveProfile()
    }
    
    func setName(_ name: String) {
        profile.name = name
        saveProfile()
    }
    
    func setAvatar(_ emoji: String) {
        profile.avatarEmoji = emoji
        saveProfile()
    }
    
    private func checkMilestones() {
        // Check for new milestones
        if profile.totalDays == 1 && !hasMilestone(.firstDay) {
            addMilestone(.firstDay, title: "First Day!", description: "Started your darood journey")
        }
        
        if profile.currentStreak >= 7 && !hasMilestone(.weekStreak) {
            addMilestone(.weekStreak, title: "7 Day Streak!", description: "Completed 7 days in a row")
        }
        
        if profile.currentStreak >= 30 && !hasMilestone(.monthStreak) {
            addMilestone(.monthStreak, title: "30 Day Streak!", description: "Completed 30 days in a row")
        }
        
        if profile.totalDarood >= 1100 && !hasMilestone(.totalDarood) {
            addMilestone(.totalDarood, title: "1100 Darood!", description: "Completed your first full day")
        }
        
        if profile.totalDarood >= 11000 && !hasMilestone(.totalDarood) {
            addMilestone(.totalDarood, title: "11000 Darood!", description: "Completed 10 full days")
        }
    }
    
    private func hasMilestone(_ type: Milestone.MilestoneType) -> Bool {
        profile.milestones.contains { $0.type == type }
    }
    
    private func addMilestone(_ type: Milestone.MilestoneType, title: String, description: String) {
        let milestone = Milestone(title: title, description: description, date: Date(), type: type)
        profile.milestones.append(milestone)
    }
    
    func getLevel() -> (level: Int, title: String, nextLevel: Int) {
        let total = profile.totalDarood
        switch total {
        case 0..<1100:
            return (1, "Beginner", 1100)
        case 1100..<11000:
            return (2, "Dedicated", 11000)
        case 11000..<55000:
            return (3, "Committed", 55000)
        case 55000..<110000:
            return (4, "Devoted", 110000)
        case 110000..<550000:
            return (5, "Faithful", 550000)
        default:
            return (6, "Master", Int.max)
        }
    }
    
    private func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private static func loadProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: "DaroodTracker_Profile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        }
        return UserProfile.defaultProfile
    }
}
