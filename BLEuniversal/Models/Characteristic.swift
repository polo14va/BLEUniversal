//
//  Characteristic.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 15/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Characteristic {
    var characteristic: CBCharacteristic
    var latestValue: Data?
}
