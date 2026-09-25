import SwiftUI

public struct TimerPresetsView: View {
    @Bindable var state: DisplaySleepState
    
    let presets = TimerPreset.standard
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Desligar com Timer", systemImage: "timer")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Selecione um tempo")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            
            // Flow of preset chips
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(presets) { preset in
                    PresetChip(
                        preset: preset,
                        isSelected: state.isTimerActive && state.totalTimerSeconds == preset.seconds
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            state.startTimer(seconds: preset.seconds, label: preset.label)
                        }
                    }
                }
            }
        }
        .glassCard(cornerRadius: 14, padding: 12)
    }
}

private struct PresetChip: View {
    let preset: TimerPreset
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(preset.label)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : (isHovered ? .primary : .secondary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            isSelected ?
                            Color.accentColor :
                            Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.9 : 0.4)
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(
                            isSelected ?
                            Color.white.opacity(0.3) :
                            Color.primary.opacity(isHovered ? 0.15 : 0.05),
                            lineWidth: 1
                        )
                }
                .scaleEffect(isHovered ? 1.04 : 1.0)
                .animation(.snappy(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
