//
//  SettingsView.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 17.03.25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account Einstellungen")) {
                    TextField("Neue E-Mail", text: $viewModel.newEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("E-Mail aktualisieren") {
                        Task {
                            await viewModel.updateEmailSetting()
                        }
                    }
                    
                    PasswordFieldView(title: "Neues Passwort", text: $viewModel.newPassword, showPassword: $showPassword)
                    PasswordFieldView(title: "Passwort bestätigen", text: $viewModel.newPasswordConfirm, showPassword: $showConfirmPassword)
                    
                    Button("Passwort aktualisieren") {
                        Task {
                            await viewModel.updatePassword()
                        }
                    }
                }
                
                Section(header: Text("Darstellung")) {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                    }
                    .onChange(of: isDarkMode) { _, newValue in
                        viewModel.toggleDarkMode()
                    }
                }

                Section {
                    Button("Abmelden") {
                        Task {
                            await viewModel.signOut()
                        }
                    }
                    .foregroundStyle(.red)
                }
                
                if let message = viewModel.updateMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
