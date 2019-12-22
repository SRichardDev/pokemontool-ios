
import Firebase
import CodableFirebase

class ChatConnector {
    private let chatsRef = Database.database().reference(withPath: DatabaseKeys.chats)
    private let arenasRef = Database.database().reference(withPath: DatabaseKeys.arenas)

    weak var raidChatDelegate: RaidChatDelegate?

    private func associateChatIdToMeetup(id: String, arena: inout Arena) {
        arena.raid?.meetup?.chatId = id
        arenasRef
            .child(arena.geohash)
            .child(arena.id)
            .child(DatabaseKeys.raid)
            .child(DatabaseKeys.meetup)
            .updateChildValues([DatabaseKeys.chatId : id])
    }
    
    func sendMessage(_ message: ChatMessage, in arena: inout Arena) {
        
        let sendMessage: (_ chatId: String) -> Void = { chatId in
            let data = try! FirebaseEncoder().encode(message)
            var dataWithTimestamp = data as! [String: Any]
            dataWithTimestamp[DatabaseKeys.timestamp] = ServerValue.timestamp()
            self.chatsRef
                .child(chatId)
                .childByAutoId()
                .setValue(dataWithTimestamp)
        }
        
        if let chatId = arena.raid?.meetup?.chatId {
            sendMessage(chatId)
        } else {
            guard let chatId = chatsRef.childByAutoId().key else { return }
            associateChatIdToMeetup(id: chatId, arena: &arena)
            observeRaidChat(for: chatId)
            arena.raid?.meetup?.chatId = chatId
            sendMessage(chatId)
        }
    }
    
    func observeRaidChat(for id: String) {
        chatsRef
            .child(id)
            .removeAllObservers()
        
        chatsRef
            .child(id)
            .observe(.value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    guard let chatMessage: ChatMessage = decode(from: child) else { continue }
                    self.raidChatDelegate?.didReceiveNewChatMessage(chatMessage)
                }
            }
        })
    }
    
    func deleteOldChat(for arena: Arena) {
        guard let id = arena.raid?.meetup?.chatId else { return }
        print("🏟💬 Clearing chat in arena \(arena.id ?? "??")")
        chatsRef
            .child(id)
            .removeValue()
    }
}
