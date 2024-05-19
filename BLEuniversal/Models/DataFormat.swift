//
//  DataFormat.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 19/3/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

enum DataFormat: String, CaseIterable, Identifiable {
    case string = "ASCII"
    case hex = "Hex"
    case binary = "Binary"
    case decimal = "Decimal"

    var id: String { self.rawValue }
}
