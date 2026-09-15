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

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupEventMonitor()
        scheduleDailyReminder()
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
    
    func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.setupNotification()
            }
        }
    }
    
    func setupNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Darood Tracker"
        content.body = "Time for your daily darood! Don't break your streak."
        content.sound = .default
        
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
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
