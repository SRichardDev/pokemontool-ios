
import UIKit
import MessageKit
import MessageInputBar

struct Message: MessageType {
    var sender: Sender
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
              let trainerName = firebaseConnector.user?.trainerName else { fatalError() }
        sender = Sender(id: userId, displayName: trainerName)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true

        firebaseConnector.raidChatDelegate = self
        guard let raidMeetupId = viewModel.arena.raid?.raidMeetupId else { return }
        firebaseConnector.observeRaidChat(for: raidMeetupId)
    }

    private func insertNewMessage(_ message: Message) {
        guard !messages.contains( where: { return $0.messageId == message.messageId }) else { return }

        messages.append(message)
        messages = messages.sorted(by: { $0.sentDate < $1.sentDate })
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
        }

        let isLatestMessage = messages.index{$0.messageId == message.messageId} == (messages.count - 1)
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
        firebaseConnector.user(for: chatMessage.senderId) { user in
            let sender = Sender(id: chatMessage.senderId, displayName: user.trainerName ?? "Unknown")
            let message = Message(sender: sender,
                                  messageId: chatMessage.id,
                                  sentDate: chatMessage.timestamp?.dateFromUnixTime() ?? Date(),
                                  kind: .text(chatMessage.message))
            self.insertNewMessage(message)
        }
    }
}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> Sender {
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.blue.withAlphaComponent(0.5) : UIColor.green.withAlphaComponent(0.5)
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }

    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
}

extension ChatViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let chatMessage = ChatMessage(message: text, senderId: sender.id)
        firebaseConnector.sendMessage(chatMessage, in: &viewModel.arena)
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
        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
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
