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
            case .onboardingSecond:
                OnboardingSecondView(
                    onBack: { setLaunchStage(.onboardingFirst) },
                    onFinish: finishOnboarding
                )
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
                set: { if !$0 { auth.alertMessage = nil } }
            )
        ) {
            Button("Bağla", role: .cancel) { auth.alertMessage = nil }
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

private struct LaunchView: View {
    let isLoading: Bool
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Button(action: onContinue) {
                ZStack(alignment: .bottom) {
                    Color.white.ignoresSafeArea()
                    OnboardingWaves()
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

private struct OnboardingFirstView: View {
    let onBack: () -> Void
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                OnboardingWaves()
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

private struct OnboardingSecondView: View {
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
                Color.white.ignoresSafeArea()
                OnboardingWaves()
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

private struct OnboardingFeature: Identifiable {
    let icon: String
    let title: String
    var id: String { title }
}

private struct OnboardingPageIndicator: View {
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

private struct OnboardingActionButton: View {
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
            .background(secondary ? Color(red: 0.94, green: 0.95, blue: 0.97) : ElmiYolStyle.primary, in: Capsule())
        }
        .buttonStyle(.plain)
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

private struct OnboardingWaves: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                OnboardingWaveShape()
                    .fill(ElmiYolStyle.primary.opacity(0.05))
                    .frame(height: geometry.size.height * 0.78)
                    .offset(y: 18)
                OnboardingWaveShape()
                    .fill(ElmiYolStyle.primary.opacity(0.07))
                    .frame(height: geometry.size.height * 0.58)
                    .offset(y: 22)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct OnboardingWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.24))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.20),
            control1: CGPoint(x: rect.width * 0.27, y: -rect.height * 0.05),
            control2: CGPoint(x: rect.width * 0.58, y: rect.height * 0.50)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct WelcomeView: View {
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

private struct LoginView: View {
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

                AuthTextField(title: "E-poçt ünvanı", placeholder: "example@mail.com", text: $email, icon: "envelope")
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

private struct RoleSelectionView: View {
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

private struct StudentRegistrationView: View {
    @EnvironmentObject private var auth: AuthManager
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var groupNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @StateObject private var catalog = CatalogViewModel()
    @State private var university: CatalogItem?
    @State private var faculty: CatalogItem?
    @State private var speciality: CatalogItem?
    @State private var studyYears: CatalogItem?
    @State private var showSelectionErrors = false
    @State private var acceptedTerms = false

    private var studyYearsItems: [CatalogItem] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0...3).map {
            let text = "\(currentYear + $0)-\(currentYear + $0 + 2)"
            return CatalogItem(id: text, name: text)
        }
    }

    var body: some View {
        AuthPageScaffold {
            VStack(alignment: .leading, spacing: 18) {
                registrationHeading(title: "Magistr tələbəsi", subtitle: "Tələbə profilinizi yaratmaq üçün məlumatları doldurun.")
                AuthTextField(title: "Ad", placeholder: "Adınızı daxil edin", text: $firstName, icon: "person")
                    .textContentType(.givenName)
                AuthTextField(title: "Soyad", placeholder: "Soyadınızı daxil edin", text: $lastName, icon: "person")
                    .textContentType(.familyName)
                AuthTextField(title: "E-poçt ünvanı", placeholder: "example@mail.com", text: $email, icon: "envelope")
                    .textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .disabled(auth.user != nil)
                AuthTextField(title: "Telefon nömrəsi", placeholder: "50 123 45 67", text: $phone, icon: "phone")
                    .keyboardType(.phonePad)
                
                CatalogPickerField(
                    title: "Universitet", placeholder: "Universitetinizi seçin", icon: "building.columns",
                    items: catalog.universities,
                    isLoading: catalog.isLoadingUniversities,
                    loadError: catalog.universitiesError,
                    fieldError: showSelectionErrors && university == nil ? "Universiteti seçin" : nil,
                    selection: $university,
                    onRetry: { Task { await catalog.loadUniversities() } }
                )
                
                CatalogPickerField(
                    title: "Fakültə", placeholder: "Fakültənizi seçin", icon: "person.text.rectangle",
                    items: catalog.faculties,
                    isLoading: catalog.isLoadingFaculties,
                    loadError: catalog.facultiesError,
                    isEnabled: university != nil,
                    disabledHint: "Əvvəlcə universiteti seçin",
                    fieldError: showSelectionErrors && faculty == nil && university != nil ? "Fakültəni seçin" : nil,
                    selection: $faculty,
                    onRetry: {
                        if let university { Task { await catalog.loadFaculties(universityId: university.id) } }
                    }
                )
                
                CatalogPickerField(
                    title: "İxtisas", placeholder: "İxtisasınızı seçin", icon: "graduationcap",
                    items: catalog.specialities,
                    isLoading: catalog.isLoadingSpecialities,
                    loadError: catalog.specialitiesError,
                    isEnabled: faculty != nil,
                    disabledHint: "Əvvəlcə fakültəni seçin",
                    fieldError: showSelectionErrors && speciality == nil && faculty != nil ? "İxtisası seçin" : nil,
                    selection: $speciality,
                    onRetry: {
                        if let university, let faculty {
                            Task { await catalog.loadSpecialities(universityId: university.id, facultyId: faculty.id) }
                        }
                    }
                )
                
                AuthTextField(title: "Qrup nömrəsi", placeholder: "Məs: 704a2", text: $groupNumber, icon: "number")
                
                CatalogPickerField(
                    title: "Təhsil illəri", placeholder: "Təhsil illərinizi seçin", icon: "calendar",
                    items: studyYearsItems,
                    fieldError: showSelectionErrors && studyYears == nil ? "Təhsil illərini seçin" : nil,
                    selection: $studyYears
                )
                
                if auth.user == nil {
                    AuthSecureField(title: "Şifrə", placeholder: "Şifrə yaradın", text: $password)
                        .textContentType(.newPassword)
                    AuthSecureField(title: "Şifrəni təkrar daxil edin", placeholder: "Şifrəni təkrar edin", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                termsToggle
                PrimaryActionButton(title: "Qeydiyyatdan keç", isLoading: auth.isBusy) {
                    submit()
                }
                existingAccountPrompt
            }
        }
        .onAppear(perform: prefillAccountDetails)
        
        .task { await catalog.loadUniversities() }
        .onChange(of: university) { _, newValue in
            faculty = nil
            speciality = nil
            guard let newValue else { catalog.clearFaculties(); return }
            Task { await catalog.loadFaculties(universityId: newValue.id) }
        }
        .onChange(of: faculty) { _, newValue in
            speciality = nil
            guard let newValue, let university else { catalog.clearSpecialities(); return }
            Task { await catalog.loadSpecialities(universityId: university.id, facultyId: newValue.id) }
        }
    }

    private var termsToggle: some View {
        Toggle(isOn: $acceptedTerms) {
            Text("Məlumatların düzgün olduğunu təsdiqləyirəm və istifadə şərtləri ilə razıyam.")
                .font(.system(size: 13))
                .foregroundStyle(ElmiYolStyle.secondary)
        }
        .tint(ElmiYolStyle.primary)
        .toggleStyle(.checkboxLike)
    }

    private var existingAccountPrompt: some View {
        HStack(spacing: 4) {
            Text("Artıq hesabınız var?").foregroundStyle(ElmiYolStyle.secondary)
            Button("Daxil ol") { auth.path = [.login] }
                .foregroundStyle(ElmiYolStyle.primary).fontWeight(.semibold)
        }
        .font(.system(size: 14)).frame(maxWidth: .infinity).padding(.top, 2)
    }

    private func prefillAccountDetails() {
        if firstName.isEmpty { firstName = auth.registrationFirstName }
        if lastName.isEmpty { lastName = auth.registrationLastName }
        if email.isEmpty { email = auth.registrationEmail }
    }

    private func submit() {
        showSelectionErrors = true
        var model = StudentRegisterModel()
        model.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        model.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        model.groupNumber = groupNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        model.university = university?.name ?? ""
        model.universityId = university?.id ?? ""
        model.faculty = faculty?.name ?? ""
        model.facultyId = faculty?.id ?? ""
        model.speciality = speciality?.name ?? ""
        model.specialityId = speciality?.id ?? ""
        model.studyYears = studyYears?.name ?? ""
        
        model.password = auth.user == nil ? password : ""
        model.confirmPassword = auth.user == nil ? confirmPassword : ""
        model.acceptedTerms = acceptedTerms

        let required: [(String, ValidatorType)] = [
            (model.firstName, .name), (model.lastName, .surname), (model.email, .email),
            (model.phone, .phone), (model.groupNumber, .required(fieldName: "Qrup nömrəsi"))
        ]
        guard validate(required, onError: { auth.showMessage($0) }) else { return }
        guard university != nil, faculty != nil, speciality != nil, studyYears != nil else {
            auth.showMessage("Universitet, fakültə, ixtisas və təhsil illərini seçin.")
            return
        }
        if auth.user == nil {
            guard validate([(password, .password), (confirmPassword, .confirmPassword(originalPassword: { password }))], onError: { auth.showMessage($0) }) else { return }
        }
        guard acceptedTerms else {
            auth.showMessage("Davam etmək üçün istifadə şərtləri ilə razılaşın.")
            return
        }
        Task { await auth.registerStudent(model) }
    }
}

private struct SupervisorRegistrationView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var catalog = CatalogViewModel()
    @State private var workplace: CatalogItem?
    @State private var specialityField: CatalogItem?
    @State private var showSelectionErrors = false
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var position = ""
    @State private var academicDegree = ""
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptedTerms = false

    private let positionOptions = ["Professor", "Dosent", "Baş müəllim", "Assistent"]
    private let degreeOptions = ["Elmlər doktoru", "Fəlsəfə doktoru (PhD)", "Dosent", "Professor"]
   

    var body: some View {
        AuthPageScaffold {
            VStack(alignment: .leading, spacing: 18) {
                registrationHeading(title: "Elmi rəhbər", subtitle: "Rəhbər profilinizi yaratmaq üçün məlumatları doldurun.")
                AuthTextField(title: "Ad", placeholder: "Adınızı daxil edin", text: $firstName, icon: "person").textContentType(.givenName)
                AuthTextField(title: "Soyad", placeholder: "Soyadınızı daxil edin", text: $lastName, icon: "person").textContentType(.familyName)
                AuthTextField(title: "E-poçt ünvanı", placeholder: "example@mail.com", text: $email, icon: "envelope")
                    .textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .disabled(auth.user != nil)
                AuthTextField(title: "Telefon nömrəsi", placeholder: "50 123 45 67", text: $phone, icon: "phone").keyboardType(.phonePad)
                
                CatalogPickerField(
                    title: "İş yeri / Universitet", placeholder: "İş yerinizi seçin", icon: "building.columns",
                    items: catalog.universities,
                    isLoading: catalog.isLoadingUniversities,
                    loadError: catalog.universitiesError,
                    fieldError: showSelectionErrors && workplace == nil ? "İş yerini seçin" : nil,
                    selection: $workplace,
                    onRetry: { Task { await catalog.loadUniversities() } }
                )
                
                ChoicePickerField(title: "Vəzifə", placeholder: "Vəzifənizi seçin", selection: $position, options: positionOptions, icon: "person.text.rectangle")
                ChoicePickerField(title: "Elmi dərəcə", placeholder: "Elmi dərəcənizi seçin", selection: $academicDegree, options: degreeOptions, icon: "graduationcap")
                
                CatalogPickerField(
                    title: "İxtisas sahəsi", placeholder: "İxtisas sahənizi seçin", icon: "book",
                    items: catalog.faculties,
                    isLoading: catalog.isLoadingFaculties,
                    loadError: catalog.facultiesError,
                    isEnabled: workplace != nil,
                    disabledHint: "Əvvəlcə iş yerini seçin",
                    fieldError: showSelectionErrors && specialityField == nil && workplace != nil ? "İxtisas sahəsini seçin" : nil,
                    selection: $specialityField,
                    onRetry: {
                        if let workplace { Task { await catalog.loadFaculties(universityId: workplace.id) } }
                    }
                )
                
                if auth.user == nil {
                    AuthSecureField(title: "Şifrə", placeholder: "Şifrə yaradın", text: $password).textContentType(.newPassword)
                    AuthSecureField(title: "Şifrəni təkrar daxil edin", placeholder: "Şifrəni təkrar edin", text: $confirmPassword).textContentType(.newPassword)
                }
                Toggle(isOn: $acceptedTerms) {
                    Text("Məlumatların düzgün olduğunu təsdiq edirəm və istifadə şərtləri ilə razıyam.")
                        .font(.system(size: 13)).foregroundStyle(ElmiYolStyle.secondary)
                }
                .tint(ElmiYolStyle.primary)
                .toggleStyle(.checkboxLike)
                PrimaryActionButton(title: "Qeydiyyatdan keç", isLoading: auth.isBusy) { submit() }
                HStack(spacing: 4) {
                    Text("Artıq hesabınız var?").foregroundStyle(ElmiYolStyle.secondary)
                    Button("Daxil ol") { auth.path = [.login] }.foregroundStyle(ElmiYolStyle.primary).fontWeight(.semibold)
                }
                .font(.system(size: 14)).frame(maxWidth: .infinity).padding(.top, 2)
            }
        }
        .onAppear(perform: prefillAccountDetails)
        .task { await catalog.loadUniversities() }
        .onChange(of: workplace) { _, newValue in
            specialityField = nil
            guard let newValue else { catalog.clearFaculties(); return }
            Task { await catalog.loadFaculties(universityId: newValue.id) }
        }
    }

    private func prefillAccountDetails() {
        if firstName.isEmpty { firstName = auth.registrationFirstName }
        if lastName.isEmpty { lastName = auth.registrationLastName }
        if email.isEmpty { email = auth.registrationEmail }
    }

    private func submit() {
        var model = SupervisorRegisterModel()
        model.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        model.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        showSelectionErrors = true
        model.workplace = workplace?.name ?? ""
        model.workplaceId = workplace?.id ?? ""
        model.specialityField = specialityField?.name ?? ""
        model.facultyId = specialityField?.id ?? ""
        
        model.position = position
        model.academicDegree = academicDegree
        model.password = auth.user == nil ? password : ""
        model.confirmPassword = auth.user == nil ? confirmPassword : ""
        model.acceptedTerms = acceptedTerms

        let required: [(String, ValidatorType)] = [
            (model.firstName, .name), (model.lastName, .surname), (model.email, .email), (model.phone, .phone)
        ]
        guard validate(required, onError: { auth.showMessage($0) }) else { return }
        guard workplace != nil, specialityField != nil,
              !model.position.isEmpty, !model.academicDegree.isEmpty else {
            auth.showMessage("İş yeri, vəzifə, elmi dərəcə və ixtisas sahəsini seçin.")
            return
        }
        if auth.user == nil {
            guard validate([(password, .password), (confirmPassword, .confirmPassword(originalPassword: { password }))], onError: { auth.showMessage($0) }) else { return }
        }
        guard acceptedTerms else {
            auth.showMessage("Davam etmək üçün istifadə şərtləri ilə razılaşın.")
            return
        }
        Task { await auth.registerSupervisor(model) }
    }
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

private struct AuthPageScaffold<Content: View>: View {
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

private struct BrandMark: View {
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

private struct BrandName: View {
    let fontSize: CGFloat

    var body: some View {
        (Text("Elmi").foregroundColor(ElmiYolStyle.navy) + Text("Yol").foregroundColor(ElmiYolStyle.primary))
            .font(.system(size: fontSize, weight: .heavy))
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

private struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil

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
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(ElmiYolStyle.border, lineWidth: 1))
        }
    }
}

private struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(ElmiYolStyle.ink)
            SecureField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundStyle(ElmiYolStyle.ink)
                .padding(.horizontal, 14)
                .frame(minHeight: 52)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(ElmiYolStyle.border, lineWidth: 1))
        }
    }
}

private struct ChoicePickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String
    let options: [String]
    let icon: String

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
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(ElmiYolStyle.border, lineWidth: 1))
            }
        }
    }
}

