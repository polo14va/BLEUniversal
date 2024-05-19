// OTAUpdateService.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 1/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.

import Foundation
import CoreBluetooth


class OTAUpdateService {
    private unowned var peripheral: CBPeripheral
    private var rxCharacteristic: CBCharacteristic?
    private var txCharacteristic: CBCharacteristic?
    private var firmwareData: Data
    private var bleManager: BLEManager

    var otaManager: OTAManager?

    weak var delegate: OTAUpdateServiceDelegate?

    var txCharacteristicUUID = "fb1e4003-54ae-4a28-9f74-dfccb248601d"
    var rxCharacteristicUUID = "fb1e4002-54ae-4a28-9f74-dfccb248601d"

    init(peripheral: CBPeripheral, rxCharacteristic: CBCharacteristic?, txCharacteristic: CBCharacteristic?, firmwareData: Data, delegate: OTAUpdateServiceDelegate?, bleManager: BLEManager) {
        self.peripheral = peripheral
        self.rxCharacteristic = rxCharacteristic
        self.txCharacteristic = txCharacteristic
        self.firmwareData = firmwareData
        self.delegate = delegate
        self.bleManager = bleManager

        if let rxCharacteristic = rxCharacteristic, let txCharacteristic = txCharacteristic {
            self.otaManager = OTAManager(peripheral: peripheral, rxCharacteristic: rxCharacteristic, txCharacteristic: txCharacteristic, firmwareData: firmwareData, delegate: delegate, bleManager: bleManager)
        }
    }

    func startUpdate() {
        guard let otaManager = otaManager else {
            print("OTA Manager not initialized")
            delegate?.otaUpdateFailed(error: "OTA Manager not initialized")
            return
        }

        guard let txCharacteristic = txCharacteristic else {
            print("TX Characteristic not found")
            delegate?.otaUpdateFailed(error: "TX Characteristic not found")
            return
        }

        peripheral.setNotifyValue(true, for: txCharacteristic)
        otaManager.startUpdate()
    }

    func handleUpdatedValue(for characteristic: CBCharacteristic, error: Error?, in peripherals: inout [DiscoveredPeripheral], delegate: BLEPeripheralDelegate?) {
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
        }

        // Actualizar la lista de periféricos descubiertos
        if let peripheral = characteristic.service?.peripheral,
           let peripheralIndex = peripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }),
           let serviceIndex = peripherals[peripheralIndex].services.firstIndex(where: { $0.service.uuid == characteristic.service?.uuid }),
           let charIndex = peripherals[peripheralIndex].services[serviceIndex].characteristics.firstIndex(where: { $0.characteristic.uuid == characteristic.uuid }) {

            peripherals[peripheralIndex].services[serviceIndex].characteristics[charIndex].latestValue = value

            if let valueString = String(data: value, encoding: .utf8) {
                print("Value for characteristic \(characteristic.uuid) is now: \(valueString)")
            } else {
                let hexString = value.map { String(format: "%02hhx", $0) }.joined()
                print("Value for characteristic \(characteristic.uuid) in hex: \(hexString)")
            }
        } else {
            print("Characteristic \(characteristic.uuid) not found in discovered peripherals.")
        }

        // Notificar al delegado
        if let peripheral = characteristic.service?.peripheral {
            DispatchQueue.main.async {
                delegate?.didUpdateValueForCharacteristic(value, characteristic: characteristic, peripheral: peripheral, error: nil)
            }
        } else {
            print("No peripheral associated with characteristic \(characteristic.uuid).")
        }
    }
}
