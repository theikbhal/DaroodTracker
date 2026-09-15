import SwiftUI

struct SubGoalsView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var subGoals: SubGoalManager
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var experiments: ExperimentsManager
    @Environment(\.dismiss) var dismiss
    @State private var showAddSheet = false
    @State private var newGoalName = ""
    @State private var newGoalTarget = 100
    @State private var selectedColor = "blue"
    
    let colors = ["blue", "purple", "pink", "orange", "green", "red", "cyan", "yellow"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Subgoals")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            
            Divider()
            
            // Overall progress
            VStack(spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(subGoals.totalCurrent) / \(subGoals.totalTarget)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(subGoals.totalCurrent), total: Double(subGoals.totalTarget))
                    .tint(theme.currentTheme.accentColor)
                
                Text("\(subGoals.completedCount) of \(subGoals.subGoals.count) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(theme.currentTheme.accentColor.opacity(0.1))
            .cornerRadius(12)
            
            // Subgoals list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(subGoals.subGoals) { goal in
                        SubGoalCard(goal: goal)
                    }
                }
            }
        }
        .padding()
        .frame(width: 400, height: 500)
        .sheet(isPresented: $showAddSheet) {
            AddSubGoalSheet(
                name: $newGoalName,
                target: $newGoalTarget,
                selectedColor: $selectedColor,
                colors: colors,
                onAdd: {
                    subGoals.addSubGoal(name: newGoalName, targetCount: newGoalTarget, color: selectedColor)
                    newGoalName = ""
                    newGoalTarget = 100
                    showAddSheet = false
                }
            )
        }
    }
}

struct SubGoalCard: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var subGoals: SubGoalManager
    @EnvironmentObject var theme: ThemeManager
    let goal: SubGoal
    
    var color: Color {
        switch goal.color {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "orange": return .orange
        case "green": return .green
        case "red": return .red
        case "cyan": return .cyan
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                    
                    Text("\(goal.currentCount) / \(goal.targetCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Text("\(goal.remaining)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            ProgressView(value: goal.progress)
                .tint(color)
            
            HStack(spacing: 12) {
                Button(action: {
                    subGoals.incrementCount(for: goal.id, by: 1)
                    SoundManager.shared.play(.tick)
                }) {
                    Label("+1", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .disabled(goal.isCompleted)
                
                Button(action: {
                    subGoals.incrementCount(for: goal.id, by: 10)
                    SoundManager.shared.play(.tick)
                }) {
                    Label("+10", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
                .disabled(goal.isCompleted)
                
                Button(action: {
                    subGoals.incrementCount(for: goal.id, by: 100)
                    SoundManager.shared.play(.batchComplete)
                }) {
                    Label("+100", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
                .disabled(goal.isCompleted)
                
                Spacer()
                
                Button(action: {
                    subGoals.resetSubGoal(goal.id)
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(goal.isCompleted ? .green : color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AddSubGoalSheet: View {
    @Binding var name: String
    @Binding var target: Int
    @Binding var selectedColor: String
    let colors: [String]
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add New Subgoal")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Goal Name", text: $name)
                .textFieldStyle(.roundedBorder)
            
            Picker("Target Count", selection: $target) {
                ForEach([50, 100, 150, 200, 250, 500], id: \.self) { num in
                    Text("\(num)").tag(num)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Color", selection: $selectedColor) {
                ForEach(colors, id: \.self) { color in
                    Text(color.capitalized).tag(color)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Add") {
                    onAdd()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 350, height: 250)
    }
}
