import SwiftUI

public struct SettingsSectionView: View {
    @Bindable var state: DisplaySleepState
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferências")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
            
            // Menu bar icon picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Ícone da Barra:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(MenuIconStyle.allCases) { icon in
                        Button {
                            withAnimation(.snappy(duration: 0.15)) {
                                state.selectedIcon = icon
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: icon.rawValue)
                                    .font(.system(size: 11))
                                Text(icon.displayName)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(state.selectedIcon == icon ? Color.accentColor : Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            }
                            .foregroundColor(state.selectedIcon == icon ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
                .opacity(0.5)
            
            // Toggles
            VStack(spacing: 8) {
                Toggle(isOn: $state.sleepOnLidClose) {
                    VStack(alignment: .leading, spacing: 1) {
                        Label("Dormir ao Fechar a Tampa", systemImage: "laptopcomputer.and.arrow.down")
                            .font(.system(size: 11, weight: .medium))
                        Text("Força o sono mesmo com dock/monitor")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                
                Toggle(isOn: $state.soundFeedback) {
                    Label("Sinal Sonoro de Confirmação", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 11, weight: .medium))
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                
                Toggle(isOn: $state.launchAtLogin) {
                    Label("Abrir ao Iniciar o Mac", systemImage: "macwindow.badge.plus")
                        .font(.system(size: 11, weight: .medium))
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                
                Toggle(isOn: $state.autoDismissPopoverOnSleep) {
                    Label("Fechar Popover ao Apagar", systemImage: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 11, weight: .medium))
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
            }
            
            if let lastSleep = state.lastSleepTime {
                Divider()
                    .opacity(0.5)
                
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text("Último sono/apagamento: \(lastSleep.formatted(date: .omitted, time: .standard))")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .glassCard(cornerRadius: 14, padding: 12)
    }
}
