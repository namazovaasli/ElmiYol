import AuthenticationServices
import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var launchStage: LaunchStage = .splash
    
    @State private var goingForward = true

    private var slide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goingForward ? .trailing : .leading),
            removal: .move(edge: goingForward ? .leading : .trailing)
        )
    }

    var body: some View {
        Group {
            switch launchStage {
            case .splash:
                LaunchView(isLoading: auth.isResolvingSession, onContinue: continueFromSplash)
                    .transition(slide)
                    .gesture(swipeLeft { continueFromSplash() })
            case .onboardingFirst:
                OnboardingFirstView(
                    onBack: { setLaunchStage(.splash) },
                    onSkip: { setLaunchStage(.onboardingSecond) },
                    onContinue: { setLaunchStage(.onboardingSecond) }
                )
                .swipeBack { setLaunchStage(.splash) }
                .transition(slide)
                .gesture(swipeLeft { setLaunchStage(.onboardingSecond) })
            case .onboardingSecond:
                OnboardingSecondView(
                    onBack: { setLaunchStage(.onboardingFirst) },
                    onFinish: finishOnboarding
                )
                .swipeBack { setLaunchStage(.onboardingFirst) }
                .transition(slide)
                .gesture(swipeLeft { finishOnboarding() })
            case .complete:
                if let role = auth.role {
                    LegacyMainAppView(role: role)
                        .transition(slide)
                        .ignoresSafeArea()
                } else {
                    NavigationStack(path: $auth.path){
                        WelcomeView()
                            .transition(slide)
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

    private func order(_ stage: LaunchStage) -> Int {
        switch stage {
        case .splash: return 0
        case .onboardingFirst: return 1
        case .onboardingSecond: return 2
        case .complete: return 3
        }
    }

    private func setLaunchStage(_ stage: LaunchStage) {
        goingForward = order(stage) >= order(launchStage)
        withAnimation(.easeInOut(duration: 0.3)) {
            launchStage = stage
        }
    }

    private func swipeLeft(_ action: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 30).onEnded { value in
            if value.translation.width < -60,
               abs(value.translation.height) < abs(value.translation.width) {
                action()
            }
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
