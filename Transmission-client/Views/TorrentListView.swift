//
//  ContentView.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import SwiftUI
import SwiftData

struct TorrentListView: View {
    @Bindable var api:TransmissionRPC
    @State var paused:Bool = false
    
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
                        Button("Pause") {
                            print("pause!")
                        }.tint(.gray)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Notif") {
                            print("notif!")
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
    /*
    private func addItem() {
        withAnimation {
            let newItem = Item(url: URL(string: "http://pi5.local:9091/transmission/web/")!)
            modelContext.insert(newItem)
            do {
                try modelContext.save()
            } catch{
                print(error)
            }
        }
    }
     */
}


#Preview {
    TorrentListView(api: TransmissionRPC(mct: try! ModelContainer()))
}

