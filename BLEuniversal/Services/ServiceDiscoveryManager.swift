//
//  ServiceDiscoveryManager.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 11/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import CoreBluetooth

class ServiceDiscoveryManager: NSObject, CBPeripheralDelegate {
    func discoverServices(for peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("Error discovering services: \(String(describing: error))")
            return
        }
//        print("Discovered services for \(peripheral.name ?? "a device").")
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        guard service.characteristics != nil else {
            print("No characteristics found for service \(service.uuid)")
            return
        }
        print("Discovered characteristics for service \(service.uuid).")
    }
}
