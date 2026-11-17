import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = CountdownStore()

    var body: some Scene {
        MenuBarExtra {
            SettingsView()
                .environmentObject(store)
        } label: {
            Text(store.menuBarTitle)
        }
        .menuBarExtraStyle(.window)
    }
}
