//
//  FavoritesRepository.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 18.03.25.
//

import Foundation
import FirebaseFirestore

class FavoritesRepository {
    static let shared = FavoritesRepository()
    private let db = Firestore.firestore()
    
    private init() { }
    
    func addFavorite(coinId: String, for userId: String) async throws {
        var currentFavorites = try await fetchFavorites(for: userId)
        currentFavorites.insert(coinId)
        if let userEmail = try await fetchUserEmail(for: userId) {
            try await updateFavorites(favorites: currentFavorites, for: userId, userEmail: userEmail)
        }
    }
    
    func updateFavorites(favorites: Set<String>, for userId: String, userEmail: String) async throws {
        let favoritesArray = Array(favorites)
        try await db.collection("users").document(userId).setData([
            "favorites": favoritesArray,
            "email": userEmail
        ], merge: true)
    }
    
    func updateEmail(newEmail: String, for userId: String) async throws {
        let docRef = db.collection("users").document(userId)
        let document = try await docRef.getDocument()
        if document.exists {
            try await docRef.setData(["email": newEmail], merge: true)
        } else {
            try await docRef.setData(["email": newEmail])
        }
    }

    
    func fetchFavorites(for userId: String) async throws -> Set<String> {
        let document = try await db.collection("users").document(userId).getDocument()
        if let data = document.data(), let favArray = data["favorites"] as? [String] {
            return Set(favArray)
        }
        return []
    }
    
    func fetchUserEmail(for userId: String) async throws -> String? {
        let document = try await db.collection("users").document(userId).getDocument()
        if let data = document.data(), let email = data["email"] as? String {
            return email
        }
        return nil
    }
    
    func deleteFavorites(for userId: String) async throws {
        try await db.collection("users").document(userId).updateData(["favorites": FieldValue.delete()])
    }
}
