// BLEManager.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 15/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import SwiftUI

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager()
    
    @Published var navigationStack: [NavigationItem] = []
    @Published var selectedNavigationItem: NavigationItem = .none
    
    private var centralManager: CBCentralManager!
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var errorMessage: String? = nil
    @Published var navigationPath = NavigationPath()
    
    weak var delegate: BLEPeripheralDelegate?
    
    var otaManager: OTAManager?
    var discoveredPeripheralsPublisher = PassthroughSubject<DiscoveredPeripheral, Never>()
    
    private var characteristicReadCompletions: [CBUUID: (Result<Data, Error>) -> Void] = [:]
    private var characteristicWriteCompletions: [CBUUID: (Result<Void, Error>) -> Void] = [:]
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func push(_ item: NavigationItem) {
        DispatchQueue.main.async {
            self.navigationStack.append(item)
            self.selectedNavigationItem = item
        }
    }
    
    func pop() {
        DispatchQueue.main.async {
            if !self.navigationStack.isEmpty {
                self.navigationStack.removeLast()
            }
            self.selectedNavigationItem = self.navigationStack.last ?? .none
        }
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on")
            return
        }
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Starting scan for peripherals.")
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
        print("Scanning stopped.")
    }
    
    func navigateToMainView() {
        DispatchQueue.main.async {
            self.navigationStack = []
            self.selectedNavigationItem = .none
        }
    }

    func disconnectCurrentDevice() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        }
    }
    
    func connectToDevice(_ peripheral: DiscoveredPeripheral) {
        guard let foundPeripheral = discoveredPeripherals.first(where: { $0.id == peripheral.id })?.peripheral else {
            print("Peripheral not found in discovered list.")
            return
        }
        print("Connecting to device: \(foundPeripheral.name ?? "unknown")")
        centralManager.connect(foundPeripheral, options: nil)
        connectedPeripheral = foundPeripheral
    }
    
    func disconnectDevice(_ peripheral: DiscoveredPeripheral) {
        guard let foundPeripheral = discoveredPeripherals.first(where: { $0.id == peripheral.id })?.peripheral else {
            print("Device not found in discovered list.")
            return
        }
        print("Disconnecting device: \(foundPeripheral.name ?? "unknown")")
        centralManager.cancelPeripheralConnection(foundPeripheral)
        if connectedPeripheral == foundPeripheral {
            connectedPeripheral = nil
            isConnected = false
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on and ready.")
            delegate?.didUpdateBluetoothState(isOn: true)
            startScanning()
        case .poweredOff:
            print("Bluetooth is powered off.")
            delegate?.didUpdateBluetoothState(isOn: false)
            errorMessage = "Bluetooth is powered off. Please enable it to use this app."
            stopScanning()
        default:
            print("Bluetooth state is \(central.state.rawValue)")
            delegate?.didUpdateBluetoothState(isOn: false)
            errorMessage = "Bluetooth is not available."
            stopScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
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
        
        if let otaManager = otaManager {
            peripheral.delegate = otaManager
            peripheral.discoverServices(nil)  // Descubrir servicios después de conectar
        } else {
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
        
        delegate?.didConnectPeripheral(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "unknown")")
        errorMessage = "Failed to connect to \(peripheral.name ?? "unknown"): \(error?.localizedDescription ?? "Unknown error")"
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
        if let error = error {
            print("Error updating value for characteristic \(characteristic.uuid): \(error.localizedDescription)")
            characteristicReadCompletions[characteristic.uuid]?(.failure(error))
            characteristicReadCompletions.removeValue(forKey: characteristic.uuid)
            return
        }

        guard let value = characteristic.value else {
            print("No data received for characteristic \(characteristic.uuid).")
            let error = BluetoothError.unableToReadCharacteristic
            characteristicReadCompletions[characteristic.uuid]?(.failure(error))
            characteristicReadCompletions.removeValue(forKey: characteristic.uuid)
            return
        }

        characteristicReadCompletions[characteristic.uuid]?(.success(value))
        characteristicReadCompletions.removeValue(forKey: characteristic.uuid)

        if let peripheralIndex = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }),
           let serviceIndex = discoveredPeripherals[peripheralIndex].services.firstIndex(where: { $0.service.uuid == characteristic.service?.uuid }),
           let charIndex = discoveredPeripherals[peripheralIndex].services[serviceIndex].characteristics.firstIndex(where: { $0.characteristic.uuid == characteristic.uuid }) {
            
            discoveredPeripherals[peripheralIndex].services[serviceIndex].characteristics[charIndex].latestValue = value
            
            if let valueString = String(data: value, encoding: .utf8) {
                print("Value for characteristic \(characteristic.uuid) is now: \(valueString)")
            } else {
                let hexString = value.map { String(format: "%02hhx", $0) }.joined()
                print("Value for characteristic \(characteristic.uuid) in hex: \(hexString)")
            }
        } else {
            print("Characteristic \(characteristic.uuid) not found in discovered peripherals.")
        }

        delegate?.didUpdateValueForCharacteristic(value, characteristic: characteristic, peripheral: peripheral, error: nil)

        if characteristic.uuid.uuidString.lowercased() == otaManager?.txCharacteristic.uuid.uuidString.lowercased() {
            otaManager?.processReceivedData(value)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value for characteristic \(characteristic.uuid): \(error.localizedDescription)")
            characteristicWriteCompletions[characteristic.uuid]?(.failure(error))
            characteristicWriteCompletions.removeValue(forKey: characteristic.uuid)
            return
        }
        
        characteristicWriteCompletions[characteristic.uuid]?(.success(()))
        characteristicWriteCompletions.removeValue(forKey: characteristic.uuid)
    }

    func readRSSI(for peripheral: CBPeripheral) {
        peripheral.readRSSI()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        print("Read RSSI \(RSSI) for \(peripheral.name ?? "unknown")")
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredPeripherals[index].rssi = RSSI.intValue
            delegate?.didUpdateRSSI(RSSI.intValue, for: peripheral)
        }
    }
    
    // Utility function to find peripheral by ID
    func findPeripheral(by id: String) -> DiscoveredPeripheral? {
        return discoveredPeripherals.first { $0.id == id }
    }
    
    // Utility function to find a characteristic in any discovered peripheral
    func findCharacteristic(by uuid: CBUUID) -> SimpleCharacteristic? {
        for discoveredPeripheral in discoveredPeripherals {
            for service in discoveredPeripheral.services {
                if let characteristic = service.characteristics.first(where: { $0.characteristic.uuid == uuid }) {
                    return characteristic
                }
            }
        }
        return nil
    }
    
    // Utility function to return the service name by UUID
    func serviceName(for uuid: CBUUID) -> String {
        return ServiceNames.shared.name(for: uuid)
    }
    
    func readCharacteristic(_ characteristic: SimpleCharacteristic, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let peripheral = connectedPeripheral else {
            completion(.failure(BluetoothError.peripheralDisconnected))
            return
        }
        
        guard characteristic.characteristic.properties.contains(.read) else {
            completion(.failure(BluetoothError.unableToReadCharacteristic))
            return
        }
        
        characteristicReadCompletions[characteristic.characteristic.uuid] = completion
        peripheral.readValue(for: characteristic.characteristic)
    }

    func writeCharacteristic(_ characteristic: SimpleCharacteristic, data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let peripheral = connectedPeripheral else {
            completion(.failure(BluetoothError.peripheralDisconnected))
            return
        }
        
        guard characteristic.characteristic.properties.contains(.write) || characteristic.characteristic.properties.contains(.writeWithoutResponse) else {
            completion(.failure(BluetoothError.unableToWriteCharacteristic))
            return
        }
        
        let type: CBCharacteristicWriteType = characteristic.characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
        characteristicWriteCompletions[characteristic.characteristic.uuid] = completion
        peripheral.writeValue(data, for: characteristic.characteristic, type: type)
    }
}


extension CBPeripheral {
    var isDiscoveringServices: Bool {
        return services?.isEmpty ?? true
    }
    
    func pauseServiceDiscovery() {
        // Implementar lógica para pausar la detección de servicios si es necesario
        print("Service discovery paused")
    }
    
    func resumeServiceDiscovery() {
        // Implementar lógica para reanudar la detección de servicios si es necesario
        print("Service discovery resumed")
    }
}
