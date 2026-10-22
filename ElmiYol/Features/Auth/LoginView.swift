//
//  LoginView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        AuthPageScaffold {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daxil ol")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(ElmiYolStyle.ink)
                    Text("Hesabınıza daxil olmaq üçün məlumatlarınızı yazın.")
                        .font(.system(size: 15))
                        .foregroundStyle(ElmiYolStyle.secondary)
                }

                AuthTextField(title: "E-poçt ünvanı", placeholder: "example@mail.com", text: $email, icon: "envelope", validator: .email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                AuthSecureField(title: "Şifrə", placeholder: "Şifrənizi daxil edin", text: $password)
                    .textContentType(.password)

                HStack {
                    Spacer()
                    Button("Şifrəni unutdunuz?") { resetPassword() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ElmiYolStyle.primary)
                }
                .padding(.top, -10)

                PrimaryActionButton(title: "Daxil ol", isLoading: auth.isBusy) {
                    Task { await auth.signIn(email: email, password: password) }
                }

                HStack(spacing: 12) {
                    Rectangle().fill(ElmiYolStyle.border).frame(height: 1)
                    Text("və ya").font(.system(size: 14)).foregroundStyle(ElmiYolStyle.muted)
                    Rectangle().fill(ElmiYolStyle.border).frame(height: 1)
                }

                Button {
                    Task { await auth.signInWithGoogle() }
                } label: {
                    HStack(spacing: 10) {
                        Image("google_icon").resizable().scaledToFit().frame(width: 20, height: 20)
                        Text("Google ilə davam et")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ElmiYolStyle.ink)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(.white, in: RoundedRectangle(cornerRadius: 15))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(ElmiYolStyle.border, lineWidth: 1))
                }
                .disabled(auth.isBusy)

                HStack(spacing: 4) {
                    Text("Hesabınız yoxdur?").foregroundStyle(ElmiYolStyle.secondary)
                    Button("Qeydiyyatdan keçin") { auth.path.append(.roleSelection) }
                        .foregroundStyle(ElmiYolStyle.primary)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    private var validEmail: Bool {
        FieldValidator(type: .email).validate(email).isValid
    }

    private func resetPassword() {
        guard validEmail else {
            auth.showMessage("Şifrəni sıfırlamaq üçün əvvəlcə düzgün e-poçt ünvanınızı daxil edin.")
            return
        }
        Task { await auth.sendPasswordReset(to: email) }
    }
}
