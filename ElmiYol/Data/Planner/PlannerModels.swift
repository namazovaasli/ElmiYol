//
//  PlannerModels.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 28.10.26.
//

import FirebaseFirestore
import Foundation

struct Meeting: Identifiable, Equatable {
    let id: String
    var title: String
    var studentUid: String
    var studentName: String
    var supervisorUid: String
    var supervisorName: String
    var startsAt: Date
    var endsAt: Date
    var mode: String
    var location: String
    var note: String
    var status: String
    var createdBy: String

    func otherName(for uid: String) -> String { uid == studentUid ? supervisorName : studentName }
    func otherUid(for uid: String) -> String { uid == studentUid ? supervisorUid : studentUid }

    var firestoreData: [String: Any] {
        [
            "title": title,
            "studentUid": studentUid, "studentName": studentName,
            "supervisorUid": supervisorUid, "supervisorName": supervisorName,
            "participants": [studentUid, supervisorUid],
            "startsAt": Timestamp(date: startsAt), "endsAt": Timestamp(date: endsAt),
            "mode": mode, "location": location, "note": note,
            "status": status, "createdBy": createdBy,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}

extension Meeting {
    init?(document: QueryDocumentSnapshot) {
        let d = document.data(with: .estimate)
        guard let title = d["title"] as? String,
              let start = (d["startsAt"] as? Timestamp)?.dateValue(),
              let end = (d["endsAt"] as? Timestamp)?.dateValue() else { return nil }
        self.init(
            id: document.documentID, title: title,
            studentUid: d["studentUid"] as? String ?? "",
            studentName: d["studentName"] as? String ?? "",
            supervisorUid: d["supervisorUid"] as? String ?? "",
            supervisorName: d["supervisorName"] as? String ?? "",
            startsAt: start, endsAt: end,
            mode: d["mode"] as? String ?? "",
            location: d["location"] as? String ?? "",
            note: d["note"] as? String ?? "",
            status: d["status"] as? String ?? "pending",
            createdBy: d["createdBy"] as? String ?? "")
    }
}

struct Research: Identifiable, Equatable {
    let id: String
    var title: String
    var category: String
    var details: String
    var studentUid: String
    var studentName: String
    var supervisorUid: String
    var supervisorName: String
    var startDate: Date
    var endDate: Date
    var status: String         
    var progress: Double
    var createdBy: String

    func otherName(for uid: String) -> String { uid == studentUid ? supervisorName : studentName }

    var firestoreData: [String: Any] {
        [
            "title": title, "category": category, "details": details,
            "studentUid": studentUid, "studentName": studentName,
            "supervisorUid": supervisorUid, "supervisorName": supervisorName,
            "participants": [studentUid, supervisorUid],
            "startDate": Timestamp(date: startDate), "endDate": Timestamp(date: endDate),
            "status": status, "progress": progress, "createdBy": createdBy,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}

extension Research {
    init?(document: QueryDocumentSnapshot) {
        let d = document.data(with: .estimate)
        guard let title = d["title"] as? String,
              let start = (d["startDate"] as? Timestamp)?.dateValue(),
              let end = (d["endDate"] as? Timestamp)?.dateValue() else { return nil }
        self.init(
            id: document.documentID, title: title,
            category: d["category"] as? String ?? "",
            details: d["details"] as? String ?? "",
            studentUid: d["studentUid"] as? String ?? "",
            studentName: d["studentName"] as? String ?? "",
            supervisorUid: d["supervisorUid"] as? String ?? "",
            supervisorName: d["supervisorName"] as? String ?? "",
            startDate: start, endDate: end,
            status: d["status"] as? String ?? "active",
            progress: d["progress"] as? Double ?? 0,
            createdBy: d["createdBy"] as? String ?? "")
    }
}
