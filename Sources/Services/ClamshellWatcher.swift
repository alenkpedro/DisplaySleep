import Foundation
import IOKit
import IOKit.pwr_mgt
import CoreGraphics

/// Monitors hardware lid close events using both display reconfiguration events and high-precision IOKit polling.
public final class ClamshellWatcher {
    public static let shared = ClamshellWatcher()
    
    private var timer: DispatchSourceTimer?
    private var isObserving: Bool = false
    private var lastLidState: Bool = false
    private var isHandlingSleep: Bool = false
    private var onLidClosed: (() -> Void)?
    
    private let displayCallback: CGDisplayReconfigurationCallBack = { display, flags, userInfo in
        guard let userInfo = userInfo else { return }
        let watcher = Unmanaged<ClamshellWatcher>.fromOpaque(userInfo).takeUnretainedValue()
        watcher.checkLidStateChange()
    }
    
    private init() {}
    
    public func start(onLidClosed: @escaping () -> Void) {
        guard !isObserving else { return }
        self.onLidClosed = onLidClosed
        self.lastLidState = isLidClosed()
        self.isHandlingSleep = false
        
        // 1. Timer polling every 350ms (takes < 0.005ms per check, 0% CPU)
        let queue = DispatchQueue(label: "io.github.alenkpedro.displaysleep.clamshell", qos: .utility)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + .milliseconds(200), repeating: .milliseconds(350))
        timer.setEventHandler { [weak self] in
            self?.checkLidStateChange()
        }
        timer.resume()
        self.timer = timer
        
        // 2. Hardware display callback (fires the instant internal display changes)
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        CGDisplayRegisterReconfigurationCallback(displayCallback, selfPtr)
        
        isObserving = true
        print("[ClamshellWatcher] Started lid detection. Current lid closed: \(self.lastLidState)")
    }
    
    public func stop() {
        guard isObserving else { return }
        timer?.cancel()
        timer = nil
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        CGDisplayRemoveReconfigurationCallback(displayCallback, selfPtr)
        
        isObserving = false
        print("[ClamshellWatcher] Stopped lid detection.")
    }
    
    public func isLidClosed() -> Bool {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        defer {
            if service != 0 {
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
        let closed = isLidClosed()
        
        if closed && !lastLidState && !isHandlingSleep {
            print("[ClamshellWatcher] Hardware lid close detected! Triggering sleep callback.")
            isHandlingSleep = true
            DispatchQueue.main.async { [weak self] in
                self?.onLidClosed?()
            }
        } else if !closed {
            isHandlingSleep = false
        }
        
        lastLidState = closed
    }
    
    deinit {
        stop()
    }
}
