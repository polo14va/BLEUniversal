//
//  Item.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 8/2/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
