//
//  EventStore.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//
import Foundation

@MainActor
final class EventStore: ObservableObject {
    @Published private(set) var events: [PetEvent] = []

    // Used to trigger toast in LogEventsView
    @Published var lastLogged: PetEvent? = nil

    private let fileURL: URL

    init(filename: String = "events.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)
        load()
    }

    // MARK: - Write

    func add(type: EventType, at date: Date, petId: UUID) {
        let e = PetEvent(id: UUID(), type: type, timestamp: date, petId: petId)
        events.insert(e, at: 0)
        lastLogged = e
        save()
    }

    func add(types: [EventType], at date: Date, petId: UUID) {
        let newEvents = types.map { PetEvent(id: UUID(), type: $0, timestamp: date, petId: petId) }
        events = newEvents.sorted { $0.timestamp > $1.timestamp } + events
        lastLogged = newEvents.first
        save()
    }

    func update(_ event: PetEvent, timestamp: Date) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = PetEvent(id: event.id, type: event.type, timestamp: timestamp, petId: event.petId)
        events.sort { $0.timestamp > $1.timestamp }
        save()
    }

    func delete(at offsets: IndexSet, from list: [PetEvent]) {
        let idsToRemove = offsets.map { list[$0].id }
        events.removeAll { idsToRemove.contains($0.id) }
        save()
    }

    func deleteAllEvents(for petId: UUID) {
        events.removeAll { $0.petId == petId }
        save()
    }

    // MARK: - Read

    func events(for day: Date, petId: UUID) -> [PetEvent] {
        let cal = Calendar.current
        return events
            .filter { $0.petId == petId && cal.isDate($0.timestamp, inSameDayAs: day) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func events(for petId: UUID) -> [PetEvent] {
        events.filter { $0.petId == petId }.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Migration

    /// Reassigns events saved before multi-pet support to the given pet.
    /// Safe to call on every launch — no-ops if no orphaned events exist.
    func migrateOrphanedEvents(to petId: UUID) {
        let sentinel = PetEvent.unassignedPetId
        guard events.contains(where: { $0.petId == sentinel }) else { return }
        events = events.map { e in
            e.petId == sentinel
                ? PetEvent(id: e.id, type: e.type, timestamp: e.timestamp, petId: petId)
                : e
        }
        save()
    }

    // MARK: - Persistence

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([PetEvent].self, from: data)
            self.events = decoded.sorted { $0.timestamp > $1.timestamp }
        } catch {
            self.events = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: fileURL, options: [.atomic])
        } catch {}
    }
}
