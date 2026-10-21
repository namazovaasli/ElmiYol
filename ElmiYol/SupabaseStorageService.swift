//
//  SupabaseStorageService.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.10.26.
//

import Foundation
import UniformTypeIdentifiers

enum SupabaseConfig {
    static let url = "https://rscaulzoylcdaqpyapfx.supabase.co" 
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzY2F1bHpveWxjZGFxcHlhcGZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1NzQ4ODUsImV4cCI6MjEwODE1MDg4NX0.iD9i7fIJQKUz5TYQuqVgS4l8LHo0j2Z2iuMtxCpj6_0"
    static let chatBucket = "chat-files"
}

enum StorageError: LocalizedError {
    case fileTooLarge
    case uploadFailed(String)
    case badResponse

    var errorDescription: String? {
        switch self {
        case .fileTooLarge: return "Fayl 20 MB-dan böyük ola bilməz."
        case .uploadFailed(let message): return "Fayl yüklənmədi: \(message)"
        case .badResponse: return "Server cavabı düzgün deyil."
        }
    }
}

final class SupabaseStorageService {
    static let shared = SupabaseStorageService()
    private init() {}

    private let maxSize = 20 * 1024 * 1024

    private func makeRequest(_ path: String, method: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(SupabaseConfig.url)/storage/v1/\(path)")!)
        request.httpMethod = method
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        return request
    }

    func upload(localURL: URL, folder: String) async throws -> (path: String, name: String) {
        let accessed = localURL.startAccessingSecurityScopedResource()
        defer { if accessed { localURL.stopAccessingSecurityScopedResource() } }

        let data = try Data(contentsOf: localURL, options: .mappedIfSafe)
        guard data.count <= maxSize else { throw StorageError.fileTooLarge }

        let originalName = localURL.lastPathComponent
        let path = "\(folder)/\(UUID().uuidString)_\(Self.sanitize(originalName))"
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let mime = UTType(filenameExtension: localURL.pathExtension)?.preferredMIMEType ?? "application/octet-stream"

        var request = makeRequest("object/\(SupabaseConfig.chatBucket)/\(encodedPath)", method: "POST")
        request.setValue(mime, forHTTPHeaderField: "Content-Type")
        request.setValue("false", forHTTPHeaderField: "x-upsert")

        let (body, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let http = response as? HTTPURLResponse else { throw StorageError.badResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw StorageError.uploadFailed(Self.serverMessage(body, status: http.statusCode))
        }
        return (path, originalName)
    }

    private static func serverMessage(_ body: Data, status: Int) -> String {
        if let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
           let message = json["message"] as? String {
            return "\(message) (HTTP \(status))"
        }
        return "HTTP \(status)"
    }

    func signedURL(path: String, expiresIn: Int = 3600) async throws -> URL {
        var request = makeRequest("object/sign/\(SupabaseConfig.chatBucket)/\(path)", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["expiresIn": expiresIn])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let signed = json["signedURL"] as? String else {
            throw StorageError.badResponse
        }
        let full = signed.hasPrefix("/storage/v1")
            ? "\(SupabaseConfig.url)\(signed)"
            : "\(SupabaseConfig.url)/storage/v1\(signed)"
        guard let url = URL(string: full) else { throw StorageError.badResponse }
        return url
    }

    private static func sanitize(_ name: String) -> String {
        String(name.map { ch -> Character in
            ((ch.isASCII && (ch.isLetter || ch.isNumber)) || ch == "." || ch == "-" || ch == "_") ? ch : "_"
        })
    }
}
