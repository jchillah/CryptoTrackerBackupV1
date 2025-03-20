//
//  SettingsRepository.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 19.03.25.
//

import Foundation
import FirebaseFirestore

class SettingsRepository {
    static let shared = SettingsRepository()
    private let db = Firestore.firestore()
    
    private init() { }
    
    func setSettings(_ settings: [String: Any], for userId: String) async throws {
        try await db.collection("users").document(userId).setData(settings, merge: true)
    }
    
    func fetchSettings(for userId: String) async throws -> [String: Any] {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data() ?? [:]
    }
    
    func updateSettings(_ settings: [String: Any], for userId: String) async throws {
        try await db.collection("users").document(userId).updateData(settings)
    }
    
    func deleteSettings(for userId: String) async throws {
        try await db.collection("users").document(userId).delete()
    }
    
    func updateDarkMode(isDarkMode: Bool, for userId: String) async throws {
        let docRef = db.collection("users").document(userId)
        try await docRef.setData(["isDarkMode": isDarkMode], merge: true)
    }
    
    func updateEmail(newEmail: String, for userId: String) async throws {
            let docRef = db.collection("users").document(userId)
            try await docRef.setData(["email": newEmail], merge: true)
        }
}
