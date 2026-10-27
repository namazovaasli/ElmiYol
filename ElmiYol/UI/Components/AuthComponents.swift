//
//  AuthComponents.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct AuthPageScaffold<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let showBackButton: Bool
    @ViewBuilder let content: Content

    init(showBackButton: Bool = true, @ViewBuilder content: () -> Content) {
        self.showBackButton = showBackButton
        self.content = content()
    }

    var body: some View {
        ZStack {
            ElmiYolStyle.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        if showBackButton {
                            Button { dismiss() } label: {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(ElmiYolStyle.primary)
                                    .frame(width: 40, height: 40)
                                    .background(.white, in: Circle())
                                    .overlay(Circle().stroke(ElmiYolStyle.border, lineWidth: 1))
                            }
                        } else {
                            Color.clear.frame(width: 40, height: 40)
                        }
                        BrandMark(size: 44)
                        BrandName(fontSize: 21)
                        Spacer()
                    }
                    .padding(.bottom, 26)
                    content
                }
                .frame(maxWidth: 520)
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct BrandMark: View {
    let size: CGFloat

    var body: some View {
        Image("elmiyol_logo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .background(.white, in: Circle())
            .overlay(Circle().stroke(ElmiYolStyle.border.opacity(0.7), lineWidth: 1))
    }
}

struct BrandName: View {
    let fontSize: CGFloat

    var body: some View {
        (Text("Elmi").foregroundColor(ElmiYolStyle.navy) + Text("Yol").foregroundColor(ElmiYolStyle.primary))
            .font(.system(size: fontSize, weight: .heavy))
    }
}

struct FieldErrorText: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(.red)
                .transition(.opacity)
        }
    }
}

struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var validator: ValidatorType? = nil
    var showErrorsWhenEmpty = false
    var inputFilter: ((String) -> String)? = nil

    private var errorMessage: String? {
        guard let validator, showErrorsWhenEmpty || !text.isEmpty else { return nil }
        return FieldValidator(type: validator).validate(text).errorMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(ElmiYolStyle.ink)
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 15, weight: .medium)).foregroundStyle(ElmiYolStyle.muted).frame(width: 20)
                }
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .foregroundStyle(ElmiYolStyle.ink)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(errorMessage == nil ? ElmiYolStyle.border : Color.red.opacity(0.7), lineWidth: 1)
            )
            FieldErrorText(message: errorMessage)
        }
        .animation(.easeOut(duration: 0.15), value: errorMessage)
        .onChange(of: text) { _, newValue in
            guard let inputFilter else { return }
            let filtered = inputFilter(newValue)
            if filtered != newValue { text = filtered }
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var validator: ValidatorType? = nil
    var showErrorsWhenEmpty = false

    private var errorMessage: String? {
        guard let validator, showErrorsWhenEmpty || !text.isEmpty else { return nil }
        return FieldValidator(type: validator).validate(text).errorMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(ElmiYolStyle.ink)
            SecureField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundStyle(ElmiYolStyle.ink)
                .padding(.horizontal, 14)
                .frame(minHeight: 52)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(errorMessage == nil ? ElmiYolStyle.border : Color.red.opacity(0.7), lineWidth: 1)
                )
            FieldErrorText(message: errorMessage)
        }
        .animation(.easeOut(duration: 0.15), value: errorMessage)
    }
}

struct ChoicePickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    var fieldError: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(ElmiYolStyle.ink)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon).font(.system(size: 15, weight: .medium)).foregroundStyle(ElmiYolStyle.muted).frame(width: 20)
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(.system(size: 15))
                        .foregroundStyle(selection.isEmpty ? ElmiYolStyle.muted : ElmiYolStyle.ink)
                    Spacer()
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(ElmiYolStyle.muted)
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 52)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(fieldError == nil ? ElmiYolStyle.border : Color.red.opacity(0.7), lineWidth: 1)
                )
            }
            FieldErrorText(message: fieldError)
        }
    }
}

struct PrimaryActionButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading { ProgressView().tint(.white) }
                Text(isLoading ? "Gözləyin..." : title)
                if !isLoading { Image(systemName: "arrow.right") }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(ElmiYolStyle.primary, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isLoading)
    }
}

extension ToggleStyle where Self == CheckboxLikeToggleStyle {
    static var checkboxLike: CheckboxLikeToggleStyle { CheckboxLikeToggleStyle() }
}

struct CheckboxLikeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(configuration.isOn ? ElmiYolStyle.primary : ElmiYolStyle.muted)
                configuration.label
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

func fieldIsValid(_ value: String, _ type: ValidatorType) -> Bool {
    FieldValidator(type: type).validate(value).isValid
}

func phoneDigits(_ value: String) -> String {
    String(value.filter(\.isNumber).prefix(9))
}

extension View {
    func registrationHeading(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.system(size: 28, weight: .bold)).foregroundStyle(ElmiYolStyle.ink)
            Text("Qeydiyyatı").font(.system(size: 28, weight: .bold)).foregroundStyle(ElmiYolStyle.primary)
            Text(subtitle).font(.system(size: 14)).foregroundStyle(ElmiYolStyle.secondary).lineSpacing(3).padding(.top, 8)
        }
        .padding(.bottom, 4)
    }
    func swipeBack(_ action: @escaping () -> Void) -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 24).onEnded { value in
                if value.startLocation.x < 60, value.translation.width > 80, abs(value.translation.height) < 80 {
                    action()
                }
            }
        )
    }
}
struct GoogleContinueButton: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
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
            .background(ElmiYolStyle.surface, in: RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(ElmiYolStyle.border, lineWidth: 1))
        }
        .disabled(auth.isBusy)
    }
}

struct OrDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(ElmiYolStyle.border).frame(height: 1)
            Text("və ya").font(.system(size: 14)).foregroundStyle(ElmiYolStyle.muted)
            Rectangle().fill(ElmiYolStyle.border).frame(height: 1)
        }
    }
}
