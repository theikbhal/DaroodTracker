import Foundation
import ServiceManagement
import SwiftUI

class LaunchAtLoginManager: ObservableObject {
    @Published var status: SMAppService.Status = .notRegistered
    
    private let service = SMAppService.mainApp
    private let statusKey = "DaroodTracker_LaunchAtLogin"
    
    init() {
        refresh()
    }
    
    var isEnabled: Bool {
        status == .enabled
    }
    
    var isAvailable: Bool {
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundlePath.hasSuffix(".app")
    }
    
    func toggle() {
        do {
            if status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
        refresh()
    }
    
    func refresh() {
        status = service.status
    }
    
    func openLoginItemsSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
    
    var statusDescription: String? {
        switch status {
        case .notRegistered, .enabled:
            return nil
        case .requiresApproval:
            return "Approval required in System Settings"
        case .notFound:
            return "Login item not found"
        @unknown default:
            return nil
        }
    }
}
