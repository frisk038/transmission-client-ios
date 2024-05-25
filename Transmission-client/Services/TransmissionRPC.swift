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
    var activity: Activity<TransmissionProgressAttributes>? = nil
    
    var config: Item
    
    /*
    func getBasicAuth() -> String {
        if config.user.isEmpty || config.password.isEmpty { return "" }
        let passwordData = "\(config.user):\(config.password)".data(using:String.Encoding.utf8)!
        let base64EncodedCredential = passwordData.base64EncodedString()
        let authString = "Basic \(base64EncodedCredential)"
        
    }
    */
    
    func storeSessionID() {
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: url){ data, response, error in
            guard let resp = response as? HTTPURLResponse else { return }
            if resp.statusCode == 409, let sessionId = resp.allHeaderFields["X-Transmission-Session-Id"] as? String {
                self.sessionID = sessionId
            }
        }
        task.resume()
    }
    
    func fetchTorrentList() {
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
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
            self?.updateActivity()
        }
    }
    
    func stopFetchingTorrentList() {
            timer?.invalidate()
            timer = nil
    }
    
    func stopAllTorrent() {
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
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
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
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
        
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
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
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
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
        guard let url = URL(string: "\(config.url)/transmission/rpc") else { return }
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
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
    
    func updateConfig(config:Item) {
        stopFetchingTorrentList()
    
        context.delete(self.config)
        self.config = config
        context.insert(self.config)
    
        startFetchingTorrentList()
    }

    func updateActivity() {
        guard let activity = self.activity else { return }
        guard let torrentIndex = torrentList.firstIndex(where: { $0.id == activity.attributes.id }) else { return }
        let torrent = torrentList[torrentIndex]
        let contentState = TransmissionProgressAttributes.ContentState(progression: torrent.percentDone, state: torrent.status.rawValue, eta: torrent.eta)
        
        Task {
            await activity.update(
                ActivityContent<TransmissionProgressAttributes.ContentState>(
                    state: contentState,
                    staleDate: Date.now + 15,
                    relevanceScore: 50
                ),
                alertConfiguration: nil
            )
        }
    }
    
    func startActivity(torrentID: Int) {
        guard let torrentIndex = torrentList.firstIndex(where: { $0.id == torrentID }) else { return }
        var torrent = torrentList[torrentIndex]
        
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let tp = TransmissionProgressAttributes(name: torrent.name, id: torrentID)
                let initialState = TransmissionProgressAttributes.ContentState(progression: torrent.percentComplete, state: torrent.status.rawValue, eta: torrent.eta)
                
                let activity = try Activity.request(
                    attributes: tp,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: nil
                )
                self.activity = activity
            } catch {
                fatalError("can't launch activity \(error)")
            }
        }
    }
    
    func stopActivity(){
        guard let activity = self.activity else { return }
        guard let torrentIndex = torrentList.firstIndex(where: { $0.id == activity.attributes.id }) else { return }
        var torrent = torrentList[torrentIndex]
        let finalContent = TransmissionProgressAttributes.ContentState(progression: torrent.percentDone, state: torrent.status.rawValue, eta: torrent.eta)
        
        Task {
            await activity.end(ActivityContent(state: finalContent, staleDate: nil), dismissalPolicy: .immediate)
        }
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
