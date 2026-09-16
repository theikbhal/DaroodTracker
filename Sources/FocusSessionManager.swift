import Foundation
import SwiftUI
import Combine

class FocusSessionManager: ObservableObject {
    @Published var isSessionActive = false
    @Published var elapsedSeconds: Int = 0
    @Published var daroodCount: Int = 0
    @Published var currentBatch: Int = 1
    @Published var showMicroBreak = false
    @Published var showBatchBreak = false
    @Published var microBreakCountdown: Int = 10
    @Published var batchBreakCountdown: Int = 30
    @Published var isIdle = false
    @Published var idleSeconds: Int = 0
    @Published var sessionDaroodPerMinute: Double = 0
    
    private var sessionTimer: Timer?
    private var breakTimer: Timer?
    private var idleTimer: Timer?
    private var lastCountTime: Date?
    private let store: DaroodStore
    
    // Settings
    @AppStorage("focusModeEnabled") var focusModeEnabled = true
    @AppStorage("autoStartFocus") var autoStartFocus = true
    @AppStorage("microBreakAfterCount") var microBreakAfterCount = 10
    @AppStorage("microBreakDuration") var microBreakDuration = 10
    @AppStorage("batchBreakDuration") var batchBreakDuration = 30
    @AppStorage("idleDetectionEnabled") var idleDetectionEnabled = true
    @AppStorage("idleThresholdSeconds") var idleThresholdSeconds = 120
    
    let dailyTarget = 1100
    let batchSize = 100
    
    init(store: DaroodStore) {
        self.store = store
        self.daroodCount = store.todayTotalCount
        self.currentBatch = (store.todayTotalCount / batchSize) + 1
        
        if autoStartFocus && focusModeEnabled {
            startSession()
        }
    }
    
    var todayProgress: Double {
        Double(daroodCount) / Double(dailyTarget)
    }
    
    var remainingCount: Int {
        max(0, dailyTarget - daroodCount)
    }
    
    var completedBatches: Int {
        daroodCount / batchSize
    }
    
    var remainingBatches: Int {
        11 - completedBatches
    }
    
    var paceNeeded: Double {
        let remaining = Double(remainingCount)
        let hoursLeft = hoursUntilDeadline()
        guard hoursLeft > 0 else { return remaining }
        return remaining / hoursLeft
    }
    
    var formattedElapsed: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var isAheadOfSchedule: Bool {
        let expectedProgress = expectedProgressForNow()
        return todayProgress >= expectedProgress
    }
    
    // MARK: - Session Control
    
    func startSession() {
        guard !isSessionActive else { return }
        isSessionActive = true
        elapsedSeconds = 0
        lastCountTime = Date()
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        
        startIdleDetection()
    }
    
    func stopSession() {
        isSessionActive = false
        sessionTimer?.invalidate()
        sessionTimer = nil
        breakTimer?.invalidate()
        breakTimer = nil
        idleTimer?.invalidate()
        idleTimer = nil
        isIdle = false
        idleSeconds = 0
    }
    
    func toggleSession() {
        if isSessionActive {
            stopSession()
        } else {
            startSession()
        }
    }
    
    // MARK: - Counting
    
    func addCount(_ count: Int = 1) {
        daroodCount += count
        lastCountTime = Date()
        isIdle = false
        idleSeconds = 0
        
        store.addCount(count)
        updatePace()
        checkBreakThreshold()
    }
    
    func addBatch() {
        let count = batchSize
        addCount(count)
    }
    
    private func updatePace() {
        guard elapsedSeconds > 0 else { return }
        sessionDaroodPerMinute = Double(daroodCount) / Double(elapsedSeconds) * 60.0
    }
    
    private func checkBreakThreshold() {
        let inBatch = daroodCount % batchSize
        
        // Micro break after every N darood within a batch
        if inBatch > 0 && inBatch % microBreakAfterCount == 0 && daroodCount % batchSize != 0 {
            triggerMicroBreak()
        }
        
        // Batch break after every 100
        if daroodCount > 0 && daroodCount % batchSize == 0 {
            triggerBatchBreak()
        }
        
        // Goal complete
        if daroodCount >= dailyTarget {
            NotificationCenter.default.post(name: .goalComplete, object: nil)
        }
    }
    
    // MARK: - Breaks
    
    private func triggerMicroBreak() {
        showMicroBreak = true
        microBreakCountdown = microBreakDuration
        SoundManager.shared.play(.batchComplete)
        
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.microBreakCountdown -= 1
                if self.microBreakCountdown <= 0 {
                    self.endMicroBreak()
                }
            }
        }
    }
    
    func endMicroBreak() {
        showMicroBreak = false
        breakTimer?.invalidate()
        breakTimer = nil
        SoundManager.shared.play(.tick)
    }
    
    func skipMicroBreak() {
        endMicroBreak()
    }
    
    private func triggerBatchBreak() {
        showBatchBreak = true
        batchBreakCountdown = batchBreakDuration
        SoundManager.shared.play(.goalComplete)
        
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.batchBreakCountdown -= 1
                if self.batchBreakCountdown <= 0 {
                    self.endBatchBreak()
                }
            }
        }
    }
    
    func endBatchBreak() {
        showBatchBreak = false
        breakTimer?.invalidate()
        breakTimer = nil
        currentBatch = completedBatches + 1
        SoundManager.shared.play(.tick)
    }
    
    func skipBatchBreak() {
        endBatchBreak()
    }
    
    // MARK: - Idle Detection
    
    private func startIdleDetection() {
        guard idleDetectionEnabled else { return }
        
        idleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.checkIdle()
            }
        }
    }
    
    private func checkIdle() {
        guard let lastCount = lastCountTime else { return }
        let idle = Int(Date().timeIntervalSince(lastCount))
        
        if idle >= idleThresholdSeconds {
            if !isIdle {
                isIdle = true
                idleSeconds = idle
                NotificationCenter.default.post(name: .idleDetected, object: idle)
            }
            idleSeconds = idle
        }
    }
    
    // MARK: - Time Calculations
    
    private func hoursUntilDeadline() -> Double {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 18 // 6 PM deadline
        components.minute = 0
        
        guard let deadline = calendar.date(from: components) else { return 1 }
        let remaining = deadline.timeIntervalSince(now)
        return max(0, remaining / 3600)
    }
    
    private func expectedProgressForNow() -> Double {
        let calendar = Calendar.current
        let now = Date()
        var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
        startComponents.hour = 6 // Assume 6 AM start
        startComponents.minute = 0
        
        guard let startTime = calendar.date(from: startComponents) else { return 0 }
        let totalDaySeconds = 18.0 * 3600 // 6 AM to 6 PM
        let elapsed = now.timeIntervalSince(startTime)
        
        return min(1.0, max(0, elapsed / totalDaySeconds))
    }
    
    // MARK: - Timer Tick
    
    private func tick() {
        elapsedSeconds += 1
        updatePace()
    }
    
    func resetSession() {
        stopSession()
        daroodCount = 0
        elapsedSeconds = 0
        currentBatch = 1
        sessionDaroodPerMinute = 0
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let goalComplete = Notification.Name("goalComplete")
    static let idleDetected = Notification.Name("idleDetected")
    static let microBreakStarted = Notification.Name("microBreakStarted")
    static let batchBreakStarted = Notification.Name("batchBreakStarted")
}
