//
//  SupervisorRegistrationView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct SupervisorRegistrationView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var catalog = CatalogViewModel()

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var workplace: CatalogItem?
    @State private var faculty: CatalogItem?
    @State private var speciality: CatalogItem?
    @State private var position = ""
    @State private var academicDegree = ""
    @State private var acceptedTerms = false
    @State private var showErrors = false

    private let positionOptions = ["Professor", "Dosent", "Baş müəllim", "Assistent"]
    private let degreeOptions = ["Elmlər doktoru", "Fəlsəfə doktoru (PhD)", "Dosent", "Professor"]

    private var isFormValid: Bool {
        fieldIsValid(firstName, .name) && fieldIsValid(lastName, .surname)
        && fieldIsValid(email, .email) && fieldIsValid(phone, .phone)
        && workplace != nil && faculty != nil && speciality != nil
        && !position.isEmpty && !academicDegree.isEmpty
        && (auth.user != nil
            || (fieldIsValid(password, .password)
                && fieldIsValid(confirmPassword, .confirmPassword(originalPassword: { password }))))
        && acceptedTerms
    }

    var body: some View {
        AuthPageScaffold {
            VStack(alignment: .leading, spacing: 18) {
                registrationHeading(title: "Elmi rəhbər", subtitle: "Rəhbər profilinizi yaratmaq üçün məlumatları doldurun.")

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
                    title: "İş yeri / Universitet", placeholder: "İş yerinizi seçin", icon: "building.columns",
                    items: catalog.universities,
                    isLoading: catalog.isLoadingUniversities,
                    loadError: catalog.universitiesError,
                    fieldError: showErrors && workplace == nil ? "İş yerini seçin" : nil,
                    selection: $workplace,
                    onRetry: { Task { await catalog.loadUniversities() } }
                )

                CatalogPickerField(
                    title: "Fakültə", placeholder: "Fakültənizi seçin", icon: "person.text.rectangle",
                    items: catalog.faculties,
                    isLoading: catalog.isLoadingFaculties,
                    loadError: catalog.facultiesError,
                    isEnabled: workplace != nil,
                    disabledHint: "Əvvəlcə iş yerini seçin",
                    fieldError: showErrors && faculty == nil && workplace != nil ? "Fakültəni seçin" : nil,
                    selection: $faculty,
                    onRetry: {
                        if let workplace { Task { await catalog.loadFaculties(universityId: workplace.id) } }
                    }
                )

                CatalogPickerField(
                    title: "İxtisas sahəsi", placeholder: "İxtisas sahənizi seçin", icon: "book",
                    items: catalog.specialities,
                    isLoading: catalog.isLoadingSpecialities,
                    loadError: catalog.specialitiesError,
                    isEnabled: faculty != nil,
                    disabledHint: "Əvvəlcə fakültəni seçin",
                    fieldError: showErrors && speciality == nil && faculty != nil ? "İxtisas sahəsini seçin" : nil,
                    selection: $speciality,
                    onRetry: {
                        if let workplace, let faculty {
                            Task { await catalog.loadSpecialities(universityId: workplace.id, facultyId: faculty.id) }
                        }
                    }
                )

                ChoicePickerField(title: "Vəzifə", placeholder: "Vəzifənizi seçin", selection: $position,
                                  options: positionOptions, icon: "person.text.rectangle",
                                  fieldError: showErrors && position.isEmpty ? "Vəzifəni seçin" : nil)
                ChoicePickerField(title: "Elmi dərəcə", placeholder: "Elmi dərəcənizi seçin", selection: $academicDegree,
                                  options: degreeOptions, icon: "graduationcap",
                                  fieldError: showErrors && academicDegree.isEmpty ? "Elmi dərəcəni seçin" : nil)

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
                        Text("Məlumatların düzgün olduğunu təsdiq edirəm və istifadə şərtləri ilə razıyam.")
                            .font(.system(size: 13)).foregroundStyle(ElmiYolStyle.secondary)
                    }
                    .tint(ElmiYolStyle.primary)
                    .toggleStyle(.checkboxLike)
                    FieldErrorText(message: showErrors && !acceptedTerms ? "Davam etmək üçün istifadə şərtləri ilə razılaşın." : nil)
                }

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
            faculty = nil
            speciality = nil
            guard let newValue else { Task { @MainActor in await Task.yield(); catalog.clearFaculties() }; return }
            Task { await catalog.loadFaculties(universityId: newValue.id) }
        }
        .onChange(of: faculty) { _, newValue in
            speciality = nil
            guard let newValue, let workplace else { Task { @MainActor in await Task.yield(); catalog.clearSpecialities() }; return }
            Task { await catalog.loadSpecialities(universityId: workplace.id, facultyId: newValue.id) }
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

        var model = SupervisorRegisterModel()
        model.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        model.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        model.phone = phone
        model.workplace = workplace?.name ?? ""
        model.workplaceId = workplace?.id ?? ""
        model.faculty = faculty?.name ?? ""
        model.facultyId = faculty?.id ?? ""
        model.specialityField = speciality?.name ?? ""
        model.specialityId = speciality?.id ?? ""
        model.position = position
        model.academicDegree = academicDegree
        model.password = auth.user == nil ? password : ""
        model.confirmPassword = auth.user == nil ? confirmPassword : ""
        model.acceptedTerms = acceptedTerms

        Task { await auth.registerSupervisor(model) }
    }
}
