import Foundation
import SwiftUI

// MARK: - Data Models

struct DailyRecord: Codable, Identifiable {
    var id: String { date }
    let date: String // "YYYY-MM-DD"
    var counts: [CountSession]
    var targetCount: Int
    
    var totalCount: Int {
        counts.reduce(0) { $0 + $1.count }
    }
    
    var isComplete: Bool {
        totalCount >= targetCount
    }
    
    var remainingCount: Int {
        max(0, targetCount - totalCount)
    }
    
    var completedBatches: Int {
        totalCount / 100
    }
}

struct CountSession: Codable, Identifiable {
    var id = UUID()
    let timestamp: Date
    var count: Int
    var batchNumber: Int // 1-11 for 100 each
}

// MARK: - Store

class DaroodStore: ObservableObject {
    @Published var records: [String: DailyRecord] = [:]
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    let dailyTarget = 1100
    let batchSize = 100
    
    private let saveKey = "DaroodTracker_Records"
    private let streakKey = "DaroodTracker_Streaks"
    
    init() {
        loadRecords()
        calculateStreaks()
    }
    
    // MARK: - Current Day
    
    var todayKey: String {
        formatDate(Date())
    }
    
    var todayRecord: DailyRecord {
        if let record = records[todayKey] {
            return record
        }
        let newRecord = DailyRecord(date: todayKey, counts: [], targetCount: dailyTarget)
        records[todayKey] = newRecord
        return newRecord
    }
    
    var todayTotalCount: Int {
        todayRecord.totalCount
    }
    
    var todayRemaining: Int {
        todayRecord.remainingCount
    }
    
    var todayProgress: Double {
        Double(todayTotalCount) / Double(dailyTarget)
    }
    
    var completedBatches: Int {
        todayTotalCount / batchSize
    }
    
    var remainingBatches: Int {
        11 - completedBatches
    }
    
    // MARK: - Any Day Access
    
    func record(for date: Date) -> DailyRecord {
        let key = formatDate(date)
        if let record = records[key] {
            return record
        }
        return DailyRecord(date: key, counts: [], targetCount: dailyTarget)
    }
    
    func totalCount(for date: Date) -> Int {
        record(for: date).totalCount
    }
    
    func isComplete(for date: Date) -> Bool {
        record(for: date).isComplete
    }
    
    func progress(for date: Date) -> Double {
        let rec = record(for: date)
        return Double(rec.totalCount) / Double(rec.targetCount)
    }
    
    func daysWithRecords() -> [String] {
        records.keys.sorted()
    }
    
    func allSortedRecords() -> [(key: String, value: DailyRecord)] {
        records.sorted { $0.key < $1.key }
    }
    
    // MARK: - Counting
    
    func addCount(_ count: Int = 1) {
        var record = todayRecord
        
        if record.counts.isEmpty {
            record.counts.append(CountSession(timestamp: Date(), count: count, batchNumber: 1))
        } else {
            let newTotal = record.totalCount + count
            
            if newTotal / batchSize > (record.totalCount / batchSize) {
                record.counts.append(CountSession(timestamp: Date(), count: count, batchNumber: (newTotal / batchSize) + 1))
            } else {
                record.counts[record.counts.count - 1].count += count
            }
        }
        
        records[todayKey] = record
        saveRecords()
        calculateStreaks()
    }
    
    func completeBatch() {
        let remaining = batchSize - (todayTotalCount % batchSize)
        if remaining > 0 && remaining < batchSize {
            addCount(remaining)
        }
    }
    
    func resetToday() {
        records[todayKey] = DailyRecord(date: todayKey, counts: [], targetCount: dailyTarget)
        saveRecords()
        calculateStreaks()
    }
    
    func resetDay(_ date: Date) {
        let key = formatDate(date)
        records[key] = DailyRecord(date: key, counts: [], targetCount: dailyTarget)
        saveRecords()
        calculateStreaks()
    }
    
    func resetAll() {
        records = [:]
        saveRecords()
        calculateStreaks()
    }
    
    // MARK: - Streaks
    
    func calculateStreaks() {
        let sortedDates = records.keys.sorted().reversed()
        var tempStreak = 0
        var currentLongest = 0
        var tempLongest = 0
        
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        
        // Current streak
        for dateKey in sortedDates {
            if let record = records[dateKey], record.isComplete {
                if let date = getDate(from: dateKey) {
                    let daysDiff = calendar.dateComponents([.day], from: date, to: checkDate).day ?? 0
                    
                    if daysDiff <= 1 {
                        tempStreak += 1
                        checkDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
                    } else {
                        break
                    }
                }
            }
        }
        
        // Longest streak
        let allSortedDates = records.keys.sorted()
        var prevDate: Date?
        tempLongest = 0
        
        for dateKey in allSortedDates {
            if let record = records[dateKey], record.isComplete {
                if let date = getDate(from: dateKey) {
                    if let prev = prevDate {
                        let daysDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                        if daysDiff == 1 {
                            tempLongest += 1
                        } else {
                            tempLongest = 1
                        }
                    } else {
                        tempLongest = 1
                    }
                    
                    if tempLongest > currentLongest {
                        currentLongest = tempLongest
                    }
                    
                    prevDate = date
                }
            }
        }
        
        self.currentStreak = tempStreak
        self.longestStreak = currentLongest
    }
    
