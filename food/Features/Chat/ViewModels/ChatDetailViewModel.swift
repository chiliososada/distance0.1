import Foundation
import SwiftUI
import Combine

final class ChatDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var messages: [Message] = []
    @Published var newMessage = ""
    @Published var isAnnouncementVisible = true
    @Published var showMemberList = false
    @Published private(set) var viewState: ViewState = .loading
    @Published var showEmojiPicker = false
    @Published var showOptionsMenu = false
    
    // MARK: - Properties
    private let chatRoom: ChatRoom
    private var messageSubscription: AnyCancellable?
    private var debounceTimer: Timer?
    private var messageBatch: [Message] = []
    private let batchSize = 20
    private var isLoadingMore = false
    
    let currentMember: Member
    
    //emoji
    @Published var isShowingEmoji = false
    
    //media
    @Published var showMediaOptions = false
    @Published var showImagePicker = false
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    
    // MARK: - View State
    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
        case loadingMore
        
        static func ==(lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading),
                 (.loaded, .loaded),
                 (.loadingMore, .loadingMore):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Message Management
    private var messageQueue: [(Message, Timer?)] = []
    private let maxRetryAttempts = 3
    private var retryCount: [UUID: Int] = [:]
    
    // MARK: - Initialization
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        self.currentMember = Member(
            id: UUID(),
            name: "Me",
            avatar: "sample1",
            role: .member
        )
        
        setupMessageSubscription()
        loadInitialMessages()
    }
    
    // MARK: - Public Methods
    func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let newMsg = Message(
            id: UUID(),
            sender: currentMember,
            content: .text(trimmedMessage),
            timestamp: Date(),
            status: .sending
        )
        
        withAnimation {
            messages.append(newMsg)
        }
        
        // 清空输入并隐藏键盘
        newMessage = ""
        dismissKeyboard()
        
        // 添加到消息队列
        enqueueMessage(newMsg)
    }
    
    func loadMoreMessages() {
        guard !isLoadingMore, viewState == .loaded else { return }
        
        isLoadingMore = true
        viewState = .loadingMore
        
        // 模拟加载更多消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // 模拟获取更多历史消息
            let olderMessages = self.generateOlderMessages()
            
            withAnimation {
                self.messages.insert(contentsOf: olderMessages, at: 0)
            }
            
            self.isLoadingMore = false
            self.viewState = .loaded
        }
    }
    
    func retry(messageId: UUID) {
        guard let index = messages.firstIndex(where: { $0.id == messageId }),
              messages[index].status == .failed else { return }
        
        let message = messages[index]
        retryCount[messageId, default: 0] += 1
        
        if retryCount[messageId, default: 0] <= maxRetryAttempts {
            // 重试发送消息
            updateMessageStatus(messageId: messageId, status: .sending)
            enqueueMessage(message)
        }
    }
    
    // MARK: - Private Methods
    private func setupMessageSubscription() {
        // 监听新消息
        messageSubscription = NotificationCenter.default
            .publisher(for: .newMessageReceived)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let message = notification.object as? Message else { return }
                self?.handleIncomingMessage(message)
            }
    }
    
    private func enqueueMessage(_ message: Message) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.processMessage(message)
        }
        messageQueue.append((message, timer))
    }
    
    private func processMessage(_ message: Message) {
        // 模拟消息发送
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 模拟成功率 90%
            let isSuccess = Double.random(in: 0...1) > 0.1
            
            if isSuccess {
                self.updateMessageStatus(messageId: message.id, status: .sent)
                
                // 模拟消息送达
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.updateMessageStatus(messageId: message.id, status: .delivered)
                }
            } else {
                self.updateMessageStatus(messageId: message.id, status: .failed)
            }
            
            // 从队列中移除消息
            self.messageQueue.removeAll { $0.0.id == message.id }
        }
    }
    
    private func updateMessageStatus(messageId: UUID, status: Message.MessageStatus) {
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else { return }
        
        withAnimation {
            let updatedMessage = Message(
                id: messages[index].id,
                sender: messages[index].sender,
                content: messages[index].content,
                timestamp: messages[index].timestamp,
                status: status
            )
            messages[index] = updatedMessage
        }
    }
    
    private func handleIncomingMessage(_ message: Message) {
        withAnimation {
            messages.append(message)
        }
        
        // 如果消息不在视图底部，显示新消息提醒
        // 这里可以添加新消息提醒的逻辑
    }
    
    private func generateOlderMessages() -> [Message] {
        // 生成模拟的历史消息
        // 实际应用中，这里应该从服务器获取历史消息
        return []
    }
    
    private func loadInitialMessages() {
        viewState = .loading
        
        // 实现批量加载逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // 使用批量加载优化性能
            self.loadMessageBatch(count: self.batchSize) { messages in
                withAnimation {
                    self.messages = messages
                    self.viewState = .loaded
                }
            }
        }
    }
    
    private func loadMessageBatch(count: Int, completion: @escaping ([Message]) -> Void) {
        // 实现批量加载逻辑
        // 这里使用示例数据
        let alice = Member(id: UUID(), name: "Alice", avatar: "sample1", role: .member)
        let bob = Member(id: UUID(), name: "Bob", avatar: "sample2", role: .member)
        
        let messages = [
            Message(
                id: UUID(),
                sender: alice,
                content: .text("Lets goooooo @AJPicard913, I'm buying mine now"),
                timestamp: Date().addingTimeInterval(-3600),
                status: .read
            ),
            Message(
                id: UUID(),
                sender: bob,
                content: .text("Count me in! Can't wait!"),
                timestamp: Date().addingTimeInterval(-1800),
                status: .read
            ),
            Message(
                id: UUID(),
                sender: currentMember,
                content: .text("Great! See you all there!"),
                timestamp: Date(),
                status: .sent
            )
        ]
        
        completion(messages)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    // MARK: - UI Actions
    func toggleAnnouncement() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isAnnouncementVisible.toggle()
        }
    }
    
    func showSettings() {
        showMemberList = true
    }
    
    func showMoreOptions() {
          // 如果键盘或表情键盘是打开状态，先关闭它们
          if isShowingEmoji {
              isShowingEmoji = false
          }
          // 关闭系统键盘
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                       to: nil,
                                       from: nil,
                                       for: nil)
          
          withAnimation {
              showMediaOptions.toggle()
          }
      }
    
    
    func handleMediaResult(_ result: MediaResult) {
            switch result {
            case .capturedImage(let image):
                // 处理拍照的图片
                sendImageMessage(image)
                
            case .selectedImages(let images):
                // 处理选择的多张图片
                for image in images {
                    sendImageMessage(image)
                }
                
            case .sticker:
                print("选择贴纸") // 实现贴纸功能
                
            case .audio:
                print("录制音频") // 实现音频功能
                
            case .more:
                print("更多选项") // 实现更多选项
            }
        }
    private func sendImageMessage(_ image: UIImage) {
           // 这里应该先上传图片到服务器，获取URL后再发送消息
           // 这里使用模拟的URL
           let imageUrl = URL(string: "https://example.com/image.jpg")!
           
           let newMsg = Message(
               id: UUID(),
               sender: currentMember,
               content: .image(imageUrl),
               timestamp: Date(),
               status: .sending
           )
           
           withAnimation {
               messages.append(newMsg)
           }
           
           // 添加到消息队列
           enqueueMessage(newMsg)
       }
    func showEmojiPickerView() {
        // 如果媒体选项菜单是打开的，先关闭它
        if showMediaOptions {
            showMediaOptions = false
        }
        
        isShowingEmoji.toggle()
        
        // 确保切换后文本框保持焦点
        if isShowingEmoji {
            // 稍微延迟以确保切换状态已更新
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .showKeyboard, object: nil)
            }
        }
    }
    
    deinit {
        messageSubscription?.cancel()
        debounceTimer?.invalidate()
        messageQueue.forEach { _, timer in
            timer?.invalidate()
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let newMessageReceived = Notification.Name("newMessageReceived")
}

// MARK: - Preview Helper
extension ChatDetailViewModel {
    static func preview(chatRoom: ChatRoom) -> ChatDetailViewModel {
        let viewModel = ChatDetailViewModel(chatRoom: chatRoom)
        return viewModel
    }
}


// 添加通知名称
extension Notification.Name {
    static let showKeyboard = Notification.Name("showKeyboard")
}
