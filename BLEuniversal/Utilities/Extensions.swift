// Extensions.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 9/2/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.

import Foundation
import SwiftUI

extension String {
    // Convierte una cadena hexadecimal en Data
    func hexToData() -> Data {
        var data = Data()
        var temp = ""
        for (index, character) in self.enumerated() {
            temp.append(character)
            if index % 2 != 0 {
                if let byte = UInt8(temp, radix: 16) {
                    data.append(byte)
                }
                temp = ""
            }
        }
        return data
    }
    
    // Convierte una cadena binaria en Data
    func binaryToData() -> Data {
        var data = Data()
        let binaryStrings = self.split(separator: " ")
        for binaryString in binaryStrings {
            if let byte = UInt8(binaryString, radix: 2) {
                data.append(byte)
            }
        }
        return data
    }
    
    // Divide una cadena en partes de longitud específica
    func chunked(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [String]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(String(self[startIndex..<endIndex]))
            startIndex = endIndex
        }
        
        return results
    }
}

extension Data {
    // Convierte Data en una cadena hexadecimal
    func toHex() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }

    // Convierte Data en una cadena binaria
    func toBinary() -> String {
        return self.map { String($0, radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0) }.joined(separator: " ")
    }

    // Convierte Data en una cadena UTF-8
    func toUtf8String() -> String {
        return String(decoding: self, as: UTF8.self)
    }
}

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
