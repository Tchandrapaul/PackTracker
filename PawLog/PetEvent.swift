//
//  PetEvent.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import Foundation
import SwiftUI

enum EventType: String, Codable, CaseIterable, Hashable {
    case pee, poop, water, walk, food, treat

    var label: String {
        switch self {
        case .pee: return "Pee"
        case .poop: return "Poop"
        case .water: return "Water"
        case .walk: return "Walk"
        case .food: return "Food"
        case .treat: return "Treat"
        }
    }

    var iconName: String {
        switch self {
        case .pee: return "drop.fill"
        case .poop: return "moon.fill"
        case .water: return "cup.and.saucer.fill"
        case .walk: return "figure.walk"
        case .food: return "fork.knife"
        case .treat: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .pee: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .poop: return Color(red: 0.55, green: 0.35, blue: 0.15)
        case .water: return .blue
        case .walk: return .teal
        case .food: return .orange
        case .treat: return .purple
        }
    }
}

struct PetEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let type: EventType
    let timestamp: Date
    var petId: UUID

    /// Sentinel used for events saved before multi-pet support.
    /// migrateOrphanedEvents(to:) in EventStore reassigns these on first launch.
    static let unassignedPetId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    init(id: UUID = UUID(), type: EventType, timestamp: Date, petId: UUID) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.petId = petId
    }

    // Custom decoder: old JSON records without petId decode to unassignedPetId
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(UUID.self,       forKey: .id)
        type      = try c.decode(EventType.self,  forKey: .type)
        timestamp = try c.decode(Date.self,        forKey: .timestamp)
        petId     = try c.decodeIfPresent(UUID.self, forKey: .petId) ?? Self.unassignedPetId
    }
}
