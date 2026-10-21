//
//  AccountInfoView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.10.26.
//

import FirebaseAuth
import SwiftUI

struct AccountInfoView: View {
    let onBack: () -> Void

    private struct Row: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let value: String
    }

    private func clean(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "—" }
        return value
    }

    private var roleTitle: String {
        UserSession.shared.currentRole == .supervisor ? "Elmi rəhbər" : "Magistr tələbəsi"
    }

    private var rows: [Row] {
        let session = UserSession.shared
        let email = session.displayEmail.isEmpty ? (Auth.auth().currentUser?.email ?? "") : session.displayEmail
        switch session.currentRole {
        case .student:
            let s = session.studentData
            return [
                Row(icon: "person.fill", title: "Ad", value: clean(s?.firstName)),
                Row(icon: "person.fill", title: "Soyad", value: clean(s?.lastName)),
                Row(icon: "envelope.fill", title: "E-poçt", value: clean(email)),
                Row(icon: "phone.fill", title: "Telefon", value: clean(session.displayPhone)),
                Row(icon: "building.columns.fill", title: "Universitet", value: clean(s?.university)),
                Row(icon: "person.text.rectangle.fill", title: "Fakültə", value: clean(s?.faculty)),
                Row(icon: "graduationcap.fill", title: "İxtisas", value: clean(s?.speciality)),
                Row(icon: "number", title: "Qrup nömrəsi", value: clean(s?.groupNumber)),
                Row(icon: "calendar", title: "Təhsil illəri", value: clean(s?.studyYears))
            ]
        case .supervisor:
            let s = session.supervisorData
            return [
                Row(icon: "person.fill", title: "Ad", value: clean(s?.firstName)),
                Row(icon: "person.fill", title: "Soyad", value: clean(s?.lastName)),
                Row(icon: "envelope.fill", title: "E-poçt", value: clean(email)),
                Row(icon: "phone.fill", title: "Telefon", value: clean(session.displayPhone)),
                Row(icon: "building.columns.fill", title: "İş yeri", value: clean(s?.workplace)),
                Row(icon: "person.text.rectangle.fill", title: "Fakültə", value: clean(s?.faculty)),
                Row(icon: "book.fill", title: "İxtisas sahəsi", value: clean(s?.specialityField)),
                Row(icon: "briefcase.fill", title: "Vəzifə", value: clean(s?.position)),
                Row(icon: "graduationcap.fill", title: "Elmi dərəcə", value: clean(s?.academicDegree))
            ]
        case .none:
            return [Row(icon: "envelope.fill", title: "E-poçt", value: clean(email))]
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ElmiYolStyle.primary)
                            .frame(width: 48, height: 48)
                            .background(.white, in: Circle())
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hesab məlumatları")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(ElmiYolStyle.ink)
                    Text("Qeydiyyat zamanı daxil etdiyiniz məlumatlar.")
                        .font(.system(size: 14))
                        .foregroundStyle(ElmiYolStyle.secondary)
                    Text(roleTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ElmiYolStyle.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(ElmiYolStyle.primary.opacity(0.1), in: Capsule())
                        .padding(.top, 4)
                }

                VStack(spacing: 0) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: row.icon)
                                .font(.system(size: 15))
                                .foregroundStyle(ElmiYolStyle.primary)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(row.title).font(.system(size: 12)).foregroundStyle(ElmiYolStyle.muted)
                                Text(row.value).font(.system(size: 15, weight: .medium)).foregroundStyle(ElmiYolStyle.ink)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        if row.id != rows.last?.id { Divider().padding(.leading, 50) }
                    }
                }
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(ElmiYolStyle.background.ignoresSafeArea())
    }
}
