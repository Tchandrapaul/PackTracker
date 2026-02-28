//
//  SettingsView.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var petStore: PetStore
    @EnvironmentObject private var store: EventStore

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("use24HourTime") private var use24HourTime = false

    @State private var showingAddPet = false
    @State private var editingPet: Pet? = nil

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        NavigationStack {
            List {

                // MARK: Pets
                petsSection

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
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddPet) {
                PetFormSheet(mode: .add) {
                    showingAddPet = false
                }
            }
            .sheet(item: $editingPet) { pet in
                PetFormSheet(mode: .edit(pet), onDelete: { deletePet(pet) }) {
                    editingPet = nil
                }
            }
        }
    }

    @ViewBuilder private var petsSection: some View {
        Section {
            ForEach(petStore.pets) { pet in
                PetRow(
                    pet: pet,
                    color: petStore.color(for: pet),
                    isActive: pet.id == petStore.activePetId,
                    onSelect: { petStore.activePetId = pet.id },
                    onEdit:   { editingPet = pet },
                    onDelete: { deletePet(pet) }
                )
            }
            Button {
                showingAddPet = true
            } label: {
                Label("Add Pet", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Pets")
        } footer: {
            Text("Tap a pet to make it active. Swipe right to edit, left to delete.")
        }
    }

    private func deletePet(_ pet: Pet) {
        store.deleteAllEvents(for: pet.id)
        petStore.delete(pet)
        if editingPet?.id == pet.id { editingPet = nil }
    }
}

// MARK: - Pet Row

private struct PetRow: View {
    let pet: Pet
    let color: Color
    let isActive: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Text(pet.initial)
                        .font(.subheadline).bold()
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if let subtitle = pet.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Pet Form Sheet

private enum PetFormMode {
    case add
    case edit(Pet)
}

private struct PetFormSheet: View {
    @EnvironmentObject private var petStore: PetStore

    let mode: PetFormMode
    var onDelete: (() -> Void)? = nil
    let onDismiss: () -> Void

    @State private var name = ""
    @State private var breed = ""
    @State private var hasBirthdate = false
    @State private var birthdate = Date()

    init(mode: PetFormMode, onDelete: (() -> Void)? = nil, onDismiss: @escaping () -> Void) {
        self.mode = mode
        self.onDelete = onDelete
        self.onDismiss = onDismiss

        if case .edit(let pet) = mode {
            _name        = State(initialValue: pet.name)
            _breed       = State(initialValue: pet.breed ?? "")
            _hasBirthdate = State(initialValue: pet.birthdate != nil)
            _birthdate   = State(initialValue: pet.birthdate ?? Date())
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pet Info") {
                    TextField("Name", text: $name)
                    TextField("Breed (optional)", text: $breed)
                }

                Section {
                    Toggle("Add Birthday", isOn: $hasBirthdate.animation())
                    if hasBirthdate {
                        DatePicker(
                            "Birthday",
                            selection: $birthdate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                    }
                }

                if isEditing, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            if case .edit(let pet) = mode {
                                Text("Delete \(pet.name)")
                            }
                        }
                    } footer: {
                        Text("This will permanently delete all events for this pet.")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Pet" : "New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                        onDismiss()
                    }
                    .bold()
                    .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let trimName  = name.trimmingCharacters(in: .whitespaces)
        let trimBreed = breed.trimmingCharacters(in: .whitespaces)

        switch mode {
        case .add:
            petStore.add(Pet(
                name: trimName,
                breed: trimBreed.isEmpty ? nil : trimBreed,
                birthdate: hasBirthdate ? birthdate : nil
            ))
        case .edit(let existing):
            var updated = existing
            updated.name      = trimName
            updated.breed     = trimBreed.isEmpty ? nil : trimBreed
            updated.birthdate = hasBirthdate ? birthdate : nil
            petStore.update(updated)
        }
    }
}
