import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var hoveredId: UUID? = nil
    @State private var ellipsisHoveredId: UUID? = nil
    @State private var presentingMenuForChat: ChatItem? = nil // State for custom menu

    var body: some View {
        VStack(spacing: 0) {
            // 顶部固定项目
            // 新聊天按钮
            Button(action: {
                viewModel.createNewChat()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .frame(width: 20, height: 20)
                        
                    Text("New chat")
                    Spacer()
                }
                .foregroundColor(Color.icon)
                .contentShape(Rectangle())
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .padding(.top, 18)

            Button(action: {
                print("Projects")
            }) {
                HStack {
                    Image(systemName: "folder")
                        .frame(width: 20, height: 20)
                    Text("Projects")
                    Spacer()
                }
                .foregroundColor(.fontSiderbar)
                .contentShape(Rectangle())
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Button(action: {
                print("Chats")
            }) {
                HStack {
                    Image(systemName: "bubble.left.fill")
                        .frame(width: 20, height: 20)
                    Text("Chats")
                    Spacer()
                }
                .foregroundColor(.fontSiderbar)
                .contentShape(Rectangle())
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Recents")
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            

            // 最近聊天列表
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 2) {
                    
                    ForEach(viewModel.recentChats) { chat in
                        Button {
                            viewModel.selectedChat = chat
                        } label: {
                            HStack(spacing: 0) {
                                // 使用 ZStack 来处理渐变和文本叠加
                                ZStack(alignment: .trailing) {
                                    // 聊天标题
                                    Text(chat.title)
                                        .lineLimit(1)
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )

                                    // 当选中时添加渐变效果
                                    if viewModel.selectedChat?.id == chat.id {
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                .clear, Color.bgSiderSelect,
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(width: 50)
                                    }
                                }

                                // 修改显示条件：行被选中、悬停，或者其菜单正在显示时
                                if viewModel.selectedChat?.id == chat.id || hoveredId == chat.id || presentingMenuForChat?.id == chat.id {
                                    // 使用 Button 触发 Popover
                                    Button {
                                        presentingMenuForChat = chat
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .frame(width: 16, height: 16)
                                            .background( // 条件性添加背景
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(ellipsisHoveredId == chat.id ? Color.gray.opacity(0.2) : Color.clear)
                                            )
                                            .animation(.easeInOut(duration: 0.15), value: ellipsisHoveredId)
                                            .onHover { hovering in
                                                ellipsisHoveredId = hovering ? chat.id : nil
                                            }
                                    }
                                    .buttonStyle(.borderless) // 移除按钮默认样式
                                    .popover(
                                        isPresented: Binding<Bool>(
                                            get: { presentingMenuForChat?.id == chat.id },
                                            set: { if !$0 { presentingMenuForChat = nil } }
                                        ),
                                        attachmentAnchor: .point(.center),
                                        arrowEdge: .bottom
                                    ) {
                                        // 自定义菜单视图 (稍后创建)
                                        ChatActionMenuView(chat: chat, viewModel: viewModel)
                                            // 可以给 popover 添加一些内边距和样式
                                            .padding(8)
                                            .background(Material.regularMaterial) // 使用毛玻璃效果
                                            .cornerRadius(8)
                                            .shadow(radius: 5)
                                    }
                                }
                            }
                            .padding(8)
                            .contentShape(Rectangle())  // 确保整个区域可点击
                        }
                        .foregroundColor(viewModel.selectedChat?.id == chat.id ? Color.fontChat : Color.fontSiderbar)
                        .buttonStyle(.borderless)
                        .background(
                            Group {
                                if viewModel.selectedChat?.id == chat.id {  // 选中状态
                                    Color.bgSiderSelect
                                } else if hoveredId == chat.id {  // 悬停状态
                                    Color.bgSiderSelect.opacity(0.5)
                                } else {  // 默认状态
                                    Color.clear
                                }
                            }
                        )
                        // 添加动画效果
                        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedChat?.id)
                        .animation(.easeInOut(duration: 0.15), value: hoveredId)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .onHover { isHovered in
                            // 更新行的悬停状态，同时确保 ellipsis 悬停状态被重置
                            if !isHovered {
                                ellipsisHoveredId = nil
                            }
                            hoveredId = isHovered ? chat.id : nil
                        }
                    }
                }
                // 在 VStack 上添加动画，监听 recentChats 的变化
                .animation(.default, value: viewModel.recentChats)
                .background(Color.bgSiderbar)
                .frame(maxWidth: .infinity)
            }
            .background(Color.bgSiderbar)
            // 添加顶部和底部渐变蒙版
            .mask(
                VStack(spacing: 0) {
                    // 顶部渐变
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 20) // 渐变的高度，可以调整
                    Rectangle().fill(Color.black)
                    // 底部渐变
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 20) // 渐变的高度，可以调整
                }
            )

            Spacer()

            // 固定底部
            HStack {
                Image(systemName: "gearshape")
                    .frame(width: 20, height: 20)
                Text("Settings")
                Spacer()
            }
            .foregroundColor(.fontSiderbar)
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            
        }
        .padding(8)
        .background(Color.bgSiderbar)
        .frame(minWidth: 180, maxWidth: 400, minHeight: 400)

    }
}

#Preview {
    SidebarView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.light)
}
