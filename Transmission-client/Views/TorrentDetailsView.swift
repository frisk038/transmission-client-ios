//
//  TorrentDetailsView.swift
//  Transmission-client
//
//  Created by Olivier on 28/05/2024.
//

import SwiftUI

struct TorrentDetailsView: View {
    var torrent: Torrent
    var body: some View {
        List{
            Text(torrent.name)
            HStack{Text("Size"); Spacer(); Text(torrent.sizeReadable())}
            HStack{Text("Destination"); Spacer(); Text(torrent.downloadDir)}
            HStack{Text("Added Date"); Spacer(); Text(torrent.addedDate.formatted(date: .abbreviated, time: .shortened))}
            HStack{Text("Creator"); Spacer(); Text(torrent.creator)}
            HStack{Text("Hash"); Spacer(); Text(torrent.hashString)}
            HStack{Text("Size"); Spacer(); Text(String(format: "%.1f", torrent.percentDone * 100) + " %")}
            HStack{Text("Status"); Spacer(); Text(statusToString(torrent.status))}
            if torrent.eta != -1 {
                HStack{Text("ETA"); Spacer(); Text(torrent.etaReadable())}
            }
            
            
        }
    }
    
    func statusToString(_ status: Status) -> String{
        switch status {
        case .Download:
            return "Downloading"
        case .Stop:
            return "Stopped"
        case .QueueLocalVerif:
            return "Stopped"
        case .LocalVerif:
            return "Local verification"
        case .QueueDownload:
            return "Queued for download"
        case .QueueSeed:
            return "Queued for seed"
        case .Seed:
            return "Seeding"
        case .Error:
            return "Error"
        }
    }
    
}




#Preview {
    TorrentDetailsView(torrent: Torrent(addedDate: Date.now, downloadDir: "/downloads/complete", error: 0, errorString: "", eta: -1, id: 123, name: "John Wick", percentDone: 0.149, status:.Download, totalSize: 399022, hashString: "c2f55858987ac39db53e364bef5a6caa62641d9c", creator: "YggTorrent"))
}
