//
//  Item.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import Foundation
import SwiftData

enum FetchSpeed: Double, Codable, CaseIterable {
    case slow = 5.0
    case normal = 2.5
    case fast = 1.0
}

@Model
final class Item {
    var url: URL
    var port: Int
    var user: String
    var password: String
    var speed: FetchSpeed

    init(url: URL = URL(fileURLWithPath: ""), user: String = "", password: String = "", speed: FetchSpeed = .normal, port: Int = 9091) {
        self.url = url
        self.user = user
        self.password = password
        self.speed = speed
        self.port = port
    }
}
