import SwiftUI

public struct HeroSleepButton: View {
    @Bindable var state: DisplaySleepState
    @State private var isHovered = false
    @State private var isPressed = false
    
    public var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.12)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                state.triggerInstantSleep()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "powersleep")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(nsColor: .systemTeal).opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 6, x: 0, y: 0)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Desligar Tela Agora")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("⌘D")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .foregroundColor(.white)
                    }
                    
                    Text("pmset displaysleepnow")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.75))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(isHovered ? 0.95 : 0.6))
                    .offset(x: isHovered ? 2 : 0)
                    .animation(.snappy, value: isHovered)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.25, green: 0.20, blue: 0.75),
                                Color(red: 0.15, green: 0.10, blue: 0.52)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.38),
                                        Color.white.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color(red: 0.22, green: 0.16, blue: 0.70).opacity(isHovered ? 0.5 : 0.25),
                        radius: isHovered ? 10 : 5,
                        x: 0,
                        y: isHovered ? 4 : 2
                    )
            }
            .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.01 : 1.0))
            .animation(.snappy(duration: 0.18), value: isHovered)
            .animation(.snappy(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .keyboardShortcut("d", modifiers: [.command])
    }
}
