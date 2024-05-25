//
//  TorrentProgressAttribute.swift
//  Transmission-client
//
//  Created by Olivier on 25/05/2024.
//

import ActivityKit

struct TransmissionProgressAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var progression: Double
        var state: Int
        var eta: Int
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    var id: Int
}
