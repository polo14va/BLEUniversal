//
//  DiscoveredPeripheral.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 9/2/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import CoreBluetooth

class DiscoveredPeripheral: Identifiable, Hashable {
    let id: String
    var name: String
    var rssi: Int
    let peripheral: CBPeripheral
    let isConnectable: Bool
    var data: PeripheralData?
    var services: [SimpleService] = []
    var genericFileReadService: CBService?

    init(
        id: String,
        name: String,
        rssi: Int,
        isConnectable: Bool,
        peripheral: CBPeripheral,
        data: PeripheralData? = nil
    ) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.isConnectable = isConnectable
        self.peripheral = peripheral
        self.data = data
    }

    static func == (lhs: DiscoveredPeripheral, rhs: DiscoveredPeripheral) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


