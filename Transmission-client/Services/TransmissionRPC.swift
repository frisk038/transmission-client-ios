//
//  TransmissionRPC.swift
//  Transmission-client
//
//  Created by Olivier on 19/05/2024.
//

import Foundation
import SwiftData
import ActivityKit

@Observable
class TransmissionRPC {    
    private var sessionID:String = ""
    private var timer: Timer? = nil
    private(set) var torrentList:[Torrent] = []
    private var container: ModelContainer
    private var context: ModelContext
    
    var config: Item

    func getURLRequest() -> URLRequest? {
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return nil }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
        if !config.user.isEmpty && !config.password.isEmpty {
            let passwordData = "\(config.user):\(config.password)".data(using:String.Encoding.utf8)!
            request.addValue("Basic \(passwordData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func storeSessionID() {
        guard var request = getURLRequest() else { return }
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409, let sessionId = resp.allHeaderFields["X-Transmission-Session-Id"] as? String {
                self.sessionID = sessionId
            }
        }
        task.resume()
    }
    
    func fetchTorrentList() {
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
           "arguments": {
             "fields": [
               "addedDate",
               "downloadDir",
               "error",
               "errorString",
               "eta",
               "id",
               "percentDone",
               "percentComplete",
               "name",
               "status"
               
             ]
           },
           "method": "torrent-get"
        }
        """.data(using: .utf8)
                
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            if let jsonData = data {
                let apiResp = try? JSONDecoder().decode(ApiResponse.self, from: jsonData)
                self.torrentList = apiResp?.arguments.torrents ?? []
                self.torrentList = self.torrentList.map { torrent in
                    var modifiedTorrent = torrent
                    if modifiedTorrent.error != 0 || !modifiedTorrent.errorString.isEmpty {
                        modifiedTorrent.status = .Error
                    }
                    return modifiedTorrent
                }
            }
        }
        task.resume()
    }
    
    func startFetchingTorrentList() {
        if sessionID.isEmpty {
            storeSessionID()
        }
        // Ensure the timer is invalidated if already running
        stopFetchingTorrentList()
        
        timer = Timer.scheduledTimer(withTimeInterval: config.speed.rawValue, repeats: true) { [weak self] _ in
            self?.fetchTorrentList()
        }
    }
    
    func stopFetchingTorrentList() {
            timer?.invalidate()
            timer = nil
    }
    
    func stopAllTorrent() {
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
           "method": "torrent-stop"
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            if let jsonData = data {
                let apiResp = try? JSONDecoder().decode(ApiResponse.self, from: jsonData)
                print(jsonData.description)
            }
        }
        task.resume()
    }
    
    func startAllTorrent() {
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
           "method": "torrent-start"
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            if let jsonData = data {
                let apiResp = try? JSONDecoder().decode(ApiResponse.self, from: jsonData)
                print(jsonData)
            }
        }
        task.resume()
    }
    
    func cleanAllTorrent() {
        var ids:[Int] = []
        for t in self.torrentList {
            if t.status == .Error || t.status == .Seed {
                ids.append(t.id)
            }
        }
        
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
            "arguments": {
               "ids": \(ids)
            },
           "method": "torrent-remove"
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            if let jsonData = data {
                let apiResp = try? JSONDecoder().decode(ApiResponse.self, from: jsonData)
                print(jsonData.description)
            }
        }
        task.resume()
        
    }
    
    func stopTorrent(torrentID:Int) {
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
           "method": "torrent-stop",
           "arguments": {
             "ids": \([torrentID])
           }
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            if let jsonData = data {
                let apiResp = try? JSONDecoder().decode(ApiResponse.self, from: jsonData)
                print(jsonData.description)
            }
        }
        task.resume()
    }
    
    func startTorrent(torrentID:Int) {
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
           "method": "torrent-start",
           "arguments": {
             "ids": \([torrentID])
           }
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            if let jsonData = data {
                let apiResp = try? JSONDecoder().decode(ApiResponse.self, from: jsonData)
                print(jsonData.description)
            }
        }
        task.resume()
    }
    
    private func getFileB64(path fileUrl: URL) -> String? {
        if fileUrl.startAccessingSecurityScopedResource() {
            defer { fileUrl.stopAccessingSecurityScopedResource() }
            
            /*
             fetching file if missing locally
            var error: NSError?
            NSFileCoordinator().coordinate(readingItemAt: fileUrl, options: .forUploading, error: &error) { url in
                print("coordinated URL", url)
                do {
                    let resources = try fileUrl.resourceValues(forKeys:[.fileSizeKey])
                    let fileSize = resources.fileSize!
                    print ("File Size is \(fileSize)")
                } catch {
                    print("Error: \(error)")
                }
            }
             */
            
            do {
                let inputData = try Data(contentsOf: fileUrl)
                return inputData.base64EncodedString()
            } catch {
                print("Error reading file content: \(error)")
            }
        }
        
        return nil
    }
    
    func addTorrent(path: URL, savePath:String) {
        guard let fileData = getFileB64(path: path) else { return }
        guard var request = getURLRequest() else { return }
        request.httpBody = """
        {
           "method": "torrent-add",
           "arguments": {
             "metainfo": "\(fileData)",
             "download-dir": "\(savePath)"
           }
        }
        """.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409 { // get session id
                self.storeSessionID()
            }

            /*if let jsonData = data {
                do {
                    print(String(data: data!, encoding: .utf8) ?? "default value")
                    let apiResp = try JSONDecoder().decode(ApiResponse.self, from: jsonData)
                    print(String(data: data!, encoding: .utf8) ?? "default value")
                } catch {
                    print(error)
                }
            }
             */
        }
        task.resume()
    }

    init(mct: ModelContainer) {
        container = mct
        context = ModelContext(mct)
        config = Item()
        
        do {
            let items = try context.fetch(FetchDescriptor<Item>())
            if !items.isEmpty {
                print("api conf not empty", items.first!.url)
                config = items.first!
            } else {
                context.insert(config)
                print("api conf empty", config.url)
            }
        } catch {
            fatalError("can't store config \(error)")
        }
    }
}
