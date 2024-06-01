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
    @State var showDetails:Bool = false
    @State var destDir:String = ""
    @State var fileURL:URL = URL(fileURLWithPath: "")
    
    @State var laMgr: LiveActivityMGR
    
    var body: some View {
        VStack{
            list
            //header
        }
    }
    
    var list: some View {
        NavigationView{
            List(api.torrentList, id: \Torrent.id) { t in
                NavigationLink(destination: TorrentDetailsView(torrent: t)) {
                    HStack(alignment:.bottom) {
                        VStack(alignment: .leading) {
                            Text(t.name)
                                .font(.subheadline)
                            HStack {
                                Text(String(format: "%.1f", t.percentDone * 100) + " %")
                                Spacer()
                                if t.eta != -1 {
                                    Text(t.etaReadable())
                                }
                            }
                            
                            ProgressView(value: t.percentDone)
                        }
                    }
                    .listRowBackground(statusColor(status: t.status))
                    /*.swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button("Start", systemImage: "bell.badge.slash") {
                            //laMgr.startActivity(torrentID: t.id)
                            showDetails = true
                        }.tint(.blue)
                    }*/
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Start", systemImage: "play") {
                            api.startTorrent(torrentID: t.id)
                        }
                        .tint(statusColor(status: .Download))
                        Button("Pause", systemImage: "pause") {
                            api.stopTorrent(torrentID: t.id)
                        }
                        .tint(statusColor(status: .Stop))
                    }
                }.tint(statusColor(status: t.status))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                }
                ToolbarItem(placement: .topBarTrailing) {
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
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clean", systemImage: "paintbrush") {
                        api.cleanAllTorrent()
                    }
                    
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Slow", systemImage: api.turleMode ? "tortoise.fill" : "tortoise") {
                        api.setTurtleMode()
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
            return Color.orange
        case .Seed:
            return Color.green
        case .Error:
            return Color.red
        default:
            return Color.blue
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    return TorrentListView(api: TransmissionRPC(mct: container), laMgr: LiveActivityMGR(api: TransmissionRPC(mct: container), updateTime: 5))
}

