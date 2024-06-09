//
//  Item.swift
//  Pulse
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import Foundation


struct Item: Encodable, Decodable, Hashable {
    var name: String
    var price: String
    var availability: String
    var url: String
}

struct MultipleURLRequestBody: Codable {
    let urls: [String]
}

