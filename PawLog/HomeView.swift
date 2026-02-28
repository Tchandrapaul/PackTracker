//
//  HomeView.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: EventStore

    private var today: Date { Date() }

    private var todayEvents: [PetEvent] {
        store.events(for: today)
    }

    private var recentEvents: [PetEvent] {
        Array(store.events.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    PetHeaderCard()

                    TodaySummarySection(events: todayEvents)

                    RecentActivitySection(events: recentEvents)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Home")
        }
    }
}

// MARK: - Pet Header Card

private struct PetHeaderCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Pet")
                    .font(.title2).bold()
                Text("Add a pet profile in Settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 4)
    }
}

// MARK: - Today Summary

private struct TodaySummarySection: View {
    let events: [PetEvent]

    private var tally: [(EventType, Int)] {
        var counts: [EventType: Int] = [:]
        for e in events { counts[e.type, default: 0] += 1 }
        let ordered: [EventType] = [.pee, .poop, .food, .water, .walk, .treat]
        return ordered.compactMap { type in
            let count = counts[type, default: 0]
            return count > 0 ? (type, count) : nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Today", systemImage: "calendar")
                .font(.headline)

            if tally.isEmpty {
                Text("Nothing logged yet today.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            } else {
                let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(tally, id: \.0) { type, count in
                        HStack(spacing: 10) {
                            Image(systemName: type.iconName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(type.color)
                                .frame(width: 22)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(type.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(count)×")
                                    .font(.subheadline).bold()
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(10)
                        .background(type.color.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 4)
    }
}

// MARK: - Recent Activity

private struct RecentActivitySection: View {
    let events: [PetEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent Activity", systemImage: "clock")
                .font(.headline)

            if events.isEmpty {
                Text("No events logged yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        HStack(spacing: 12) {
                            Image(systemName: event.type.iconName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(event.type.color)
                                .frame(width: 28, height: 28)
                                .background(event.type.color.opacity(0.12))
                                .clipShape(Circle())

                            Text(event.type.label)
                                .font(.subheadline)

                            Spacer()

                            Text(relativeTime(event.timestamp))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)

                        if index < events.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 4)
    }

    private func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
