//
//  PriceChartViewModel.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 12.03.25.
//

import SwiftUI
import FirebaseAuth

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var newEmail: String = ""
    @Published var newPassword: String = ""
    @Published var newPasswordConfirm: String = ""
    @Published var updateMessage: String? = nil
    @Published var isLoading: Bool = false

    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        guard let uid = Auth.auth().currentUser?.uid else {
            updateMessage = "Benutzer nicht gefunden."
            return
        }
        Task {
            do {
                try await SettingsRepository.shared.updateDarkMode(isDarkMode: isDarkMode, for: uid)
            } catch {
                updateMessage = error.localizedDescription
            }
        }
    }
    
    func updateEmailSetting() async {
        guard let uid = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else {
            updateMessage = "Benutzer nicht gefunden."
            return
        }
        isLoading = true
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
            updateMessage = "Verifizierungs-E-Mail gesendet. Bitte bestätigen Sie Ihre neue E-Mail-Adresse."
     
            try await SettingsRepository.shared.updateEmail(newEmail: newEmail, for: uid)
            try await FavoritesRepository.shared.updateEmail(newEmail: newEmail, for: uid)
        } catch {
            updateMessage = error.localizedDescription
        }
        isLoading = false
    }

    
    func updatePassword() async {
        guard newPassword == newPasswordConfirm else {
            updateMessage = "Passwörter stimmen nicht überein."
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            updateMessage = "Benutzer nicht gefunden."
            return
        }
        
        guard newPassword.count >= 6 else {
            updateMessage = "Das Passwort muss mindestens 6 Zeichen lang sein."
            return
        }
        
        isLoading = true
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                currentUser.updatePassword(to: newPassword) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
            updateMessage = "Passwort erfolgreich aktualisiert."
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.requiresRecentLogin.rawValue:
                updateMessage = "Bitte melden Sie sich erneut an, um das Passwort zu ändern."
            case AuthErrorCode.weakPassword.rawValue:
                updateMessage = "Das Passwort ist zu schwach. Bitte wählen Sie ein stärkeres Passwort."
            default:
                updateMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
    
    func signOut() async {
        do {
            try AuthService.shared.signOut()
        } catch {
            updateMessage = error.localizedDescription
        }
    }
}
