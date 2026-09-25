import AppKit
import SwiftUI

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let state = DisplaySleepState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Create Status Item in Menu Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: state.statusIconName, accessibilityDescription: "DisplaySleep")
            button.imagePosition = .imageLeading
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        // Native NSPopover with triangular arrow caret ("perninha")
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
        
        let contentView = ContentView(state: state, closeAction: { [weak self] in
            self?.popover.performClose(nil)
        })
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        // Connect state hooks
        state.onStateChange = { [weak self] in
            self?.updateStatusBarButton()
        }
        
        state.requestClosePopover = { [weak self] in
            self?.popover.performClose(nil)
        }
        
        updateStatusBarButton()
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Anchor to button bounds with preferredEdge: .maxY to center popover and show the arrow ("perninha")
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    private func updateStatusBarButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: state.statusIconName, accessibilityDescription: "DisplaySleep")
        if state.isTimerActive {
            button.title = " \(state.formattedRemainingTime)"
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
        } else {
            button.title = ""
        }
    }
}