private struct PrimaryActionButton: View {
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

private extension View {
    func registrationHeading(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.system(size: 28, weight: .bold)).foregroundStyle(ElmiYolStyle.ink)
            Text("Qeydiyyatı").font(.system(size: 28, weight: .bold)).foregroundStyle(ElmiYolStyle.primary)
            Text(subtitle).font(.system(size: 14)).foregroundStyle(ElmiYolStyle.secondary).lineSpacing(3).padding(.top, 8)
        }
        .padding(.bottom, 4)
    }
}

private extension ToggleStyle where Self == CheckboxLikeToggleStyle {
    static var checkboxLike: CheckboxLikeToggleStyle { CheckboxLikeToggleStyle() }
}

private struct CheckboxLikeToggleStyle: ToggleStyle {
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

private func validate(_ fields: [(String, ValidatorType)], onError: (String) -> Void) -> Bool {
    for (value, type) in fields {
        let result = FieldValidator(type: type).validate(value)
        if let message = result.errorMessage {
            onError(message)
            return false
        }
    }
    return true
}

 enum ElmiYolStyle {
    static let background = Color(red: 0.97, green: 0.98, blue: 1)
    static let primary = Color(red: 0.16, green: 0.38, blue: 0.92)
    static let navy = Color(red: 0.09, green: 0.18, blue: 0.42)
    static let ink = Color(red: 0.13, green: 0.16, blue: 0.24)
    static let secondary = Color(red: 0.45, green: 0.5, blue: 0.6)
    static let muted = Color(red: 0.55, green: 0.6, blue: 0.68)
    static let border = Color(red: 0.88, green: 0.9, blue: 0.94)
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
