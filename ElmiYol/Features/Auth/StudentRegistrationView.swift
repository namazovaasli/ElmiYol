//
//  StudentRegistrationView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct StudentRegistrationView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var catalog = CatalogViewModel()

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var groupNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var university: CatalogItem?
    @State private var faculty: CatalogItem?
    @State private var speciality: CatalogItem?
    @State private var studyYears: CatalogItem?
    @State private var acceptedTerms = false
    @State private var showErrors = false

    private var studyYearsItems: [CatalogItem] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0..<5).map { offset in
            let start = currentYear - offset
            let text = "\(start)-\(start + 2)"
            return CatalogItem(id: text, name: text)
        }
    }

    private var isFormValid: Bool {
        fieldIsValid(firstName, .name) && fieldIsValid(lastName, .surname)
        && fieldIsValid(email, .email) && fieldIsValid(phone, .phone)
        && fieldIsValid(groupNumber, .required(fieldName: "Qrup nömrəsi"))
        && university != nil && faculty != nil && speciality != nil && studyYears != nil
        && (auth.user != nil
            || (fieldIsValid(password, .password)
                && fieldIsValid(confirmPassword, .confirmPassword(originalPassword: { password }))))
        && acceptedTerms
    }

    var body: some View {
        AuthPageScaffold {
            VStack(alignment: .leading, spacing: 18) {
                registrationHeading(title: "Magistr tələbəsi", subtitle: "Tələbə profilinizi yaratmaq üçün məlumatları doldurun.")

                AuthTextField(title: "Ad", placeholder: "Adınızı daxil edin", text: $firstName, icon: "person",
                              validator: .name, showErrorsWhenEmpty: showErrors)
                    .textContentType(.givenName)
                AuthTextField(title: "Soyad", placeholder: "Soyadınızı daxil edin", text: $lastName, icon: "person",
                              validator: .surname, showErrorsWhenEmpty: showErrors)
                    .textContentType(.familyName)
                AuthTextField(title: "E-poçt ünvanı", placeholder: "example@mail.com", text: $email, icon: "envelope",
                              validator: .email, showErrorsWhenEmpty: showErrors)
                    .textContentType(.emailAddress).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .disabled(auth.user != nil)
                AuthTextField(title: "Telefon nömrəsi (+994)", placeholder: "501234567", text: $phone, icon: "phone",
                              validator: .phone, showErrorsWhenEmpty: showErrors, inputFilter: phoneDigits)
                    .keyboardType(.numberPad)

                CatalogPickerField(
                    title: "Universitet", placeholder: "Universitetinizi seçin", icon: "building.columns",
                    items: catalog.universities,
                    isLoading: catalog.isLoadingUniversities,
                    loadError: catalog.universitiesError,
                    fieldError: showErrors && university == nil ? "Universiteti seçin" : nil,
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
                    fieldError: showErrors && faculty == nil && university != nil ? "Fakültəni seçin" : nil,
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
                    fieldError: showErrors && speciality == nil && faculty != nil ? "İxtisası seçin" : nil,
                    selection: $speciality,
                    onRetry: {
                        if let university, let faculty {
                            Task { await catalog.loadSpecialities(universityId: university.id, facultyId: faculty.id) }
                        }
                    }
                )

                AuthTextField(title: "Qrup nömrəsi", placeholder: "Məs: 704a2", text: $groupNumber, icon: "number",
                              validator: .required(fieldName: "Qrup nömrəsi"), showErrorsWhenEmpty: showErrors)

                CatalogPickerField(
                    title: "Təhsil illəri", placeholder: "Təhsil illərinizi seçin", icon: "calendar",
                    items: studyYearsItems,
                    fieldError: showErrors && studyYears == nil ? "Təhsil illərini seçin" : nil,
                    selection: $studyYears
                )

                if auth.user == nil {
                    AuthSecureField(title: "Şifrə", placeholder: "Şifrə yaradın", text: $password,
                                    validator: .password, showErrorsWhenEmpty: showErrors)
                        .textContentType(.newPassword)
                    AuthSecureField(title: "Şifrəni təkrar daxil edin", placeholder: "Şifrəni təkrar edin", text: $confirmPassword,
                                    validator: .confirmPassword(originalPassword: { password }), showErrorsWhenEmpty: showErrors)
                        .textContentType(.newPassword)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Toggle(isOn: $acceptedTerms) {
                        Text("Məlumatların düzgün olduğunu təsdiqləyirəm və istifadə şərtləri ilə razıyam.")
                            .font(.system(size: 13))
                            .foregroundStyle(ElmiYolStyle.secondary)
                    }
                    .tint(ElmiYolStyle.primary)
                    .toggleStyle(.checkboxLike)
                    FieldErrorText(message: showErrors && !acceptedTerms ? "Davam etmək üçün istifadə şərtləri ilə razılaşın." : nil)
                }

                PrimaryActionButton(title: "Qeydiyyatdan keç", isLoading: auth.isBusy) { submit() }

                HStack(spacing: 4) {
                    Text("Artıq hesabınız var?").foregroundStyle(ElmiYolStyle.secondary)
                    Button("Daxil ol") { auth.path = [.login] }
                        .foregroundStyle(ElmiYolStyle.primary).fontWeight(.semibold)
                }
                .font(.system(size: 14)).frame(maxWidth: .infinity).padding(.top, 2)
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

    private func prefillAccountDetails() {
        if firstName.isEmpty { firstName = auth.registrationFirstName }
        if lastName.isEmpty { lastName = auth.registrationLastName }
        if email.isEmpty { email = auth.registrationEmail }
    }

    private func submit() {
        showErrors = true
        guard isFormValid else { return }

        var model = StudentRegisterModel()
        model.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        model.phone = phone
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

        Task { await auth.registerStudent(model) }
    }
}
