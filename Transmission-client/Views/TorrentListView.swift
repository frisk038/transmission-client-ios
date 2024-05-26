//
//  ContentView.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import SwiftUI
import SwiftData
import ActivityKit

struct TorrentListView: View {
    @Bindable var api:TransmissionRPC
    var laMgr: LiveActivityMGR
    @State var paused:Bool = false
    @State var showAlert:Bool = false
    
    var body: some View {
        VStack{
            header
            
            NavigationStack{
                List(api.torrentList, id: \Torrent.id) { t in
                    HStack(alignment:.bottom) {
                        VStack(alignment: .leading) {
                            Text(t.name)
                            Text(String(format: "%.1f", t.percentComplete * 100) + " %")
                            ProgressView(value: t.percentComplete)
                        }
                        Spacer()
                        Text(t.downloadDir)
                    }
                    .listRowBackground(statusColor(status: t.status))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button("Start", systemImage: "bell.badge.slash") {
                            laMgr.startActivity(torrentID: t.id)
                        }.tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Start", systemImage: "play") {
                            api.startTorrent(torrentID: t.id)
                        }
                        .tint(.purple)
                        Button("Pause", systemImage: "pause") {
                            api.stopTorrent(torrentID: t.id)
                        }
                        .tint(.orange)
                    }
                }
            }
        }
    }
    var header: some View {
        HStack {
            Button("Add", systemImage: "doc.badge.plus") {
                showAlert = true
            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Not available yet..."),
                    message: Text("Soon you'll be able to add torrent")
                )
            }
            Spacer()
            if !paused {
                Button("Stop All", systemImage: "playpause") {
                    api.stopAllTorrent()
                    paused = true
                }
                .buttonStyle(.bordered)
            } else {
                Button("Start All", systemImage: "playpause") {
                    api.startAllTorrent()
                    paused = false
                }
            }
            Spacer()
            Button("Clean", systemImage: "trash") {
                api.cleanAllTorrent()
            }
        }
        .padding()
        .buttonStyle(.bordered)
    }
    
    private func statusColor(status:Status) -> Color {
        switch status {
        case .Stop:
            return Color.secondary
        case .Seed:
            return Color.green
        case .Error:
            return Color.red
        default:
            return Color(uiColor: .secondarySystemGroupedBackground)
        }
    }
}

/*
 #Preview {
 TorrentListView(api: TransmissionRPC(mct: try! ModelContainer()), laMgr: LiveActivityMGR(api: nil, updateTime: <#T##TimeInterval#>))
 }
 */
