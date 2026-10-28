//
//  PlannerRepository.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 28.10.26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

final class PlannerRepository {
    static let shared = PlannerRepository()
    private init() {}

    private var db: Firestore { Firestore.firestore() }

    func listenMeetings(uid: String, onChange: @escaping ([Meeting]) -> Void) -> ListenerRegistration {
        db.collection("meetings").whereField("participants", arrayContains: uid)
            .addSnapshotListener { snapshot, _ in
                onChange(snapshot?.documents.compactMap { Meeting(document: $0) } ?? [])
            }
    }

    func listenResearches(uid: String, onChange: @escaping ([Research]) -> Void) -> ListenerRegistration {
        db.collection("researches").whereField("participants", arrayContains: uid)
            .addSnapshotListener { snapshot, _ in
                onChange(snapshot?.documents.compactMap { Research(document: $0) } ?? [])
            }
    }

    func listenInbox(uid: String, onChange: @escaping ([QueryDocumentSnapshot]) -> Void) -> ListenerRegistration {
        db.collection("users").document(uid).collection("notifications")
            .addSnapshotListener { snapshot, _ in
                onChange(snapshot?.documents ?? [])
            }
    }

    func save(_ meeting: Meeting) async throws {
        try await db.collection("meetings").document(meeting.id).setData(meeting.firestoreData)
    }

    func updateMeeting(id: String, fields: [String: Any]) async throws {
        try await db.collection("meetings").document(id).updateData(fields)
    }

    func deleteMeeting(id: String) async throws {
        try await db.collection("meetings").document(id).delete()
    }

    func save(_ research: Research) async throws {
        try await db.collection("researches").document(research.id).setData(research.firestoreData)
    }

    func updateResearch(id: String, fields: [String: Any]) async throws {
        try await db.collection("researches").document(id).updateData(fields)
    }

    func deleteResearch(id: String) async throws {
        try await db.collection("researches").document(id).delete()
    }

    func notify(uid: String, kind: AppNotification.Kind, title: String, message: String,
                meta: String = "", person: String = "") async {
        guard let me = Auth.auth().currentUser?.uid else { return }
        _ = try? await db.collection("users").document(uid).collection("notifications").addDocument(data: [
            "fromUid": me,
            "kind": kind.rawValue,
            "title": title,
            "message": message,
            "meta": meta,
            "person": person,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }
}
