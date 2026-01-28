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
    }
}
