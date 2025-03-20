//
//  PriceChartView.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import SwiftUI
import Charts
import SwiftData

struct PriceChartView: View {
    @StateObject var viewModel: PriceChartViewModel
    let coinId: String
    let vsCurrency: String
    
    @State private var selectedDuration: ChartDuration = .week
    @Environment(\.modelContext) var modelContext: ModelContext

    init(coinId: String, vsCurrency: String, modelContext: ModelContext) {
        self.coinId = coinId
        self.vsCurrency = vsCurrency
        _viewModel = StateObject(wrappedValue: PriceChartViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Zeitraum:")
                Picker("Zeitraum", selection: $selectedDuration) {
                    ForEach(ChartDuration.allCases) { duration in
                        Text(duration.rawValue).tag(duration)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView("Lade Chart...")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Fehler: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                let filteredData = viewModel.filteredData(for: selectedDuration)
                if filteredData.isEmpty {
                    Text("Keine Daten verfügbar, versuche es bitte in einer Minute erneut.")
                        .foregroundStyle(.red)
                } else {
                    Chart {
                        ForEach(filteredData) { dataPoint in
                            LineMark(
                                x: .value("Datum", dataPoint.date),
                                y: .value("Preis", dataPoint.price)
                            )
                        }
                    }
                    .chartYAxisLabel("Preis")
                    .frame(height: 200)
                    .padding()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchPriceHistory(for: coinId)
            }
        }
        .onChange(of: selectedDuration) { _, _ in
            Task {
                await viewModel.fetchPriceHistory(for: coinId)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Schema([CryptoEntity.self, ChartDataEntity.self]))
    PriceChartView(
        coinId: "bitcoin",
        vsCurrency: "usd",
        modelContext: container.mainContext
    )
    .modelContainer(container)
}
