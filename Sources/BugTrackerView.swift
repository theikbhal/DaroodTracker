import SwiftUI

// MARK: - Bug/Feature Model

enum ItemStatus: String, CaseIterable, Identifiable {
    case open = "Open"
    case inProgress = "In Progress"
    case completed = "Completed"
    case deferred = "Deferred"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .open: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .deferred: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .open: return "circle"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .deferred: return "pause.circle"
        }
    }
}

enum ItemType: String, CaseIterable, Identifiable {
    case bug = "Bug"
    case feature = "Feature"
    case improvement = "Improvement"
    case task = "Task"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .bug: return .red
        case .feature: return .purple
        case .improvement: return .cyan
        case .task: return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .feature: return "star.fill"
        case .improvement: return "arrow.up.circle"
        case .task: return "checklist"
        }
    }
}

enum ItemPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct TrackerItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var type: ItemType
    var status: ItemStatus
    var priority: ItemPriority
    var createdAt: Date
    var updatedAt: Date
}

// MARK: - Bug Tracker View

struct BugTrackerView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var items: [TrackerItem] = []
    @State private var showAddItem = false
    @State private var selectedItem: TrackerItem?
    @State private var filterStatus: ItemStatus?
    @State private var filterType: ItemType?
    @State private var searchText = ""
    
    var filteredItems: [TrackerItem] {
        items.filter { item in
            if let status = filterStatus, item.status != status {
                return false
            }
            if let type = filterType, item.type != type {
                return false
            }
            if !searchText.isEmpty {
                return item.title.localizedCaseInsensitiveContains(searchText) ||
                       item.description.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Project Tracker")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(items.count) items • \(items.filter { $0.status == .completed }.count) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showAddItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Stats
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TrackerStatCard(title: "Open", count: items.filter { $0.status == .open }.count, color: .orange)
                    TrackerStatCard(title: "In Progress", count: items.filter { $0.status == .inProgress }.count, color: .blue)
                    TrackerStatCard(title: "Completed", count: items.filter { $0.status == .completed }.count, color: .green)
                    TrackerStatCard(title: "Bugs", count: items.filter { $0.type == .bug }.count, color: .red)
                    TrackerStatCard(title: "Features", count: items.filter { $0.type == .feature }.count, color: .purple)
                }
            }
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: filterStatus == nil && filterType == nil) {
                        filterStatus = nil
                        filterType = nil
                    }
                    
                    ForEach(ItemStatus.allCases) { status in
                        FilterChip(title: status.rawValue, isSelected: filterStatus == status) {
                            filterStatus = filterStatus == status ? nil : status
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    ForEach(ItemType.allCases) { type in
                        FilterChip(title: type.rawValue, isSelected: filterType == type) {
                            filterType = filterType == type ? nil : type
                        }
                    }
                }
            }
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search items...", text: $searchText)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Items list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredItems) { item in
                        TrackerItemRow(item: item) { updatedItem in
                            if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                                items[index] = updatedItem
                                saveItems()
                            }
                        }
                        .onTapGesture {
                            selectedItem = item
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showAddItem) {
            AddItemSheet { item in
                items.append(item)
                saveItems()
            }
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailSheet(item: item) { updatedItem in
                if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                    items[index] = updatedItem
                    saveItems()
                }
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    private func saveItems() {
        if let data = try? JSONEncoder().encode(items.map { ItemData(from: $0) }) {
            UserDefaults.standard.set(data, forKey: "BugTracker_Items")
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "BugTracker_Items"),
           let decoded = try? JSONDecoder().decode([ItemData].self, from: data) {
            items = decoded.map { $0.toTrackerItem() }
        } else {
            // Load default items
            items = defaultItems
        }
    }
    
    var defaultItems: [TrackerItem] {
        [
            TrackerItem(title: "Fix app icon not updating", description: "macOS caches app icons, need to force refresh", type: .bug, status: .completed, priority: .high, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Settings toggle closing popover", description: "Event monitor was closing on any click", type: .bug, status: .completed, priority: .high, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Add floating button", description: "Draggable +1 button for quick counting", type: .feature, status: .completed, priority: .medium, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Add Island Garden game", description: "Idle progression game with island", type: .feature, status: .completed, priority: .medium, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Add finger segments mode", description: "Count using 3 segments per finger", type: .feature, status: .completed, priority: .high, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Add webcam finger detection", description: "Use camera to detect hand gestures", type: .feature, status: .open, priority: .high, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Add iCloud sync", description: "Sync data across devices", type: .feature, status: .open, priority: .medium, createdAt: Date(), updatedAt: Date()),
            TrackerItem(title: "Improve sound effects", description: "Add more variety and better sounds", type: .improvement, status: .inProgress, priority: .low, createdAt: Date(), updatedAt: Date()),
        ]
    }
}

