import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "message.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("欢迎使用 CogniChat")
                .font(.largeTitle)
                .padding(.top)
            
            Text("请从左侧边栏选择一个对话，或创建新的对话")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("新建对话") {
                viewModel.createNewChat()
            }
            .keyboardShortcut("n", modifiers: [.command])
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
} 
