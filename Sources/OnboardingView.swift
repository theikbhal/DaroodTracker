import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var experiments: ExperimentsManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var profile: ProfileManager
    @State private var currentPage = 0
    @State private var userName = ""
    @Binding var showOnboarding: Bool
    
    let pages: [(title: String, subtitle: String, icon: String)] = [
        ("Welcome to Darood Tracker", "Track your daily darood with ease", "star.fill"),
        ("Set Your Daily Target", "1100 darood daily (11 batches of 100)", "target"),
        ("Track Your Progress", "Visual progress and streak tracking", "chart.line.uptrend.xyaxis"),
        ("Never Forget", "Daily reminders to stay on track", "bell.badge.fill"),
        ("Let's Begin", "Start your spiritual journey today", "sparkles")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? theme.currentTheme.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            // Page content
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)
                
                TargetPage()
                    .tag(1)
                
                ProgressPage()
                    .tag(2)
                
                ReminderPage()
                    .tag(3)
                
                NamePage(userName: $userName)
                    .tag(4)
            }
            .tabViewStyle(.automatic)
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                    if currentPage == pages.count - 1 {
                        completeOnboarding()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.currentTheme.accentColor)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(width: 500, height: 400)
    }
    
    func completeOnboarding() {
        if !userName.isEmpty {
            profile.setName(userName)
        }
        experiments.set("onboarding", enabled: false)
        showOnboarding = false
        SoundManager.shared.play(.welcome)
    }
}

// MARK: - Page Views

struct WelcomePage: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: theme.currentTheme.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Welcome to\nDarood Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Track your daily darood recitations\nand build a consistent spiritual practice")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct TargetPage: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(theme.currentTheme.accentColor)
            
            Text("Daily Target")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("1100")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: theme.currentTheme.progressGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("darood per day")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Text("11 batches of 100\nComplete before 6 PM daily")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ProgressPage: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(theme.currentTheme.accentColor)
            
            Text("Track Your Progress")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                FeatureRow(icon: "calendar", title: "Calendar Views", description: "Day, Week, Month, Year")
                FeatureRow(icon: "flame.fill", title: "Streak Tracking", description: "Build consistent habits")
                FeatureRow(icon: "chart.bar.fill", title: "Visual Charts", description: "See your improvement")
            }
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ReminderPage: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.currentTheme.accentColor)
            
            Text("Never Forget")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Text("Daily reminders at your preferred time")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Complete pending counts before 6 PM")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Stay consistent with your streak")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct NamePage: View {
    @Binding var userName: String
    @EnvironmentObject var theme: ThemeManager
    
    let avatars = ["🌙", "⭐", "🕌", "🤲", "📖", "✨", "🌟", "💫"]
    @State private var selectedAvatar = "🌙"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(selectedAvatar)
                .font(.system(size: 80))
            
            Text("What's your name?")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Enter your name", text: $userName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
            
            HStack(spacing: 12) {
                ForEach(avatars, id: \.self) { avatar in
                    Text(avatar)
                        .font(.title)
                        .padding(8)
                        .background(selectedAvatar == avatar ? theme.currentTheme.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedAvatar = avatar
                        }
                }
            }
        }
        .padding()
    }
}
