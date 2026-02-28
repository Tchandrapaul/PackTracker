//
//  Pet.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import Foundation

struct Pet: Identifiable, Codable {
    let id: UUID
    var name: String
    var breed: String?
    var birthdate: Date?

    init(id: UUID = UUID(), name: String, breed: String? = nil, birthdate: Date? = nil) {
        self.id = id
        self.name = name
        self.breed = breed
        self.birthdate = birthdate
    }

    /// Single initial for avatar display
    var initial: String { String(name.prefix(1)).uppercased() }

    /// Human-readable age derived from birthdate
    var ageString: String? {
        guard let birthdate else { return nil }
        let components = Calendar.current.dateComponents([.year, .month], from: birthdate, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) yr\(years == 1 ? "" : "s")"
        } else if let months = components.month, months > 0 {
            return "\(months) mo"
        } else {
            return "< 1 mo"
        }
    }

    /// Summary line for display (breed · age, breed, age, or nil)
    var subtitle: String? {
        switch (breed, ageString) {
        case (let b?, let a?): return "\(b) · \(a)"
        case (let b?, nil):    return b
        case (nil, let a?):    return a
        case (nil, nil):       return nil
        }
    }
}
