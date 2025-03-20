//
//  CryptoService.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import Foundation
import SwiftData

class CryptoService {
    private let coinDataURLBase = "https://api.coingecko.com/api/v3/coins/markets?vs_currency="
    private let exchangeRatesURL = "https://api.coingecko.com/api/v3/exchange_rates"
    
    private var exchangeRates: [String: Double] = [:]
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchCryptoData(for currency: String) async throws -> [Crypto] {
        let urlString = "\(coinDataURLBase)\(currency)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 429 {
                print("⚠️ API-Limit erreicht (429). Wartezeit empfohlen.")
                throw NSError(domain: "CryptoService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Abfrage-Limit erreicht, bitte versuchen Sie es in einer Minute erneut."])
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let coins = try JSONDecoder().decode([Crypto].self, from: data)
            saveCoinsToDatabase(coins: coins)  // Speichern in SwiftData
            return coins
        } catch {
            // Falls ein Fehler auftritt, versuche, die persistierten Daten zu laden
            let localCoins = loadCoinsFromDatabase()
            if !localCoins.isEmpty {
                // Mappe CryptoEntity zurück in Crypto
                return localCoins.map { entity in
                    return Crypto(
                        id: entity.id,
                        symbol: entity.symbol,
                        name: entity.name,
                        image: entity.image,
                        currentPrice: entity.currentPrice,
                        marketCap: entity.marketCap,
                        marketCapRank: entity.marketCapRank,
                        volume: entity.volume,
                        high24h: entity.high24h,
                        low24h: entity.low24h,
                        priceChange24h: entity.priceChange24h,
                        priceChangePercentage24h: entity.priceChangePercentage24h,
                        lastUpdated: ISO8601DateFormatter().string(from: entity.lastUpdated)
                    )
                }
            }
            throw error
        }
    }
    
    func fetchExchangeRates() async throws {
        guard let url = URL(string: exchangeRatesURL) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 429 {
                print("⚠️ API-Limit erreicht (429). Wartezeit empfohlen.")
                throw NSError(domain: "CryptoService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Abfrage-Limit erreicht, bitte versuchen Sie es in einer Minute erneut."])
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let ratesResponse = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
            exchangeRates = ratesResponse.rates.mapValues { $0.value }
        } catch {
            throw error
        }
    }
    
    func getConversionRate(for currency: String) -> Double {
        return exchangeRates[currency.lowercased()] ?? 1.0 
    }
    
    // Speichere die Coins in SwiftData
    private func saveCoinsToDatabase(coins: [Crypto]) {
        for coin in coins {
            let entity = CryptoEntity(from: coin)
            modelContext.insert(entity)
        }
        try? modelContext.save()
    }
    
    // Lade die Coins aus SwiftData
    private func loadCoinsFromDatabase() -> [CryptoEntity] {
        let fetchDescriptor = FetchDescriptor<CryptoEntity>()
        return (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
}
