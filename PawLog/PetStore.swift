//
//  PetStore.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import Foundation
import SwiftUI

@MainActor
final class PetStore: ObservableObject {
    @Published private(set) var pets: [Pet] = []

    @Published var activePetId: UUID? {
        didSet {
            UserDefaults.standard.set(activePetId?.uuidString, forKey: Self.activeIdKey)
        }
    }

    var activePet: Pet? {
        guard let id = activePetId else { return pets.first }
        return pets.first { $0.id == id } ?? pets.first
    }

    private let fileURL: URL
    private static let activeIdKey = "activePetId"

    // Colors cycled through as pets are added
    static let avatarColors: [Color] = [.blue, .purple, .orange, .teal, .pink, .green]

    func color(for pet: Pet) -> Color {
        guard let index = pets.firstIndex(where: { $0.id == pet.id }) else { return .blue }
        return Self.avatarColors[index % Self.avatarColors.count]
    }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("pets.json")
        load()

        if let s = UserDefaults.standard.string(forKey: Self.activeIdKey),
           let uuid = UUID(uuidString: s) {
            activePetId = uuid
        } else {
            activePetId = pets.first?.id
        }
    }

    func add(_ pet: Pet) {
        pets.append(pet)
        if activePetId == nil { activePetId = pet.id }
        save()
    }

    func update(_ pet: Pet) {
        guard let i = pets.firstIndex(where: { $0.id == pet.id }) else { return }
        pets[i] = pet
        save()
    }

    func delete(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        if activePetId == pet.id { activePetId = pets.first?.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Pet].self, from: data) else {
            pets = []
            return
        }
        pets = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(pets) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
