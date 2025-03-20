# CryptoTracker

CryptoTracker ist eine iOS-App, die es Benutzern ermöglicht, Kryptowährungen in Echtzeit zu verfolgen, Preischarts zu analysieren und favorisierte Coins zu speichern. Die App nutzt **Firebase** zur Benutzerauthentifizierung und **Firestore** zur Speicherung von Favoriten sowie **Keychain** für sichere API-Schlüssel.

## Features

- **Echtzeit-Kryptodaten:** Anzeige aktueller Preise und Marktdaten
- **Preisdiagramme:** Historische Preisdaten in interaktiven Charts
- **Favoriten speichern:** Nutzer können Coins als Favoriten markieren
- **Benutzerauthentifizierung:** Sign-In/Sign-Up mit Firebase
- **API-Schlüssel sicher speichern:** Keychain zur sicheren Speicherung des API-Keys

## Installation

### Voraussetzungen

1. **Xcode** (aktuelle Version empfohlen; Xcode nutzt den integrierten Dependency Manager, sodass kein `pod install` mehr notwendig ist)
2. **Firebase-Setup:**
   - Erstelle ein Firebase-Projekt auf [Firebase Console](https://console.firebase.google.com/)
   - Lade die `GoogleService-Info.plist` herunter und füge sie in dein Xcode-Projekt ein

3. **API-Key generieren:**
   - Registriere dich auf [CoinGecko](https://www.coingecko.com/) oder einer ähnlichen API-Plattform
   - Speichere den API-Key sicher in der Keychain:
     ```swift
     let keychain = Keychain()
     try? keychain.set("DEIN_API_KEY", key: "CryptoAPIKey")
     ```
     
   **API-Key abrufen:**
   ```swift
   // Beispiel: API-Key aus der Keychain abrufen
   if let apiKey = try? keychain.get("CryptoAPIKey") {
       // API-Key erfolgreich abgerufen, nun hier verwenden
       print("API Key: \(apiKey)")
   } else {
       // Fehler: API-Key konnte nicht abgerufen werden
       print("Kein API-Key in der Keychain gefunden.")
   }
   ```

## Projekt einrichten

1. **Repository klonen:**
   ```swift
git clone https://github.com/jchillah/CryptoTracker.git
cd CryptoTracker
   ```
2. **Xcode öffnen:**
    - Öffne die Projektdatei CryptoTracker.xcodeproj
    - Xcode lädt automatisch alle Abhängigkeiten über den integrierten Dependency Manager
    
3. **API-Key auf https://newsapi.org/ erstellen**
    - API Key in der CryptoTrackerApp.swift eintragen an der Stelle "YOUR_API_KEY_Here"
    - an angegebener Stelle den Code entkommentieren
    
4. **App starten:**
    - Wähle einen iOS-Simulator oder ein physisches Gerät aus.
    - Klicke auf Run (▶) in Xcode.
    - den entkommentierten Text löschen oder wieder kommentieren sonst wird der API-Key bei jedem App start erneut gesetzt
    
## VerzeichnisStruktur
   ```swift
CryptoTracker/
├── CryptoTrackerApp.swift  # Haupt-App-Datei
├── Views/                  # SwiftUI Views
├── ViewModels/             # MVVM ViewModels
├── Repositories            # Firestore-Services
├── Services/               # API-Services
├── Models/                 # Datenmodelle
├── Utils/                  # Hilfsfunktionen
├── Resources/              # Assets, GoogleService-Info.plist
└── README.md          
   ```

## Hinweise zur SwiftData-Integration
    Die App verwendet SwiftData zur persistenten Speicherung von Daten (z. B. gespeicherte Kryptowährungsdaten oder Preishistorien). Das persistierbare Modell wird über SwiftData als **CryptoEntity** bzw. **ChartDataEntity** definiert. Im Code werden die Daten in SwiftData (ModelContainer und ModelContext) gespeichert und bei Fehlern (wie dem API-Limit) als Fallback geladen. Dadurch bleiben die Daten auch nach einem Neustart der App verfügbar.

## API Key und Sicherheitsaspekte
Stelle sicher, dass du deinen API-Key niemals öffentlich in GitHub oder ähnlichen Repositories veröffentlichst. Die oben gezeigten Beispiele zur sicheren Speicherung und zum Abruf des API-Keys mit der Keychain sollen dir dabei helfen, die Sicherheit deiner Anwendung zu erhöhen.

## Beiträge
Beiträge sind herzlich willkommen! Bitte lese unsere [CONTRIBUTING.md](https://github.com/jchillah/CryptoTracker/blob/main/contributing.md) für Details zum Verhaltenskodex und zum Einreichungsprozess.
Solltest du Änderungen oder neue Features vorschlagen wollen, erstelle bitte ein Issue mit einer detaillierten Beschreibung der gewünschten Änderungen.

## Lizenz
Dieses Projekt ist proprietary. Alle Rechte sind vorbehalten. Der Code darf ohne ausdrückliche schriftliche Genehmigung des Autors nicht in anderen Apps oder Projekten verwendet werden.

## Kontakt
Für Fragen, Feedback oder Beiträge kontaktiere bitte:
Jaychillah@gmail.com

## Viel Spaß!
