//
//  PlannerStore.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 28.10.26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

extension Notification.Name {
    static let plannerChanged = Notification.Name("plannerChanged")
}

final class PlannerStore {
    static let shared = PlannerStore()
    private init() {}

    private(set) var meetings: [Meeting] = []
    private(set) var researches: [Research] = []
    private var listeners: [ListenerRegistration] = []

    var myUid: String { Auth.auth().currentUser?.uid ?? "" }

    func start() {
        guard listeners.isEmpty, let uid = Auth.auth().currentUser?.uid else { return }

        listeners.append(PlannerRepository.shared.listenMeetings(uid: uid) { [weak self] items in
            self?.meetings = items
            self?.changed()
        })
        listeners.append(PlannerRepository.shared.listenResearches(uid: uid) { [weak self] items in
            self?.researches = items
            self?.changed()
        })
       
        listeners.append(PlannerRepository.shared.listenInbox(uid: uid) { docs in
            for doc in docs {
                let d = doc.data(with: .estimate)
                NotificationStore.shared.upsert(
                    refId: "remote:\(doc.documentID)",
                    kind: AppNotification.Kind(rawValue: d["kind"] as? String ?? "") ?? .system,
                    title: d["title"] as? String ?? "Bildiriş",
                    message: d["message"] as? String ?? "",
                    meta: d["meta"] as? String ?? "",
                    person: d["person"] as? String ?? "",
                    createdAt: (d["createdAt"] as? Timestamp)?.dateValue() ?? Date())
                doc.reference.delete()
            }
        })
    }

    func stop() {
        listeners.forEach { $0.remove() }
        listeners = []
        meetings = []
        researches = []
        changed()
    }

    var upcomingMeetings: [Meeting] {
        meetings
            .filter { $0.status != "cancelled" && $0.endsAt >= Date() }
            .sorted { $0.startsAt < $1.startsAt }
    }

    var meetingsThisWeekCount: Int {
        let calendar = Calendar.current
        return upcomingMeetings.filter {
            calendar.isDate($0.startsAt, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
    }

    var activeResearches: [Research] {
        researches.filter { $0.status == "active" }.sorted { $0.startDate > $1.startDate }
    }

    private func changed() {
        NotificationCenter.default.post(name: .plannerChanged, object: nil)
    }
}
