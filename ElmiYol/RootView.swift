import AuthenticationServices
import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        Group {
            if auth.isResolvingSession {
                LaunchView()
            } else if let role = auth.role {
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
}

private struct LaunchView: View {
    var body: some View {
        ZStack {
            ElmiYolStyle.background.ignoresSafeArea()
            VStack(spacing: 18) {
                BrandMark(size: 116)
                BrandName(fontSize: 38)
                Text("Elmi yolunuzda etibarlı tərəfdaşınız.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(ElmiYolStyle.secondary)
                ProgressView().tint(ElmiYolStyle.primary).padding(.top, 22)
            }
        }
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

                SignInWithAppleButton(.signIn) { request in
                    auth.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task { await auth.handleApple(result) }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .disabled(auth.isBusy)

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

                Button {
                    guard validEmail else {
                        auth.showMessage("E-poçt bağlantısı almaq üçün düzgün e-poçt ünvanı daxil edin.")
                        return
                    }
                    Task { await auth.sendEmailSignInLink(to: email) }
                } label: {
                    Label("E-poçt linki ilə daxil ol", systemImage: "envelope.badge")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ElmiYolStyle.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
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
                    Text(auth.isCompletingOAuthProfile ? "Profilinizi tamamlayın" : "Rolünüzü seçin")
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

                if auth.user != nil {
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
    @State private var university = ""
    @State private var faculty = ""
    @State private var speciality = ""
    @State private var groupNumber = ""
    @State private var studyYears = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptedTerms = false

    private let universityOptions = ["Bakı Dövlət Universiteti", "ADA Universiteti", "Xəzər Universiteti", "Azərbaycan Texniki Universiteti", "UNEC"]
    private let facultyOptions = ["Kompüter Elmləri", "İqtisadiyyat", "Filologiya", "Hüquq", "Fizika"]
    private let specialityOptions = ["Proqram Mühəndisliyi", "Maliyyə", "Marketinq", "Beynəlxalq Münasibətlər"]
    private var studyYearsOptions: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0...3).map { "\(currentYear + $0)-\(currentYear + $0 + 2)" }
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
                ChoicePickerField(title: "Universitet", placeholder: "Universitetinizi seçin", selection: $university, options: universityOptions, icon: "building.columns")
                ChoicePickerField(title: "Fakültə", placeholder: "Fakültənizi seçin", selection: $faculty, options: facultyOptions, icon: "person.text.rectangle")
                ChoicePickerField(title: "İxtisas", placeholder: "İxtisasınızı seçin", selection: $speciality, options: specialityOptions, icon: "graduationcap")
                AuthTextField(title: "Qrup nömrəsi", placeholder: "Məs: 704a2", text: $groupNumber, icon: "number")
                ChoicePickerField(title: "Təhsil illəri", placeholder: "Təhsil illərinizi seçin", selection: $studyYears, options: studyYearsOptions, icon: "calendar")
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
        var model = StudentRegisterModel()
        model.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        model.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        model.university = university
        model.faculty = faculty
        model.speciality = speciality
        model.groupNumber = groupNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        model.studyYears = studyYears
        model.password = auth.user == nil ? password : ""
        model.confirmPassword = auth.user == nil ? confirmPassword : ""
        model.acceptedTerms = acceptedTerms

        let required: [(String, ValidatorType)] = [
            (model.firstName, .name), (model.lastName, .surname), (model.email, .email),
            (model.phone, .phone), (model.groupNumber, .required(fieldName: "Qrup nömrəsi"))
        ]
        guard validate(required, onError: { auth.showMessage($0) }) else { return }
        guard !model.university.isEmpty, !model.faculty.isEmpty, !model.speciality.isEmpty, !model.studyYears.isEmpty else {
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
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var workplace = ""
    @State private var position = ""
    @State private var academicDegree = ""
    @State private var specialityField = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptedTerms = false

    private let workplaceOptions = ["Bakı Dövlət Universiteti", "ADA Universiteti", "Xəzər Universiteti", "Azərbaycan Texniki Universiteti", "UNEC"]
    private let positionOptions = ["Professor", "Dosent", "Baş müəllim", "Assistent"]
    private let degreeOptions = ["Elmlər doktoru", "Fəlsəfə doktoru (PhD)", "Dosent", "Professor"]
    private let specialityOptions = ["Kompüter Elmləri", "İqtisadiyyat", "Filologiya", "Hüquq", "Fizika"]

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
                ChoicePickerField(title: "İş yeri / Universitet", placeholder: "İş yerinizi seçin", selection: $workplace, options: workplaceOptions, icon: "building.columns")
                ChoicePickerField(title: "Vəzifə", placeholder: "Vəzifənizi seçin", selection: $position, options: positionOptions, icon: "person.text.rectangle")
                ChoicePickerField(title: "Elmi dərəcə", placeholder: "Elmi dərəcənizi seçin", selection: $academicDegree, options: degreeOptions, icon: "graduationcap")
                ChoicePickerField(title: "İxtisas sahəsi", placeholder: "İxtisas sahənizi seçin", selection: $specialityField, options: specialityOptions, icon: "book")
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
        model.workplace = workplace
        model.position = position
        model.academicDegree = academicDegree
        model.specialityField = specialityField
        model.password = auth.user == nil ? password : ""
        model.confirmPassword = auth.user == nil ? confirmPassword : ""
        model.acceptedTerms = acceptedTerms

        let required: [(String, ValidatorType)] = [
            (model.firstName, .name), (model.lastName, .surname), (model.email, .email), (model.phone, .phone)
        ]
        guard validate(required, onError: { auth.showMessage($0) }) else { return }
        guard !model.workplace.isEmpty, !model.position.isEmpty, !model.academicDegree.isEmpty, !model.specialityField.isEmpty else {
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

private enum ElmiYolStyle {
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
