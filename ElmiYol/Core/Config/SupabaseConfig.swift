//
//  SupabaseConfig.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import Foundation

enum SupabaseConfig {
    static let url = "https://rscaulzoylcdaqpyapfx.supabase.co\(value("SupabaseHost"))"
    static let anonKey = value("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzY2F1bHpveWxjZGFxcHlhcGZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1NzQ4ODUsImV4cCI6MjEwODE1MDg4NX0.iD9i7fIJQKUz5TYQuqVgS4l8LHo0j2Z2iuMtxCpj6_0")
    static let chatBucket = "chat-files"

    private static func value(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
}
