//
//  CryptoEntity.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 19.03.25.
//

import SwiftData
import Foundation

@Model
class CryptoEntity {
    @Attribute(.unique) var id: String
    var symbol: String
    var name: String
    var image: String
    var currentPrice: Double
    var marketCap: Double
    var marketCapRank: Int
    var volume: Double
    var high24h: Double
    var low24h: Double
    var priceChange24h: Double
    var priceChangePercentage24h: Double
    var lastUpdated: Date

    init(from crypto: Crypto) {
        self.id = crypto.id
        self.symbol = crypto.symbol
        self.name = crypto.name
        self.image = crypto.image
        self.currentPrice = crypto.currentPrice
        self.marketCap = crypto.marketCap
        self.marketCapRank = crypto.marketCapRank
        self.volume = crypto.volume
        self.high24h = crypto.high24h
        self.low24h = crypto.low24h
        self.priceChange24h = crypto.priceChange24h
        self.priceChangePercentage24h = crypto.priceChangePercentage24h
        self.lastUpdated = ISO8601DateFormatter().date(from: crypto.lastUpdated) ?? Date()
    }
}
