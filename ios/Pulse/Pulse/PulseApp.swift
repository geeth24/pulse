//
//  PulseApp.swift
//  Pulse
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ItemURL.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Color("AccentColor"))
        }
        .modelContainer(sharedModelContainer)
    }
}
