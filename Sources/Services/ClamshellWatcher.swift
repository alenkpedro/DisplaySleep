import Foundation
import IOKit
import IOKit.pwr_mgt

/// Monitors hardware lid close events via IOKit IOPMrootDomain.
public final class ClamshellWatcher {
    public static let shared = ClamshellWatcher()
    
    private var notifyPort: IONotificationPortRef?
    private var notification: io_object_t = 0
    private var rootDomainService: io_service_t = 0
    private var isObserving: Bool = false
    private var lastLidState: Bool = false
    private var onLidClosed: (() -> Void)?
    
    private init() {}
    
    public func start(onLidClosed: @escaping () -> Void) {
        guard !isObserving else { return }
        self.onLidClosed = onLidClosed
        
        rootDomainService = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        guard rootDomainService != 0 else {
            print("[ClamshellWatcher] Could not find IOPMrootDomain service.")
            return
        }
        
        notifyPort = IONotificationPortCreate(kIOMainPortDefault)
        guard let notifyPort = notifyPort else {
            print("[ClamshellWatcher] Could not create IONotificationPort.")
            return
        }
        
        let runLoopSource = IONotificationPortGetRunLoopSource(notifyPort).takeUnretainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .defaultMode)
        
        lastLidState = isLidClosed()
        
        let callback: IOServiceInterestCallback = { refcon, service, messageType, messageArgument in
            guard let refcon = refcon else { return }
            let watcher = Unmanaged<ClamshellWatcher>.fromOpaque(refcon).takeUnretainedValue()
            watcher.checkLidStateChange()
        }
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let kr = IOServiceAddInterestNotification(
            notifyPort,
            rootDomainService,
            kIOGeneralInterest,
            callback,
            selfPtr,
            &notification
        )
        
        if kr == kIOReturnSuccess {
            isObserving = true
            print("[ClamshellWatcher] Successfully registered lid watcher.")
        } else {
            print("[ClamshellWatcher] Failed to register interest notification: \(kr)")
        }
    }
    
    public func stop() {
        guard isObserving else { return }
        
        if notification != 0 {
            IOObjectRelease(notification)
            notification = 0
        }
        if rootDomainService != 0 {
            IOObjectRelease(rootDomainService)
            rootDomainService = 0
        }
        if let notifyPort = notifyPort {
            IONotificationPortDestroy(notifyPort)
            self.notifyPort = nil
        }
        
        isObserving = false
        print("[ClamshellWatcher] Stopped lid watcher.")
    }
    
    public func isLidClosed() -> Bool {
        let service = rootDomainService != 0 ? rootDomainService : IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        defer {
            if rootDomainService == 0 && service != 0 {
                IOObjectRelease(service)
            }
        }
        guard service != 0 else { return false }
        
        if let property = IORegistryEntryCreateCFProperty(service, "AppleClamshellState" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? Bool {
            return property
        }
        return false
    }
    
    private func checkLidStateChange() {
        let currentState = isLidClosed()
        if currentState && !lastLidState {
            // Lid was just closed!
            print("[ClamshellWatcher] Lid closed detected! Triggering sleep callback.")
            DispatchQueue.main.async { [weak self] in
                self?.onLidClosed?()
            }
        }
        lastLidState = currentState
    }
    
    deinit {
        stop()
    }
}
