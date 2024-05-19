//
//  NavigationItem.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 29/3/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

enum NavigationItem: Hashable {
    case settings
    case peripheral(id: String)
    case service(String)
    case characteristic(String)
    case none
}

