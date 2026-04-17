import SwiftUI

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .assistant {
                Circle()
                    .fill(Color.accentColor.gradient)
                    .frame(width: 28, height: 28)
                    .overlay {
                        Text("🤖")
                            .font(.system(size: 14))
                    }
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background {
                        if message.role == .user {
                            Color.accentColor
                        } else {
                            Color(.secondarySystemBackground)
                        }
                    }
                    .clipShape(ChatBubbleShape(isUser: message.role == .user))
            }

            if message.role == .user {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Text("👤")
                            .font(.system(size: 14))
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}

struct ChatBubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 16
        var path = Path()

        if isUser {
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
            // cut bottom-left corner
            path.move(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - r))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r), radius: r,
                       startAngle: .degrees(90), endAngle: .degrees(180), clockwise: true)
        } else {
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
            // cut bottom-right corner
            path.move(to: CGPoint(x: rect.maxX - r, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r), radius: r,
                       startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)
        }
        return path
    }
}
