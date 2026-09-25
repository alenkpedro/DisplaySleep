import SwiftUI

public struct ContentView: View {
    @Bindable var state: DisplaySleepState
    var closeAction: (() -> Void)? = nil
    
    @State private var isSettingsHovered = false
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
            
            // Bottom Action Bar (Ajustes & Sair) styled like Vorssaint
            HStack(spacing: 10) {
                // Ajustes Button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        state.isSettingsExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(state.isSettingsExpanded ? "Fechar Ajustes" : "Ajustes")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(state.isSettingsExpanded ? .accentColor : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor).opacity(state.isSettingsExpanded ? 0.9 : 0.5))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(
                                state.isSettingsExpanded ?
                                Color.accentColor.opacity(0.3) :
                                Color.primary.opacity(isSettingsHovered ? 0.15 : 0.08),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .onHover { isSettingsHovered = $0 }
                
                // Sair Button
                Button {
                    NSApp.terminate(nil)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "power")
                            .font(.system(size: 11, weight: .bold))
                        Text("Sair")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(isQuitHovered ? .red : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                isQuitHovered ?
                                Color.red.opacity(0.12) :
                                Color(nsColor: .controlBackgroundColor).opacity(0.5)
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(
                                isQuitHovered ?
                                Color.red.opacity(0.35) :
                                Color.primary.opacity(0.08),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .onHover { isQuitHovered = $0 }
                .keyboardShortcut("q", modifiers: [.command])
                .help("Encerrar o DisplaySleep (⌘Q)")
            }
            .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 310)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: state.isTimerActive)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: state.isSettingsExpanded)
    }
}
