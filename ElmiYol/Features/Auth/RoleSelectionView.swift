//
//  RoleSelectionView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        AuthPageScaffold(showBackButton: auth.user == nil) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(auth.isCompletingOAuthProfile ? "Profilinizi tamamlayın" : "Rolunuzu seçin")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(ElmiYolStyle.ink)
                    Text(auth.isCompletingOAuthProfile
                         ? "Hesabınız yaradıldı. Davam etmək üçün ElmiYol-dakı rolunuzu seçin."
                         : "ElmiYol-dan istifadə qaydanıza uyğun hesab növünü seçin.")
                        .font(.system(size: 15))
                        .foregroundStyle(ElmiYolStyle.secondary)
                        .lineSpacing(3)
                }

                RoleChoiceCard(
                    image: "role_student_illustration",
                    title: "Magistr tələbəsi",
                    detail: "Tədqiqatınızı, tapşırıqlarınızı və rəhbərinizlə görüşləri idarə edin.",
                    actionTitle: "Tələbə kimi davam et"
                ) {
                    auth.path.append(.studentRegistration)
                }

                RoleChoiceCard(
                    image: "role_supervisor_illustration",
                    title: "Elmi rəhbər",
                    detail: "Tələbələrin tədqiqat işlərini izləyin və onlara rəy verin.",
                    actionTitle: "Rəhbər kimi davam et"
                ) {
                    auth.path.append(.supervisorRegistration)
                }

                if auth.user == nil {
                    Button {
                        auth.path = [.login]
                    } label: {
                        Text("Daxil ol")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ElmiYolStyle.primary)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(ElmiYolStyle.border, lineWidth: 1))
                    }
                    .padding(.top, 2)
                } else {
                    Button("Başqa hesabla daxil olun") { auth.signOut() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ElmiYolStyle.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
            }
        }
    }
}

private struct RoleChoiceCard: View {
    let image: String
    let title: String
    let detail: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(image).resizable().scaledToFit().frame(height: 110)
            Text(title).font(.system(size: 19, weight: .bold)).foregroundStyle(ElmiYolStyle.ink)
            Text(detail).font(.system(size: 14)).foregroundStyle(ElmiYolStyle.secondary).multilineTextAlignment(.center)
            Button(action: action) {
                HStack {
                    Text(actionTitle)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ElmiYolStyle.primary)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(ElmiYolStyle.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 2)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(ElmiYolStyle.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.03), radius: 14, y: 7)
    }
}
