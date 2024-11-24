import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isShowingPostInputView = false

    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        print("HomeViewModel initialized")
        setupSubscriptions()
    }
    
    // MARK: - Setup Methods
    private func setupSubscriptions() {
        // 监听系统状态或全局事件
        // 比如监听是否需要隐藏导航栏等
    }
    
    
    // MARK: - Cleanup
    deinit {
        print("HomeViewModel deinitialized")
        cancellables.removeAll()
    }
}

#if DEBUG
extension HomeViewModel {
    static func preview() -> HomeViewModel {
        let viewModel = HomeViewModel()
        return viewModel
    }
}
#endif
