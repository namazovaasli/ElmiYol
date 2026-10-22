//
//  UnreadMessagesObserver.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.10.26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

extension Notification.Name {
    static let unreadMessagesChanged = Notification.Name("unreadMessagesChanged")
}

final class UnreadMessagesObserver {
    static let shared = UnreadMessagesObserver()
    private var listener: ListenerRegistration?
    private init() {}

    func start() {
        guard listener == nil, let uid = Auth.auth().currentUser?.uid else { return }
        listener = ChatRepository.shared.listenThreads(for: uid) { threads in
            UserSession.shared.unreadMessagesCount = threads.reduce(0) { $0 + $1.unread }
            NotificationCenter.default.post(name: .unreadMessagesChanged, object: nil)
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
        UserSession.shared.unreadMessagesCount = 0
        NotificationCenter.default.post(name: .unreadMessagesChanged, object: nil)
    }
}
