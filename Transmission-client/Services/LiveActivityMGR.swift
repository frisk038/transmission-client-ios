//
//  LiveActivityMGR.swift
//  Transmission-client
//
//  Created by Olivier on 26/05/2024.
//

import Foundation
import ActivityKit

class LiveActivityMGR {
    private var activity: Activity<TransmissionProgressAttributes>? = nil
    private var timer: Timer? = nil
    private var api: TransmissionRPC
    private var updateTime:TimeInterval
    
    func startUpdatingActivity() {
        stopUpdatingActivity()
        
        timer = Timer.scheduledTimer(withTimeInterval: updateTime, repeats: true) { [weak self] _ in
            self?.updateActivity()
        }
    }

    func stopUpdatingActivity() {
            timer?.invalidate()
            timer = nil
    }
    
    func startActivity(torrentID: Int) {
        if activity != nil {
            stopActivity(policy: .immediate)
        }
        
        guard let torrentIndex = api.torrentList.firstIndex(where: { $0.id == torrentID }) else { return }
        let torrent = api.torrentList[torrentIndex]
        
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let tp = TransmissionProgressAttributes(name: torrent.name, id: torrentID)
                let initialState = TransmissionProgressAttributes.ContentState(progression: torrent.percentDone, state: torrent.status.rawValue, eta: torrent.eta)
                
                let activity = try Activity.request(
                    attributes: tp,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: nil
                )
                self.activity = activity
                startUpdatingActivity()
            } catch {
                fatalError("can't launch activity \(error)")
            }
        }
    }
    
    func updateActivity() {
        guard let activity = self.activity else { return }
        guard let torrentIndex = api.torrentList.firstIndex(where: { $0.id == activity.attributes.id }) else { return }
        let torrent = api.torrentList[torrentIndex]
        let contentState = TransmissionProgressAttributes.ContentState(progression: torrent.percentDone, state: torrent.status.rawValue, eta: torrent.eta)
        
        if activity.content.state.progression == 1 {
            stopActivity(policy: .after(Date.now.addingTimeInterval(60)))
        }
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
    
    func stopActivity(policy: ActivityUIDismissalPolicy){
        guard let activity = self.activity else { return }
        guard let torrentIndex = api.torrentList.firstIndex(where: { $0.id == activity.attributes.id }) else { return }
        let torrent = api.torrentList[torrentIndex]
        
        stopUpdatingActivity()
        let finalContent = TransmissionProgressAttributes.ContentState(progression: torrent.percentDone, state: torrent.status.rawValue, eta: torrent.eta)
        
        Task {
            await activity.end(ActivityContent(state: finalContent, staleDate: nil), dismissalPolicy: policy)
            self.activity = nil
        }
    }
    
    func isRunnning() -> Bool {
        return activity != nil
    }

    init(api: TransmissionRPC, updateTime: TimeInterval) {
        self.api = api
        self.updateTime = updateTime
    }
}
