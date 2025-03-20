//
//  PriceHistoryService.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import Foundation
import SwiftData

class ChartDataService {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchChartData(for coinId: String, vsCurrency: String) async throws -> [ChartData] {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coinId)/market_chart?vs_currency=\(vsCurrency)&days=365"
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
                throw NSError(domain: "ChartDataService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Abfrage-Limit erreicht, bitte versuchen Sie es in einer Minute erneut."])
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            saveDataToLocalJSON(data: data, for: coinId, vsCurrency: vsCurrency)
            let chartData = try parseChartData(data)
            
            // Persistiere die Daten in SwiftData
            saveChartDataToDatabase(chartData: chartData, coinId: coinId, vsCurrency: vsCurrency)
            return chartData
        } catch {
            // Falls ein Fehler auftritt (z. B. API-Limit), versuche, persistierte Daten zu laden
            let entities = loadChartDataFromDatabase(for: coinId, vsCurrency: vsCurrency)
            if !entities.isEmpty {
                return entities.map { $0.toChartData() }
            }
            if let urlError = error as? URLError, urlError.code == .badServerResponse {
                throw NSError(domain: "ChartDataService", code: -1011, userInfo: [NSLocalizedDescriptionKey: "Abfrage-Limit erreicht, bitte versuchen Sie es in einer Minute erneut."])
            }
            print("Kein lokaler Cache verfügbar. Rückgabe eines leeren Arrays. Fehler: \(error)")
            return []
        }
    }
    
    private func parseChartData(_ data: Data) throws -> [ChartData] {
        let decoder = JSONDecoder()
        let historyResponse = try decoder.decode(ChartHistoryResponse.self, from: data)
        let priceData: [ChartData] = historyResponse.prices.compactMap { array in
            guard array.count >= 2 else { return nil }
            let timestamp = array[0]
            let price = array[1]
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            return ChartData(date: date, price: price)
        }
        return priceData
    }
    
    private func localFileURL(for coinId: String, vsCurrency: String) -> URL {
        let fileName = "\(coinId)_\(vsCurrency)_365.json"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }
    
    private func saveDataToLocalJSON(data: Data, for coinId: String, vsCurrency: String) {
        let fileURL = localFileURL(for: coinId, vsCurrency: vsCurrency)
        do {
            try data.write(to: fileURL)
        } catch {
            print("Fehler beim Speichern der lokalen JSON: \(error)")
        }
    }
    
    private func loadLocalJSON(for coinId: String, vsCurrency: String) -> Data? {
        let fileURL = localFileURL(for: coinId, vsCurrency: vsCurrency)
        return try? Data(contentsOf: fileURL)
    }
    
    // MARK: - SwiftData Persistenz
    
    private func saveChartDataToDatabase(chartData: [ChartData], coinId: String, vsCurrency: String) {
        let existing = loadChartDataFromDatabase(for: coinId, vsCurrency: vsCurrency)
        for entity in existing {
            modelContext.delete(entity)
        }
        
        chartData.forEach { data in
            let entity = ChartDataEntity(from: data)
            modelContext.insert(entity)
        }
        try? modelContext.save()
    }
    
    private func loadChartDataFromDatabase(for coinId: String, vsCurrency: String) -> [ChartDataEntity] {
        let fetchDescriptor = FetchDescriptor<ChartDataEntity>()
        return (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
}
