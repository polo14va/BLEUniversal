//
//  SimpleService.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 11/2/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
import Foundation
import CoreBluetooth

struct SimpleService: Identifiable, Hashable {
    var id: String { service.uuid.uuidString }
    let service: CBService
    var characteristics: [SimpleCharacteristic] = []
    var characteristicsCount: Int { characteristics.count }
    var allowsNotifications: Bool {
        characteristics.contains { $0.characteristic.properties.contains(.notify) }
    }
    
    
    init(service: CBService) {
        self.service = service
    }
}
