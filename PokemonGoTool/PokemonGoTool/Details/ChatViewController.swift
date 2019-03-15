
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
        sender = Sender(id: firebaseConnector.user?.id ?? "", displayName: firebaseConnector.user?.trainerName ?? "")

        let testMessage0 = Message(sender: sender, messageId: "adfgr4t", sentDate: Date(), kind: .text("Hallo"))
        let testMessage1 = Message(sender: sender, messageId: "adfgs4t", sentDate: Date(), kind: .text("Lol"))
        let testMessage2 = Message(sender: sender, messageId: "adfg34t", sentDate: Date(), kind: .text("Penis"))
        let testMessage3 = Message(sender: sender, messageId: "adfg64t", sentDate: Date(), kind: .text("Kacke"))
        let testMessage4 = Message(sender: sender, messageId: "adfg24t", sentDate: Date(), kind: .text("Deine Mama ist fett!"))

        insertNewMessage(testMessage0)
        insertNewMessage(testMessage1)
        insertNewMessage(testMessage2)
        insertNewMessage(testMessage3)
        insertNewMessage(testMessage4)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

    private func insertNewMessage(_ message: Message) {
        guard !messages.contains( where: { return $0.messageId == message.messageId }) else { return }

        messages.append(message)
        messagesCollectionView.reloadData()

        let isLatestMessage = messages.index{$0.messageId == message.messageId} == (messages.count - 1)
        let shouldScrollToBottom = isLatestMessage //&& messagesCollectionView.isAtBottom

        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
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

extension ChatViewController: MessagesDisplayDelegate {}

extension ChatViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Message(sender: sender, messageId: "96syufs\(Int.random(in: 0...100))", sentDate: Date(), kind: .text(text))
        insertNewMessage(message)
        inputBar.inputTextView.text = ""

        let chatMessage = ChatMessage(message: "Foo", senderId: "Foo")
        firebaseConnector.sendMessage(chatMessage, to: viewModel.meetup?.id ?? "")
    }
}

extension ChatViewController: MessagesLayoutDelegate {

    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath,
                           with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
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
