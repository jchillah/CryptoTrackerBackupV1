//
//  CryptoDetailViewModel.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import Foundation
import SwiftData

@MainActor
class CryptoDetailViewModel: ObservableObject {
    let coin: Crypto
    let applyConversion: Bool
    private let parentViewModel: CryptoListViewModel
    private let fixedCurrency: String?
    private let modelContext: ModelContext

    init(coin: Crypto, viewModel: CryptoListViewModel, currency: String? = nil, applyConversion: Bool = false, modelContext: ModelContext) {
        self.coin = coin
        self.applyConversion = applyConversion
        self.parentViewModel = viewModel
        self.fixedCurrency = currency
        self.modelContext = modelContext
    }
    
    var effectiveCurrency: String {
        fixedCurrency ?? parentViewModel.selectedCurrency
    }
    
    var conversionFactor: Double {
        parentViewModel.conversionFactor(for: effectiveCurrency)
    }
    
    var effectivePrice: Double {
        applyConversion ? coin.currentPrice * conversionFactor : coin.currentPrice
    }
    
    var effectiveMarketCap: Double {
        applyConversion ? coin.marketCap * conversionFactor : coin.marketCap
    }
    
    var effectiveVolume: Double {
        applyConversion ? coin.volume * conversionFactor : coin.volume
    }
    
    var effectiveHigh24h: Double {
        applyConversion ? coin.high24h * conversionFactor : coin.high24h
    }
    
    var effectiveLow24h: Double {
        applyConversion ? coin.low24h * conversionFactor : coin.low24h
    }
}
