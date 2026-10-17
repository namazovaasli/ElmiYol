//
//  CatalogPickerField.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.10.26.
//

import SwiftUI

struct CatalogPickerField: View {
    let title: String
    let placeholder: String
    let icon: String
    let items: [CatalogItem]
    var isLoading: Bool = false
    var loadError: String? = nil
    var isEnabled: Bool = true
    var disabledHint: String = ""
    var fieldError: String? = nil
    @Binding var selection: CatalogItem?
    var onRetry: () -> Void = {}

    @State private var isSheetPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ElmiYolStyle.ink)

            Button {
                isSheetPresented = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(ElmiYolStyle.muted)
                        .frame(width: 20)
                    Text(selection?.name ?? placeholder)
                        .font(.system(size: 15))
                        .foregroundStyle(selection == nil ? ElmiYolStyle.muted : ElmiYolStyle.ink)
                        .lineLimit(1)
                    Spacer()
                    if isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ElmiYolStyle.muted)
                    }
                }
                .padding(.horizontal, 14)
                .frame(minHeight: 52)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(fieldError == nil ? ElmiYolStyle.border : Color.red.opacity(0.7), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.55)

            if let fieldError {
                Text(fieldError)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
            } else if !isEnabled && !disabledHint.isEmpty {
                Text(disabledHint)
                    .font(.system(size: 12))
                    .foregroundStyle(ElmiYolStyle.muted)
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            CatalogSelectionSheet(
                title: title,
                items: items,
                isLoading: isLoading,
                loadError: loadError,
                selection: $selection,
                onRetry: onRetry
            )
        }
    }
}

private struct CatalogSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let items: [CatalogItem]
    let isLoading: Bool
    let loadError: String?
    @Binding var selection: CatalogItem?
    let onRetry: () -> Void

    @State private var query = ""

    private var filtered: [CatalogItem] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(text) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.count > 7 {
                    content.searchable(text: $query, prompt: "Axtar")
                } else {
                    content
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Bağla") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading && items.isEmpty {
            ProgressView("Yüklənir...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let loadError, items.isEmpty {
            VStack(spacing: 14) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 30))
                    .foregroundStyle(ElmiYolStyle.muted)
                Text(loadError)
                    .font(.system(size: 14))
                    .foregroundStyle(ElmiYolStyle.secondary)
                    .multilineTextAlignment(.center)
                Button("Yenidən cəhd et", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if items.isEmpty {
            VStack(spacing: 10) {
                Text("Siyahı boşdur")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ElmiYolStyle.ink)
                Text("Kataloq məlumatlarının Firebase Firestore-a əlavə olunduğunu yoxlayın.")
                    .font(.system(size: 14))
                    .foregroundStyle(ElmiYolStyle.secondary)
                    .multilineTextAlignment(.center)
                Button("Yenidən yoxla", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filtered.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            List(filtered) { item in
                Button {
                    selection = item
                    dismiss()
                } label: {
                    HStack {
                        Text(item.name).foregroundStyle(ElmiYolStyle.ink)
                        Spacer()
                        if item == selection {
                            Image(systemName: "checkmark").foregroundStyle(ElmiYolStyle.primary)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
