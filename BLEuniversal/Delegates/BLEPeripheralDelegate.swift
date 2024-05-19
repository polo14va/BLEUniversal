//
//  BLEPeripheralDelegate.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 15/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEPeripheralDelegate: AnyObject {
    func didUpdateBluetoothState(isOn: Bool)
    func didDiscoverPeripheral(_ peripheral: DiscoveredPeripheral)
    func didConnectPeripheral(_ peripheral: CBPeripheral)
    func didDisconnectPeripheral(_ peripheral: CBPeripheral)
    func didDiscoverServices(_ services: [CBService], for peripheral: CBPeripheral)
    func didDiscoverCharacteristics(_ characteristics: [CBCharacteristic], for service: CBService, peripheral: CBPeripheral)
    func didUpdateValueForCharacteristic(_ data: Data?, characteristic: CBCharacteristic, peripheral: CBPeripheral, error: Error?)
    func didUpdateRSSI(_ RSSI: Int, for peripheral: CBPeripheral)
}
