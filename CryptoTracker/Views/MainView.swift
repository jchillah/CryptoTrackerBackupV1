//
//  MainView.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: CryptoListViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    var body: some View {
        TabView {
            CryptoListView()
                .tabItem {
                    Label("Top Coins", systemImage: "bitcoinsign.circle.fill")
                }
            FavoritesView()
                .tabItem {
                    Label("Favoriten", systemImage: "star.fill")
                }
                .environmentObject(favoritesViewModel)
            
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .environmentObject(authViewModel)
                .environmentObject(viewModel)
                .environmentObject(favoritesViewModel)
                .environmentObject(settingsViewModel)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Schema([CryptoEntity.self, ChartDataEntity.self]))
    MainView()
        .environmentObject(AuthViewModel())
        .environmentObject(CryptoListViewModel(modelContext: container.mainContext))
        .environmentObject(FavoritesViewModel())
        .environmentObject(SettingsViewModel())
        .modelContainer(container)
}
