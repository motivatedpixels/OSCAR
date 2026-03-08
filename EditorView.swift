//
//  EditorView.swift
//  OSCAR
//
//  Editor view for oscar.txt content
//

import SwiftUI

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content: String = ""
    @State private var originalContent: String = ""
    @State private var hasUnsavedChanges: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showWarning: Bool = false
    @State private var warningMessage: String = ""

    private var itemCount: Int {
        OscarFileManager.shared.countItems(in: content)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Oscar Items")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            // Text Editor
            TextEditor(text: $content)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .onChange(of: content) { oldValue, newValue in
                    hasUnsavedChanges = (newValue != originalContent)
                }

            Divider()

            // Footer with buttons and item count
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(".", modifiers: .command)

                Spacer()

                Text("\(itemCount) items")
                    .foregroundColor(.secondary)
                    .font(.caption)

                Spacer()

                Button("Save") {
                    saveContent()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!hasUnsavedChanges)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear {
            loadContent()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Warning", isPresented: $showWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Continue") {
                saveForcefully()
            }
        } message: {
            Text(warningMessage)
        }
    }

    private func loadContent() {
        do {
            content = try OscarFileManager.shared.loadOscarContentForEditor()
            originalContent = content
            hasUnsavedChanges = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func saveContent() {
        // Validate content
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedContent.isEmpty {
            errorMessage = "Cannot save empty file. The bingo grid requires 24 unique items."
            showError = true
            return
        }

        let count = OscarFileManager.shared.countItems(in: content)
        if count < 24 {
            warningMessage = "Warning: You have only \(count) items. The bingo grid requires 24 unique items. Some items may be repeated. Continue?"
            showWarning = true
            return
        }

        // Content is valid, save it
        saveForcefully()
    }

    private func saveForcefully() {
        do {
            try OscarFileManager.shared.saveOscarContent(content)
            originalContent = content
            hasUnsavedChanges = false

            // Post notification to update cached data in memory
            NotificationCenter.default.post(name: NSNotification.Name("OscarDataUpdated"), object: nil)

            // Close window
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    EditorView()
        .frame(width: 700, height: 500)
}
