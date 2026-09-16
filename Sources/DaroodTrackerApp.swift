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
    @StateObject private var focusManager: FocusSessionManager
    
    init() {
        let store = DaroodStore()
        _store = StateObject(wrappedValue: store)
        _focusManager = StateObject(wrappedValue: FocusSessionManager(store: store))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(experiments)
                .environmentObject(theme)
                .environmentObject(profile)
                .environmentObject(subGoals)
                .environmentObject(focusManager)
                .preferredColorScheme(theme.currentTheme == .dark ? .dark : theme.currentTheme == .light ? .light : nil)
                .onAppear {
                    setupAdaptiveNotifications()
                }
        }
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
    }
    
    private func setupAdaptiveNotifications() {
        AdaptiveNotificationEngine.shared.setupNotifications()
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
        
        let store = DaroodStore()
        let contentView = MenuBarView()
            .environmentObject(store)
            .environmentObject(ExperimentsManager.shared)
            .environmentObject(ThemeManager())
            .environmentObject(ProfileManager.shared)
            .environmentObject(SubGoalManager.shared)
            .environmentObject(FocusSessionManager(store: store))
        
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .applicationDefined
    }
    
    func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return }
            let popover = self.popover
            guard popover.isShown else { return }
            
            // Get the window that was clicked
            if let window = event.window {
                // Don't close if clicking inside any of our app's windows
                if window == popover.contentViewController?.view.window {
                    return
                }
                // Also don't close if clicking in a sheet (like settings)
                if window.sheetParent != nil {
                    return
                }
                // Don't close if clicking in a window that belongs to our app
                if window.windowController?.contentViewController != nil {
                    return
                }
            }
            
            popover.performClose(nil)
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    AdaptiveNotificationEngine.shared.setupNotifications()
                }
            }
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
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
