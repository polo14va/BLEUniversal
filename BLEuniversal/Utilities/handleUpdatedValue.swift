// handleUpdatedValue.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 15/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CharacteristicUpdateDelegate: AnyObject {
    func didUpdateValueForCharacteristic(_ data: Data?, characteristic: CBCharacteristic, peripheral: CBPeripheral, error: Error?)
}

func handleUpdatedValue(for characteristic: CBCharacteristic, error: Error?, in peripherals: inout [DiscoveredPeripheral], delegate: CharacteristicUpdateDelegate?, txCharacteristicUUID: String, otaManager: OTAManager?) {
    if let error = error {
        print("Error updating value for characteristic \(characteristic.uuid): \(error.localizedDescription)")
        return
    }

    guard let value = characteristic.value else {
        print("No data received for characteristic \(characteristic.uuid).")
        return
    }

    if characteristic.uuid.uuidString.lowercased() == txCharacteristicUUID.lowercased() {
        otaManager?.processReceivedData(value)
    } else {
        if let peripheral = characteristic.service?.peripheral,
           let peripheralIndex = peripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }),
           let serviceIndex = peripherals[peripheralIndex].services.firstIndex(where: { $0.service.uuid == characteristic.service?.uuid }),
           let charIndex = peripherals[peripheralIndex].services[serviceIndex].characteristics.firstIndex(where: { $0.characteristic.uuid == characteristic.uuid }) {

            peripherals[peripheralIndex].services[serviceIndex].characteristics[charIndex].latestValue = value

            let valueString = value.toUtf8String()
            let hexString = value.toHex()
            print("Value for characteristic \(characteristic.uuid) is now: \(valueString) (Hex: \(hexString))")
        } else {
            print("Characteristic \(characteristic.uuid) not found in discovered peripherals.")
        }

        if let peripheral = characteristic.service?.peripheral {
            DispatchQueue.main.async {
                delegate?.didUpdateValueForCharacteristic(value, characteristic: characteristic, peripheral: peripheral, error: nil)
            }
        } else {
            print("No peripheral associated with characteristic \(characteristic.uuid).")
        }
    }
}
