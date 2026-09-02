import AppKit
import MacTuckCore
import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    var exclusions: Exclusions
    var loginItem: LoginItem

    var body: some View {
        Form {
            Section("Strip material") {
                Picker("Material", selection: $settings.material) {
                    ForEach(StripMaterial.allCases, id: \.self) { material in
                        Text(material.label).tag(material)
                    }
                }
            }
            Section("Excluded apps") {
                if exclusions.bundleIDs.isEmpty {
                    Text("None. Use “Exclude …” in the dropdown to add one.").foregroundStyle(.secondary)
                }
                ForEach(exclusions.bundleIDs.sorted(), id: \.self) { bundleID in
                    let info = AppInfo.lookup(bundleID: bundleID)
                    HStack {
                        if let icon = info.icon {
                            Image(nsImage: icon).resizable().frame(width: 18, height: 18)
                        }
                        Text(info.name)
                        Spacer()
                        Button("Remove") { exclusions.remove(bundleID) }
                    }
                }
            }
            Section("Launch at login") {
                Toggle("Open MacTuck at login", isOn: Binding(
                    get: { loginItem.isEnabled },
                    set: { loginItem.setEnabled($0) }
                ))
                if let error = loginItem.lastError {
                    Text(error).foregroundStyle(.red)
                }
            }
            Section("About") {
                Text("MacTuck \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev")")
                Text("Accessibility: granted")
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 420)
    }
}
