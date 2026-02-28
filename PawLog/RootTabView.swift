//
//  RootTabView.swift
//  PawLog
//
//  Created by Trevor Chandrapaul on 1/6/26.
//

import SwiftUI

struct RootTabView: View {
    enum Tab { case home, log, events, settings }
    @State private var selection: Tab = .log   // 👈 default = Log

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            LogEventsView()
                .tabItem { Label("Log", systemImage: "plus.circle") }
                .tag(Tab.log)

            EventsView()
                .tabItem { Label("Events", systemImage: "list.bullet") }
                .tag(Tab.events)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}
