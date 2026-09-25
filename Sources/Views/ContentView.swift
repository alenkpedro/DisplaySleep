import SwiftUI

public struct ContentView: View {
    @Bindable var state: DisplaySleepState
    @State private var isQuitHovered = false
    
    public var body: some View {
        VStack(spacing: 12) {
            HeaderView(state: state)
            
            HeroSleepButton(state: state)
            
            if state.isTimerActive {
                ActiveTimerView(state: state)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
            } else {
                TimerPresetsView(state: state)
                    .transition(.opacity)
            }
            
            if state.isSettingsExpanded {
                SettingsSectionView(state: state)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            // Footer Bar
            HStack {
                Text("v1.0.0 • pmset utility")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.7))
                
                Spacer()
                
                Button {
                    NSApp.terminate(nil)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                            .font(.system(size: 9, weight: .bold))
                        Text("Encerrar")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(isQuitHovered ? .red : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(isQuitHovered ? Color.red.opacity(0.12) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .onHover { isQuitHovered = $0 }
                .keyboardShortcut("q", modifiers: [.command])
                .help("Encerrar o DisplaySleep (⌘Q)")
            }
            .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 320)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: state.isTimerActive)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: state.isSettingsExpanded)
    }
}
