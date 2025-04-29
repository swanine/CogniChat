import SwiftUI

class AppViewModel: ObservableObject {
    @Published var selectedChat: ChatItem?
    @Published var recentChats: [ChatItem] = []
    @Published var isSidebarVisible: Bool = true // 控制侧边栏可见性
    
    init() {
        // 初始化一些示例聊天
        recentChats = [
            ChatItem(title: "Can a Soldier Carry a 14-Meter Spear Through a 5x12-Meter Hole?"),
            ChatItem(title: "Arranging 7 people in a mountain-shaped formation"),
            ChatItem(title: "Animated Weather Card UI with CSS"),
            ChatItem(title: "Troubleshooting Video Cover Generation"),
            ChatItem(title: "Custom Drawer Component for Content"),
            ChatItem(title: "Friendly Assistance Offered"),
            ChatItem(title: "Friendly Assistance Offered1"),
            ChatItem(title: "Friendly Assistance Offered2"),
            ChatItem(title: "Friendly Assistance Offered3")
        ]
    }
    
    func createNewChat() {
        // 创建新的聊天项
        let newChat = ChatItem(title: "新对话")
        recentChats.insert(newChat, at: 0)
        selectedChat = newChat
    }
    
    // 删除聊天
    func deleteChat(_ chat: ChatItem) {
        // 使用 removeAll(where:) 更安全地删除
        recentChats.removeAll { $0.id == chat.id }
        
        // 如果删除的是当前选中的聊天，则清空选中状态
        if selectedChat?.id == chat.id {
            selectedChat = nil
        }
    }
    
    // 切换收藏状态
    func toggleFavorite(_ chat: ChatItem) {
        // 找到需要修改的聊天的索引
        if let index = recentChats.firstIndex(where: { $0.id == chat.id }) {
            // 直接修改数组中的元素（因为 isFavorite 是 var）
            recentChats[index].isFavorite.toggle()
            
            // 如果修改的是当前选中的聊天，确保 selectedChat 也更新
            // （虽然 SwiftUI 通常会自动处理，但显式更新更保险）
             if selectedChat?.id == chat.id {
                 selectedChat = recentChats[index] 
             }
        }
    }
}

// 聊天项数据模型
struct ChatItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    var isFavorite: Bool = false // 添加收藏状态属性
    
    // 需要实现 Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatItem, rhs: ChatItem) -> Bool {
        return lhs.id == rhs.id
    }
} 
