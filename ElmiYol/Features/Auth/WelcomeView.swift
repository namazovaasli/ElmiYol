//
//  WelcomeView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        ZStack {
            ElmiYolStyle.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 48)
                    BrandMark(size: 142)
                    BrandName(fontSize: 40).padding(.top, 8)
                    Text("Elmi yolunuzda etibarlı tərəfdaşınız.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(ElmiYolStyle.secondary)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Elmi işlərinizi bir yerdə idarə edin")
                            .font(.system(size: 29, weight: .bold))
                            .foregroundStyle(ElmiYolStyle.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Tədqiqat mərhələlərini izləyin, rəhbərinizlə əlaqədə qalın və görüşlərinizi planlaşdırın.")
                            .font(.system(size: 16))
                            .foregroundStyle(ElmiYolStyle.secondary)
                            .lineSpacing(4)
                        HStack(spacing: 12) {
                            FeatureBadge(icon: "checkmark.circle.fill", title: "İrəliləyiş")
                            FeatureBadge(icon: "person.2.fill", title: "Əməkdaşlıq")
                            FeatureBadge(icon: "calendar", title: "Planlama")
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(22)
                    .background(.white, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(ElmiYolStyle.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.035), radius: 16, y: 8)
                    .padding(.top, 44)

                    VStack(spacing: 12) {
                        PrimaryActionButton(title: "Daxil ol", isLoading: false) {
                            auth.path.append(.login)
                        }
                        Button {
                            auth.path.append(.roleSelection)
                        } label: {
                            Text("Hesab yarat")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(ElmiYolStyle.primary)
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(ElmiYolStyle.border, lineWidth: 1))
                        }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 28)
                    Spacer(minLength: 24)
                }
                .frame(maxWidth: 520)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct FeatureBadge: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(ElmiYolStyle.primary)
            Text(title).font(.system(size: 11, weight: .medium)).foregroundStyle(ElmiYolStyle.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(ElmiYolStyle.background, in: RoundedRectangle(cornerRadius: 14))
    }
}
