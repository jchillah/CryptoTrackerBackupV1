//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SwiftData

@main
struct CryptoTrackerApp: App {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    let container: ModelContainer

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var cryptoListViewModel: CryptoListViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var priceChartViewModel: PriceChartViewModel

    init() {
        //         let saved = KeychainHelper.shared.saveAPIKey("YOUR_API_KEY_HERE")
        //         if saved {
        //             print("API-Key erfolgreich in der Keychain gespeichert.")
        //         } else {
        //             print("Fehler beim Speichern des API-Keys.")
        //         }
        FirebaseApp.configure()
        let schema = Schema([CryptoEntity.self, ChartDataEntity.self])
        self.container = try! ModelContainer(for: schema)
        let mainContext = container.mainContext
        _cryptoListViewModel = StateObject(wrappedValue: CryptoListViewModel(modelContext: mainContext))
        _priceChartViewModel = StateObject(wrappedValue: PriceChartViewModel(modelContext: mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(authViewModel)
                .environmentObject(favoritesViewModel)
                .environmentObject(cryptoListViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(priceChartViewModel)
                .modelContainer(container)
                .task {
                    if let userId = Auth.auth().currentUser?.uid {
                        do {
                            let settings = try await SettingsRepository.shared.fetchSettings(for: userId)
                            if let dm = settings["isDarkMode"] as? Bool {
                                isDarkMode = dm
                            }
                        } catch {
                            print("Fehler beim Abrufen der Einstellungen: \(error)")
                        }
                    }
                }
        }
    }
}
