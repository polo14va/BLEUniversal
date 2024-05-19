//
//  ServiceNames.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 28/3/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import CoreBluetooth

struct ServiceNames {
    static let shared = ServiceNames()

    let mapping: [CBUUID: String] = [
        CBUUID(string: "1800"): "Generic Access",
        CBUUID(string: "1801"): "Generic Attribute",
        CBUUID(string: "1802"): "Immediate Alert",
        CBUUID(string: "1803"): "Link Loss",
        CBUUID(string: "1804"): "Tx Power",
        CBUUID(string: "1805"): "Current Time Service",
        CBUUID(string: "1806"): "Reference Time Update Service",
        CBUUID(string: "1807"): "Next DST Change Service",
        CBUUID(string: "1808"): "Glucose",
        CBUUID(string: "1809"): "Health Thermometer",
        CBUUID(string: "180A"): "Device Information",
        CBUUID(string: "180D"): "Heart Rate",
        CBUUID(string: "180E"): "Phone Alert Status Service",
        CBUUID(string: "180F"): "Battery Service",
        CBUUID(string: "1810"): "Blood Pressure",
        CBUUID(string: "1811"): "Alert Notification Service",
        CBUUID(string: "1812"): "Human Interface Device",
        CBUUID(string: "1813"): "Scan Parameters",
        CBUUID(string: "1814"): "Running Speed and Cadence",
        CBUUID(string: "1815"): "Automation IO",
        CBUUID(string: "1816"): "Cycling Speed and Cadence",
        CBUUID(string: "1818"): "Cycling Power",
        CBUUID(string: "1819"): "Location and Navigation",
        CBUUID(string: "181A"): "Environmental Sensing",
        CBUUID(string: "181B"): "Body Composition",
        CBUUID(string: "181C"): "User Data",
        CBUUID(string: "181D"): "Weight Scale",
        CBUUID(string: "181E"): "Bond Management",
        CBUUID(string: "181F"): "Continuous Glucose Monitoring",
        CBUUID(string: "1820"): "Internet Protocol Support",
        CBUUID(string: "1821"): "Indoor Positioning",
        CBUUID(string: "1822"): "Pulse Oximeter",
        CBUUID(string: "1823"): "HTTP Proxy",
        CBUUID(string: "1824"): "Transport Discovery",
        CBUUID(string: "1825"): "Object Transfer",
        CBUUID(string: "1826"): "Fitness Machine",
        CBUUID(string: "1827"): "Mesh Provisioning",
        CBUUID(string: "1828"): "Mesh Proxy",
        CBUUID(string: "1829"): "Reconnection Configuration",
        CBUUID(string: "182A"): "Insulin Delivery",
        CBUUID(string: "182B"): "Binary Sensor",
        CBUUID(string: "182C"): "Emergency Configuration",
        CBUUID(string: "182D"): "Physical Activity Monitor",
        CBUUID(string: "182E"): "Audio Input Control",
        CBUUID(string: "182F"): "Volume Control",
        CBUUID(string: "183A"): "Volume Offset Control Service",
        CBUUID(string: "183B"): "Coordinated Set Identification Service",
        CBUUID(string: "183C"): "Device Time",
        CBUUID(string: "183E"): "Media Control Service",
        CBUUID(string: "183F"): "Generic Media Control Service",
        CBUUID(string: "1840"): "Constant Tone Extension",
        CBUUID(string: "1841"): "Telephone Bearer Service",
        CBUUID(string: "1842"): "Generic Telephone Bearer Service",
        CBUUID(string: "1843"): "Microphone Control",
        CBUUID(string: "1844"): "Audio Stream Control Service",
        CBUUID(string: "1845"): "Broadcast Audio Scan Service",
        CBUUID(string: "1846"): "Published Audio Capabilities Service",
        CBUUID(string: "1847"): "Basic Audio Announcement Service",
        CBUUID(string: "1848"): "Broadcast Audio Announcement Service",
        CBUUID(string: "1849"): "Common Audio Service",
        CBUUID(string: "184A"): "Hearing Access Service",
        CBUUID(string: "184B"): "Tamper Alert",
        CBUUID(string: "184C"): "Key-based Access Control",
        CBUUID(string: "184D"): "Sub-GHz",
        CBUUID(string: "184E"): "DMM",
        CBUUID(string: "184F"): "Universal Control",
        CBUUID(string: "1850"): "Electric Vehicle Charging",
        CBUUID(string: "1851"): "Lighting",
        CBUUID(string: "1852"): "Time Sync",
        CBUUID(string: "2A29"): "Factory",
        CBUUID(string: "2A24"): "Model",
        CBUUID(string: "fb1e4001-54ae-4a28-9f74-dfccb248601d"): "OTA FIRMWARE SERVICE",
        CBUUID(string: "fb1e4002-54ae-4a28-9f74-dfccb248601d"): "RX CHARACTERISTIC",
        CBUUID(string: "fb1e4003-54ae-4a28-9f74-dfccb248601d"): "TX CHARACTERISTIC",
    ]
    
    func name(for uuid: CBUUID) -> String {
        mapping[uuid] ?? "Unknown Service"
    }
}
