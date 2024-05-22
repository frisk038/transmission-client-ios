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
    let torrents: [Torrent]
}

struct Torrent:Codable {
    let addedDate: Date
    let downloadDir: String
    let error: Int
    let errorString: String
    let eta: Int
    let id: Int
    let name: String
    let percentComplete: Double
    let percentDone: Double
    var status: Status
}

