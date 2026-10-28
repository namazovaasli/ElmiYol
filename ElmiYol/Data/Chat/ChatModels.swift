//
//  ChatModels.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//


import FirebaseAuth
import FirebaseFirestore
import Foundation

enum ChatMessageKind: String {
    case text, file
}

struct ChatMessageDoc: Identifiable, Equatable {
    let id: String
    let senderId: String
    let text: String
    let kind: ChatMessageKind
    let filePath: String?
    let fileName: String?
    let createdAt: Date
    let edited: Bool
    let deleted: Bool
    let hiddenFor: [String]
    
    var isMine: Bool { senderId == Auth.auth().currentUser?.uid }

    var timeText: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: createdAt)
    }

    init?(document: QueryDocumentSnapshot) {
        let d = document.data(with: .estimate)
        guard let sender = d["senderId"] as? String else { return nil }
        id = document.documentID
        senderId = sender
        text = d["text"] as? String ?? ""
        kind = ChatMessageKind(rawValue: d["kind"] as? String ?? "text") ?? .text
        filePath = d["filePath"] as? String
        fileName = d["fileName"] as? String
        createdAt = (d["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        edited = d["edited"] as? Bool ?? false
        deleted = d["deleted"] as? Bool ?? false
        hiddenFor = d["hiddenFor"] as? [String] ?? []
    }
}

struct ChatThreadDoc: Identifiable, Equatable {
    let id: String
    let otherUid: String
    let otherName: String
    let lastMessage: String
    let lastSenderId: String
    let lastMessageAt: Date
    let unread: Int

    var timeText: String {
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDateInToday(lastMessageAt) ? "HH:mm" : "dd.MM"
        return f.string(from: lastMessageAt)
    }

    var initials: String {
        otherName.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    init?(document: QueryDocumentSnapshot, me: String) {
        let d = document.data(with: .estimate)
        guard let participants = d["participants"] as? [String],
              let other = participants.first(where: { $0 != me }),
              let at = (d["lastMessageAt"] as? Timestamp)?.dateValue() else { return nil }
        id = document.documentID
        otherUid = other
        let names = d["names"] as? [String: String] ?? [:]
        otherName = names[other] ?? "İstifadəçi"
        lastMessage = d["lastMessage"] as? String ?? ""
        lastSenderId = d["lastSenderId"] as? String ?? ""
        lastMessageAt = at
        unread = (d["unread"] as? [String: Any])?[me] as? Int ?? 0
    }
}
