//
//  SettingsView.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("use24HourTime") private var use24HourTime = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: Pets
                Section {
                    HStack {
                        Label("My Pets", systemImage: "pawprint.fill")
                        Spacer()
                        Text("Coming in Phase 2")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Pets")
                }

                // MARK: Pack
                Section {
                    HStack {
                        Label("Pack Sharing", systemImage: "person.2.fill")
                        Spacer()
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Sign In with Apple", systemImage: "apple.logo")
                        Spacer()
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Pack")
                } footer: {
                    Text("Share your pet's log with family members and other caregivers.")
                }

                // MARK: App
                Section("App") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Reminders", systemImage: "bell.fill")
                    }
                    Toggle(isOn: $use24HourTime) {
                        Label("24-Hour Time", systemImage: "clock.fill")
                    }
                }

                // MARK: About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Built with")
                        Spacer()
                        Text("SwiftUI + CloudKit")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
