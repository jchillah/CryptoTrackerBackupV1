//
//  FavoritesViewModel.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 18.03.25.
//

import Foundation
import FirebaseAuth

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteIDs: Set<String> = []
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Kein angemeldeter Benutzer oder keine Email gefunden.")
            return
        }
        
        Task {
            do {
                let fetched = try await FavoritesRepository.shared.fetchFavorites(for: userID)
                self.favoriteIDs = fetched
            } catch {
                print("Fehler beim Laden der Favoriten: \(error)")
            }
        }
    }
    
    func toggleFavorite(coin: Crypto) {
        guard let userID = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            print("Kein angemeldeter Benutzer oder keine Email gefunden.")
            return
        }
        
        if favoriteIDs.contains(coin.id) {
            favoriteIDs.remove(coin.id)
        } else {
            favoriteIDs.insert(coin.id)
        }
        
        Task {
            do {
                try await FavoritesRepository.shared.updateFavorites(favorites: favoriteIDs, for: userID, userEmail: email)
            } catch {
                print("Fehler beim Speichern der Favoriten: \(error)")
            }
        }
    }
    
    func isFavorite(coin: Crypto) -> Bool {
        return favoriteIDs.contains(coin.id)
    }
}
