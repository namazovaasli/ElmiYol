import AuthenticationServices
import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var launchStage: LaunchStage = .splash

    var body: some View {
        Group {
            switch launchStage {
            case .splash:
                LaunchView(isLoading: auth.isResolvingSession, onContinue: continueFromSplash)
            case .onboardingFirst:
                OnboardingFirstView(
                    onBack: { setLaunchStage(.splash) },
                    onSkip: { setLaunchStage(.onboardingSecond) },
                    onContinue: { setLaunchStage(.onboardingSecond) }
                )
                .swipeBack { setLaunchStage(.splash) }
            case .onboardingSecond:
                OnboardingSecondView(
                    onBack: { setLaunchStage(.onboardingFirst) },
                    onFinish: finishOnboarding
                )
                .swipeBack { setLaunchStage(.onboardingFirst) }
            case .complete:
                if let role = auth.role {
                    LegacyMainAppView(role: role)
                        .ignoresSafeArea()
                } else {
                    NavigationStack(path: $auth.path) {
                        WelcomeView()
                            .navigationDestination(for: AuthFlowDestination.self) { destination in
                                switch destination {
                                case .login:
                                    LoginView()
                                case .roleSelection:
                                    RoleSelectionView()
                                case .studentRegistration:
                                    StudentRegistrationView()
                                case .supervisorRegistration:
                                    SupervisorRegistrationView()
                                }
                            }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: launchStage)
        .tint(ElmiYolStyle.primary)
        .alert(
            auth.alertTitle,
            isPresented: Binding(
                get: { auth.alertMessage != nil },
                set: { newValue in
                    if !newValue, auth.alertMessage != nil {
                        auth.alertMessage = nil
                    }
                }
            )
        ) {
            Button("Bağla", role: .cancel) { }
        } message: {
            Text(auth.alertMessage ?? "")
        }
        .sheet(isPresented: $auth.isEmailPromptPresented) {
            EmailLinkCompletionSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private func continueFromSplash() {
        guard !auth.isResolvingSession else { return }
        if auth.user != nil {
            if auth.needsRoleSelection {
                auth.path = [.roleSelection]
            }
            setLaunchStage(.complete)
        } else {
            setLaunchStage(.onboardingFirst)
        }
    }

    private func finishOnboarding() {
        auth.path = [.roleSelection]
        setLaunchStage(.complete)
    }

    private func setLaunchStage(_ stage: LaunchStage) {
        withAnimation(.easeInOut(duration: 0.25)) {
            launchStage = stage
        }
    }
}

private enum LaunchStage: Equatable {
    case splash
    case onboardingFirst
    case onboardingSecond
    case complete
}


private struct EmailLinkCompletionSheet: View {
    @EnvironmentObject private var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("E-poçt ilə giriş").font(.system(size: 24, weight: .bold)).foregroundStyle(ElmiYolStyle.ink)
            Text("Bağlantının göndərildiyi e-poçt ünvanını daxil edin.")
                .font(.system(size: 15)).foregroundStyle(ElmiYolStyle.secondary)
            AuthTextField(title: "E-poçt ünvanı", placeholder: "example@mail.com", text: $auth.emailForEmailLink, icon: "envelope")
                .keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
            HStack(spacing: 12) {
                Button("Ləğv et") {
                    auth.dismissEmailPrompt()
                    dismiss()
                }
                .foregroundStyle(ElmiYolStyle.secondary)
                Spacer()
                Button("Davam et") {
                    auth.completeEmailSignInFromPrompt()
                    dismiss()
                }
                .fontWeight(.semibold).foregroundStyle(ElmiYolStyle.primary)
                .disabled(!FieldValidator(type: .email).validate(auth.emailForEmailLink).isValid)
            }
        }
        .padding(24)
        .padding(.top, 12)
        .background(ElmiYolStyle.background.ignoresSafeArea())
    }
}

private struct LegacyMainAppView: UIViewControllerRepresentable {
    let role: UserRole

    func makeUIViewController(context: Context) -> MainTabBarController {
        let controller = MainTabBarController()
        controller.roleContext = role == .student ? .student : .supervisor
        return controller
    }

    func updateUIViewController(_ controller: MainTabBarController, context: Context) {
        controller.roleContext = role == .student ? .student : .supervisor
    }
}
