import SwiftUI

struct ChatActionMenuView: View {
    let chat: ChatItem
    @ObservedObject var viewModel: AppViewModel
    // 可以添加一个 @Environment(\.dismiss) var dismiss 来手动关闭 popover (如果需要)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 收藏按钮
            Button {
                viewModel.toggleFavorite(chat)
                // 点击后通常希望菜单消失
                // dismiss() // 如果需要手动关闭
            } label: {
                Image(systemName: "star")
                // 自定义按钮样式
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle()) // 确保整个区域可点击
            }
            .buttonStyle(.plain) // 使用无边框样式，以便自定义背景反馈
            // .background(...) // 可以添加悬停时的背景效果

            Divider()

            // 删除按钮
            Button(role: .destructive) {
                viewModel.deleteChat(chat)
                // dismiss()
            } label: {
                Image(systemName: "trash")
                 
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // .background(...)
        }
        // 固定宽度，防止内容变化导致 popover 大小跳动
        .frame(width: 40)
    }
}

// Preview (可选，但建议添加)
#Preview {
    // 创建一个示例 ChatItem 和 ViewModel 用于预览
    let sampleChat = ChatItem(title: "Sample Chat", isFavorite: false)
    let sampleViewModel = AppViewModel()
    // 添加示例聊天以便删除/收藏操作能在预览中反映（虽然预览不持久）
    // sampleViewModel.recentChats.append(sampleChat) 
    
    return ChatActionMenuView(chat: sampleChat, viewModel: sampleViewModel)
        .padding(8)
        .background(Material.regularMaterial)
        .cornerRadius(8)
        .shadow(radius: 5)
        // 提供环境对象以便预览正常工作
        .environmentObject(sampleViewModel) 
} 
