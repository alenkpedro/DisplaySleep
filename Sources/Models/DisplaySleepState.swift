import SwiftUI
import Observation
import ServiceManagement

public enum MenuIconStyle: String, CaseIterable, Identifiable {
    case moon = "moon.fill"
    case display = "display"
    case moonZzz = "moon.zzz.fill"
    case bolt = "bolt.fill"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .moon: return "Lua"
        case .display: return "Tela"
        case .moonZzz: return "Sono"
        case .bolt: return "Raio"
        }
    }
}

public struct TimerPreset: Identifiable, Equatable {
    public let id = UUID()
    public let seconds: Int
    public let label: String
    
    public static let standard: [TimerPreset] = [
        TimerPreset(seconds: 15, label: "15s"),
        TimerPreset(seconds: 30, label: "30s"),
        TimerPreset(seconds: 60, label: "1m"),
        TimerPreset(seconds: 300, label: "5m"),
        TimerPreset(seconds: 600, label: "10m"),
        TimerPreset(seconds: 900, label: "15m"),
        TimerPreset(seconds: 1800, label: "30m"),
        TimerPreset(seconds: 3600, label: "1h")
    ]
}

@Observable
@MainActor
public final class DisplaySleepState {
    public var isTimerActive: Bool = false
    public var remainingSeconds: Int = 0
    public var totalTimerSeconds: Int = 0
    public var activePresetLabel: String = ""
    public var isSettingsExpanded: Bool = false {
        didSet {
            onRequestResize?()
        }
    }
    public var lastSleepTime: Date? = nil
    
    public var onStateChange: (() -> Void)?
    public var requestClosePopover: (() -> Void)?
    public var onRequestResize: (() -> Void)?
    
    public var selectedIcon: MenuIconStyle = .moon {
        didSet {
            UserDefaults.standard.set(selectedIcon.rawValue, forKey: "SelectedMenuIcon")
            onStateChange?()
        }
    }
    
    public var soundFeedback: Bool = true {
        didSet {
            UserDefaults.standard.set(soundFeedback, forKey: "SoundFeedback")
        }
    }
    
    public var autoDismissPopoverOnSleep: Bool = true {
        didSet {
            UserDefaults.standard.set(autoDismissPopoverOnSleep, forKey: "AutoDismissPopover")
        }
    }
    
    public var sleepOnLidClose: Bool = false {
        didSet {
            UserDefaults.standard.set(sleepOnLidClose, forKey: "SleepOnLidClose")
            updateLidWatcher(sleepOnLidClose)
        }
    }
    
    public var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin(launchAtLogin)
        }
    }
    
    private var timerTask: Task<Void, Never>? = nil
    
    public init() {
        if let savedIcon = UserDefaults.standard.string(forKey: "SelectedMenuIcon"),
           let icon = MenuIconStyle(rawValue: savedIcon) {
            self.selectedIcon = icon
        }
        if UserDefaults.standard.object(forKey: "SoundFeedback") != nil {
            self.soundFeedback = UserDefaults.standard.bool(forKey: "SoundFeedback")
        }
        if UserDefaults.standard.object(forKey: "AutoDismissPopover") != nil {
            self.autoDismissPopoverOnSleep = UserDefaults.standard.bool(forKey: "AutoDismissPopover")
        }
        if UserDefaults.standard.object(forKey: "SleepOnLidClose") != nil {
            self.sleepOnLidClose = UserDefaults.standard.bool(forKey: "SleepOnLidClose")
        }
        
        // Check Launch at Login status
        if #available(macOS 13.0, *) {
            self.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
        
        if self.sleepOnLidClose {
            updateLidWatcher(true)
        }
    }
    
    public var statusIconName: String {
        if isTimerActive {
            return "timer"
        }
        return selectedIcon.rawValue
    }
    
    public var formattedRemainingTime: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    public var timerProgress: Double {
        guard totalTimerSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalTimerSeconds)
    }
    
    public func triggerInstantSleep() {
        if soundFeedback {
            PowerService.playFeedbackSound()
        }
        lastSleepTime = Date()
        PowerService.sleepDisplay()
        
        if autoDismissPopoverOnSleep {
            requestClosePopover?()
            NSApp.hide(nil)
        }
    }
    
    public func startTimer(seconds: Int, label: String) {
        cancelTimer()
        
        totalTimerSeconds = seconds
        remainingSeconds = seconds
        activePresetLabel = label
        isTimerActive = true
        onStateChange?()
        
        timerTask = Task { @MainActor in
            while self.remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                self.remainingSeconds -= 1
                self.onStateChange?()
            }
            
            if !Task.isCancelled {
                self.isTimerActive = false
                self.onStateChange?()
                self.triggerInstantSleep()
            }
        }
    }
    
    public func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        isTimerActive = false
        remainingSeconds = 0
        totalTimerSeconds = 0
        activePresetLabel = ""
        onStateChange?()
    }
    
    private func updateLidWatcher(_ enable: Bool) {
        if enable {
            ClamshellWatcher.shared.start { [weak self] in
                Task { @MainActor in
                    self?.lastSleepTime = Date()
                    if self?.soundFeedback == true {
                        PowerService.playFeedbackSound()
                    }
                    PowerService.sleepDisplay()
                    PowerService.sleepSystem()
                }
            }
        } else {
            ClamshellWatcher.shared.stop()
        }
    }
    
    private func updateLaunchAtLogin(_ enable: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enable {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("[DisplaySleep] Erro ao alterar Launch at Login: \(error)")
            }
        }
    }
}
