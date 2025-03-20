//
//  PasswordFieldView.swift
//  CryptoTracker
//
//  Created by Michael Winkler on 20.03.25.
//

import SwiftUI

struct PasswordFieldView: View {
    let title: String
    @Binding var text: String
    @Binding var showPassword: Bool
    
    var body: some View {
        HStack {
            if showPassword {
                TextField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                SecureField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Button(action: {
                showPassword.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}
