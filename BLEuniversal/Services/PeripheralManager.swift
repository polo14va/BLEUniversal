// PeripheralManager.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 11/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.

import Foundation
import CoreBluetooth
import Combine

class PeripheralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = PeripheralManager()
    
    private var centralManager: CBCentralManager!
    var discoveredPeripherals = [DiscoveredPeripheral]()
    weak var delegate: BLEPeripheralDelegate?
    var discoveredPeripheralsPublisher = PassthroughSubject<DiscoveredPeripheral, Never>()
    var otaUpdateService: OTAUpdateService?
    
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isConnected = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on")
            return
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Starting scan for peripherals.")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        print("Scanning stopped.")
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        if connectedPeripheral != peripheral {
            print("Connecting to device: \(peripheral.name ?? "unknown")")
            centralManager.connect(peripheral, options: nil)
            connectedPeripheral = peripheral
        }
    }

    func disconnectDevice(_ peripheral: CBPeripheral) {
        print("Disconnecting device: \(peripheral.name ?? "unknown")")
        centralManager.cancelPeripheralConnection(peripheral)
        if connectedPeripheral == peripheral {
            connectedPeripheral = nil
            isConnected = false
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on and ready.")
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .resetting:
            print("The Bluetooth connection is resetting.")
        case .unauthorized:
            print("Bluetooth usage is unauthorized.")
        case .unsupported:
            print("Bluetooth is not supported on this device.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            print("A new, unknown state of Bluetooth.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let discoveredPeripheral = DiscoveredPeripheral(
            id: peripheral.identifier.uuidString,
            name: peripheral.name ?? "Unknown",
            rssi: RSSI.intValue,
            isConnectable: advertisementData[CBAdvertisementDataIsConnectable] as? Bool ?? false,
            peripheral: peripheral
        )
        if !discoveredPeripherals.contains(where: { $0.id == discoveredPeripheral.id }) {
            discoveredPeripherals.append(discoveredPeripheral)
            discoveredPeripheralsPublisher.send(discoveredPeripheral)
            delegate?.didDiscoverPeripheral(discoveredPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "unknown")")
        isConnected = true
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        delegate?.didConnectPeripheral(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "unknown")")
        if peripheral == connectedPeripheral {
            isConnected = false
            connectedPeripheral = nil
        }
        delegate?.didDisconnectPeripheral(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("Error discovering services: \(String(describing: error))")
            return
        }

        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredPeripherals[index].services = services.map { SimpleService(service: $0) }
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered \(services.count) services for \(peripheral.name ?? "unknown")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for \(service.uuid)")
            return
        }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                print("Subscribing to notifications for \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }),
               let serviceIndex = discoveredPeripherals[index].services.firstIndex(where: { $0.service.uuid == service.uuid }) {
                discoveredPeripherals[index].services[serviceIndex].characteristics.append(SimpleCharacteristic(characteristic: characteristic))
            }
        }
        
        print("Discovered \(characteristics.count) characteristics for service \(service.uuid) on \(peripheral.name ?? "unknown")")
        DispatchQueue.main.async {
            self.delegate?.didDiscoverCharacteristics(characteristics, for: service, peripheral: peripheral)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        handleUpdatedValue(
            for: characteristic,
            error: error,
            in: &self.discoveredPeripherals,
            delegate: self.delegate as? CharacteristicUpdateDelegate,
            txCharacteristicUUID: self.otaUpdateService?.txCharacteristicUUID ?? "",
            otaManager: self.otaUpdateService?.otaManager
        )
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }
        print("Notification state changed for \(characteristic.uuid)")
    }
}

