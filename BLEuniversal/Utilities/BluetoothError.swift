//
//  BluetoothError.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 19/3/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
import Foundation

enum BluetoothError: Error {
    case characteristicNotFound
    case unableToReadCharacteristic
    case unableToWriteCharacteristic
    case unknownError
    case peripheralDisconnected
    case bluetoothPermissionDenied
    case bluetoothPoweredOff
    case invalidDataFormat
    case localizedDescription
}

extension BluetoothError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .characteristicNotFound:
            return NSLocalizedString("The requested characteristic was not found.", comment: "")
        case .unableToReadCharacteristic:
            return NSLocalizedString("Unable to read the characteristic.", comment: "")
        case .unableToWriteCharacteristic:
            return NSLocalizedString("Unable to write the characteristic.", comment: "")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "")
        case .peripheralDisconnected:
            return NSLocalizedString("The Bluetooth peripheral got disconnected.", comment: "")
        case .bluetoothPermissionDenied:
            return NSLocalizedString("Bluetooth permission was denied.", comment: "")
        case .bluetoothPoweredOff:
            return NSLocalizedString("Bluetooth is powered off.", comment: "")
        case .invalidDataFormat:
            return NSLocalizedString("Invalid data format.", comment: "")
        case .localizedDescription:
            return NSLocalizedString("Value localizedDescription", comment: "")
        }
    }
}
