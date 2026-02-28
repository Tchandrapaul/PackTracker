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
}
