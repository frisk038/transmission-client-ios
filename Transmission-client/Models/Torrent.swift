//
//  Torrent.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import Foundation

/*
 {
   "arguments": {
     "torrents": [
       {
         "addedDate": 1715977649,
         "downloadDir": "/downloads/complete",
         "error": 0,
         "errorString": "",
         "eta": -1,
         "id": 32,
         "name": "A Man in Full",
         "percentComplete": 0.0125,
         "percentDone": 0.0125,
         "status": 0
       },
       {
         "addedDate": 1716025412,
         "downloadDir": "/downloads/complete",
         "error": 0,
         "errorString": "",
         "eta": 294,
         "id": 33,
         "name": "My Hero Academia S07E03 VOSTFR 1080p WEB x264 AAC -Tsundere-Raws (CR).mkv",
         "percentComplete": 0.9733,
         "percentDone": 0.9733,
         "status": 4
       }
     ]
   },
   "result": "success"
 }
 */

enum Status:Int, Codable {
    case Stop = 0
    case QueueLocalVerif
    case LocalVerif
    case QueueDownload
    case Download
    case QueueSeed
    case Seed
    case Error
}

struct ApiResponse: Codable {
    let arguments: Arguments
    let result: String
}

struct Arguments: Codable {
    let torrents: [Torrent]?
    let altSpeedEnabled: Bool?
    let configDir: String?
    let peerLimitPerTorrent: Int?
    let downloadDir: String?

    enum CodingKeys: String, CodingKey {
        case torrents
        case altSpeedEnabled = "alt-speed-enabled"
        case configDir = "config-dir"
        case peerLimitPerTorrent = "peer-limit-per-torrent"
        case downloadDir = "download-dir"
    }
}

/*

 Origin:
 Created by YggTorrent on Fri May 17 2024
 Date added:
 Fri May 17 2024
 */

struct Units {
    
    public let bytes: Int
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int.max:
            return "\(String(format: "%.2f", gigabytes)) GB"
        default:
            return "\(bytes) bytes"
        }
    }
}


struct Torrent:Codable {
    let addedDate: Date
    let downloadDir: String
    let error: Int
    let errorString: String
    let eta: Int
    let id: Int
    let name: String
    let percentDone: Double
    var status: Status
    let totalSize: Int
    let hashString: String
    let creator: String
    
    func sizeReadable() -> String {
        return Units(bytes: totalSize).getReadableUnit()
    }
    
    func etaReadable() -> String {
        var result = ""
        let h = eta / 3600
        if h > 0 { result = "\(h)h"}
        let m = (eta % 3600) / 60
        if m > 0 { result += "\(m)m"}
        let s = (eta % 3600) % 60
        if s > 0 { result += "\(s)s"}
        return result
    }
}

