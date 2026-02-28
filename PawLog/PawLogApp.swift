//
//  PawLogApp.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//
import SwiftUI

@main
struct PawLogApp: App {
    @StateObject private var petStore = PetStore()
    @StateObject private var store = EventStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(petStore)
                .environmentObject(store)
                .task { runMigrationIfNeeded() }
        }
    }

    /// Runs once on first launch after the multi-pet update.
    /// Creates a default pet if none exist and reassigns any pre-migration events to it.
    private func runMigrationIfNeeded() {
        if petStore.pets.isEmpty {
            let defaultPet = Pet(name: "My Pet")
            petStore.add(defaultPet)
        }
        if let firstId = petStore.activePet?.id {
            store.migrateOrphanedEvents(to: firstId)
        }
    }
}
