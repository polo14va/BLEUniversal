//  BLEUniversalApp.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 8/2/24.
//

import SwiftUI
import SwiftData

@main
struct BLEUniversalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
#if os(macOS)
            ContentViewMacOS()
                .environmentObject(BLEManager())
#else
            ContentViewIOS()
                .environmentObject(BLEManager())
#endif
        }
        .modelContainer(sharedModelContainer)
    }
}
