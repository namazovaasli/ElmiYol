//
//  OnboardingViews.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI


private struct OnboardingFeature: Identifiable {
    let icon: String
    let title: String
    var id: String { title }
}

struct OnboardingFirstView: View {
    let onBack: () -> Void
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ElmiYolStyle.background.ignoresSafeArea()
                AnimatedWaves()
                    .frame(height: geometry.size.height * 0.28)
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Keç", action: onSkip)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(ElmiYolStyle.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Image("onboarding_progress_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: min(340, geometry.size.height * 0.42))
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    OnboardingPageIndicator(activePage: 0)
                        .padding(.top, 10)

                    (Text("İrəliləyişinizi\n").foregroundColor(ElmiYolStyle.ink)
                     + Text("asanlıqla izləyin").foregroundColor(ElmiYolStyle.primary))
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 18)

                    Text("Dissertasiya, tezis və məqalələrinizin mərhələlərini izləyin, son tarixləri qaçırmayın. Hədəflərinizə addım-addım yaxınlaşın.")
                        .font(.system(size: 15))
                        .foregroundStyle(ElmiYolStyle.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 36)
                        .padding(.top, 12)

                    Spacer(minLength: 18)
                    HStack(spacing: 12) {
                        OnboardingActionButton(title: "Geri", secondary: true, action: onBack)
                        OnboardingActionButton(title: "Növbəti", icon: "chevron.right", action: onContinue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom + 16, 28))
                }
            }
        }
    }
}

struct OnboardingSecondView: View {
    let onBack: () -> Void
    let onFinish: () -> Void

    private let features: [OnboardingFeature] = [
        OnboardingFeature(icon: "bubble.left.and.bubble.right.fill", title: "Rəylər və\nşərhlər"),
        OnboardingFeature(icon: "square.and.arrow.up.fill", title: "Fayl\npaylaşımı"),
        OnboardingFeature(icon: "bell.fill", title: "Bildirişlərlə\nxəbərdar olun")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ElmiYolStyle.background.ignoresSafeArea()
                AnimatedWaves()
                    .frame(height: geometry.size.height * 0.25)
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Keç", action: onFinish)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(ElmiYolStyle.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Image("onboarding_teacher_student_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: min(320, geometry.size.height * 0.39))
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    OnboardingPageIndicator(activePage: 1)
                        .padding(.top, 10)

                    (Text("Elmi rəhbərlə\n").foregroundColor(ElmiYolStyle.ink)
                     + Text("daim əlaqədə olun").foregroundColor(ElmiYolStyle.primary))
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 18)

                    Text("Rəyləri görün, suallarınızı verin, fayl və sənədlərinizi asanlıqla paylaşın.")
                        .font(.system(size: 15))
                        .foregroundStyle(ElmiYolStyle.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 36)
                        .padding(.top, 12)

                    HStack(alignment: .top, spacing: 8) {
                        ForEach(features) { feature in
                            VStack(spacing: 8) {
                                Image(systemName: feature.icon)
                                    .font(.system(size: 19, weight: .medium))
                                    .foregroundStyle(ElmiYolStyle.primary)
                                Text(feature.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(ElmiYolStyle.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                    Spacer(minLength: 16)
                    HStack(spacing: 12) {
                        OnboardingActionButton(title: "Geri", secondary: true, action: onBack)
                        OnboardingActionButton(title: "Başlayaq", icon: "chevron.right", action: onFinish)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom + 16, 28))
                }
            }
        }
    }
}

struct OnboardingPageIndicator: View {
    let activePage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<2) { page in
                Capsule()
                    .fill(page == activePage ? ElmiYolStyle.primary : ElmiYolStyle.border)
                    .frame(width: page == activePage ? 20 : 8, height: 7)
            }
        }
        .accessibilityLabel("Səhifə \(activePage + 1), 2-dən")
    }
}


struct OnboardingActionButton: View {
    let title: String
    var icon: String? = nil
    var secondary = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Text(title)
                if let icon { Image(systemName: icon) }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(secondary ? ElmiYolStyle.ink : .white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(secondary ? Color(uiColor: AppColors.separator) : ElmiYolStyle.primary, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

