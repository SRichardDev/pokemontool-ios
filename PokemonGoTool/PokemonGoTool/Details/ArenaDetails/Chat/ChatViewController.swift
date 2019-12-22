
import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController, StoryboardInitialViewController {

    var firebaseConnector: FirebaseConnector!
    var viewModel: ArenaDetailsViewModel!
    var sender: Sender!
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chat"
        guard let userId = firebaseConnector.user?.id,
              let trainerName = firebaseConnector.user?.publicData?.trainerName else { fatalError() }
        sender = Sender(id: userId, displayName: trainerName)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true

        messagesCollectionView.backgroundColor = .systemBackground
        messageInputBar.backgroundColor = .systemBackground
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
        
        firebaseConnector.chatConnector.raidChatDelegate = self
        guard let chatId = viewModel.arena.raid?.meetup?.chatId else { return }
        firebaseConnector.chatConnector.observeRaidChat(for: chatId)
        isModalInPresentation = true
    }

    private func insertNewMessage(_ message: Message) {
        guard !messages.contains( where: { return $0.messageId == message.messageId }) else { return }

        messages.append(message)
        messages = messages.sorted(by: { $0.sentDate < $1.sentDate })
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
        }

        let isLatestMessage = messages.firstIndex{$0.messageId == message.messageId} == (messages.count - 1)
        let shouldScrollToBottom = isLatestMessage && messagesCollectionView.isAtBottom

        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
}

extension ChatViewController: RaidChatDelegate {
    func didReceiveNewChatMessage(_ chatMessage: ChatMessage) {
        firebaseConnector.user(for: chatMessage.senderId) { publicData in
            let sender = Sender(id: chatMessage.senderId, displayName: publicData.trainerName ?? "Unknown")
            let message = Message(sender: sender,
                                  messageId: chatMessage.id,
                                  sentDate: chatMessage.timestamp?.dateFromUnixTime() ?? Date(),
                                  kind: .text(chatMessage.message))
            self.insertNewMessage(message)
        }
    }
}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        
        return NSAttributedString(string: name, attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.lightGray
            ]
        )
    }
}

extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    }
 
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return true
    }

    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(image: nil, initials: String(message.sender.displayName.prefix(2))))
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let chatMessage = ChatMessage(message: text, senderId: sender.id)
        firebaseConnector.chatConnector.sendMessage(chatMessage, in: &viewModel.arena)
        inputBar.inputTextView.text = ""
    }
}

extension ChatViewController: MessagesLayoutDelegate {

    func avatarSize(for message: MessageType,
                    at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func footerViewSize(for message: MessageType,
                        at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType,
                               at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
}

extension UIScrollView {

    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }

    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
