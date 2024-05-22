//
//  Item.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var url: URL
    var user: String
    var password: String
    
    init(url: URL = URL(string: "http://zerovalue.com:8090")!, user: String = "", password: String = "") {
        self.url = url
        self.user = user
        self.password = password
    }
}
