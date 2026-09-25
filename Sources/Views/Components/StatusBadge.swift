import SwiftUI

public struct StatusBadge: View {
    public let isTimerActive: Bool
    public let remainingTime: String
    
    public var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isTimerActive ? Color.orange : Color.green)
                .frame(width: 7, height: 7)
                .shadow(color: (isTimerActive ? Color.orange : Color.green).opacity(0.6), radius: 3, x: 0, y: 0)
            
            Text(isTimerActive ? "Timer \(remainingTime)" : "Pronto")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(isTimerActive ? .orange : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        }
        .overlay {
            Capsule()
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        }
    }
}
