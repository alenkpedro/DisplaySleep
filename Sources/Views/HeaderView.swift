import SwiftUI

public struct HeaderView: View {
    @Bindable var state: DisplaySleepState
    
    public var body: some View {
        VStack(spacing: 8) {
            // Centered Branding Icon with Soft Ambient Glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.indigo.opacity(0.4),
                                Color.purple.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 32
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: state.statusIconName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(nsColor: .systemIndigo).opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .indigo.opacity(0.7), radius: 8, x: 0, y: 2)
            }
            .padding(.top, 2)
            
            // App Title and Status Pill
            HStack(spacing: 6) {
                Text("DisplaySleep")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                
                StatusBadge(isTimerActive: state.isTimerActive, remainingTime: state.formattedRemainingTime)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 2)
    }
}
