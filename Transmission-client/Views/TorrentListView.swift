//
//  ContentView.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import SwiftUI
import SwiftData
import ActivityKit
import UniformTypeIdentifiers

struct TorrentListView: View {

    @Bindable var api:TransmissionRPC
    @State var paused:Bool = false
    @State var showAlert:Bool = false
    @State var showPicker:Bool = false
    @State var destDir:String = ""
    @State var fileURL:URL = URL(fileURLWithPath: "")
    
    @State var laMgr: LiveActivityMGR
    
    var body: some View {
        VStack{
            header
            
            NavigationStack{
                List(api.torrentList, id: \Torrent.id) { t in
                    HStack(alignment:.bottom) {
                        VStack(alignment: .leading) {
                            Text(t.name)
                            Text(String(format: "%.1f", t.percentDone * 100) + " %")
                            ProgressView(value: t.percentDone)
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
            }
            .sheet(isPresented: $showAlert) {
                Form{
                    TextField("download dir", text: $destDir)
                        .autocapitalization(.none)
                    if fileURL.absoluteString != "file:///" {
                        Text(fileURL.lastPathComponent)
                    }
                    Button("pick file", systemImage: "folder") {
                        showPicker = true
                    }
                    .fileImporter(isPresented: $showPicker, allowedContentTypes: [.item]) { result in
                        switch result {
                        case .success(let file):
                            fileURL = file
                        default:
                            break
                        }
                    }
                    if fileURL.absoluteString != "file:///" && !destDir.isEmpty {
                        Button("Start new torrent", systemImage: "doc.badge.plus") {
                            api.addTorrent(path: fileURL, savePath: destDir)
                            showAlert = false
                            fileURL = URL(filePath: "")
                            destDir = ""
                        }
                    }
                }
            }
            
            Spacer()
            if !paused {
                Button("Stop", systemImage: "playpause") {
                    api.stopAllTorrent()
                    paused = true
                }
            } else {
                Button("Start All", systemImage: "playpause") {
                    api.startAllTorrent()
                    paused = false
                }
            }
            Spacer()
            Button("Clean", systemImage: "paintbrush") {
                api.cleanAllTorrent()
            }
            Spacer()
            Button("Slow", systemImage: api.turleMode ? "tortoise.fill" : "tortoise") {
                api.setTurtleMode()
            }
            /*
            Button {
                api.setTurtleMode()
            } label: {
                Image(systemName: api.turleMode ? "tortoise.fill" : "tortoise")
            }
             */
        }
        .padding()        
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    return TorrentListView(api: TransmissionRPC(mct: container), laMgr: LiveActivityMGR(api: TransmissionRPC(mct: container), updateTime: 5))
}

