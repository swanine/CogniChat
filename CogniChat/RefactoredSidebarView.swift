import SwiftUI

struct RefactoredSidebarView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var scrollOffset: CGFloat = 0
    
    // 定义动画触发的滚动阈值
    let animationThreshold: CGFloat = 80.0 // 可根据需要调整

    var body: some View {
        GeometryReader { geometry in // 使用 GeometryReader 获取安全区域
            VStack(spacing: 0) {
                HeaderArea(
                    safeAreaTop: geometry.safeAreaInsets.top, // 传入安全区域顶部边距
                    scrollOffset: scrollOffset,
                    threshold: animationThreshold
                )
                .background(Color.header.gradient) // 标题栏背景
                .zIndex(1) // 确保标题栏在最上层

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) { // 使用 0 间距使视觉上连接
                        // 在滚动内容顶部添加一个占位符或不可见元素
                        // 用于定义初始滚动位置（偏移量为 0）
                        // 如果需要，其高度应大致对应于初始按钮区域的高度，
                        // 或者如果偏移计算能处理起始位置，则可以设为最小。
                        Color.clear.frame(height: 1) // 最小占位符

                        // 可滚动内容
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            ForEach(1...20, id: \.self) { _ in // 增加项目数量以便更好地测试滚动
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 100)
                            }
                        }
                        .padding() // 在网格周围添加填充
                        .background(Color.bg) // 内容区域背景
                    }
                    .offset(coordinateSpace: .named("SCROLL")) { offset in
                        // 更新滚动偏移量
                        scrollOffset = offset
                    }
                }
                .coordinateSpace(name: "SCROLL")
                .background(Color.bg) // 确保 ScrollView 背景覆盖
            }
            // These paddings seem incorrectly placed on the VStack containing Header and ScrollView
            // These should likely be inside the HeaderArea or applied differently.
            // Consider reviewing placement of these modifiers.
            // 这些 padding 似乎错误地放在了包含 Header 和 ScrollView 的 VStack 上
            // 可能应该放在 HeaderArea 内部或以不同方式应用。
            // 考虑检查这些修饰符的位置。
            .padding(.horizontal, 15)
            .padding(.bottom, 10) // 最终按钮行之前的间距
            .padding(.top, geometry.safeAreaInsets.top + 10) // 使用传入的安全区域顶部值
            .ignoresSafeArea(.all, edges: .top) // 允许内容延伸到状态栏/安全区域顶部下方
            .background(Color.bg) // 整体背景
            .environment(\.colorScheme, .dark) // 为标题栏元素设置一致的暗色模式
        }
    }
  
}

// MARK: - Header Area View // 标题区域视图
struct HeaderArea: View {
    let safeAreaTop: CGFloat // 添加安全区域顶部边距参数
    let scrollOffset: CGFloat
    let threshold: CGFloat
    
    // 定义按钮的初始垂直偏移量
    let initialButtonOffsetY: CGFloat = 60 // 根据布局调整此值

    var body: some View {
        // 计算进度（0 = 向下滚动，1 = 向上滚动）
        let progress = min(1, max(0, -scrollOffset / threshold))
        // 根据进度计算当前按钮的 Y 轴偏移量
        let currentButtonOffsetY = initialButtonOffsetY * (1 - progress)
        
        VStack(spacing: 0) { 
            // 标题栏顶部（搜索、个人资料）
            HStack(spacing: 15) {
                SearchBar()
                
                // 个人资料图片
                Image("Pic") // 使用你的实际图片
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .background {
                        Circle()
                            .fill(.white)
                            .padding(-2)
                    }
            }
            .padding(.horizontal, 15)
//            .padding(.bottom, 10) // 最终按钮行之前的间距
            .padding(.top, safeAreaTop + 10) // 使用传入的安全区域顶部值

            // 单行按钮，始终存在于标题栏中
            HStack(spacing: 0) { // 使用 0 间距或按需调整
                CustomButton(symbolImage: "sun.max", title: "晴天", progress: progress) {}
                CustomButton(symbolImage: "moon.stars", title: "夜晚", progress: progress) {}
                CustomButton(symbolImage: "cloud.rain", title: "雨天", progress: progress) {}
                CustomButton(symbolImage: "cloud.sun", title: "多云", progress: progress) {}
            }
            .offset(y: currentButtonOffsetY) // 应用计算出的垂直偏移量
            .padding(.bottom, 10) // 在最终状态下为按钮下方添加填充
            .padding(.horizontal, progress * 20)

        }
        // 如果需要，调整整体填充或框架以适应按钮的初始位置
        .padding(.bottom, initialButtonOffsetY * (1 - progress) > 10 ? initialButtonOffsetY * (1 - progress) : 10) // 动态调整底部填充
        .clipped() // 如果偏移将按钮推出边界，则裁剪内容到 HeaderArea 边界
        // 背景渐变已从此移除，应用于主 VStack
    }
}

// MARK: - Search Bar Component // 搜索栏组件
struct SearchBar: View {
    @State private var searchText: String = ""
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.white)
            
            TextField("搜索", text: $searchText)
                .tint(.white)
                .textFieldStyle(.plain) // 使用 plain 样式以更好地集成
        }
        .padding(.vertical, 8) // 略微减小填充
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous) // 稍小的圆角半径
                .fill(.black.opacity(0.15))
        }
    }
}

// MARK: - Button Components (Reused/Adapted) // 按钮组件（重用/改编）
struct CustomButton: View {
    let symbolImage: String
    let title: String
    let progress: Double // 添加进度参数
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(spacing: 8) {
                Image(systemName: symbolImage)
                    .fontWeight(.semibold)
                    .foregroundColor(.header) // 如果已定义，则使用颜色集
                    .frame(width: 35, height: 35)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                            .opacity(1.0 - progress) // 淡出背景
                    }

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .opacity(1.0 - progress) // 淡出文字
            }
            .frame(maxWidth: .infinity) // 确保它们分配空间
            .contentShape(Rectangle()) // 使整个区域可点击
        }
        .buttonStyle(.plain) // 使用 plain 样式以获得自定义外观
    }
}

// MARK: - Offset PreferenceKey (Assuming it exists elsewhere or add here) // 偏移 PreferenceKey（假设它存在于别处或在此添加）
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offset(
        coordinateSpace: CoordinateSpace,
        completion: @escaping (CGFloat) -> Void
    ) -> some View {
        self.overlay {
            GeometryReader { proxy in
                let minY = proxy.frame(in: coordinateSpace).minY
                Color.clear
                    .preference(key: OffsetKey.self, value: minY)
                    .onPreferenceChange(OffsetKey.self) { value in
                        completion(value)
                    }

            }
        }
    }
}

// MARK: - Preview // 预览
#Preview {
    // Assuming AppViewModel exists and can be instantiated
    // 假设 AppViewModel 存在并且可以实例化
     RefactoredSidebarView()
        .environmentObject(AppViewModel()) // 确保提供 ViewModel
        .preferredColorScheme(.light) // 或根据你的设计使用 .dark
        .frame(width: 250) // 预览示例宽度
}
