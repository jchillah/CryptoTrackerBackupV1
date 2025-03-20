//
//  ChartDataEntity.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 19.03.25.
//

import SwiftData
import Foundation

@Model
class ChartDataEntity: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date
    var price: Double
    
    init(from chartData: ChartData) {
        self.date = chartData.date
        self.price = chartData.price
    }
    
    func toChartData() -> ChartData {
        return ChartData(date: self.date, price: self.price)
    }
}
