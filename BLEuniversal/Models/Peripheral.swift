//
//  Peripheral.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 15/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Peripheral {
    var peripheral: CBPeripheral
    var services: [Service]
}
