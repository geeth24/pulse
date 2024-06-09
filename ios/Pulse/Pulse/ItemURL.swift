//
//  ItemURL.swift
//  Pulse
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import Foundation
import SwiftData

@Model
final class ItemURL {
    var url: String?
    
    init(url: String) {
        self.url = url
    }
}
