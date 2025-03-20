//
//  CryptoListView.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import SwiftUI
import FirebaseFirestore
import SwiftData

struct CryptoListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject var cryptoViewModel: CryptoListViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let lastUpdate = cryptoViewModel.lastUpdate {
                        Text("Update: \(DateFormatterUtil.formatDateToGermanStyle(lastUpdate))")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    Text(cryptoViewModel.statusMessage)
                        .foregroundStyle(cryptoViewModel.statusMessage.contains("Fehler") ? .red : .gray)
                        .padding(.horizontal)
                    
                    Picker("Währung", selection: $cryptoViewModel.selectedCurrency) {
                        ForEach(["usd", "eur", "gbp"], id: \.self) { currency in
                            Text(currency.uppercased()).tag(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: cryptoViewModel.selectedCurrency) { _, _ in
                        Task { await cryptoViewModel.fetchCoins() }
                    }
                    
                    if cryptoViewModel.coins.isEmpty {
                        Text("Keine Daten verfügbar, versuche es bitte in einer Minute erneut.")
                            .foregroundStyle(.gray)
                            .padding()
                    } else {
                        ForEach(cryptoViewModel.coins) { coin in
                            NavigationLink(
                                destination: CryptoDetailView(
                                    coin: coin,
                                    currency: cryptoViewModel.selectedCurrency,
                                    applyConversion: true
                                )
                                .environmentObject(cryptoViewModel)
                                .environmentObject(favoritesViewModel)
                            ) {
                                CryptoRowView(coin: coin, currency: cryptoViewModel.selectedCurrency)
                            }
                        }
                    }
                }
                .padding()
            }
            .refreshable {
                await cryptoViewModel.fetchCoins()
            }
            .navigationTitle("Krypto-Preise")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Schema([CryptoEntity.self, ChartDataEntity.self]))
    CryptoListView()
        .environmentObject(AuthViewModel())
        .environmentObject(CryptoListViewModel(modelContext: container.mainContext))
        .environmentObject(FavoritesViewModel())
        .modelContainer(container)
}
