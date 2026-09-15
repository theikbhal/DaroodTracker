import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var profile: ProfileManager
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var editName = ""
    
    let avatars = ["🌙", "⭐", "🕌", "🤲", "📖", "✨", "🌟", "💫", "🕌", "🤲", "📖", "✨"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar and Name
                    VStack(spacing: 12) {
                        Text(profile.profile.avatarEmoji)
                            .font(.system(size: 80))
                        
                        if isEditing {
                            HStack {
                                TextField("Name", text: $editName)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button("Save") {
                                    profile.setName(editName)
                                    isEditing = false
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(width: 200)
                        } else {
                            HStack {
                                Text(profile.profile.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Button(action: {
                                    editName = profile.profile.name
                                    isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                }
                            }
                        }
                    }
                    
                    // Avatar Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Change Avatar")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(avatars, id: \.self) { avatar in
                                Text(avatar)
                                    .font(.title)
                                    .padding(8)
                                    .background(profile.profile.avatarEmoji == avatar ? theme.currentTheme.accentColor.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        profile.setAvatar(avatar)
                                    }
                            }
                        }
                    }
                    
                    // Level
                    let levelInfo = profile.getLevel()
                    VStack(spacing: 8) {
                        Text("Level \(levelInfo.level)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(theme.currentTheme.accentColor)
                        
                        Text(levelInfo.title)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if levelInfo.nextLevel != Int.max {
                            ProgressView(value: Double(profile.profile.totalDarood), total: Double(levelInfo.nextLevel))
                                .tint(theme.currentTheme.accentColor)
                            
                            Text("\(profile.profile.totalDarood) / \(levelInfo.nextLevel) darood")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(theme.currentTheme.accentColor.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        StatBox(title: "Total Darood", value: "\(profile.profile.totalDarood)", icon: "star.fill", color: .yellow)
                        StatBox(title: "Total Days", value: "\(profile.profile.totalDays)", icon: "calendar", color: .blue)
                        StatBox(title: "Current Streak", value: "\(profile.profile.currentStreak)", icon: "flame.fill", color: .orange)
                        StatBox(title: "Longest Streak", value: "\(profile.profile.longestStreak)", icon: "trophy.fill", color: .purple)
                    }
                    
                    // Milestones
                    if !profile.profile.milestones.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Milestones")
                                .font(.headline)
                            
                            ForEach(profile.profile.milestones.suffix(5)) { milestone in
                                HStack {
                                    Image(systemName: "medal.fill")
                                        .foregroundColor(.yellow)
                                    
                                    VStack(alignment: .leading) {
                                        Text(milestone.title)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        
                                        Text(milestone.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(milestone.date, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
