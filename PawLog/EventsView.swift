import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var store: EventStore

    @State private var selectedDay = Date()
    @State private var showFullCalendar = false
    @State private var editingEvent: PetEvent? = nil

    private var dayEvents: [PetEvent] { store.events(for: selectedDay) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Sticky day strip — always visible while list scrolls beneath it
                DayStrip(selectedDay: $selectedDay)
                    .padding(.vertical, 8)

                List {
                    // MARK: Calendar header
                    Section {
                        HStack {
                            Text(monthYear(selectedDay))
                                .font(.headline)
                            Spacer()
                            Button(showFullCalendar ? "Collapse" : "Expand") {
                                withAnimation(.easeInOut) {
                                    showFullCalendar.toggle()
                                }
                            }
                        }

                        if showFullCalendar {
                            DatePicker(
                                "Select Day",
                                selection: $selectedDay,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .transition(.opacity)
                        }
                    }

                    // MARK: Summary card
                    Section {
                        SummaryCard(items: tally(for: selectedDay))
                            .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowBackground(Color.clear)

                    // MARK: Events list
                    Section("Events") {
                        if dayEvents.isEmpty {
                            Text("No events for this day.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(dayEvents) { e in
                                HStack(spacing: 12) {
                                    Image(systemName: e.type.iconName)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(e.type.color)
                                        .frame(width: 24)
                                    Text(e.type.label)
                                    Spacer()
                                    Text(e.timestamp, style: .time)
                                        .foregroundStyle(.secondary)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        editingEvent = e
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                            .onDelete { offsets in
                                store.delete(at: offsets, from: dayEvents)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .animation(.easeInOut, value: showFullCalendar)
            }
            .navigationTitle("Events")
            .sheet(item: $editingEvent) { event in
                EditEventSheet(event: event) { newDate in
                    store.update(event, timestamp: newDate)
                    editingEvent = nil
                } onCancel: {
                    editingEvent = nil
                }
            }
        }
    }

    private func monthYear(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func tally(for day: Date) -> [(EventType, Int)] {
        var counts: [EventType: Int] = [:]
        for e in store.events(for: day) {
            counts[e.type, default: 0] += 1
        }
        let ordered: [EventType] = [.pee, .poop, .food, .water, .walk, .treat]
        return ordered.map { ($0, counts[$0, default: 0]) }
    }
}

// MARK: - Edit Event Sheet

private struct EditEventSheet: View {
    let event: PetEvent
    let onSave: (Date) -> Void
    let onCancel: () -> Void

    @State private var date: Date

    init(event: PetEvent, onSave: @escaping (Date) -> Void, onCancel: @escaping () -> Void) {
        self.event = event
        self.onSave = onSave
        self.onCancel = onCancel
        self._date = State(initialValue: event.timestamp)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Event type indicator (read-only)
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(event.type.color.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: event.type.iconName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(event.type.color)
                    }
                    Text(event.type.label)
                        .font(.title2).bold()
                }
                .padding(.top, 8)

                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                Spacer()
            }
            .padding(.top, 8)
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { onSave(date) }
                        .bold()
                }
            }
        }
    }
}

// MARK: - Summary Card

private struct SummaryCard: View {
    let items: [(EventType, Int)]

    private let cols = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Summary")
                .font(.headline)

            LazyVGrid(columns: cols, spacing: 10) {
                ForEach(items, id: \.0) { type, count in
                    HStack(spacing: 8) {
                        Image(systemName: type.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(type.color)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(type.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(count)")
                                .font(.title3)
                                .bold()
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(type.color.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 6)
    }
}

// MARK: - Day Strip

private struct DayStrip: View {
    @Binding var selectedDay: Date

    // Fixed range: 90 days back → 14 days forward, anchored to today (not selectedDay).
    // This means the strip always covers the same dates regardless of selection,
    // and the user can browse ~3 months of history without touching the full calendar.
    private var days: [Date] {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        return (-90...14).compactMap { cal.date(byAdding: .day, value: $0, to: todayStart) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(days, id: \.self) { day in
                        DayPill(
                            day: day,
                            isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDay),
                            isToday: Calendar.current.isDateInToday(day)
                        )
                        .id(day)
                        .onTapGesture {
                            withAnimation(.easeInOut) { selectedDay = day }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Defer one run loop so the scroll view has finished layout
                DispatchQueue.main.async {
                    let todayStart = Calendar.current.startOfDay(for: Date())
                    proxy.scrollTo(todayStart, anchor: .center)
                }
            }
            .onChange(of: selectedDay) { newDay in
                let startOfNew = Calendar.current.startOfDay(for: newDay)
                withAnimation(.easeInOut) {
                    proxy.scrollTo(startOfNew, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Day Pill

private struct DayPill: View {
    let day: Date
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        let cal = Calendar.current
        let dayNum = cal.component(.day, from: day)
        let weekday = shortWeekday(day)

        VStack(spacing: 6) {
            Text(weekday)
                .font(.caption)
                .foregroundStyle(isToday ? Color.accentColor : .secondary)
                .fontWeight(isToday ? .semibold : .regular)

            Text("\(dayNum)")
                .font(.headline)
                .frame(width: 38, height: 38)
                .foregroundStyle(isSelected ? Color.accentColor : (isToday ? Color.accentColor : .primary))
                .background {
                    if isSelected {
                        Circle().fill(Color.accentColor.opacity(0.2))
                    } else if isToday {
                        Circle().strokeBorder(Color.accentColor, lineWidth: 1.5)
                    } else {
                        Circle().fill(Color.secondary.opacity(0.12))
                    }
                }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
    }

    private func shortWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }
}