    func getDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    // MARK: - Calendar Data
    
    func getRecordsForWeek(ending date: Date) -> [DailyRecord] {
        let calendar = Calendar.current
        var result: [DailyRecord] = []
        
        for i in (0..<7).reversed() {
            if let d = calendar.date(byAdding: .day, value: -i, to: date) {
                result.append(record(for: d))
            }
        }
        
        return result
    }
    
    func getRecordsForMonth(_ date: Date) -> [DailyRecord] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        
        var result: [DailyRecord] = []
        
        for day in range {
            var components = calendar.dateComponents([.year, .month], from: date)
            components.day = day
            
            if let d = calendar.date(from: components) {
                result.append(record(for: d))
            }
        }
        
        return result
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Export JSON
    
    func exportJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(records),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }
        return json
    }
    
    // MARK: - Export CSV
    
    func exportCSV() -> String {
        var csv = "date,total_count,target,remaining,completed,completed_batches,sessions\n"
        
        let sorted = records.sorted { $0.key < $1.key }
        
        for (_, record) in sorted {
            let sessions = record.counts.map { "(\($0.count),\($0.batchNumber),\($0.timestamp.ISO8601Format()))" }.joined(separator: ";")
            csv += "\(record.date),\(record.totalCount),\(record.targetCount),\(record.remainingCount),\(record.isComplete),\(record.completedBatches),\"\(sessions)\"\n"
        }
        
        return csv
    }
    
    // MARK: - Export Markdown
    
    func exportMarkdown() -> String {
        var md = "# Darood Tracker Export\n\n"
        md += "Generated: \(Date())\n\n"
        md += "| Date | Total | Target | Remaining | Complete | Batches |\n"
        md += "|------|-------|--------|-----------|----------|--------|\n"
        
        let sorted = records.sorted { $0.key < $1.key }
        
        for (_, record) in sorted {
            let status = record.isComplete ? "✅" : "⏳"
            md += "| \(record.date) | \(record.totalCount) | \(record.targetCount) | \(record.remainingCount) | \(status) | \(record.completedBatches)/11 |\n"
        }
        
        md += "\n## Summary\n\n"
        md += "- **Total Days Tracked:** \(records.count)\n"
        md += "- **Total Darood:** \(records.values.reduce(0) { $0 + $1.totalCount })\n"
        md += "- **Days Completed:** \(records.values.filter { $0.isComplete }.count)\n"
        md += "- **Current Streak:** \(currentStreak) days\n"
        md += "- **Longest Streak:** \(longestStreak) days\n"
        
        return md
    }
    
    // MARK: - Export SQL
    
    func exportSQL() -> String {
        var sql = """
        -- Darood Tracker Database Schema
        -- Generated: \(Date())
        
        CREATE TABLE IF NOT EXISTS daily_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            total_count INTEGER NOT NULL DEFAULT 0,
            target_count INTEGER NOT NULL DEFAULT 1100,
            remaining_count INTEGER NOT NULL DEFAULT 1100,
            is_complete INTEGER NOT NULL DEFAULT 0,
            completed_batches INTEGER NOT NULL DEFAULT 0
        );
        
        CREATE TABLE IF NOT EXISTS count_sessions (
            id TEXT PRIMARY KEY,
            daily_record_date TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            count INTEGER NOT NULL,
            batch_number INTEGER NOT NULL,
            FOREIGN KEY (daily_record_date) REFERENCES daily_records(date)
        );
        
        CREATE INDEX IF NOT EXISTS idx_sessions_date ON count_sessions(daily_record_date);
        CREATE INDEX IF NOT EXISTS idx_sessions_timestamp ON count_sessions(timestamp);
        
        -- Data
        
        """
        
        let sorted = records.sorted { $0.key < $1.key }
        
        for (_, record) in sorted {
            sql += """
            INSERT INTO daily_records (date, total_count, target_count, remaining_count, is_complete, completed_batches)
            VALUES ('\(record.date)', \(record.totalCount), \(record.targetCount), \(record.remainingCount), \(record.isComplete ? 1 : 0), \(record.completedBatches));
            
            """
            
            for session in record.counts {
                sql += """
                INSERT INTO count_sessions (id, daily_record_date, timestamp, count, batch_number)
                VALUES ('\(session.id.uuidString)', '\(record.date)', '\(session.timestamp.ISO8601Format())', \(session.count), \(session.batchNumber));
                
                """
            }
        }
        
        return sql
    }
    
    // MARK: - Persistence
    
    func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([String: DailyRecord].self, from: data) {
            records = decoded
        }
    }
}
