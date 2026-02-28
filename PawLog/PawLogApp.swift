//
//  PawLogApp.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//
import SwiftUI

@main
struct PawLogApp: App {
    @StateObject private var store = EventStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
