import SwiftUI

@main
struct DisplaySleepApp: App {
    @State private var state = DisplaySleepState()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(state: state)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: state.statusIconName)
                if state.isTimerActive {
                    Text(state.formattedRemainingTime)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
