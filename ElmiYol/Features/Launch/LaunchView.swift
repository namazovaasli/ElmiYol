//
//  LaunchView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct LaunchView: View {
    let isLoading: Bool
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Button(action: onContinue) {
                ZStack(alignment: .bottom) {
                    ElmiYolStyle.background.ignoresSafeArea()
                    AnimatedWaves()
                        .frame(height: geometry.size.height * 0.43)
                        .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .stroke(ElmiYolStyle.primary.opacity(0.2), lineWidth: 1)
                                .frame(width: 184, height: 184)
                            BrandMark(size: 150)
                        }
                        .padding(.bottom, 22)

                        BrandName(fontSize: 44)
                        SplashDivider()
                            .padding(.top, 17)
                        Text("Elmi yolunuzda\netibarlı tərəfdaşınız.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(ElmiYolStyle.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)

                        Spacer(minLength: 24)
                        if isLoading {
                            ProgressView()
                                .tint(ElmiYolStyle.primary.opacity(0.75))
                        } else {
                            Text("Davam etmək üçün toxunun")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(ElmiYolStyle.secondary)
                        }
                    }
                    .padding(.top, max(geometry.safeAreaInsets.top + 46, 76))
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom + 32, 48))
                }
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

 private struct SplashDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(ElmiYolStyle.primary.opacity(0.45)).frame(width: 50, height: 1)
            Circle().fill(ElmiYolStyle.primary).frame(width: 6, height: 6)
            Rectangle().fill(ElmiYolStyle.primary.opacity(0.45)).frame(width: 50, height: 1)
        }
    }
}
