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
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseDown])
        }
        
        // Native NSPopover with caret ("perninha")
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
        
        let contentView = ContentView(state: state, closeAction: { [weak self] in
            self?.popover.performClose(nil)
        })
        let hostingController = NSHostingController(rootView: contentView)
        popover.contentViewController = hostingController
        
        // Layout and set initial size so it never renders with (0,0)
        hostingController.view.layoutSubtreeIfNeeded()
        let fittingSize = hostingController.view.fittingSize
        popover.contentSize = NSSize(width: max(fittingSize.width, 310), height: max(fittingSize.height, 350))
        
        // Connect state hooks
        state.onStateChange = { [weak self] in
            self?.updateStatusBarButton()
        }
        
        state.onRequestResize = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let hosting = self.popover.contentViewController {
                    hosting.view.needsLayout = true
                    hosting.view.layoutSubtreeIfNeeded()
                    let newSize = hosting.view.fittingSize
                    self.popover.contentSize = NSSize(width: max(newSize.width, 310), height: newSize.height)
                }
            }
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
            // Update size to current content before showing
            if let hosting = popover.contentViewController {
                hosting.view.needsLayout = true
                hosting.view.layoutSubtreeIfNeeded()
                let size = hosting.view.fittingSize
                popover.contentSize = NSSize(width: max(size.width, 310), height: size.height)
            }
            
            // Show anchored to button with .maxY (draws top arrow caret and centers horizontally)
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
