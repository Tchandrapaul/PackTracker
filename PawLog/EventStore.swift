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

    //used to trigger toast
    @Published var lastLogged: PetEvent? = nil

    private let fileURL: URL

    init(filename: String = "events.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)
        load()
    }

    func add(type: EventType, at date: Date) {
        let e = PetEvent(id: UUID(), type: type, timestamp: date)
        events.insert(e, at: 0)
        lastLogged = e
        save()
    }

    func add(types: [EventType], at date: Date) {
        let newEvents = types.map { PetEvent(id: UUID(), type: $0, timestamp: date) }
        // newest-first overall
        events = newEvents.sorted(by: { $0.timestamp > $1.timestamp }) + events
        lastLogged = newEvents.first
        save()
    }

    func events(for day: Date) -> [PetEvent] {
        let cal = Calendar.current
        return events
            .filter { cal.isDate($0.timestamp, inSameDayAs: day) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func delete(at offsets: IndexSet, from list: [PetEvent]) {
        let idsToRemove = offsets.map { list[$0].id }
        events.removeAll { idsToRemove.contains($0.id) }
        save()
    }

    func update(_ event: PetEvent, timestamp: Date) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = PetEvent(id: event.id, type: event.type, timestamp: timestamp)
        events.sort { $0.timestamp > $1.timestamp }
        save()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([PetEvent].self, from: data)
            self.events = decoded.sorted(by: { $0.timestamp > $1.timestamp })
        } catch {
            self.events = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // fail silently (don't crash)
        }
    }
}
