//
//  Transmission_clientApp.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import SwiftUI
import SwiftData

// TODO
// - basic auth
// - better live activity ui
// - add torrent
// - stop activity

@main
struct Transmission_clientApp: App {
    let api:TransmissionRPC
    let activityMgr:LiveActivityMGR
    var sharedModelContainer: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            TabView{
                TorrentListView(api: api, laMgr: activityMgr)
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
            self.activityMgr = LiveActivityMGR(api: self.api, updateTime: 5.0)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
