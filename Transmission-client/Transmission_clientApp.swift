//
//  Transmission_clientApp.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import SwiftUI
import SwiftData

@main
struct Transmission_clientApp: App {
    let api:TransmissionRPC
    var sharedModelContainer: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            TabView{
                TorrentListView(api: api)
                    .tabItem {
                        Label("Torrents", systemImage: "list.and.film")
                    }
                ConfigView(api: api)
                    .tabItem {
                        Label("Configuration", systemImage: "gear")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        do {
            self.sharedModelContainer = try ModelContainer(for: Item.self)
            self.api = TransmissionRPC(mct: self.sharedModelContainer)
            self.api.startFetchingTorrentList()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
