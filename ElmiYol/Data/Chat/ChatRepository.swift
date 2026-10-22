//
//  ChatRepository.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 20.10.26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

final class ChatRepository {
    static let shared = ChatRepository()
    private init() {}

    private var db: Firestore { Firestore.firestore() }

    static func chatId(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }

    func ensureChat(chatId: String, me: String, other: String, myName: String, otherName: String) async throws {
        try await db.collection("chats").document(chatId).setData([
            "participants": [me, other],
            "names": [me: myName, other: otherName]
        ], merge: true)
    }

    func listenMessages(chatId: String, onChange: @escaping ([ChatMessageDoc]) -> Void) -> ListenerRegistration {
        db.collection("chats").document(chatId).collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, _ in
                onChange(snapshot?.documents.compactMap { ChatMessageDoc(document: $0) } ?? [])
            }
    }

    func listenReadState(chatId: String, onChange: @escaping ([String: Date]) -> Void) -> ListenerRegistration {
        db.collection("chats").document(chatId).addSnapshotListener { snapshot, _ in
            let data = snapshot?.data(with: .estimate) ?? [:]
            let raw = data["lastRead"] as? [String: Any] ?? [:]
            onChange(raw.compactMapValues { ($0 as? Timestamp)?.dateValue() })
        }
    }

    func listenThreads(for uid: String, onChange: @escaping ([ChatThreadDoc]) -> Void) -> ListenerRegistration {
        db.collection("chats")
            .whereField("participants", arrayContains: uid)
            .addSnapshotListener { snapshot, _ in
                let threads = (snapshot?.documents.compactMap { ChatThreadDoc(document: $0, me: uid) } ?? [])
                    .sorted { $0.lastMessageAt > $1.lastMessageAt }
                onChange(threads)
            }
    }

    func send(chatId: String, me: String, other: String, text: String = "",
              kind: ChatMessageKind = .text, filePath: String? = nil, fileName: String? = nil) async throws {
        let chatRef = db.collection("chats").document(chatId)
        let msgRef = chatRef.collection("messages").document()
        let preview = kind == .file ? "\(fileName ?? "Fayl")" : text

        var data: [String: Any] = [
            "senderId": me,
            "text": text,
            "kind": kind.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let filePath { data["filePath"] = filePath }
        if let fileName { data["fileName"] = fileName }

        let batch = db.batch()
        batch.setData(data, forDocument: msgRef)
        batch.setData([
            "participants": [me, other],
            "lastMessage": preview,
            "lastSenderId": me,
            "lastMessageAt": FieldValue.serverTimestamp(),
            "unread": [other: FieldValue.increment(Int64(1))]
        ], forDocument: chatRef, merge: true)
        try await batch.commit()
    }


    func markRead(chatId: String, me: String) async {
        try? await db.collection("chats").document(chatId).setData([
            "unread": [me: 0],
            "lastRead": [me: FieldValue.serverTimestamp()]
        ], merge: true)
    }
}

