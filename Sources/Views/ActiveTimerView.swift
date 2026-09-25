import SwiftUI

public struct ActiveTimerView: View {
    @Bindable var state: DisplaySleepState
    @State private var isHovered = false
    
    public var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                // Circular Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 4)
                        .frame(width: 52, height: 52)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(state.timerProgress))
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 52, height: 52)
                        .animation(.linear(duration: 1.0), value: state.remainingSeconds)
                    
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Desligando em")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(state.formattedRemainingTime)
                        .font(.system(size: 26, weight: .heavy, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("Preset: \(state.activePresetLabel)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.orange.opacity(0.9))
                }
                
                Spacer()
                
                // Cancel button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        state.cancelTimer()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.secondary.opacity(isHovered ? 1.0 : 0.7))
                        .padding(6)
                }
                .buttonStyle(.plain)
                .onHover { isHovered = $0 }
                .help("Cancelar contagem regressiva")
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.orange.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.orange.opacity(0.35), lineWidth: 1)
            }
        }
    }
}
