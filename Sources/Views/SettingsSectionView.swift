import SwiftUI

public struct SettingsSectionView: View {
    @Bindable var state: DisplaySleepState
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Preferências")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
            
            // Menu bar icon picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Ícone da Barra:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    ForEach(MenuIconStyle.allCases) { icon in
                        Button {
                            withAnimation(.snappy(duration: 0.15)) {
                                state.selectedIcon = icon
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: icon.rawValue)
                                    .font(.system(size: 11))
                                Text(icon.displayName)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(state.selectedIcon == icon ? Color.accentColor : Color(nsColor: .controlBackgroundColor).opacity(0.45))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(state.selectedIcon == icon ? Color.white.opacity(0.25) : Color.primary.opacity(0.06), lineWidth: 1)
                            }
                            .foregroundColor(state.selectedIcon == icon ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
                .opacity(0.5)
            
            // Clean, aligned toggle list
            VStack(spacing: 6) {
                SettingToggleRow(
                    icon: "laptopcomputer.and.arrow.down",
                    title: "Dormir ao Fechar a Tampa",
                    subtitle: "Força o sono mesmo com dock/monitor",
                    isOn: $state.sleepOnLidClose
                )
                
                SettingToggleRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sinal Sonoro de Confirmação",
                    subtitle: "Toca som suave ao apagar a tela",
                    isOn: $state.soundFeedback
                )
                
                SettingToggleRow(
                    icon: "macwindow.badge.plus",
                    title: "Abrir ao Iniciar o Mac",
                    subtitle: "Inicializa junto com o sistema",
                    isOn: $state.launchAtLogin
                )
                
                SettingToggleRow(
                    icon: "arrow.down.right.and.arrow.up.left",
                    title: "Fechar Popover ao Apagar",
                    subtitle: "Recolhe o menu automaticamente",
                    isOn: $state.autoDismissPopoverOnSleep
                )
            }
            
            if let lastSleep = state.lastSleepTime {
                Divider()
                    .opacity(0.5)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text("Último sono/apagamento: \(lastSleep.formatted(date: .omitted, time: .standard))")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .glassCard(cornerRadius: 14, padding: 12)
    }
}

private struct SettingToggleRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                    .frame(width: 24, height: 24)
                
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .labelsHidden()
        }
        .padding(.vertical, 3)
    }
}
