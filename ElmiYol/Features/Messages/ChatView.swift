//
//  ChatView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.10.26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import SafariServices
import SwiftUI
import UniformTypeIdentifiers

struct OpenedFile: Identifiable {
    let id = UUID()
    let url: URL
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageDoc] = []
    @Published var otherLastRead: Date?
    @Published var isSending = false
    @Published var errorMessage: String?
    @Published var openedFile: OpenedFile?

    var isActive = true

    private let otherUid: String
    private let otherName: String
    private let me: String?
    private let chatId: String
    private var messagesListener: ListenerRegistration?
    private var readListener: ListenerRegistration?
    private var started = false

    init(otherUid: String, otherName: String) {
        self.otherUid = otherUid
        self.otherName = otherName
        let uid = Auth.auth().currentUser?.uid
        self.me = uid
        self.chatId = ChatRepository.chatId(uid ?? "", otherUid)
    }

    func start() async {
        guard !started, let me else { return }
        started = true
        do {
            try await ChatRepository.shared.ensureChat(
                chatId: chatId, me: me, other: otherUid,
                myName: UserSession.shared.displayFullName, otherName: otherName
            )
        } catch {
            errorMessage = error.localizedDescription
            started = false
            return
        }
        messagesListener = ChatRepository.shared.listenMessages(chatId: chatId) { [weak self] items in
            Task { @MainActor in self?.receive(items) }
        }
        readListener = ChatRepository.shared.listenReadState(chatId: chatId) { [weak self] map in
            Task { @MainActor in self?.otherLastRead = map[self?.otherUid ?? ""] }
        }
        await markRead()
    }

    func clearErrorMessage() {
        errorMessage = nil
    }

    func stop() {
        messagesListener?.remove()
        readListener?.remove()
        messagesListener = nil
        readListener = nil
        started = false
    }

    private func receive(_ items: [ChatMessageDoc]) {
        let visible = items.filter { !$0.hiddenFor.contains(me ?? "") }
        messages = visible
        if isActive, let last = visible.last, last.senderId != me {
            Task { await markRead() }
        }
    }

    func markRead() async {
        guard let me else { return }
        await ChatRepository.shared.markRead(chatId: chatId, me: me)
    }

    func isRead(_ message: ChatMessageDoc) -> Bool {
        guard let otherLastRead else { return false }
        return otherLastRead >= message.createdAt
    }

    func send(_ rawText: String) async -> Bool {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let me else { return false }
        do {
            try await ChatRepository.shared.send(chatId: chatId, me: me, other: otherUid, text: text)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func edit(_ message: ChatMessageDoc, to rawText: String) async {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, message.isMine else { return }
        do {
            try await ChatRepository.shared.editMessage(
                chatId: chatId, messageId: message.id, text: text,
                isLast: messages.last?.id == message.id)
        } catch {
            errorMessage = "Mesaj redaktə olunmadı."
        }
    }

    func hide(_ ids: [String]) async {
        guard let me, !ids.isEmpty else { return }
        do {
            try await ChatRepository.shared.hideMessages(chatId: chatId, messageIds: ids, for: me)
        } catch {
            errorMessage = "Mesajlar silinmədi."
        }
    }

    func deleteForEveryone(_ ids: [String]) async {
        let mine = messages.filter { ids.contains($0.id) && $0.isMine }.map(\.id)
        guard !mine.isEmpty else { return }
        do {
            try await ChatRepository.shared.deleteMessages(
                chatId: chatId, messageIds: mine, lastId: messages.last?.id)
        } catch {
            errorMessage = "Mesajlar silinmədi."
        }
    }
    
    func sendFile(_ url: URL) async {
        guard let me else { return }
        isSending = true
        defer { isSending = false }
        do {
            let uploaded = try await SupabaseStorageService.shared.upload(localURL: url, folder: "chats/\(chatId)")
            try await ChatRepository.shared.send(
                chatId: chatId, me: me, other: otherUid,
                kind: .file, filePath: uploaded.path, fileName: uploaded.name
            )
        } catch {
            let ns = error as NSError
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Fayl göndərilmədi: \(ns.localizedDescription) (\(ns.domain) \(ns.code))"
        }
    }

    func open(_ message: ChatMessageDoc) async {
        guard let path = message.filePath else { return }
        do {
            let url = try await SupabaseStorageService.shared.signedURL(path: path)
            openedFile = OpenedFile(url: url)
        } catch {
            errorMessage = "Faylı açmaq mümkün olmadı."
        }
    }
}

struct ChatView: View {
    @StateObject private var vm: ChatViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var draft = ""
    @State private var editing: ChatMessageDoc?
    @State private var editText = ""
    @State private var selecting = false
    @State private var selected = Set<String>()
    @State private var showDeleteChoice = false
    
    private var canDeleteForAll: Bool {
        let items = vm.messages.filter { selected.contains($0.id) }
        return !items.isEmpty && items.allSatisfy { $0.isMine && !$0.deleted }
    }
    
    private func exitSelection() {
        selecting = false
        selected = []
    }
    
    @State private var showImporter = false
    
    private let name: String
    private let subtitle: String
    private let onBack: () -> Void
    
    init(otherUid: String, otherName: String, subtitle: String, onBack: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: ChatViewModel(otherUid: otherUid, otherName: otherName))
        self.name = otherName
        self.subtitle = subtitle
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            messagesList
            inputBar
        }
        .background(ElmiYolStyle.background.ignoresSafeArea())
        .task { await vm.start() }
        .onDisappear { vm.stop() }
        .onChange(of: scenePhase) { _, phase in
            vm.isActive = phase == .active
            if phase == .active { Task { await vm.markRead() } }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            if case .success(let url) = result { Task { await vm.sendFile(url) } }
        }
        .sheet(item: Binding(
            get: { vm.openedFile },
            set: { newValue in
                Task { @MainActor in vm.openedFile = newValue }
            }
        )) { file in
            SafariView(url: file.url).ignoresSafeArea()
        }
        .alert("Xəta", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { Task { @MainActor in vm.clearErrorMessage() } } }
        )) {
            Button("Bağla", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert("Mesajı redaktə et", isPresented: Binding(
            get: { editing != nil },
            set: { if !$0 { editing = nil } }
        )) {
            TextField("Mesaj", text: $editText)
            Button("Saxla") {
                if let m = editing { Task { await vm.edit(m, to: editText) } }
            }
            Button("Ləğv et", role: .cancel) {}
        }
        .confirmationDialog("\(selected.count) mesaj silinsin?", isPresented: $showDeleteChoice, titleVisibility: .visible) {
            Button("Məndən sil") {
                let ids = Array(selected)
                Task { await vm.hide(ids) }
                exitSelection()
            }
            if canDeleteForAll {
                Button("Hər ikisindən sil", role: .destructive) {
                    let ids = Array(selected)
                    Task { await vm.deleteForEveryone(ids) }
                    exitSelection()
                }
            }
            Button("Ləğv et", role: .cancel) {
                if !selecting { selected = [] }
            }
        }
        .overlay(alignment: .bottom) {
            if selecting {
                HStack {
                    Button("Ləğv et") { exitSelection() }
                    Spacer()
                    Text("\(selected.count) seçildi").font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Button { showDeleteChoice = true } label: { Image(systemName: "trash") }
                        .disabled(selected.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(ElmiYolStyle.surface)
                .overlay(alignment: .top) { Divider() }
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ElmiYolStyle.primary)
                    .frame(width: 40, height: 40)
                    .background(ElmiYolStyle.background, in: Circle())
            }
            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ElmiYolStyle.primary)
                .frame(width: 40, height: 40)
                .background(ElmiYolStyle.primary.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 16, weight: .bold)).foregroundStyle(ElmiYolStyle.ink)
                Text(subtitle).font(.system(size: 12)).foregroundStyle(ElmiYolStyle.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(ElmiYolStyle.surface)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if vm.messages.isEmpty {
                        Text("Söhbətə başlayın 👋")
                            .font(.system(size: 14))
                            .foregroundStyle(ElmiYolStyle.muted)
                            .padding(.top, 40)
                    }
                    ForEach(vm.messages) { message in
                        MessageBubble(
                            message: message,
                            isRead: vm.isRead(message),
                            onTapFile: { if !selecting { Task { await vm.open(message) } } }
                        )
                        .id(message.id)
                        .padding(.vertical, 2)
                        .background(selected.contains(message.id) ? ElmiYolStyle.primary.opacity(0.15) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard selecting else { return }
                            if selected.contains(message.id) {
                                selected.remove(message.id)
                            } else {
                                selected.insert(message.id)
                            }
                        }
                        .contextMenu {
                            if !message.deleted && message.isMine && message.kind == .text {
                                Button {
                                    editText = message.text
                                    editing = message
                                } label: { Label("Redaktə et", systemImage: "pencil") }
                            }
                            Button {
                                selecting = true
                                selected = [message.id]
                            } label: { Label("Seç", systemImage: "checkmark.circle") }
                            Button(role: .destructive) {
                                selected = [message.id]
                                showDeleteChoice = true
                            } label: { Label("Sil", systemImage: "trash") }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: vm.messages.last?.id) { _, id in
                guard let id else { return }
                withAnimation { proxy.scrollTo(id, anchor: .bottom) }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { showImporter = true } label: {
                Image(systemName: "paperclip")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(ElmiYolStyle.primary)
                    .frame(width: 36, height: 36)
            }
            .disabled(vm.isSending)

            TextField("Mesaj yazın...", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .font(.system(size: 15))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(uiColor: AppColors.separator), in: RoundedRectangle(cornerRadius: 20))

            Button {
                let text = draft
                draft = ""
                Task { if await vm.send(text) == false { draft = text } }
            } label: {
                Group {
                    if vm.isSending {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "arrow.up").font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(ElmiYolStyle.primary, in: Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(ElmiYolStyle.surface)
    }
    
    private struct MessageBubble: View {
        let message: ChatMessageDoc
        let isRead: Bool
        let onTapFile: () -> Void
        
        var body: some View {
            HStack {
                if message.isMine { Spacer(minLength: 48) }
                VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                    if message.deleted {
                        Text("Bu mesaj silindi").font(.system(size: 14).italic()).opacity(0.7)
                    } else if message.kind == .file {
                        Button(action: onTapFile) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.fill")
                                Text(message.fileName ?? "Fayl").underline().lineLimit(2).multilineTextAlignment(.leading)
                            }
                            .font(.system(size: 15))
                        }
                    } else {
                        Text(message.text).font(.system(size: 15))
                    }
                    HStack(spacing: 4) {
                        if message.edited && !message.deleted { Text("redaktə olunub") }
                        Text(message.timeText)
                        if message.isMine {
                            Text(isRead ? "✓✓" : "✓").fontWeight(.bold)
                        }
                    }
                    .font(.system(size: 11))
                    .opacity(0.75)
                }
                .foregroundStyle(message.isMine ? Color.white : ElmiYolStyle.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.isMine ? ElmiYolStyle.primary : Color(uiColor: AppColors.separator),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                if !message.isMine { Spacer(minLength: 48) }
            }
        }
    }
    
    struct SafariView: UIViewControllerRepresentable {
        let url: URL
        func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
        func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
    }
}
