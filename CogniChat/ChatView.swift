import SwiftUI

struct ChatView: View {
    let title: String
    @State private var message: String = ""
    @State private var messages: [ChatMessage] = []
    @EnvironmentObject private var viewModel: AppViewModel
    
    init(title: String) {
        self.title = title
        // 为默认的聊天添加一些示例消息
        if title.contains("14-Meter Spear") {
            _messages = State(initialValue: [
                ChatMessage(
                    id: UUID(),
                    sender: .user,
                    content: "古代攻城的时候，有个5*12米的长方形洞洞，士兵需要拿着14米的枪，他能否穿过这个门呢?",
                    timestamp: Date()
                ),
                ChatMessage(
                    id: UUID(),
                    sender: .assistant, 
                    content: "分析士兵无法携带14米长枪穿过洞洞。\n\n这个问题是在问士兵能否拿着14米长的枪穿过5*12米的长方形洞洞。\n\n要解决这个问题，我需要确定最长的物体能否穿过这个长方形开口。几何学上，能穿过长方形开口的最长物体的长度等于该长方形的对角线长度。\n\n计算对角线长度：\n√(5² + 12²) = √(25 + 144) = √169 = 13米\n\n由于长方形洞洞的对角线长度为13米，而士兵的枪长14米，所以士兵无法直接穿枪穿过洞洞。即使以最佳角度斜着穿过，枪的长度也超过了洞洞最大通过长度13米，因此士兵无法通过。\n\n答案是：不能，士兵无法拿着14米长的枪穿过这个5*12米的洞洞。",
                    timestamp: Date()
                )
            ])
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .foregroundStyle(.fontChat)
                Spacer()
            }
            .padding()
            .padding(.leading, 10)
            .background(Color.bgHeader)
            .overlay(
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 1), // 根据文本高度调整
                    alignment: .bottom
                )
            
            Spacer()
            
            // 消息列表
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(messages) { message in
                        MessageView(message: message)
                    }
                }
                .padding()
            }
            
            // 底部输入区
            VStack(spacing: 8) {
                Text("input")
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .background(Color.bgMain)
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        
        // 添加用户消息
        let userMessage = ChatMessage(
            id: UUID(),
            sender: .user,
            content: message,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // 清空输入框
        message = ""
        
        // 模拟AI回复（实际应用中这里会调用API）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let assistantMessage = ChatMessage(
                id: UUID(),
                sender: .assistant,
                content: "这是对你问题的回复。在实际应用中，这里会显示AI的响应内容。",
                timestamp: Date()
            )
            messages.append(assistantMessage)
        }
    }
}

// 消息数据模型
struct ChatMessage: Identifiable {
    enum Sender {
        case user
        case assistant
    }
    
    let id: UUID
    let sender: Sender
    let content: String
    let timestamp: Date
}

// 单条消息视图
struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 消息头部
            HStack {
                // 头像
                if message.sender == .user {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("N")
                                .font(.caption)
                                .foregroundColor(.black)
                        )
                } else {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
                
                // 时间戳
                Text(timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 消息内容
            Text(message.content)
                .padding(.top, 4)
                .textSelection(.enabled)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(message.sender == .assistant ? Color.gray.opacity(0.1) : Color.clear)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

#Preview {
    ChatView(title: "Test Conversation")
        .environmentObject(AppViewModel())
} 