// MARK: - Tracker Stat Card

struct TrackerStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 60)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tracker Item Row

struct TrackerItemRow: View {
    let item: TrackerItem
    let onUpdate: (TrackerItem) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: item.type.icon)
                .foregroundColor(item.type.color)
                .frame(width: 24)
            
            // Title and description
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Priority badge
            Text(item.priority.rawValue)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(item.priority.color.opacity(0.2))
                .foregroundColor(item.priority.color)
                .cornerRadius(4)
            
            // Status
            Image(systemName: item.status.icon)
                .foregroundColor(item.status.color)
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Add Item Sheet

struct AddItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var type: ItemType = .bug
    @State private var priority: ItemPriority = .medium
    let onSave: (TrackerItem) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add New Item")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Cancel") { dismiss() }
            }
            
            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
            
            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)
            
            Picker("Type", selection: $type) {
                ForEach(ItemType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Priority", selection: $priority) {
                ForEach(ItemPriority.allCases) { priority in
                    Text(priority.rawValue).tag(priority)
                }
            }
            .pickerStyle(.segmented)
            
            Button("Add Item") {
                let item = TrackerItem(
                    title: title,
                    description: description,
                    type: type,
                    status: .open,
                    priority: priority,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                onSave(item)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.isEmpty)
        }
        .padding()
        .frame(width: 400, height: 350)
    }
}

// MARK: - Item Detail Sheet

struct ItemDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let item: TrackerItem
    let onUpdate: (TrackerItem) -> Void
    @State private var status: ItemStatus
    @State private var priority: ItemPriority
    
    init(item: TrackerItem, onUpdate: @escaping (TrackerItem) -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        _status = State(initialValue: item.status)
        _priority = State(initialValue: item.priority)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") { dismiss() }
            }
            
            Text(item.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                Text("Type:")
                    .fontWeight(.medium)
                Spacer()
                HStack {
                    Image(systemName: item.type.icon)
                    Text(item.type.rawValue)
                }
                .foregroundColor(item.type.color)
            }
            
            HStack {
                Text("Status:")
                    .fontWeight(.medium)
                Spacer()
                Picker("Status", selection: $status) {
                    ForEach(ItemStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
                .onChange(of: status) { _, newValue in
                    var updated = item
                    updated.status = newValue
                    updated.updatedAt = Date()
                    onUpdate(updated)
                }
            }
            
            HStack {
                Text("Priority:")
                    .fontWeight(.medium)
                Spacer()
                Picker("Priority", selection: $priority) {
                    ForEach(ItemPriority.allCases) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
                .onChange(of: priority) { _, newValue in
                    var updated = item
                    updated.priority = newValue
                    updated.updatedAt = Date()
                    onUpdate(updated)
                }
            }
            
            HStack {
                Text("Created:")
                    .fontWeight(.medium)
                Spacer()
                Text(item.createdAt, style: .date)
            }
            
            HStack {
                Text("Updated:")
                    .fontWeight(.medium)
                Spacer()
                Text(item.updatedAt, style: .date)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 450, height: 400)
    }
}

// MARK: - Item Data (for persistence)

struct ItemData: Codable {
    let id: UUID
    let title: String
    let description: String
    let type: String
    let status: String
    let priority: String
    let createdAt: Date
    let updatedAt: Date
    
    init(from item: TrackerItem) {
        self.id = item.id
        self.title = item.title
        self.description = item.description
        self.type = item.type.rawValue
        self.status = item.status.rawValue
        self.priority = item.priority.rawValue
        self.createdAt = item.createdAt
        self.updatedAt = item.updatedAt
    }
    
    func toTrackerItem() -> TrackerItem {
        TrackerItem(
            title: title,
            description: description,
            type: ItemType(rawValue: type) ?? .bug,
            status: ItemStatus(rawValue: status) ?? .open,
            priority: ItemPriority(rawValue: priority) ?? .medium,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
