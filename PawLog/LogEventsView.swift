//
//  LogEventsView.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import SwiftUI

struct LogEventsView: View {
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var petStore: PetStore

    @State private var isBatchMode = false
    @State private var selectedTypes = Set<EventType>()

    @State private var showingTimeSheet = false
    @State private var pendingTypes: [EventType] = []
    @State private var chosenDate = Date()

    // Toast
    @State private var showToast = false
    @State private var toastText = "Logged"

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                if petStore.activePet == nil {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text("No active pet")
                            .font(.title3).bold()
                        Text("Add a pet in Settings to start logging.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {

                // Icon grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(EventType.allCases, id: \.self) { type in
                        EventButton(
                            type: type,
                            isSelected: isBatchMode && selectedTypes.contains(type),
                            isBatchMode: isBatchMode
                        ) {
                            handleTap(type)
                        }
                    }
                }
                .padding(.horizontal)

                // Batch action button
                if isBatchMode {
                    Button {
                        guard !selectedTypes.isEmpty else { return }
                        pendingTypes = Array(selectedTypes)
                        chosenDate = Date()
                        showingTimeSheet = true
                    } label: {
                        Text("Log Selected")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .disabled(selectedTypes.isEmpty)
                }

                Spacer(minLength: 0)
                } // end activePet guard
            }
            .navigationTitle(isBatchMode ? "Select Events" : "Log Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        toggleBatchMode()
                    } label: {
                        Image(systemName: isBatchMode ? "xmark" : "plus")
                    }
                }
            }
            .sheet(isPresented: $showingTimeSheet) {
                TimePickerSheet(
                    date: $chosenDate,
                    onCancel: {
                        showingTimeSheet = false
                        pendingTypes = []
                    },
                    onConfirm: {
                        guard let petId = petStore.activePet?.id else { return }
                        // log
                        if pendingTypes.count == 1, let t = pendingTypes.first {
                            store.add(type: t, at: chosenDate, petId: petId)
                            triggerToast("\(t.label) logged")
                        } else {
                            store.add(types: pendingTypes, at: chosenDate, petId: petId)
                            triggerToast("Events logged")
                        }

                        // dismiss
                        showingTimeSheet = false
                        pendingTypes = []

                        // If we were batching, reset after log
                        if isBatchMode {
                            selectedTypes.removeAll()
                            isBatchMode = false
                        }
                    }
                )
            }
            .overlay(alignment: .top) {
                if showToast {
                    ToastView(text: toastText)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    private func handleTap(_ type: EventType) {
        if isBatchMode {
            // toggle selection
            if selectedTypes.contains(type) {
                selectedTypes.remove(type)
            } else {
                selectedTypes.insert(type)
            }
        } else {
            // quick log: single type
            pendingTypes = [type]
            chosenDate = Date()
            showingTimeSheet = true
        }
    }

    private func toggleBatchMode() {
        isBatchMode.toggle()
        if !isBatchMode { selectedTypes.removeAll() }
    }

    private func triggerToast(_ text: String) {
        toastText = text
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showToast = false
            }
        }
    }
}

// MARK: - Components

private struct EventButton: View {
    let type: EventType
    let isSelected: Bool
    let isBatchMode: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? type.color.opacity(0.25) : type.color.opacity(0.12))
                        .frame(width: 72, height: 72)

                    Image(systemName: type.iconName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(type.color)

                    if isBatchMode && isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .offset(x: 26, y: -26)
                    }
                }

                Text(type.label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

private struct TimePickerSheet: View {
    @Binding var date: Date
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.top, 12)

                Spacer()
            }
            .navigationTitle("Pick Time")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: onConfirm)
                        .bold()
                }
            }
        }
    }
}

private struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline).bold()
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 8)
    }
}
