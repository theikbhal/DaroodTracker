import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: DaroodStore
    @State private var selectedDate = Date()
    @State private var viewMode: ViewMode = .month
    
    enum ViewMode: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("View", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
            }
            
            // Navigation
            HStack {
                Button(action: { navigate(-1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(dateTitle)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { navigate(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Content
            switch viewMode {
            case .day:
                DayView(date: selectedDate)
            case .week:
                WeekView(ending: selectedDate)
            case .month:
                MonthView(date: selectedDate)
            case .year:
                YearView(date: selectedDate)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    var dateTitle: String {
        let formatter = DateFormatter()
        
        switch viewMode {
        case .day:
            formatter.dateFormat = "MMMM d, yyyy"
        case .week:
            formatter.dateFormat = "MMMM yyyy"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        case .year:
            formatter.dateFormat = "yyyy"
        }
        
        return formatter.string(from: selectedDate)
    }
    
    func navigate(_ direction: Int) {
        let calendar = Calendar.current
        
        switch viewMode {
        case .day:
            selectedDate = calendar.date(byAdding: .day, value: direction, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: direction, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: direction, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: direction, to: selectedDate) ?? selectedDate
        }
    }
}

// MARK: - Day View

struct DayView: View {
    @EnvironmentObject var store: DaroodStore
    let date: Date
    
    var record: DailyRecord {
        let key = store.formatDate(date)
        return store.records[key] ?? DailyRecord(date: key, counts: [], targetCount: store.dailyTarget)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary
            HStack {
                StatCard(title: "Total", value: "\(record.totalCount)", color: .blue)
                StatCard(title: "Remaining", value: "\(record.remainingCount)", color: .orange)
                StatCard(title: "Progress", value: "\(Int(Double(record.totalCount) / Double(record.targetCount) * 100))%", color: .green)
            }
            
            // Sessions
            if record.counts.isEmpty {
                Text("No sessions recorded")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(record.counts) { session in
                    HStack {
                        Text("Batch \(session.batchNumber)")
                        Spacer()
                        Text("\(session.count)")
                        Text(session.timestamp, style: .time)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Week View

struct WeekView: View {
    @EnvironmentObject var store: DaroodStore
    let ending: Date
    
    var records: [DailyRecord] {
        store.getRecordsForWeek(ending: ending)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(records) { record in
                    DayCell(record: record)
                }
            }
        }
    }
}

struct DayCell: View {
    let record: DailyRecord
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        if let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: Date()))) {
            return formatter.string(from: date)
        }
        return ""
    }
    
    var progress: Double {
        Double(record.totalCount) / Double(record.targetCount)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.caption)
            
            ZStack {
                Circle()
                    .fill(record.isComplete ? Color.green.opacity(0.3) : Color.gray.opacity(0.1))
                
                if record.totalCount > 0 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .fill(Color.blue)
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: 35, height: 35)
            
            Text("\(record.totalCount)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Month View

struct MonthView: View {
    @EnvironmentObject var store: DaroodStore
    let date: Date
    
    var records: [DailyRecord] {
        store.getRecordsForMonth(date)
    }
    
    var completedDays: Int {
        records.filter { $0.isComplete }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary
            HStack {
                StatCard(title: "Completed", value: "\(completedDays)", color: .green)
                StatCard(title: "Total Count", value: "\(records.reduce(0) { $0 + $1.totalCount })", color: .blue)
                StatCard(title: "Completion", value: "\(completedDays * 100 / max(1, records.count))%", color: .purple)
            }
            
            // Calendar grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(records) { record in
                        DayCell(record: record)
                    }
                }
            }
        }
    }
}

// MARK: - Year View

struct YearView: View {
    @EnvironmentObject var store: DaroodStore
    let date: Date
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary
            let yearRecords = getYearRecords()
            let completedDays = yearRecords.filter { $0.isComplete }.count
            
            HStack {
                StatCard(title: "Completed Days", value: "\(completedDays)", color: .green)
                StatCard(title: "Total Count", value: "\(yearRecords.reduce(0) { $0 + $1.totalCount })", color: .blue)
                StatCard(title: "Streak", value: "\(store.longestStreak)", color: .purple)
            }
            
            // Month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(1...12, id: \.self) { month in
                    MonthMiniCard(month: month, year: Calendar.current.component(.year, from: date))
                }
            }
        }
    }
    
    func getYearRecords() -> [DailyRecord] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        var records: [DailyRecord] = []
        
        for month in 1...12 {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1
            
            if let date = calendar.date(from: components) {
                records.append(contentsOf: store.getRecordsForMonth(date))
            }
        }
        
        return records
    }
}

struct MonthMiniCard: View {
    @EnvironmentObject var store: DaroodStore
    let month: Int
    let year: Int
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var components = DateComponents()
        components.month = month
        return formatter.string(from: Calendar.current.date(from: components) ?? Date())
    }
    
    var completedDays: Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        
        guard let date = calendar.date(from: components) else { return 0 }
        let records = store.getRecordsForMonth(date)
        return records.filter { $0.isComplete }.count
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(monthName)
                .font(.caption)
                .fontWeight(.bold)
            
            Text("\(completedDays)")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("days")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 60)
        .background(completedDays > 0 ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
