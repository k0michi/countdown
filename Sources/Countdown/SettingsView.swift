import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CountdownStore
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var loginItemError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.countdownText)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            LabeledContent("Title") {
                TextField("e.g. Deadline", text: $store.title)
                    .textFieldStyle(.roundedBorder)
            }

            LabeledContent("Target date") {
                DatePicker("", selection: $store.targetDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.field)
            }

            DatePicker("", selection: $store.targetDate, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.graphical)
                .frame(maxWidth: .infinity, alignment: .center)

            Toggle("Show title in menu bar", isOn: $store.showTitle)

            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, enabled in
                    setLaunchAtLogin(enabled)
                }

            if let loginItemError {
                Text(loginItemError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Divider()

            HStack {
                Text("Version \(appVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                Spacer()
                Button("Quit Countdown") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
        }
        .padding(16)
        .frame(width: 280)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginItemError = nil
        } catch {
            loginItemError = "Could not update login item: \(error.localizedDescription)"
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
