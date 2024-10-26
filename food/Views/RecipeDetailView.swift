//import SwiftUI
//
//struct RecipeDetailView: View {
//    let recipe: RecommendedRecipe
//    @State private var currentImageIndex = 0
//    @State private var isPressed = false
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var tabBarManager: TabBarManager
//    
//    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        ZStack {
//            ScrollView {
//                VStack(spacing: 0) {
//                    // 图片轮播
//                    ImageCarousel(
//                        images: recipe.imageNames,
//                        currentIndex: $currentImageIndex,
//                        onDismiss: { presentationMode.wrappedValue.dismiss() }
//                    )
//                    
//                    PageIndicator(total: recipe.imageNames.count, current: currentImageIndex)
//                        .padding(.vertical, 8)
//                    
//                    // 内容
//                    DetailContent(recipe: recipe)
//                }
//            }
//            
//            // 悬浮按钮
//            FloatingJoinButton(isPressed: $isPressed)
//        }
//        .edgesIgnoringSafeArea(.top)
//        .navigationBarHidden(true)
//        .onAppear { tabBarManager.isViewTabBarHidden = true }
//        .onDisappear { tabBarManager.isViewTabBarHidden = false }
//        .onReceive(timer) { _ in
//            withAnimation(.easeInOut(duration: 1)) {
//                isPressed.toggle()
//            }
//        }
//    }
//}
//
//// MARK: - Supporting Views
//private struct ImageCarousel: View {
//    let images: [String]
//    @Binding var currentIndex: Int
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        ZStack(alignment: .top) {
//            TabView(selection: $currentIndex) {
//                ForEach(0..<images.count, id: \.self) { index in
//                    Image(images[index])
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: UIScreen.main.bounds.width)
//                        .clipped()
//                        .tag(index)
//                }
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .frame(height: 450)
//            
//            NavigationBar(onDismiss: onDismiss)
//        }
//    }
//}
//
//private struct NavigationBar: View {
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        HStack {
//            Button(action: onDismiss) {
//                Image(systemName: "chevron.left")
//                    .font(.title3)
//                    .foregroundColor(.black)
//                    .padding(9)
//                    .background(Color.white)
//                    .clipShape(Circle())
//                    .shadow(radius: 3)
//            }
//            
//            Spacer()
//            
//            ShareButton()
//        }
//        .padding(.horizontal, 16)
//        .padding(.top, 45)
//    }
//}
//
//private struct ShareButton: View {
//    var body: some View {
//        Button(action: {}) {
//            Image(systemName: "square.and.arrow.up")
//                .font(.title3)
//                .foregroundColor(.black)
//                .padding(9)
//                .background(Color.white)
//                .clipShape(Circle())
//                .shadow(radius: 3)
//        }
//    }
//}
//
//private struct PageIndicator: View {
//    let total: Int
//    let current: Int
//    
//    var body: some View {
//        HStack(spacing: 6) {
//            ForEach(0..<total, id: \.self) { index in
//                Circle()
//                    .fill(index == current ? Color.black : Color.gray)
//                    .frame(width: 6, height: 6)
//            }
//        }
//    }
//}
//
//private struct FloatingJoinButton: View {
//    @Binding var isPressed: Bool
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            Button(action: {}) {
//                Text("Join")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(width: 60, height: 60)
//                    .background(Circle().fill(Color.black))
//                    .shadow(radius: 10)
//                    .opacity(0.8)
//            }
//            .scaleEffect(isPressed ? 1.2 : 1.0)
//            .padding(.bottom, 50)
//        }
//    }
//}
//
//// MARK: - Preview
//struct RecipeDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeDetailView(
//            recipe: RecommendedRecipe(
//                imageName: "reco_1",
//                title: "測試標題",
//                imageNames: ["sample1", "reco_1", "reco_1", "reco_1"]
//            )
//        )
//        .environmentObject(TabBarManager())
//    }
//}
