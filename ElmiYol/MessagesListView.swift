//
//  MessagesListView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.10.26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ChatPerson: Hashable {
    let uid: String
    let name: String
    let subtitle: String
}

@MainActor
final class MessagesListViewModel: ObservableObject {
    @Published var threads: [ChatThreadDoc] = []
    private var listener: ListenerRegistration?

    func start() {
        guard listener == nil, let uid = Auth.auth().currentUser?.uid else { return }
        listener = ChatRepository.shared.listenThreads(for: uid) { [weak self] items in
            Task { @MainActor in self?.threads = items }
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }
}

private enum MessageFilterKind { case all, unread }

struct MessagesListView: View {
    @StateObject private var vm = MessagesListViewModel()
    @State private var filter: MessageFilterKind = .all
    @State private var query = ""
    @State private var showPicker = false
    @State private var pendingPerson: ChatPerson?

    var onMenu: () -> Void = {}
    var onNotifications: () -> Void = {}
    var onOpenChat: (ChatPerson) -> Void = { _ in }

    private var myUid: String { Auth.auth().currentUser?.uid ?? "" }

    private var otherSubtitle: String {
        UserSession.shared.currentRole == .supervisor ? "Magistr tələbəsi" : "Elmi rəhbər"
    }

    private var unreadTotal: Int { vm.threads.reduce(0) { $0 + $1.unread } }

    private var visibleThreads: [ChatThreadDoc] {
        vm.threads.filter { thread in
            (filter == .all || thread.unread > 0)
            && (query.isEmpty || thread.otherName.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    circleButton("line.3.horizontal", action: onMenu)
                    Spacer()
                    circleButton("bell", action: onNotifications)
                }

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mesajlar")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(ElmiYolStyle.ink)
                        Text(UserSession.shared.currentRole == .supervisor
                             ? "Tələbələrinizlə mesajlaşın."
                             : "Elmi rəhbəriniz ilə mesajlaşın.")
                            .font(.system(size: 15))
                            .foregroundStyle(ElmiYolStyle.secondary)
                    }
                    Spacer(minLength: 8)
                    Button { showPicker = true } label: {
                        Label("Yeni mesaj", systemImage: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(ElmiYolStyle.primary, in: Capsule())
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(ElmiYolStyle.muted)
                    TextField("Axtarış et...", text: $query).font(.system(size: 15))
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))

                HStack(spacing: 8) {
                    chip("Hamısı", selected: filter == .all) { filter = .all }
                    chip(unreadTotal > 0 ? "Oxunmamış (\(unreadTotal))" : "Oxunmamış", selected: filter == .unread) {
                        filter = .unread
                    }
                }

                if visibleThreads.isEmpty {
                    Text(filter == .unread
                         ? "Oxunmamış mesaj yoxdur."
                         : "Hələ mesaj yoxdur. «Yeni mesaj» ilə söhbətə başlayın.")
                        .font(.system(size: 14))
                        .foregroundStyle(ElmiYolStyle.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 0) {
                        ForEach(visibleThreads) { thread in
                            Button {
                                onOpenChat(ChatPerson(uid: thread.otherUid, name: thread.otherName, subtitle: otherSubtitle))
                            } label: {
                                threadRow(thread)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(ElmiYolStyle.background.ignoresSafeArea())
        .task { vm.start() }
        .onDisappear { vm.stop() }
        .sheet(isPresented: $showPicker, onDismiss: {
            if let person = pendingPerson {
                pendingPerson = nil
                onOpenChat(person)
            }
        }) {
            PeoplePickerView { person in
                pendingPerson = person
                showPicker = false
            }
        }
    }

    private func threadRow(_ thread: ChatThreadDoc) -> some View {
        let hasUnread = thread.unread > 0
        return HStack(spacing: 12) {
            Text(thread.initials)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ElmiYolStyle.primary)
                .frame(width: 52, height: 52)
                .background(ElmiYolStyle.primary.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(thread.otherName)
                    .font(.system(size: 15, weight: hasUnread ? .bold : .semibold))
                    .foregroundStyle(ElmiYolStyle.ink)
                    .lineLimit(1)
                Text((thread.lastSenderId == myUid ? "Siz: " : "") + thread.lastMessage)
                    .font(.system(size: 13, weight: hasUnread ? .semibold : .regular))
                    .foregroundStyle(hasUnread ? ElmiYolStyle.ink : ElmiYolStyle.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 6) {
                Text(thread.timeText)
                    .font(.system(size: 12))
                    .foregroundStyle(hasUnread ? ElmiYolStyle.primary : ElmiYolStyle.muted)
                if hasUnread {
                    Text("\(thread.unread)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(ElmiYolStyle.primary, in: Capsule())
                }
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func circleButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(ElmiYolStyle.ink)
                .frame(width: 48, height: 48)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(selected ? .white : ElmiYolStyle.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selected ? ElmiYolStyle.primary : Color.white, in: Capsule())
        }
    }
}

struct PeoplePickerView: View {
    let onPick: (ChatPerson) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var people: [PublicProfile] = []
    @State private var isLoading = true
    @State private var errorText: String?
    @State private var query = ""

    private var filtered: [PublicProfile] {
        query.isEmpty ? people : people.filter { $0.fullName.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let errorText {
                    VStack(spacing: 12) {
                        Text(errorText).multilineTextAlignment(.center).foregroundStyle(ElmiYolStyle.secondary)
                        Button("Yenidən cəhd et") { Task { await load() } }.buttonStyle(.borderedProminent)
                    }
                    .padding(24)
                } else if filtered.isEmpty {
                    Text("Hələ uyğun istifadəçi yoxdur.").foregroundStyle(ElmiYolStyle.muted)
                } else {
                    List(filtered) { person in
                        Button {
                            let subtitle = person.role == .supervisor ? "Elmi rəhbər" : "Magistr tələbəsi"
                            onPick(ChatPerson(uid: person.id, name: person.fullName, subtitle: subtitle))
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(person.fullName).font(.system(size: 16, weight: .semibold)).foregroundStyle(ElmiYolStyle.ink)
                                Text([person.position, person.university].filter { !$0.isEmpty }.joined(separator: " • "))
                                    .font(.system(size: 13)).foregroundStyle(ElmiYolStyle.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Şəxs seçin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Bağla") { dismiss() } }
            }
            .searchable(text: $query, prompt: "Axtar")
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorText = nil
        let repo = FirestoreDirectoryRepository.shared
        let session = UserSession.shared
        do {
            switch session.currentRole {
            case .student:
                var list = try await repo.supervisors(universityId: session.studentData?.universityId)
                if list.isEmpty { list = try await repo.supervisors(universityId: nil) }
                people = list
            case .supervisor:
                var list = try await repo.students(universityId: session.supervisorData?.workplaceId)
                if list.isEmpty { list = try await repo.students(universityId: nil) }
                people = list
            case .none:
                people = []
            }
        } catch {
            errorText = "Siyahını yükləmək mümkün olmadı. İnternet bağlantısını yoxlayın."
        }
        isLoading = false
    }
}
