//
//  DateFormatterUtil.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 18.03.25.
//

import Foundation

struct DateFormatterUtil {
    static func formatDateToGermanStyle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm" // Tag.Monat.Jahr, Stunden:Minuten
        formatter.locale = Locale(identifier: "de_DE") // Deutsche Spracheinstellung
        return formatter.string(from: date)
    }
}
