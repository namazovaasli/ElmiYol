//
//  NotificationStore.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 23.10.26.
//

import FirebaseAuth
import Foundation

struct AppNotification: Codable, Identifiable, Equatable {
    enum Kind: String, Codable { case message, meeting, research, system }

    let id: String
    var kind: Kind
    var title: String
    var message: String
    var meta: String
    var person: String
    var createdAt: Date
    var isRead: Bool
    var refId: String? = nil
}

final class NotificationStore {
    static let shared = NotificationStore()
    static let didChange = Notification.Name("NotificationStoreDidChange")
    private init() {}

    private var cache: [String: [AppNotification]] = [:]
    private var uid: String { Auth.auth().currentUser?.uid ?? "anonymous" }
    private var key: String { "notifications.\(uid)" }

    var unread: [AppNotification] {
        all().filter { !$0.isRead }.sorted { $0.createdAt > $1.createdAt }
    }
    var unreadCount: Int { all().filter { !$0.isRead }.count }

    func add(kind: AppNotification.Kind, title: String, message: String,
             meta: String = "", person: String = "") {
        var items = all()
        items.append(AppNotification(id: UUID().uuidString, kind: kind, title: title,
                                     message: message, meta: meta, person: person,
                                     createdAt: Date(), isRead: false))
        save(items)
    }

    func markRead(id: String) {
        var items = all()
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].isRead = true
        save(items)
    }

    func markAllRead() {
        save(all().map { var n = $0; n.isRead = true; return n })
    }

    func upsert(refId: String, kind: AppNotification.Kind, title: String, message: String,
                meta: String = "", person: String = "", createdAt: Date) {
        var items = all()
        if let i = items.firstIndex(where: { $0.refId == refId }) {
            if items[i].isRead && createdAt <= items[i].createdAt { return }
            if !items[i].isRead && items[i].message == message { return }
            items[i].message = message
            items[i].person = person
            items[i].createdAt = createdAt
            items[i].isRead = false
        } else {
            items.append(AppNotification(id: UUID().uuidString, kind: kind, title: title,
                                         message: message, meta: meta, person: person,
                                         createdAt: createdAt, isRead: false, refId: refId))
        }
        save(items)
    }

    func markRead(refId: String) {
        var items = all()
        var changed = false
        for i in items.indices where items[i].refId == refId && !items[i].isRead {
            items[i].isRead = true
            changed = true
        }
        if changed { save(items) }
    }
    
    func delete(id: String) {
        save(all().filter { $0.id != id })
    }

    func refreshSessionCount() {
        UserSession.shared.unreadNotificationsCount = unreadCount
    }

    private func all() -> [AppNotification] {
        if let cached = cache[key] { return cached }
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([AppNotification].self, from: data) else { return [] }
        cache[key] = items
        return items
    }

    private func save(_ items: [AppNotification]) {
        let trimmed = Array(items.sorted { $0.createdAt > $1.createdAt }.prefix(200))
        cache[key] = trimmed
        if let data = try? JSONEncoder().encode(trimmed) {
            UserDefaults.standard.set(data, forKey: key)
        }
        refreshSessionCount()
        NotificationCenter.default.post(name: Self.didChange, object: nil)
    }
}
