//
//  SimpleCharacteristic.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 2/3/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
import Foundation
import CoreBluetooth

struct SimpleCharacteristic: Identifiable, Hashable {
    let id: String
    let characteristic: CBCharacteristic
    var descriptors: [CBDescriptor]? = nil
    var latestValue: Data? 

    init(characteristic: CBCharacteristic) {
        self.id = characteristic.uuid.uuidString
        self.characteristic = characteristic
    }
}
