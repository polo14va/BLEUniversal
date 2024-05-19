// OTAManager.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 15/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.
//
import Foundation
import CoreBluetooth

class OTAManager: NSObject {
    private var currentOffset = 0
    private let chunkSize = 16000
    private let mtu = 500
    private var firmwareData: Data
    private var rxCharacteristic: CBCharacteristic
    var txCharacteristic: CBCharacteristic
    private var peripheral: CBPeripheral
    private weak var delegate: OTAUpdateServiceDelegate?
    
    private var totalChunks: Int = 0
    private var chunksSent: Int = 0
    private var isCancelled: Bool = false
    var bleManager: BLEManager
    
    var txCharacteristicUUID: String {
        return txCharacteristic.uuid.uuidString
    }
    
    init(peripheral: CBPeripheral, rxCharacteristic: CBCharacteristic, txCharacteristic: CBCharacteristic, firmwareData: Data, delegate: OTAUpdateServiceDelegate?, bleManager: BLEManager) {
        self.peripheral = peripheral
        self.rxCharacteristic = rxCharacteristic
        self.txCharacteristic = txCharacteristic
        self.firmwareData = firmwareData
        self.delegate = delegate
        self.bleManager = bleManager
        super.init()
        self.peripheral.delegate = self
        totalChunks = (firmwareData.count + chunkSize - 1) / chunkSize
    }
    
    func startUpdate() {
        isCancelled = false
        sendOtaCommand(byte: 0xFD)
        sendFileSize()
        sendOtaInfo()
    }
    
    func cancelUpdate() {
        isCancelled = true
    }
    
    private func sendOtaCommand(byte: UInt8) {
        let data = Data([byte])
        peripheral.writeValue(data, for: rxCharacteristic, type: .withResponse)
    }
    
    private func sendFileSize() {
        let fileSize = firmwareData.count
        let data = Data([
            0xFE,
            UInt8((fileSize >> 24) & 0xFF),
            UInt8((fileSize >> 16) & 0xFF),
            UInt8((fileSize >> 8) & 0xFF),
            UInt8(fileSize & 0xFF)
        ])
        peripheral.writeValue(data, for: rxCharacteristic, type: .withResponse)
    }
    
    private func sendOtaInfo() {
        let totalParts = totalChunks
        let data = Data([
            0xFF,
            UInt8((totalParts >> 8) & 0xFF),
            UInt8(totalParts & 0xFF),
            UInt8((mtu >> 8) & 0xFF),
            UInt8(mtu & 0xFF)
        ])
        peripheral.writeValue(data, for: rxCharacteristic, type: .withResponse)
    }
    
    private func sendNextChunk() {
        guard !isCancelled else {
            print("OTA update cancelled.")
            return
        }
        
        if currentOffset < firmwareData.count {
            let endOffset = min(currentOffset + chunkSize, firmwareData.count)
            let chunk = firmwareData.subdata(in: currentOffset..<endOffset)
            let numberOfPackets = (endOffset - currentOffset + mtu - 1) / mtu
            
            for packetIndex in 0..<numberOfPackets {
                let packetStart = currentOffset + packetIndex * mtu
                let packetEnd = min(packetStart + mtu, endOffset)
                let packet = chunk.subdata(in: packetStart - currentOffset..<packetEnd - currentOffset)
                var command = Data([0xFB, UInt8(packetIndex)])
                command.append(packet)
                peripheral.writeValue(command, for: rxCharacteristic, type: .withResponse)
            }
            
            let chunkLength = endOffset - currentOffset
            let partIndex = currentOffset / chunkSize
            let fcCommand = Data([
                0xFC,
                UInt8((chunkLength >> 8) & 0xFF),
                UInt8(chunkLength & 0xFF),
                UInt8((partIndex >> 8) & 0xFF),
                UInt8(partIndex & 0xFF)
            ])
            peripheral.writeValue(fcCommand, for: rxCharacteristic, type: .withResponse)
            
            chunksSent += 1
            let progress = min(100.0, (Double(chunksSent) / Double(totalChunks)) * 100.0)
            print("Progress updated: \(progress)%")
            DispatchQueue.main.async {
                self.delegate?.otaUpdateProgress(Float(progress))
            }
            
            currentOffset += chunkSize
        } else {
            sendOtaCommand(byte: 0xF2)
        }
    }
    
    func processReceivedData(_ data: Data) {
        guard data.count > 0 else { return }
        
        let command = data[0]
        switch command {
        case 0xAA:
            let transferMode = data[1]
            print("Transfer mode:", transferMode)
            if transferMode == 1 {
                for _ in 0..<totalChunks {
                    sendNextChunk()
                }
            } else {
                sendNextChunk()
            }
        case 0xF1:
            let nextPart = Int(data[1]) * 256 + Int(data[2])
            currentOffset = nextPart * chunkSize
            print("Received command 0xF1, setting next part: \(nextPart)")
            sendNextChunk()
        case 0xF2:
            print("Installing firmware")
            delegate?.otaUpdateComplete()
        case 0x0F:
            let result = String(data: data[1...], encoding: .utf8) ?? "Unknown error"
            print("OTA result: ", result)
            if result.contains("Success") {
                delegate?.otaUpdateComplete()
            } else {
                delegate?.otaUpdateFailed(error: result)
            }
        default:
            print("Unexpected command received: \(command)")
        }
    }
}

extension OTAManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }

        guard let value = characteristic.value else {
            print("No data received for characteristic \(characteristic.uuid).")
            return
        }

        if characteristic.uuid.uuidString.lowercased() == txCharacteristic.uuid.uuidString.lowercased() {
            processReceivedData(value)
        } else {
            print("Unexpected characteristic UUID: \(characteristic.uuid.uuidString)")
        }
    }
}
