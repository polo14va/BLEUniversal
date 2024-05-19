//
//  PeripheralData.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 9/2/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
struct PeripheralData {
    var int: Int
    var float: Float
    var bool: Bool
    var string: String

    init(int: Int, float: Float, bool: Bool, string: String) {
        self.int = int
        self.float = float
        self.bool = bool
        self.string = string
    }
}
