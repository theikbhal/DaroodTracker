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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
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
    
    // MARK: - Counting
    
    func addCount(_ count: Int = 1) {
        var record = todayRecord
        
        if record.counts.isEmpty {
            record.counts.append(CountSession(timestamp: Date(), count: count, batchNumber: 1))
        } else {
            let newTotal = record.totalCount + count
            
            if newTotal / batchSize > (record.totalCount / batchSize) {
                // New batch started
                record.counts.append(CountSession(timestamp: Date(), count: count, batchNumber: (newTotal / batchSize) + 1))
            } else {
                // Continue current batch
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
    }
    
    // MARK: - Streaks
    
    func calculateStreaks() {
        let sortedDates = records.keys.sorted().reversed()
        var streak = 0
        var tempStreak = 0
        var longestStreak = 0
        
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())
        
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
        
        streak = tempStreak
        
        // Calculate longest streak
        let allSortedDates = records.keys.sorted()
        var currentLongest = 0
        var tempLongest = 0
        var prevDate: Date?
        
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
        
        longestStreak = currentLongest
        
        self.currentStreak = streak
        self.longestStreak = longestStreak
    }
    
    func getDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    // MARK: - Calendar Data
    
    func getRecordsForWeek(ending date: Date) -> [DailyRecord] {
        let calendar = Calendar.current
        var records: [DailyRecord] = []
        
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: date) {
                let key = formatDate(date)
                if let record = self.records[key] {
                    records.append(record)
                } else {
                    records.append(DailyRecord(date: key, counts: [], targetCount: dailyTarget))
                }
            }
        }
        
        return records
    }
    
    func getRecordsForMonth(_ date: Date) -> [DailyRecord] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        
        var records: [DailyRecord] = []
        
        for day in range {
            var components = calendar.dateComponents([.year, .month], from: date)
            components.day = day
            
            if let date = calendar.date(from: components) {
                let key = formatDate(date)
                if let record = self.records[key] {
                    records.append(record)
                } else {
                    records.append(DailyRecord(date: key, counts: [], targetCount: dailyTarget))
                }
            }
        }
        
        return records
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
