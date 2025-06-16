import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var rotation = -30.0
    @State private var iconScale = 0.5
    @State private var showText = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.hongkongBlue.opacity(0.8),
                    AppColors.mainlandRed.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 日历图标动画
                ZStack {
                    // 大图标背景光晕
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .opacity(opacity)
                        .scaleEffect(scale)
                    
                    // 日历图标
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .opacity(opacity)
                        .scaleEffect(iconScale)
                }
                .frame(height: 160)
                
                // 应用名称
                Text("中港假日通")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .opacity(showText ? 1 : 0)
                
                // 标语
                Text("香港 • 内地 • 节假日一览")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 5)
                    .opacity(showText ? 1 : 0)
            }
        }
        .onAppear {
            // 执行动画序列
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                opacity = 1
                iconScale = 1
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.8)) {
                scale = 1
                rotation = 0
            }
            
            withAnimation(.easeIn(duration: 0.4).delay(1.4)) {
                showText = true
            }
            
            // 延迟后切换到主界面
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            // 跳转到主应用界面
            MainTabView()
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(ThemeManager())
} 
