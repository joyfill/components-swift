//
//  ChangelogView.swift
//  JoyfillExample
//

import SwiftUI

struct ChangelogView: View {
    @ObservedObject var changeManager: ChangeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedKind: ChangelogKind? = nil
    @State private var searchText: String = ""
    @State private var expandedEntryIDs: Set<UUID> = []
    @State private var copyToast: String? = nil

    private var filteredEntries: [ChangelogEntry] {
        changeManager.displayedEntries.reversed().filter { entry in
            if let k = selectedKind, entry.kind != k { return false }
            if !searchText.isEmpty {
                let needle = searchText.lowercased()
                if entry.copyText.lowercased().contains(needle) { return true }
                return false
            }
            return true
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                filterBar
                Divider()
                content
            }
            .navigationTitle("Change Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            copyAll()
                        } label: { Label("Copy All", systemImage: "doc.on.doc") }
                        Button {
                            exportAsJSON()
                        } label: { Label("Copy as JSON", systemImage: "curlybraces") }
                        Button(role: .destructive) {
                            changeManager.displayedEntries.removeAll()
                            expandedEntryIDs.removeAll()
                        } label: { Label("Clear All", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let msg = copyToast {
                    Text(msg)
                        .font(.caption)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                        .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                statBadge(label: "Events", value: "\(changeManager.displayedEntries.count)", color: .blue)
                statBadge(label: "Changes", value: "\(totalChangeCount())", color: .purple)
                Spacer()
            }
            TextField("Search fieldId, target, payload…", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func statBadge(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(value).font(.caption).bold().foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private func totalChangeCount() -> Int {
        changeManager.displayedEntries.reduce(0) { $0 + $1.count }
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                filterChip(title: "All", isOn: selectedKind == nil) { selectedKind = nil }
                ForEach(activeKinds, id: \.self) { kind in
                    filterChip(title: kind.label, isOn: selectedKind == kind) {
                        selectedKind = (selectedKind == kind) ? nil : kind
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var activeKinds: [ChangelogKind] {
        let order: [ChangelogKind] = [.change, .focus, .blur, .pageFocus, .pageBlur, .upload, .capture]
        let present = Set(changeManager.displayedEntries.map { $0.kind })
        return order.filter { present.contains($0) }
    }

    private func filterChip(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(isOn ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isOn ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if changeManager.displayedEntries.isEmpty {
            VStack(spacing: 8) {
                Spacer()
                Image(systemName: "tray").font(.largeTitle).foregroundColor(.gray)
                Text("No changelogs yet").foregroundColor(.gray)
                Spacer()
            }
        } else if filteredEntries.isEmpty {
            VStack {
                Spacer()
                Text("No entries match the filter").foregroundColor(.gray)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredEntries) { entry in
                        EntryCard(
                            entry: entry,
                            isExpanded: expandedEntryIDs.contains(entry.id),
                            onToggle: {
                                if expandedEntryIDs.contains(entry.id) {
                                    expandedEntryIDs.remove(entry.id)
                                } else {
                                    expandedEntryIDs.insert(entry.id)
                                }
                            },
                            onCopy: { copy(entry.copyText, label: "Entry copied") }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Actions

    private func copyAll() {
        let text = changeManager.displayedEntries.map { $0.copyText }.joined(separator: "\n\n")
        copy(text, label: "All entries copied")
    }

    private func exportAsJSON() {
        let payload: [String: Any] = [
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
            "totalEvents": changeManager.displayedEntries.count,
            "totalChanges": totalChangeCount(),
            "events": changeManager.displayedEntries.map { entry -> [String: Any] in
                [
                    "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                    "kind": entry.kind.rawValue,
                    "items": entry.items
                ]
            }
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
           let s = String(data: data, encoding: .utf8) {
            copy(s, label: "JSON copied")
        }
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        withAnimation { copyToast = label }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation { copyToast = nil }
        }
    }
}

// MARK: - Entry card

private struct EntryCard: View {
    let entry: ChangelogEntry
    let isExpanded: Bool
    let onToggle: () -> Void
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 10) {
                    kindBadge
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(DateFormatter.timestamp.string(from: entry.timestamp))
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                            if entry.count > 1 {
                                Text("×\(entry.count)")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 6).padding(.vertical, 1)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                            }
                        }
                        if !entry.summary.isEmpty {
                            Text(entry.summary)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(entry.items.enumerated()), id: \.offset) { idx, item in
                        ItemDetailRow(index: idx + 1, total: entry.items.count, item: item, kind: entry.kind)
                    }
                    HStack {
                        Spacer()
                        Button {
                            onCopy()
                        } label: {
                            Label("Copy entry", systemImage: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(10)
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var kindBadge: some View {
        Text(entry.kind.label)
            .font(.caption2.bold())
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(kindColor.opacity(0.18))
            .foregroundColor(kindColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var kindColor: Color {
        switch entry.kind {
        case .change:    return .purple
        case .focus:     return .blue
        case .blur:      return .gray
        case .pageFocus: return .teal
        case .pageBlur:  return .indigo
        case .upload:    return .green
        case .capture:   return .pink
        }
    }
}

// MARK: - Item detail

private struct ItemDetailRow: View {
    let index: Int
    let total: Int
    let item: [String: Any]
    let kind: ChangelogKind
    @State private var showRaw = false

    private var headline: String {
        if kind == .change {
            let target = item["target"] as? String ?? "—"
            let fieldId = item["fieldId"] as? String ?? "—"
            return "\(target) · \(fieldId)"
        }
        if let fieldID = item["fieldID"] as? String { return fieldID }
        if let pageDict = item["page"] as? [String: Any],
           let name = pageDict["name"] as? String { return name }
        return "—"
    }

    private var keyValues: [(String, String)] {
        var pairs: [(String, String)] = []
        if kind == .change, let inner = item["change"] as? [String: Any] {
            let preferredOrder = ["rowId", "rowIds", "columnId", "value", "schemaId", "parentPath"]
            for key in preferredOrder {
                if let v = inner[key] { pairs.append((key, stringify(v))) }
            }
            for (k, v) in inner where !preferredOrder.contains(k) {
                pairs.append((k, stringify(v)))
            }
        } else {
            let preferredOrder = ["target", "rowIds", "columnId", "schemaId", "parentPath", "type", "multi"]
            for key in preferredOrder {
                if let v = item[key] { pairs.append((key, stringify(v))) }
            }
        }
        return pairs
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if total > 1 {
                    Text("#\(index)")
                        .font(.caption2.monospaced())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
                Text(headline)
                    .font(.caption.monospaced())
                    .lineLimit(2)
                Spacer()
                Button {
                    showRaw.toggle()
                } label: {
                    Image(systemName: showRaw ? "chevron.up" : "curlybraces")
                        .font(.caption2)
                }
                .buttonStyle(.borderless)
            }

            if !keyValues.isEmpty && !showRaw {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(keyValues, id: \.0) { kv in
                        HStack(alignment: .top, spacing: 6) {
                            Text(kv.0)
                                .font(.caption2.bold())
                                .foregroundColor(.secondary)
                                .frame(minWidth: 70, alignment: .leading)
                            Text(kv.1)
                                .font(.caption2.monospaced())
                                .textSelection(.enabled)
                                .lineLimit(3)
                        }
                    }
                }
                .padding(.leading, 4)
            }

            if showRaw {
                Text(prettyJSON(item))
                    .font(.caption2.monospaced())
                    .textSelection(.enabled)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func stringify(_ value: Any) -> String {
        if let s = value as? String { return s }
        if let arr = value as? [String] { return "[\(arr.joined(separator: ", "))]" }
        if let dict = value as? [String: Any] {
            return prettyJSON(dict)
        }
        if let arr = value as? [Any],
           let data = try? JSONSerialization.data(withJSONObject: arr, options: [.sortedKeys]),
           let s = String(data: data, encoding: .utf8) {
            return s
        }
        return "\(value)"
    }

    private func prettyJSON(_ dict: [String: Any]) -> String {
        guard JSONSerialization.isValidJSONObject(dict),
              let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
              let s = String(data: data, encoding: .utf8) else {
            return "\(dict)"
        }
        return s
    }
}
