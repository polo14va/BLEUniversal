//
//  PeripheralRow.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 5/4/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
import SwiftUI
import CoreBluetooth

struct PeripheralRow: View, Equatable {
    static func == (lhs: PeripheralRow, rhs: PeripheralRow) -> Bool {
        lhs.peripheral.id == rhs.peripheral.id && lhs.systemImage == rhs.systemImage
    }

    var peripheral: DiscoveredPeripheral
    var systemImage: String

    var body: some View {
        HStack {
            Text(peripheral.name.isEmpty ? "Unnamed Device" : peripheral.name)
            Spacer()
            Image(systemName: systemImage)
            Text("\(peripheral.rssi)")
        }
    }
}
