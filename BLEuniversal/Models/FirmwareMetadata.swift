//
//  FirmwareMetadata.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 1/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

struct FirmwareMetadata: Codable {
    let checksum: UInt32
    let totalLotes: Int
    let firmwareSize: Int
}
