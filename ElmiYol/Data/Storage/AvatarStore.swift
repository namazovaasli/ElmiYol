//
//  AvatarStore.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 28.10.26.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

extension Notification.Name {
    static let avatarChanged = Notification.Name("avatarChanged")
}

@MainActor
final class AvatarStore {
    static let shared = AvatarStore()
    private init() {}

    private let bucket = "avatars"
    private(set) var image: UIImage?
    private(set) var photoURL: URL?

    func refresh() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let doc = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        guard let string = doc?.data()?["photoURL"] as? String, let url = URL(string: string) else {
            publish(image: nil, url: nil)
            return
        }
        if url == photoURL, image != nil { return }
        if let (data, _) = try? await URLSession.shared.data(from: url), let img = UIImage(data: data) {
            publish(image: img, url: url)
        }
    }

    func upload(_ original: UIImage) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let resized = original.squareCropped().resized(maxSide: 600)
        guard let data = resized.jpegData(compressionQuality: 0.8) else { return }

        let path = "\(uid)/avatar.jpg"
        var request = makeRequest("object/\(bucket)/\(path)", method: "POST")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "x-upsert")

        let (body, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw StorageError.uploadFailed(String(data: body, encoding: .utf8) ?? "naməlum xəta")
        }

        let publicURL = "\(SupabaseConfig.url)/storage/v1/object/public/\(bucket)/\(path)?v=\(Int(Date().timeIntervalSince1970))"
        try await save(photoURL: publicURL, uid: uid)
        publish(image: resized, url: URL(string: publicURL))
    }

    func remove() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let request = makeRequest("object/\(bucket)/\(uid)/avatar.jpg", method: "DELETE")
        _ = try? await URLSession.shared.data(for: request)
        try await save(photoURL: nil, uid: uid)
        publish(image: nil, url: nil)
    }

    func clear() {
        publish(image: nil, url: nil)
    }

    private func save(photoURL: String?, uid: String) async throws {
        let value: Any = photoURL ?? FieldValue.delete()
        let db = Firestore.firestore()
        try await db.collection("users").document(uid).setData(["photoURL": value], merge: true)
        try await db.collection("publicProfiles").document(uid).setData(["photoURL": value], merge: true)
    }

    private func makeRequest(_ path: String, method: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(SupabaseConfig.url)/storage/v1/\(path)")!)
        request.httpMethod = method
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        return request
    }

    private func publish(image: UIImage?, url: URL?) {
        self.image = image
        self.photoURL = url
        NotificationCenter.default.post(name: .avatarChanged, object: nil)
    }
}

extension UIImage {
    func resized(maxSide: CGFloat) -> UIImage {
        let scale = min(1, maxSide / max(size.width, size.height))
        guard scale < 1 else { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    func squareCropped() -> UIImage {
        let side = min(size.width, size.height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { _ in
            draw(at: CGPoint(x: -(size.width - side) / 2, y: -(size.height - side) / 2))
        }
    }
}
