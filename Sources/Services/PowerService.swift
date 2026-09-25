import Foundation
import AppKit

/// Service responsible for dispatching system power management commands.
public enum PowerService {
    
    /// Executes `/usr/bin/pmset displaysleepnow` to immediately power off display backlights.
    @discardableResult
    public static func sleepDisplay() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["displaysleepnow"]
        
        do {
            try process.run()
            return true
        } catch {
            print("[PowerService] Error running pmset displaysleepnow: \(error)")
            return false
        }
    }
    
    /// Executes `/usr/bin/pmset sleepnow` to put the entire computer to sleep.
    @discardableResult
    public static func sleepSystem() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["sleepnow"]
        
        do {
            try process.run()
            return true
        } catch {
            print("[PowerService] Error running pmset sleepnow: \(error)")
            return false
        }
    }
    
    /// Plays a subtle macOS sound effect for haptic/audio confirmation.
    public static func playFeedbackSound() {
        NSSound(named: "Tink")?.play()
    }
}
