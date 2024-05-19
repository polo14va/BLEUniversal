//
//  BluetoothDelegate.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 11/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import CoreBluetooth

protocol BluetoothDelegate: AnyObject {
    func didDiscoverPeripheral(_ peripheral: DiscoveredPeripheral)
    func didUpdateConnectionState(isConnected: Bool)
    func didDiscoverServices(_ services: [CBService], forPeripheral peripheral: CBPeripheral)
    func didUpdateServiceWithCharacteristics(forPeripheral peripheral: CBPeripheral, service: CBService, characteristics: [CBCharacteristic])
}
