import SwiftUI
import UserNotifications

@main
struct DaroodTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = DaroodStore()
    @StateObject private var experiments = ExperimentsManager.shared
    @StateObject private var theme = ThemeManager()
    @StateObject private var profile = ProfileManager.shared
    @StateObject private var subGoals = SubGoalManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(experiments)
                .environmentObject(theme)
                .environmentObject(profile)
                .environmentObject(subGoals)
                .preferredColorScheme(theme.currentTheme == .dark ? .dark : theme.currentTheme == .light ? .light : nil)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 320, height: 480)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupEventMonitor()
        requestNotificationPermission()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "Darood")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        let contentView = MenuBarView()
            .environmentObject(DaroodStore())
            .environmentObject(ExperimentsManager.shared)
            .environmentObject(ThemeManager())
            .environmentObject(ProfileManager.shared)
            .environmentObject(SubGoalManager.shared)
        
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
    }
    
    func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.scheduleDailyReminder()
                }
            }
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // Morning reminder
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Darood Tracker"
        morningContent.body = "Start your day with darood! You have 1100 to complete today."
        morningContent.sound = .default
        morningContent.badge = 1
        
        var morningComponents = DateComponents()
        morningComponents.hour = 8
        morningComponents.minute = 0
        
        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningComponents, repeats: true)
        let morningRequest = UNNotificationRequest(identifier: "morning_reminder", content: morningContent, trigger: morningTrigger)
        center.add(morningRequest)
        
        // Afternoon reminder
        let afternoonContent = UNMutableNotificationContent()
        afternoonContent.title = "Darood Tracker - Afternoon"
        afternoonContent.body = "Don't forget to complete your darood before 6 PM!"
        afternoonContent.sound = .default
        afternoonContent.badge = 1
        
        var afternoonComponents = DateComponents()
        afternoonComponents.hour = 14
        afternoonComponents.minute = 0
        
        let afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: afternoonComponents, repeats: true)
        let afternoonRequest = UNNotificationRequest(identifier: "afternoon_reminder", content: afternoonContent, trigger: afternoonTrigger)
        center.add(afternoonRequest)
        
        // Evening deadline reminder
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Darood Tracker - Deadline"
        eveningContent.body = "Only 2 hours left! Complete your darood before 6 PM."
        eveningContent.sound = .default
        eveningContent.badge = 1
        
        var eveningComponents = DateComponents()
        eveningComponents.hour = 16
        eveningComponents.minute = 0
        
        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComponents, repeats: true)
        let eveningRequest = UNNotificationRequest(identifier: "evening_reminder", content: eveningContent, trigger: eveningTrigger)
        center.add(eveningRequest)
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Open the app when notification is tapped
        if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        completionHandler()
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
