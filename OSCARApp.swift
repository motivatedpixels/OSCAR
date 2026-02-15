import SwiftUI

@main
struct OSCARApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 600, height: 600)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Edit Oscar Items...") {
                    NotificationCenter.default.post(name: NSNotification.Name("OpenEditorRequested"), object: nil)
                }
            }

            CommandGroup(after: .printItem) {
                Button("Print...") {
                    NotificationCenter.default.post(name: NSNotification.Name("PrintRequested"), object: nil)
                }
                .keyboardShortcut("p", modifiers: .command)

                Button("Save as PDF...") {
                    NotificationCenter.default.post(name: NSNotification.Name("SavePDFRequested"), object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }

        Window("Edit Oscar Items", id: "oscar-editor") {
            EditorView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 700, height: 500)
        .keyboardShortcut("e", modifiers: .command)
    }
}
