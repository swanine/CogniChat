//
//  CogniChatApp.swift
//  CogniChat
//
//  Created by swanine on 2025/4/15.
//

import SwiftData
import SwiftUI

@main
struct CogniChatApp: App {
    // 定义一个唯一的字符串 ID 用于窗口状态持久化
    private let mainWindowIdentifier = "cognichat-main-window-v1"

    // 创建全局的 ViewModel
    @StateObject private var viewModel = AppViewModel()

    // 侧边栏可见性状态
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    // 移除不再需要的状态变量
    // @State private var isAutoSidebarToggleEnabled: Bool = true
    // @State private var didAppear: Bool = false

    var body: some Scene {
        WindowGroup(id: mainWindowIdentifier) {
            GeometryReader { geometry in // 使用 GeometryReader 获取尺寸
                NavigationSplitView(columnVisibility: $columnVisibility) { // 绑定可见性状态
                    SidebarView()
                        .environmentObject(viewModel)
                        .navigationSplitViewColumnWidth(
                                    min: 150, ideal: 200, max: 400)
                        
                } detail: {
                    if let selectedChat = viewModel.selectedChat {
                        ChatView(title: selectedChat.title)
                            .environmentObject(viewModel)
                    } else {
                        ContentView()
                            .environmentObject(viewModel)
                    }
                }
                .navigationSplitViewStyle(.balanced) // 平衡左右宽度
                // 监听宽度变化 (只用于自动关闭)
                .onChange(of: geometry.size.width) { oldValue, newValue in // 使用新的 onChange 签名
                    // 传递 oldValue 和 newValue
                    handleWidthChange(oldValue: oldValue, newValue: newValue)
                }
                .onAppear {
                    // 设置初始状态
                    let initialWidth = geometry.size.width
                    print("[onAppear] Initial Width: \(initialWidth)")
                    if initialWidth > 0 && initialWidth <= 600 { // 确保宽度有效且小于等于阈值
                        // 初始宽度较小时，默认关闭
                        print("[onAppear] Setting initial visibility to .detailOnly")
                        columnVisibility = .detailOnly
                    } else {
                        print("[onAppear] Initial visibility remains .doubleColumn (default or > 600)")
                    }
                }
            }
            // 将 minWidth/minHeight 应用到 GeometryReader (根视图)
            .frame(minWidth: 600, minHeight: 400)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 700)
        .defaultPosition(.center)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建对话") {
                    viewModel.createNewChat()
                }
                .keyboardShortcut("n", modifiers: [.command])
            }

            CommandGroup(replacing: .sidebar) {
                
            }

            CommandGroup(replacing: .textEditing) {
                // 文本编辑相关命令（可扩展）
            }

            CommandMenu("对话") {
                Button("导出对话...") {
                    print("执行导出对话操作...")
                }

                Button("导入对话...") {
                    print("执行导入对话操作...")
                }
            }

            CommandGroup(replacing: .help) {
                Button("CogniChat 帮助") {
                    print("打开 CogniChat 帮助文档...")

                    if let url = URL(string: "http://swanine.me") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }

            CommandGroup(after: .appSettings) {
                Button("设置...") {
                    print("打开设置窗口...")
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }
    
    // 处理窗口宽度变化 (仅在跨越阈值时自动关闭)
    private func handleWidthChange(oldValue: CGFloat, newValue: CGFloat) {
        print("[handleWidthChange] Old: \(oldValue), New: \(newValue), Visibility: \(columnVisibility)")
        guard newValue > 0 else { 
            print("[handleWidthChange] Invalid width (<= 0), returning.")
            return 
        } // 确保宽度有效
        
        // 仅当宽度从 >600 变为 <=600 且侧边栏打开时，才自动关闭
        if newValue <= 600 && oldValue > 600 && columnVisibility == .doubleColumn {
            print("[handleWidthChange] Threshold crossed downwards (\(oldValue) > 600 >= \(newValue)) and sidebar open. Closing sidebar.")
            withAnimation { // 使用动画平滑过渡
                columnVisibility = .detailOnly
            }
        } else {
             print("[handleWidthChange] Condition NOT met (not crossing threshold downwards, or sidebar already closed). Doing nothing.")
        }
        // 注意：宽度变大时不做任何操作
    }
}
