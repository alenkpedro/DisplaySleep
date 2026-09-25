import SwiftUI

public struct HeaderView: View {
    @Bindable var state: DisplaySleepState
    
    public var body: some View {
        HStack(spacing: 8) {
            // App Branding Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                
                Image(systemName: state.statusIconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("DisplaySleep")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                
                Text("Controle de Tela")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            StatusBadge(isTimerActive: state.isTimerActive, remainingTime: state.formattedRemainingTime)
            
            // Settings button
            Button {
                withAnimation(.snappy(duration: 0.25)) {
                    state.isSettingsExpanded.toggle()
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(state.isSettingsExpanded ? .accentColor : .secondary)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Color(nsColor: .controlBackgroundColor).opacity(state.isSettingsExpanded ? 0.9 : 0.4))
                    )
            }
            .buttonStyle(.plain)
            .help("Preferências")
        }
    }
}
